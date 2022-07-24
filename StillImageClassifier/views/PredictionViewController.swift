//
//  PredictionViewController.swift
//  StillImageClassifier
//
//  Created by Ege Hurturk on 21.07.2022.
//

import Foundation
import UIKit
import Vision

class PredictionViewController: UIViewController {
    
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var firstRun = true
    let predictionsToShow = 2
    
    var image: UIImage = UIImage()
    
    override func viewDidLoad() {
        print("view loaded from PredictionViewController")
        let swipeActionRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeActionRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeActionRecognizer)
        
        self.imageView.image = self.image
        self.predictionLabel.text = "Predictions will go here..."
        
        let mlmodel = createImageClassifier()
        
        analyzeImage(model: mlmodel)
        
    }
    
    @objc func swipeLeft(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
        case .up:
            performSegue(withIdentifier: "goLeft", sender: self)
        default:
            break
        }
    }
    
    
    func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        let imageClassifierWrapper = try? Resnet50(configuration: defaultConfig)
        
        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        
        let imageClassifierModel = imageClassifier.model

        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        return imageClassifierVisionModel
    }
    
    func updatePredictionLabel(_ message: String) {
        DispatchQueue.main.async {
            self.predictionLabel.text = message
        }

        if self.firstRun {
            DispatchQueue.main.async {
                self.firstRun = false
                self.predictionLabel.superview?.isHidden = false
            }
        }
    }
    
    private func formatPredictions(_ predictions: [Prediction]) -> [String] {
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }


    
}

extension PredictionViewController {
    
    struct Prediction {
        let classification: String

        let confidencePercentage: String
    }
    
    func analyzeImage(model: VNCoreMLModel) {
        let imageClassificationRequest = VNCoreMLRequest(model: model, completionHandler: visionRequestHandler)
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue) )

        guard let photoImage = image.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }
        
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation!)
        let requests: [VNRequest] = [imageClassificationRequest]
        try! handler.perform(requests)
    }
    
    func visionRequestHandler(_ request: VNRequest, error: Error?) {
        
        
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        if request.results == nil {
            print("Vision request had no results.")
            return
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }
        
        let predictions = observations.map { observation in
            Prediction(classification: observation.identifier,
                       confidencePercentage: getConfidencePercentageString(confidence: observation.confidence))
        }
        
        if predictions.isEmpty {
            updatePredictionLabel("No predictions")
            return
        }
        
        let formattedPredictions = formatPredictions(predictions)
        let predictionString = formattedPredictions.joined(separator: "\n")
        updatePredictionLabel(predictionString)
    
    }
    
    
    
    private func getConfidencePercentageString(confidence: VNConfidence) -> String {
            var confidencePercentageString: String {
                let percentage = confidence * 100

                switch percentage {
                    case 100.0...:
                        return "100%"
                    case 10.0..<100.0:
                        return String(format: "%2.1f", percentage)
                    case 1.0..<10.0:
                        return String(format: "%2.1f", percentage)
                    case ..<1.0:
                        return String(format: "%1.2f", percentage)
                    default:
                        return String(format: "%2.1f", percentage)
                }
            }
            return confidencePercentageString
        }
}
