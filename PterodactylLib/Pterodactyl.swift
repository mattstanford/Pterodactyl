//
//  Pterodactyl.swift
//  PterodactylLib
//
//  Created by Matt Stanford on 2/29/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import Foundation
import XCTest

public class Pterodactyl {
    
    let targetAppBundleId: String
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 8081
    
    let pushEndpoint = "simulatorPush"
    
    public init(targetAppBundleId: String) {
        self.targetAppBundleId = targetAppBundleId
    }
    
    public init(targetApp: XCUIApplication) {
        let bundleId = targetApp.value(forKey: "bundleID") as! String
        self.targetAppBundleId = bundleId
    }
    
    public func triggerSimulatorNotification(withPayload payload: [String: Any]) {
        let endpoint = "http://localhost:8081/simulatorPush"
        
        guard let endpointUrl = URL(string: endpoint) else {
            return
        }
        
        //Make JSON to send to send to server
        var json = [String:Any]()
        json["simulatorId"] = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
        json["appBundleId"] = targetAppBundleId
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
