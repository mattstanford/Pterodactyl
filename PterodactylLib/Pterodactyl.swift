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
    var targetSimulatorId: String
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 8081
    
    let pushEndpoint = "simulatorPush"
    
    init(targetAppBundleId: String, targetSimulatorId: String) {
        self.targetAppBundleId = targetAppBundleId
        self.targetSimulatorId = targetSimulatorId
    }
    
    func triggerSimulatorNotification(withPayload payload: [String: Any]) {
        let endpoint = "http://\(serverHost):\(serverPort)/\(pushEndpoint)"
        
        guard let endpointUrl = URL(string: endpoint) else {
            return
        }
        
        //Make JSON to send to send to server
        var json = [String:Any]()
        json["simulatorId"] = targetSimulatorId
        json["appBundleId"] = targetSimulatorId
        json["pushPayload"] = payload
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return
        }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
}
