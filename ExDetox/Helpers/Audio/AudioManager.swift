//
//  AudioManager.swift
//  ExDetox
//
//  Created by Ayxan Səfərli on 04.12.25.
//

import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var currentSound: String?
    
    private var player: AVAudioPlayer?
    
    private init() {
        // Configure audio session to play even if switch is on silent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    func playSound(named soundName: String) {
        // If tapping the same sound that is playing, toggle it
        if currentSound == soundName {
            togglePlayPause()
            return
        }
        
        // Stop current if any
        stop()
        
        // In a real app, this would load the file.
        // For this demo, we'll simulate playing by just setting state.
        // If we had files:
        /*
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.play()
            isPlaying = true
            currentSound = soundName
        } catch {
            print("Error loading sound: \(error)")
        }
        */
        
        // Simulation for demo
        print("Playing sound: \(soundName)")
        isPlaying = true
        currentSound = soundName
        
        // Verify audio session is active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        print("Paused sound: \(currentSound ?? "none")")
    }
    
    func resume() {
        if let currentSound = currentSound {
            player?.play()
            isPlaying = true
            print("Resumed sound: \(currentSound)")
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentSound = nil
        print("Stopped playback")
    }
}


