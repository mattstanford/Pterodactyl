//
//  Pterodactyl.swift
//  PterodactylLib
//
//  Created by Matt Stanford on 2/29/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import Foundation

public class Pterodactyl {
    
    let targetAppBundleId: String
    let host: String
    let port: in_port_t
    
    private let pushEndpoint = "simulatorPush"
    
    public init(targetAppBundleId: String, host: String = "localhost", port: in_port_t = 8081) {
        self.targetAppBundleId = targetAppBundleId
        self.host = host
        self.port = port
    }
    
    public func triggerSimulatorNotification(withMessage message: String, additionalKeys: [String: Any]? = nil) {
        var innerAlert: [String: Any] = ["alert": message]
        if let additionalKeys = additionalKeys {
            //Merge dictionaries, override duplicates with the ones supplied by "additionalKeys"
            innerAlert = innerAlert.merging(additionalKeys) { (_, new) in new }
        }
        let payload = ["aps": innerAlert]
        triggerSimulatorNotification(withFullPayload: payload)
    }
    
    public func triggerSimulatorNotification(withFullPayload payload: [String: Any]) {
        let endpoint = "http://\(host):\(port)/\(pushEndpoint)"

        guard let endpointUrl = URL(string: endpoint) else {
            return
        }

        //Make JSON to send to send to server
        let json = PushRequest(
            simulatorId: ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? "booted",
            appBundleId: targetAppBundleId,
            pushPayload: JSONObject(payload)
        )

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(json) else { return }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        execute(request: request)
    }

    private func execute(request: URLRequest) {
        let group = DispatchGroup()
        group.enter()
        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            // Just wait for the task to complete…
            group.leave()
        }

        task.resume()
        group.wait()
    }
    
}
