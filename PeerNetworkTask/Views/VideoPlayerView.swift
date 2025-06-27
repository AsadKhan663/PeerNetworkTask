//
//  VideoPlayerView.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/26/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    let videoURL: String
    @Binding var isPlaying: Bool
    @Binding var showRetryButton: Bool
    @Binding var isShortVersion: Bool
    @Binding var showPlayPauseIcon: Bool
    
    // This ensures the view recreates when isShortVersion changes
    private var versionID: Bool { isShortVersion }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        guard let url = URL(string: videoURL) else {
            showRetryButton = true
            return containerView
        }
        
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = containerView.bounds
        containerView.layer.addSublayer(playerLayer)
        
        // Add tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        containerView.addGestureRecognizer(tapRecognizer)
        
        // Only create seekbar components if not in short version
        if !isShortVersion {
            setupSeekBar(in: containerView, coordinator: context.coordinator, player: player)
        }
        
        // Set up coordinator with player references
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        // Add observers
        player.addObserver(context.coordinator, forKeyPath: "status", options: .new, context: nil)
        player.addObserver(context.coordinator, forKeyPath: "rate", options: .new, context: nil)
        
        // Start playing if needed
        if isPlaying {
            player.play()
        }
        
        return containerView
    }
    
    private func setupSeekBar(in containerView: UIView, coordinator: Coordinator, player: AVPlayer) {
        // Create seekbar container
        let seekbarContainer = UIView()
        seekbarContainer.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        seekbarContainer.layer.cornerRadius = 12
        seekbarContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seekbarContainer)
        coordinator.seekbarContainer = seekbarContainer
        
        // Create seekbar
        let seekbar = UISlider()
        seekbar.translatesAutoresizingMaskIntoConstraints = false
        seekbar.minimumValue = 0
        seekbar.maximumValue = 1
        seekbar.value = 0
        seekbar.minimumTrackTintColor = .white
        seekbar.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        seekbar.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        seekbarContainer.addSubview(seekbar)
        coordinator.seekbar = seekbar
        
        // Time labels
        let currentTimeLabel = UILabel()
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        currentTimeLabel.textColor = .white
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        seekbarContainer.addSubview(currentTimeLabel)
        coordinator.currentTimeLabel = currentTimeLabel
        
        let durationLabel = UILabel()
        durationLabel.text = "00:00"
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        seekbarContainer.addSubview(durationLabel)
        coordinator.durationLabel = durationLabel
        
        // Constraints
        NSLayoutConstraint.activate([
            seekbarContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            seekbarContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            seekbarContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60),
            seekbarContainer.heightAnchor.constraint(equalToConstant: 40),
            
            seekbar.leadingAnchor.constraint(equalTo: seekbarContainer.leadingAnchor, constant: 8),
            seekbar.trailingAnchor.constraint(equalTo: seekbarContainer.trailingAnchor, constant: -8),
            seekbar.centerYAnchor.constraint(equalTo: seekbarContainer.centerYAnchor),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: seekbarContainer.leadingAnchor, constant: 16),
            currentTimeLabel.bottomAnchor.constraint(equalTo: seekbarContainer.topAnchor, constant: -2),
            
            durationLabel.trailingAnchor.constraint(equalTo: seekbarContainer.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: seekbarContainer.topAnchor, constant: -2)
        ])
        
        // Add time observer for seekbar updates
        coordinator.timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { time in
            coordinator.updateTimeDisplay(time: time)
        }
        
        // Add seekbar actions
        seekbar.addTarget(coordinator, action: #selector(Coordinator.seekbarValueChanged(_:)), for: .valueChanged)
        seekbar.addTarget(coordinator, action: #selector(Coordinator.seekbarTouchDown(_:)), for: .touchDown)
        seekbar.addTarget(coordinator, action: #selector(Coordinator.seekbarTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let player = context.coordinator.player,
              let playerLayer = context.coordinator.playerLayer else { return }
        
        // Update player layer frame
        playerLayer.frame = uiView.bounds
        
        // Update play/pause state
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
        
        // No need to handle seekbar changes here - the view will be recreated
        // when isShortVersion changes due to the versionID property
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.cleanup()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: VideoPlayerView
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        
        // Seekbar components
        var seekbarContainer: UIView?
        var seekbar: UISlider?
        var currentTimeLabel: UILabel?
        var durationLabel: UILabel?
        var timeObserver: Any?
        var isSeeking = false
        
        init(parent: VideoPlayerView) {
            self.parent = parent
        }
        
        func cleanup() {
            player?.removeObserver(self, forKeyPath: "status")
            player?.removeObserver(self, forKeyPath: "rate")
            cleanupSeekbar()
            player?.pause()
            player = nil
        }
        
        func cleanupSeekbar() {
            if let timeObserver = timeObserver {
                player?.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            seekbarContainer?.removeFromSuperview()
            seekbarContainer = nil
            seekbar = nil
            currentTimeLabel = nil
            durationLabel = nil
        }
        
        @objc func handleTap() {
            parent.isPlaying.toggle()
            parent.showPlayPauseIcon = true
        }
        
        func updateTimeDisplay(time: CMTime) {
            guard let player = player, !isSeeking else { return }
            
            let currentTime = player.currentTime().seconds
            let duration = player.currentItem?.duration.seconds ?? 0
            
            if duration.isFinite && duration > 0 {
                let progress = Float(currentTime / duration)
                seekbar?.value = progress
                
                currentTimeLabel?.text = formatTime(currentTime)
                durationLabel?.text = formatTime(duration)
            }
        }
        
        func formatTime(_ seconds: Double) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: seconds) ?? "00:00"
        }
        
        @objc func seekbarValueChanged(_ sender: UISlider) {
            guard let player = player else { return }
            let duration = player.currentItem?.duration.seconds ?? 0
            let newTime = Double(sender.value) * duration
            player.seek(to: CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            
            currentTimeLabel?.text = formatTime(newTime)
        }
        
        @objc func seekbarTouchDown(_ sender: UISlider) {
            isSeeking = true
            parent.isPlaying = false
            player?.pause()
        }
        
        @objc func seekbarTouchUp(_ sender: UISlider) {
            isSeeking = false
            parent.isPlaying = true
            player?.play()
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status", let player = player {
                if player.status == .failed {
                    DispatchQueue.main.async {
                        self.parent.showRetryButton = true
                    }
                }
            }
            
            if keyPath == "rate", let rate = change?[.newKey] as? Float {
                DispatchQueue.main.async {
                    if !self.isSeeking {
                        self.parent.isPlaying = rate != 0
                    }
                }
            }
        }
    }
}
