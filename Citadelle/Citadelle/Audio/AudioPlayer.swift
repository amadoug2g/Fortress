//
//  AudioPlayer.swift
//  Citadelle
//

import AVFoundation
import Foundation
import Observation

/// Streams recitations, one at a time. If a recording can't be loaded it
/// falls back to the next one (the dua's own, then the whole situation's).
@Observable
final class AudioPlayer {
    private(set) var playingID: Int?
    private(set) var isLoading = false
    private(set) var failedID: Int?

    private var player: AVPlayer?
    private var candidates: [URL] = []
    private var statusObservation: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?

    func toggle(id: Int, urls: [URL]) {
        if playingID == id {
            stop()
        } else {
            play(id: id, urls: urls)
        }
    }

    func play(id: Int, urls: [URL]) {
        stop()
        guard !urls.isEmpty else {
            failedID = id
            return
        }
        // Plays even when the ring/silent switch is on silent.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
        playingID = id
        failedID = nil
        candidates = urls
        playNextCandidate()
    }

    func stop() {
        player?.pause()
        player = nil
        statusObservation = nil
        removeEndObserver()
        playingID = nil
        isLoading = false
    }

    private func playNextCandidate() {
        guard let id = playingID else { return }
        guard !candidates.isEmpty else {
            stop()
            failedID = id
            return
        }
        let item = AVPlayerItem(url: candidates.removeFirst())
        isLoading = true
        statusObservation = item.observe(\.status) { [weak self] item, _ in
            let status = item.status
            Task { @MainActor in self?.handle(status) }
        }
        removeEndObserver()
        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification, object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.stop() }
        }
        let player = AVPlayer(playerItem: item)
        self.player = player
        player.play()
    }

    private func handle(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
        case .failed:
            playNextCandidate()
        default:
            break
        }
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
    }
}
