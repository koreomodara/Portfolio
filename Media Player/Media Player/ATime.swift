//
//  ATime.swift
//  MoviePlayer
//
//  Created by Loren Olson on 10/31/23.
//

import Foundation
import AVFoundation

// Codable wrapper for CMTime
struct ATime: Codable {
    var value: Int64
    var timescale: Int32
    
    var cmtime: CMTime {
        get {
            return CMTime(value: value, timescale: timescale)
        }
        set {
            value = newValue.value
            timescale = newValue.timescale
        }
    }
    

    static func fromCMTime(_ cmtime: CMTime) -> ATime {
        return ATime(value: cmtime.value, timescale: cmtime.timescale)
    }
    
    static var zero: ATime {
        return ATime.fromCMTime(CMTime.zero)
    }
}
