import Foundation
import AVFoundation

class CoreAudioRecorder {

    private let engine = AVAudioEngine()
    private var started = false

    func start(callback: @escaping (Double) -> Void) {

        if started {
            return
        }

        started = true

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { [weak self] buffer, _ in

            guard let self = self else {
                return
            }

            let level = self.getLevel(buffer)

            DispatchQueue.main.async {
                callback(level)
            }
        }

        do {
            try engine.start()
            print("CORE AUDIO STARTED")

        } catch {
            print("CoreAudio Error: \(error)")
            started = false
        }
    }


    func stop() {

        guard started else {
            return
        }

        started = false

        engine.inputNode.removeTap(onBus: 0)
        engine.stop()

        print("CORE AUDIO STOPPED")
    }


    private func getLevel(_ buffer: AVAudioPCMBuffer) -> Double {

        guard let data = buffer.floatChannelData else {
            return -60
        }

        let samples = data[0]
        let frameCount = Int(buffer.frameLength)

        guard frameCount > 0 else {
            return -60
        }

        var sum: Float = 0

        for i in 0..<frameCount {

            let sample = samples[i]

            sum += sample * sample
        }

        let rms = sqrt(sum / Float(frameCount))


        if rms <= 0 {
            return -60
        }


        let db = Double(20 * log10(rms))

        return max(db, -60)
    }
}