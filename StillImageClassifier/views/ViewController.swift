//
//  ViewController.swift
//  StillImageClassifier
//
//  Created by Ege Hurturk on 20.07.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    
    @IBAction func didTapAnalyzeButton() {
        print("Heyyoooo")
        performSegue(withIdentifier: "goRight", sender: self)
    }
    
    @IBAction func didTapResetButton() {
        button.isHidden = false
        nextPageButton.isHidden = true
        imageView.image = nil
        resetButton.isHidden = true
    }
    
    @IBAction func didTapButton() {
        
        let alert = UIAlertController(title: "Pick image from", message: "Select where to choose an image from:", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.showAlert(title: "Error", message: "Camera is not available in this device")
                return
            }
            self.selectImageFrom(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.selectImageFrom(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goRight" {
            guard let vc = segue.destination as? PredictionViewController else { return }
            vc.image = self.imageView.image!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resetButton.isHidden = true
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.red, for: .normal)
        nextPageButton.isHidden = true
        button.setTitle("Pick image to analyze", for: .normal)
        imageView.backgroundColor = .secondarySystemBackground

    }
    
    func selectImageFrom(_ source: ImageSource) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        switch source {
            case .camera:
                picker.sourceType = .camera
            case .photoLibrary:
                picker.sourceType = .photoLibrary
        
        }
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            showAlert(title: "Error", message: "Cannot open image")
            return
        }
        
        imageView.image = image
        button.isHidden = true
        nextPageButton.isHidden = false
        resetButton.isHidden = false
    }
    
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}



