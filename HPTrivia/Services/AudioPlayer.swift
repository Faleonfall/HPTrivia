import AVFAudio

// Bundled mp3 names, so the string literals live in one place.
enum Sound {
    static let menuMusic = "magic-in-the-air"
    static let correct = "magic-wand"
    static let wrong = "negative-beeps"
    static let flip = "page-flip"
}

// Plays one audio track. A view holds a separate instance per role, so a sound
// effect never cuts off the menu music.
@MainActor
final class AudioPlayer {
    private var player: AVAudioPlayer?

    // One-shot effect. Replaces whatever this instance was playing.
    func play(_ resource: String) {
        player = Self.makePlayer(for: resource)
        player?.play()
    }

    // Endless background track. Repeat calls are ignored so returning to a
    // screen does not restart the music.
    func loop(_ resource: String, volume: Float) {
        guard player == nil, let track = Self.makePlayer(for: resource) else { return }
        track.volume = volume
        track.numberOfLoops = -1
        track.play()
        player = track
    }

    func fade(to volume: Float, over duration: TimeInterval) {
        player?.setVolume(volume, fadeDuration: duration)
    }

    private static func makePlayer(for resource: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}
