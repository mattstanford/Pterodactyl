//
//  ServerManager.swift
//  PterodactylServer
//
//  Created by Matt Stanford on 3/14/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import Foundation
import Swifter

typealias JSON = [String: Any]

class ServerManager {
    
    private let server = HttpServer()
    let pushEndpoint = "/simulatorPush"
    let defaultPort: in_port_t = 8081
    
    func startServer(options: [StartupOption: String]) {
        do {
            let port: in_port_t
            if let portString = options[.port],
               let passedInPort = in_port_t(portString) {
                port = passedInPort
            } else {
                port = defaultPort
            }
        
            print("Starting server on port: " + port.description)
            try server.start(port)
            setupPushEndpoint()
        } catch {
            print("Error starting mock server" + error.localizedDescription)
        }
    }
    
    func stopServer() {
        server.stop()
    }
    
    private func setupPushEndpoint() {
        
        let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
            
            guard let serializedObject = try? JSONSerialization.jsonObject(with: Data(request.body), options: []),
                let json = serializedObject as? JSON,
                let simId = json["simulatorId"] as? String,
                let appBundleId = json["appBundleId"] as? String,
                let payload = json["pushPayload"] as? JSON else {
                    return HttpResponse.badRequest(nil)
            }
            
            if let pushFileUrl = self?.createTemporaryPushFile(payload: payload) {
                let command = "xcrun simctl push \(simId) \(appBundleId) \(pushFileUrl.path)"
                self?.run(command: command)
                
                do {
                    try FileManager.default.removeItem(at: pushFileUrl)
                } catch {
                    print("Error removing file!")
                }
                
                return .ok(.text("Ran command: \(command)"))
            } else {
                return .internalServerError
            }
        }
        
        server.POST[pushEndpoint] = response
    }
    
    private func createTemporaryPushFile(payload: JSON) -> URL? {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString + ".apns"
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            try jsonData.write(to: temporaryFileURL, options: .atomic)
        } catch {
            print("Error writing temporary file!")
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
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            print(result as String)
        }
        else {
            print("--- Error running command - Unable to initialize string from file data ---")
        }
    }
}
