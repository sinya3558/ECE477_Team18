//
//  InstructionsView.swift
//  Bluetooth Connection
//
//  Created by Harim Choe on 2/7/24.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("1. Please click the song that you want to play!")
                Text("2. Read out the lyrics and get the best score you can.")
                Text("3. Get the score and share it to your friends.")
            }
            .padding()
            .navigationBarTitle("Instructions", displayMode: .inline)
        }
    }
}
