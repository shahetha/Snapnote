import AVFoundation
import Foundation
import Speech
import UIKit

class SpeechRecognizer {
    private class SpeechAssist {
        var audioEngine: AVAudioEngine?
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        var onTranscription: ((String) -> Void)?

        deinit {
            reset()
        }

        func reset() {
            recognitionTask?.cancel()
            audioEngine?.stop()
            audioEngine = nil
            recognitionRequest = nil
            recognitionTask = nil
            onTranscription = nil
        }
    }

    private let assistant = SpeechAssist()

    func record(callback: @escaping (String) -> Void) {
        assistant.onTranscription = callback
        relay("Requesting access", to: callback)

        canAccess { authorized in
            guard authorized else {
                self.relay("Access denied", to: callback)
                return
            }

            self.relay("Access granted", to: callback)

            self.assistant.audioEngine = AVAudioEngine()
            guard let audioEngine = self.assistant.audioEngine else {
                self.relay("Failed to create audio engine", to: callback)
                return
            }

            self.assistant.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self.assistant.recognitionRequest else {
                self.relay("Failed to create recognition request", to: callback)
                return
            }

            recognitionRequest.shouldReportPartialResults = true

            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = audioEngine.inputNode

                let recordingFormat = inputNode.outputFormat(forBus: 0)
                if recordingFormat.sampleRate > 0 {
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                        recognitionRequest.append(buffer)
                    }

                    self.relay("Ready to record", to: callback)
                    audioEngine.prepare()
                    try audioEngine.start()

                    self.assistant.recognitionTask = self.assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                        if let result = result {
                            let transcription = result.bestTranscription.formattedString
                            self.assistant.onTranscription?(transcription)
                        }

                        if error != nil || result?.isFinal == true {
                            audioEngine.stop()
                            inputNode.removeTap(onBus: 0)
                        }
                    }
                } else {
                    #if targetEnvironment(simulator)
                    self.mockTranscription(callback: callback)
                    #else
                    self.relay("Invalid audio format", to: callback)
                    #endif
                }
            } catch {
                self.relay("Error setting up audio: \(error.localizedDescription)", to: callback)
                self.assistant.reset()
            }
        }
    }

    func stopRecording() {
        assistant.audioEngine?.stop()
        assistant.recognitionRequest?.endAudio()
        assistant.recognitionTask?.finish()
    }

    private func mockTranscription(callback: @escaping (String) -> Void) {
        relay("Using simulated speech (simulator mode)", to: callback)
        var counter = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            counter += 1
            let messages = [
                "Hello",
                "Hello there",
                "Hello there, this is",
                "Hello there, this is a test",
                "Hello there, this is a test note",
                "Hello there, this is a test note for the simulator"
            ]
            if counter < messages.count {
                self.relay(messages[counter], to: callback)
            } else {
                timer.invalidate()
            }
        }
    }

    private func canAccess(withHandler handler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                AVAudioSession.sharedInstance().requestRecordPermission { authorized in
                    handler(authorized)
                }
            } else {
                handler(false)
            }
        }
    }

    private func relay(_ message: String, to callback: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            callback(message)
        }
    }
}
