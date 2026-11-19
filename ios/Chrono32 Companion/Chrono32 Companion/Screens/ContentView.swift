//
//  ContentView.swift
//  Chrono32 Companion
//
//  Created by Phil Murphy on 11/7/26.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {

    @StateObject private var bluetooth = BluetoothManager()

    var body: some View {
        NavigationStack {
            VStack {
                Image(.watchFace)

                RetroButton(
                    buttonText: bluetooth.isConnected
                        ? "Sync Time"
                        : "Connect Watch",
                    buttonTapped: bleSync
                )
                .padding()

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Chrono32 Companion")
                        .font(.retroMono(size: 16))
                }
            }
        }
        .padding()
    }

    private func bleSync() {
        if bluetooth.isConnected {
            syncTime()
        } else {
            bluetooth.connectOrAddAccessory()
        }
    }

    private func syncTime() {
            let time = Int(Date().timeIntervalSince1970)

            guard let dataToWrite = String(time).data(using: .utf8) else { return }
            
            bluetooth.write(dataToWrite, to: "573c8962-c776-4016-a280-8daea13a01a8")
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
