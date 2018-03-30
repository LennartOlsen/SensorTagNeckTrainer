//
//  MusicPlayer.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 23/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioResource : String {
    case intro = "assumeYourNeutralPosition"
    case adjustToNeutral = "adjustToYourNeckToANeutralPosition"
    case bendForward = "bendForward"
    case bendBackward =  "bendYourNeckBackward"
    case hunchForward = "hunchForward"
    case lookForward = "lookForward"
    case lookLeft = "lookLeft"
    case lookToTheLeft = "lookToTheLeft"
    case lookToTheRight = "lookToTheRight"
    case resumeNeutral = "resumeNeutral"
    case tiltLeft = "tiltLeft"
    case tiltRight = "tiltRight"
    case tiltYourHeadBack = "tiltYourHeadBack"
}
struct DataEntryAudioResourceMap {
    static let tiltLeft : [AudioResource] = [.tiltLeft]
    static let tiltRight : [AudioResource] = [.tiltRight]
    static let rotateLeft : [AudioResource] = [.lookToTheLeft, .lookLeft]
    static let rotateRight : [AudioResource] = [.lookToTheRight]
    static let bendForward : [AudioResource] = [.bendForward]
    static let bendBackward : [AudioResource] = [.bendBackward]
    static let hunchForward : [AudioResource] = [.hunchForward]
    
    static func get(dataEntryType : DataEntryTypes, doDefault : Bool = true) -> AudioResource {
        var idx = 0
        if(!doDefault) {
//TODO : implement doNotDefault
            idx = 0
        }
        switch dataEntryType {
        case .tiltLeft:
            return tiltLeft[idx]
        case .tiltRight:
            return tiltRight[idx]
        case .rotateLeft:
            return rotateLeft[idx]
        case .rotateRight:
            return rotateRight[idx]
        case .bendForward:
            return bendForward[idx]
        case .bendBackward:
            return bendBackward[idx]
        case .hunchForward:
            return hunchForward[idx]
        default:
            return tiltLeft[0]
        }
    }
}

class SoundPlayer {
    var player: AVAudioPlayer?
    
    func play(resource : AudioResource){
        playSound(resource: resource)
    }
    
    private func playSound(resource : AudioResource) {
        guard let url = Bundle.main.url(forResource: resource.rawValue, withExtension: "mp3") else { return }
        
        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
