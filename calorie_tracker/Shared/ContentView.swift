//
//  ContentView.swift
//  Shared
//
//  Created by Jake Landers on 2/5/22.
//

import SwiftUI

/*
 Host of app, initialized the data layer,
 checks if app was in background,
 and shows a sheet when requested
 */
struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var dmodel = DataModel()
    
    @State var date = Date()
    
    @State private var wasInBackground = false
    
    init() {
        // change the font for large nav titles
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.systemFont(ofSize: 40, weight: .ultraLight)]
    }
    
    var body: some View {
        Group {
            SelectDate()
        }
        .sheet(isPresented: $dmodel.showSheet) {
            dmodel.sheetView()
        }
        .environmentObject(dmodel)
        .onChange(of: scenePhase) { newPhase in
            // check for changes in app state
            if newPhase == .active {
                print("Active")
                if (wasInBackground) {
                    wasInBackground = false
                    dmodel.reload()
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
                wasInBackground = true
            }
        }
    }
}
