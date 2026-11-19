//
//  FontExtension.swift
//  Chrono32 Companion
//
//  Created by Phil Murphy on 11/7/26.
//

import SwiftUI

extension Font {
    static func retroMono(size: CGFloat) -> Font {
        return .custom("PressStart2P-Regular", size: size, relativeTo: .body)
    }
}
