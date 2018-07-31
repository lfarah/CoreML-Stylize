//
//  ArtifyViewController.swift
//  Toni
//
//  Created by terced-lucasp on 17/07/18.
//  Copyright © 2018 FTD Educação. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import Vision
import VideoToolbox

class ArtifyViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imgvUser: UIImageView!
    @IBOutlet weak var butStyle: UIButton!
    
    // MARK: - Variables
    let model = stylize()
    
    var userImage: UIImage? {
        didSet {
            if let image = userImage {
                imgvUser.image = image
            }
        }
    }

    // MARK: - VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage = #imageLiteral(resourceName: "Dias")
    }
    
    @IBAction func butStyleTapped(_ sender: Any) {
        
        if let image = self.userImage {
            self.userImage = nil
            predict(image: image)
        } else {
            presentCamera()
        }
    }
    
    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func predict(image: UIImage) {
        
        let numStyles  = 26
        let styleIndex = 15
        
        let styleArray = try? MLMultiArray(shape: [numStyles,1,1,1,1] as [NSNumber], dataType: MLMultiArrayDataType.double)
        
        for i in 0...(numStyles - 1) {
            styleArray?[i] = 0.0
        }
        styleArray?[styleIndex] = 1.0
        
        do {
            if let pixelBuffer = image.pixelBuffer(width: 256, height: 256) {
                let prediction = try model.prediction(style_num__0: styleArray!, input__0: pixelBuffer)
                if let image = UIImage(pixelBuffer: prediction.Squeeze__0) {
                    self.userImage = image
                }
            }
        } catch let error {
            print(error)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ArtifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.butStyle.setTitle("Artify", for: .normal)
            self.userImage = image
        } else {
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
