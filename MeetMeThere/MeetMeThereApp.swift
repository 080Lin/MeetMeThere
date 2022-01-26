//
//  MeetMeThereApp.swift
//  MeetMeThere
//
//  Created by Максим Нуждин on 23.01.2022.
//

import SwiftUI

@main
struct MeetMeThereApp: App {
    @StateObject var prospects = Prospects()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(prospects)
        }
    }
}
