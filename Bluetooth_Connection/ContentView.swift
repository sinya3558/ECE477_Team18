//
//  ContentView.swift
//  Bluetooth Connection
//
//  Created by Harim Choe on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()

    // Array of image names
    let images = ["Image1", "Image2", "Image3", "Image4", "IMG_0252"]
    
    // State variable to hold the current background image name
    @State private var currentBackgroundImage = "Image1"
    
    // State variable to manage the timer
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Rotating background image
                Image(currentBackgroundImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Check Bluetooth status
                    if bluetoothManager.isBluetoothEnabled {
                        if bluetoothManager.isConnected {
                            // Buttons for songs with Bluetooth functionality
                            Button("Song 1") {
                                bluetoothManager.writeToPeripheral("Command for Song 1")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)

                            Button("Song 2") {
                                bluetoothManager.writeToPeripheral("Command for Song 2")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        } else {
                            Text("Scanning for HM-19...")
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Bluetooth is not enabled. Please enable Bluetooth in Settings.")
                            .foregroundColor(.white)
                    }

                    // Navigation links
                    NavigationLink(destination: SongsListView(bluetoothManager: bluetoothManager)) {
                        Text("Songs")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: InstructionsView()) {
                        Text("Instructions")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle("Karaoke Machine", displayMode: .large)
            .onAppear {
                startBackgroundRotation()
            }
            .onDisappear {
                // Invalidate the timer when the view disappears
                timer?.invalidate()
            }
        }
    }
    
    func startBackgroundRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            // Change the background image randomly every minute
            currentBackgroundImage = images.randomElement() ?? images.first!
        }
    }
}

#Preview {
    ContentView()
}
