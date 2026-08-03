import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

    private let microphone = CoreAudioRecorder()

    override func applicationDidFinishLaunching(_ notification: Notification) {

        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
            super.applicationDidFinishLaunching(notification)
            return
        }

        let channel = FlutterMethodChannel(
            name: "sona.microphone",
            binaryMessenger: controller.engine.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in

            switch call.method {

            case "startMicrophone":

                self?.microphone.start { level in
                    channel.invokeMethod("noiseLevel", arguments: level)
                }

                result(nil)

            case "stopMicrophone":

                self?.microphone.stop()

                result(nil)

            default:

                result(FlutterMethodNotImplemented)
            }
        }

        super.applicationDidFinishLaunching(notification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}