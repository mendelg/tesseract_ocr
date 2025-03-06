import Flutter
import UIKit
import SwiftyTesseract
import Combine

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    private var cancellables = Set<AnyCancellable>()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        initializeTessData()

        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String,
              let language = args["language"] as? String,
              let image = UIImage(contentsOfFile: imagePath) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments passed", details: nil))
            return
        }

        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            result(FlutterError(code: "DIRECTORY_ERROR", message: "Documents directory inaccessible.", details: nil))
            return
        }

        let tessDataPath = documentsURL.appendingPathComponent("tessdata").path
        guard let swiftyTesseract = SwiftyTesseract(language: .custom(args["language"] as? String ?? "eng"), bundle: Bundle(path: documentsURL.path)) else {
            result(FlutterError(code: "INIT_ERROR", message: "Failed to initialize SwiftyTesseract", details: nil))
            return
        }

        if call.method == "extractText" {
            swiftyTesseract.performOCR(on: UIImage(contentsOfFile: imagePath)!) { recognizedString in
                guard let extractText = recognizedString else {
                    result(FlutterError(code: "OCR_FAILED", message: "OCR failed", details: nil))
                    return
                }
                result(extractText)
            }
        } else if call.method == "extractHocr" {
            swiftyTesseract.performOCRPublisher(on: UIImage(contentsOfFile: imagePath)!, format: .hOCR)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        result(FlutterError(code: "OCR_FAILED", message: "OCR failed: \(error.localizedDescription)", details: nil))
                    }
                }, receiveValue: { hocrString in
                    result(hocrString)
                })
                .store(in: &cancellables)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func initializeTessData() {
        let fileManager = FileManager.default
        guard let sourceURL = Bundle.main.resourceURL?.appendingPathComponent("tessdata"),
              let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error accessing tessdata or documents directory.")
            return
        }
        let destURL = documentsURL.appendingPathComponent("tessdata")

        do {
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destURL)
            print("✅ tessdata copied successfully to \(destURL.path).")
        } catch {
            print("❌ Failed to copy tessdata: \(error)")
        }
    }
}
