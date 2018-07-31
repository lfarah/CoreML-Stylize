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
    let modelCandy = FNSCandy()
    let modelScream = FNSScream()
    let modelLaMyse = FNSLaMuse()
    
    var tileCount = 3
    
    var styledCandy: UIImage!
    var styledLaMuse: UIImage!
    var styledScream: UIImage!
    
    var userImage: UIImage? {
        didSet {
            if let image = userImage {
                imgvUser.image = image
                predict(image: image, type: .candy)
                predict(image: image, type: .laMuse)
                predict(image: image, type: .scream)
                
            }
        }
    }
    
    var gridImages: [UIImageView] = []
    
    enum ModelType {
        case candy
        case laMuse
        case scream
    }
    
    
    var currentStyle: ModelType = .candy
    
    // MARK: - VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userImage == nil {
            presentCamera()
        }
        let sideSize = (imgvUser.h / CGFloat(tileCount))
        gridImages.removeAll()
        
        for j in 0...(tileCount - 1) {
            for i in 0...(tileCount - 1) {
                let imgv = UIImageView(frame: CGRect(x: CGFloat(i) * sideSize, y: CGFloat(j) * sideSize, width: sideSize, height: sideSize))
                imgvUser.addSubview(imgv)
                imgv.alpha = 0
                imgv.addTapGesture { (_) in
                    imgv.alpha = imgv.alpha
                }
                gridImages.append(imgv)
            }
        }
        
        imgvUser.isUserInteractionEnabled = true
//        self.userImage = #imageLiteral(resourceName: "Dias")
    }
    
    @IBAction func butStyleLaMuseTapped(_ sender: Any) {
        currentStyle = .laMuse
    }
    
    @IBAction func butStyleCandyTapped(_ sender: Any) {
        currentStyle = .candy
    }
    @IBAction func butStyleTapped(_ sender: Any) {
        
        currentStyle = .scream
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        let location = touches.first?.location(in: imgvUser)
        //        print(location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: imgvUser)
            print(location)
            for (index,imgv) in gridImages.enumerated() {
                if imgv.frame.contains(location) {
                    style(at: index)
                }
            }
        }
    }
    
    func style(at styleIndex: Int) {
        var img = imgvUser.toImage()
        let scale = imgvUser.h/720
        let sideSize = (imgvUser.h / CGFloat(tileCount)) / scale

        switch currentStyle {
        case .candy:
            img = styledCandy
        case .laMuse:
            img = styledLaMuse
        case .scream:
            img = styledScream
        }
        
        var i: CGFloat = 0
        var index = styleIndex
        while index > 0, index > 2 {
//        if styleIndex % 3 {
            index -= 3
            i += 1
        }
        var idx = styleIndex
        if idx >= tileCount {
            idx = idx % tileCount
        }
        
        gridImages[styleIndex].alpha = 1
        gridImages[styleIndex].image = img.croppedImage(CGRect(x: CGFloat(idx) * sideSize, y: i * sideSize, width: sideSize, height: sideSize))
        //                imgvUser.image = image
    }
    
    func predict(image: UIImage, type: ModelType) {
        
        //        let numStyles  = 26
        //        let styleIndex = 3
        //
        //        let styleArray = try? MLMultiArray(shape: [numStyles,1,1,1,1] as [NSNumber], dataType: MLMultiArrayDataType.double)
        //
        //        for i in 0...(numStyles - 1) {
        //            styleArray?[i] = 0.0
        //        }
        //        styleArray?[styleIndex] = 1.0
        
        
        do {
            if let pixelBuffer = image.pixelBuffer(width: 720, height: 720) {
                switch type {
                case .candy:
                    let prediction = try modelCandy.prediction(inputImage: pixelBuffer)
                    if let image = UIImage(pixelBuffer: prediction.outputImage) {
                        self.styledCandy = image
                    }
                    
                case .laMuse:
                    let prediction = try modelLaMyse.prediction(inputImage: pixelBuffer)
                    if let image = UIImage(pixelBuffer: prediction.outputImage) {
                        self.styledLaMuse = image
                    }
                    
                case .scream:
                    let prediction = try modelScream.prediction(inputImage: pixelBuffer)
                    if let image = UIImage(pixelBuffer: prediction.outputImage) {
                        self.styledScream = image
                    }
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
//            self.butStyle.setTitle("Artify", for: .normal)
            self.userImage = image
        } else {
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
