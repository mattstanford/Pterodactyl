//
//  StartupOption.swift
//  PterodactylServer
//
//  Created by Matt Stanford on 10/27/21.
//  Copyright © 2021 Matt Stanford. All rights reserved.
//

import Foundation

enum StartupOption: String {
    case port = "port"
}

extension StartupOption {
    static func getDictionary(from arguments: [String]) -> [StartupOption: String] {
        var argDict: [StartupOption: String] = [:]
        for (idx, arg) in arguments.enumerated() {
            if arg.starts(with: "-") {
                let argNoHyphen = String(arg.dropFirst())
                if let option = StartupOption(rawValue: argNoHyphen),
                   idx < arguments.count - 1 {
                    let nextVal = arguments[idx + 1]
                    argDict[option] = nextVal
                }
            }
        }
        return argDict
    }
}
