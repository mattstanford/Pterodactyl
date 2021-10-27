//
//  AppDelegate.swift
//  PterodactylServer
//
//  Created by Matt Stanford on 3/14/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let serverManager = ServerManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let options = StartupOption.getDictionary(from: CommandLine.arguments)
        serverManager.startServer(options: options)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        serverManager.stopServer()
    }
}

