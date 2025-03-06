import Flutter
import UIKit
import SwiftyTesseract

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    initializeTessData()

    if call.method == "extractText" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String,
              let language = args["language"] as? String,
              let image = UIImage(contentsOfFile: imagePath) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments passed", details: nil))
            return
        }

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            result(FlutterError(code: "DIRECTORY_ERROR", message: "Could not access documents directory.", details: nil))
            return
        }

        let tessDataPath = documentsURL.path

        // Safely unwrap Bundle
        guard let bundle = Bundle(path: tessDataPath) else {
            result(FlutterError(code: "BUNDLE_ERROR", message: "Could not initialize Tesseract bundle with provided path.", details: nil))
            return
        }

        let swiftyTesseract = SwiftyTesseract(language: .custom(language), bundle: bundle)

        swiftyTesseract.performOCR(on: UIImage(contentsOfFile: imagePath)!) { recognizedString in
            guard let extractText = recognizedString else {
                result(FlutterError(code: "OCR_FAILED", message: "OCR failed", details: nil))
                return
            }
            result(extractText)
        }
    }
}

  func initializeTessData() {
    let fileManager = FileManager.default

    // Source: tessdata in app bundle
    guard let sourceURL = Bundle.main.resourceURL?.appendingPathComponent("tessdata") else {
        print("Error: Could not find tessdata in bundle.")
        return
    }

    // Destination: Documents/tessdata
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Error: Could not access documents directory.")
        return
    }
    let destURL = documentsURL.appendingPathComponent("tessdata")

    do {
        // Remove existing tessdata directory if it exists
        if fileManager.fileExists(atPath: destURL.path) {
            try fileManager.removeItem(at: destURL)
        }

        // Copy tessdata from bundle to documents directory
        try fileManager.copyItem(at: sourceURL, to: destURL)
        print("✅ tessdata copied successfully to \(destURL.path).")
    } catch {
        print("❌ Failed to copy tessdata: \(error)")
    }
}

}
