//
//  ServerManager.swift
//  PterodactylServer
//
//  Created by Matt Stanford on 3/14/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import Foundation
import Swifter
import OSLog

class ServerManager {
    
    private let server = HttpServer()
    let defaultPort: in_port_t = 8081

    let logger = Logger(subsystem: "com.mattstanford.pterodactyl", category: "server")

    let pushEndpoint = "/simulatorPush"

    func startServer(options: [StartupOption: String]) {
        do {
            let port: in_port_t
            if let portString = options[.port],
               let passedInPort = in_port_t(portString) {
                port = passedInPort
            } else {
                port = defaultPort
            }
        
            logger.info("Starting server on port \(port.description, privacy: .public)")
            try server.start(port)
            setupPushEndpoint()
        } catch {
            logger.error("Error starting mock server \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func stopServer() {
        server.stop()
    }

    private func setupPushEndpoint() {
        
        let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
            let jsonDecoder = JSONDecoder()

            guard let pushRequest = try? jsonDecoder.decode(PushRequest.self, from: Data(request.body)) else {
                return HttpResponse.badRequest(nil)
            }

            let simId = pushRequest.simulatorId
            let appBundleId = pushRequest.appBundleId
            let payload = pushRequest.pushPayload

            if let pushFileUrl = self?.createTemporaryPushFile(payload: payload) {
                let command = "xcrun simctl push \(simId) \(appBundleId) \(pushFileUrl.path)"
                self?.run(command: command)
                
                do {
                    try FileManager.default.removeItem(at: pushFileUrl)
                } catch {
                    self?.logger.error("Error removing file!")
                }
                
                return .ok(.text("Ran command: \(command)"))
            } else {
                return .internalServerError
            }
        }
        
        logger.info("Setup \(self.pushEndpoint, privacy: .public)")
        server.POST[pushEndpoint] = response
    }
    
    private func createTemporaryPushFile(payload: JSONObject) -> URL? {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString + ".apns"
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload.value, options: .prettyPrinted)
            try jsonData.write(to: temporaryFileURL, options: .atomic)
        } catch {
            logger.error("Error writing temporary file!")
            return nil
        }
        return temporaryFileURL
    }
    
    private func run(command: String) {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", command)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading

        logger.debug("Running command: \(command, privacy: .public)")

        task.launch()
        task.waitUntilExit()

        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            logger.debug("command result: \(result, privacy: .public)")
        }
        else {
            logger.error("Error running command: \(command, privacy: .public)")
        }
    }
}
