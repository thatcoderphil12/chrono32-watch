//
//  Button.swift
//  Chrono32 Companion
//
//  Created by Phil Murphy on 11/8/26.
//

import SwiftUI

struct RetroButton: View {
    let buttonText: String
    let buttonTapped: () -> Void
    var body: some View {
        Button(buttonText){
            buttonTapped()
        }
        .buttonStyle(.plain)
        .font(.retroMono(size: 12))
        .padding(12.5)
        .background(
            RoundedRectangle(cornerRadius: 12.5, style: .circular)
                .fill(Color.button)
        )
    }
}

