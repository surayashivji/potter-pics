//
//  CameraViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/6/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import AVFoundation

protocol ModalViewControllerDelegate
{
    func sendValue(value : UIImage)
}

class CameraViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: ModalViewControllerDelegate!
    
    @IBOutlet weak var collecFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var previewImgView: UIView!

    var photoTaken: Bool = false
    var imagePicker: UIImagePickerController!
    var session: AVCaptureSession?
    var unfilteredImage: UIImage?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var filters = ["Original", "CISepiaTone", "CIDotScreen", "CIGaussianBlur", "CIColorInvert", "CIPhotoEffectNoir"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.showsHorizontalScrollIndicator = false
        self.filterCollectionView.backgroundColor = UIColor.black
        setupFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.unfilteredImage = self.captureImageView.image
        
        // setup camera
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetMedium
        
        // select rear camera for input
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        }
        if session!.canAddOutput(stillImageOutput) {
            session!.addOutput(stillImageOutput)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            previewImgView.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewImgView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        photoTaken = true
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
                // process image data (sampleBuffer) to get the file for the image view
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    // let image = UIImage(cgImage: cgImageRef!)
                    self.unfilteredImage = image
                    self.captureImageView.image = image
                }
            })
        }
    }
   
    
    // MARK: Collection View Methods
    func setupFlow() {
        self.collecFlow.sectionInset = UIEdgeInsets.init(top: 0 , left: 0, bottom: 0, right: 0)
        self.collecFlow.itemSize = CGSize(width: 120, height: 120)
        self.collecFlow.minimumLineSpacing = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filtersCell", for: indexPath as IndexPath) as! FilterCollectionViewCell
        
        cell.backgroundColor = UIColor.black
        
        cell.filteredLbl.text = ""
        let placeholderImage = UIImage(named: "filterPlaceholder")
        let inputImage = CIImage(image: placeholderImage!);
        let filterName = filters[indexPath.row]
        cell.filteredImg.image = generateFilteredImage(name: filterName, image: inputImage!, placeholder: true)
        cell.filteredLbl.text = filterName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! FilterCollectionViewCell
        if cell.filteredImg.image != nil {
            if let ciVersion = CIImage(image: unfilteredImage!) {
                let filteredImage = generateFilteredImage(name: filters[indexPath.row], image: ciVersion, placeholder: !photoTaken)
                self.captureImageView.image = filteredImage
            }
        }
    }
    
    func generateFilteredImage(name: String!, image: CIImage, placeholder: Bool) -> UIImage {
        if(name == "Original") {
            return UIImage(ciImage: image)
        }
        var filteredImage = UIImage()
        let context:CIContext = CIContext(options:nil);
        let filter = CIFilter(name: name)!
        filter.setValue(image, forKey: "inputImage")
        
        let inputKeys = filter.inputKeys
        
        if (inputKeys.contains(kCIInputIntensityKey)) {
            filter.setValue(1.7, forKey: kCIInputIntensityKey)
        }
        if (inputKeys.contains(kCIInputRadiusKey)) {
            filter.setValue(10, forKey: kCIInputRadiusKey)
        }
        if (inputKeys.contains(kCIInputScaleKey)) {
            filter.setValue(0.9 * 10, forKey: kCIInputScaleKey)
        }
        
        if let cgimg = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
            let processedImage = placeholder ? UIImage(cgImage: cgimg) : UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.right)
            
            filteredImage = processedImage
        }
        return filteredImage
    }
    
    @IBAction func uploadPicture(_ sender: AnyObject) {
        delegate?.sendValue(value: self.captureImageView.image!)
        self.dismiss(animated: true, completion: nil)
    }}
