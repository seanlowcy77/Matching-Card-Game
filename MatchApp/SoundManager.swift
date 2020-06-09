//
//  SoundManager.swift
//  MatchApp
//
//  Created by Sean Low
//  From: https://www.youtube.com/user/CodeWithChris
//

import Foundation
import AVFoundation

class SoundManager {
    
    var audioPlayer: AVAudioPlayer?
    
    enum SoundEffect {
        case flip
        case match
        case nomatch
        case shuffle
    }
    
    func playSound(effect: SoundEffect) {
        
        var soundFilename = ""
        
        switch effect {
            case .flip:
                soundFilename = "cardflip"
            case .match:
                soundFilename = "dingcorrect"
            case .nomatch:
                soundFilename = "dingwrong"
            case .shuffle:
                soundFilename = "shuffle"
        }
        
        // Get the path to the resource
        // bundlePath is a string of the path to the resource
        let bundlePath = Bundle.main.path(forResource: soundFilename, ofType: ".wav")
        
        // Check that its not nil
        guard bundlePath != nil else {
            // Couldnt find the resource, exit
            return
        }
        
        // Need to create a URL object
        let url = URL(fileURLWithPath: bundlePath!)
        
        do {
            
            // Create the audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // Play the sound effect
            audioPlayer?.play()
        } catch {
            print("Couldnt create an audio player")
            return
        }
    }
}
