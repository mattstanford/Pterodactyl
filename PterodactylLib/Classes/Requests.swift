//
//  Requests.swift
//  PterodactylLib & PterodactylServer
//
//  Copyright © 2024 Matt Stanford. All rights reserved.
//

import Foundation

struct PushRequest: Codable {
    let simulatorId: String
    let appBundleId: String
    let pushPayload: JSONObject
}
