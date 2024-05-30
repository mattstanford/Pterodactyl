//
//  JSONCodingKeys.swift
//  PterodactylLib & PterodactylServer
//
//  Copyright © 2024 Matt Stanford. All rights reserved.
//

import Foundation

struct JSONCodingKeys: CodingKey {

    let stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }

}
