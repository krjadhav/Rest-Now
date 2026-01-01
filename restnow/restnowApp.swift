//
//  restnowApp.swift
//  restnow
//
//  Created by Kausthub Jadhav on 01/01/26.
//

import SwiftUI

@main
struct restnowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
