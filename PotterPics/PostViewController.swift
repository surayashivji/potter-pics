//
//  PostViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/6/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, ModalViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func sendValue(value: UIImage) {
        self.imagetoUpload.image = value
    }

    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imagetoUpload: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.captionTextField.attributedPlaceholder = NSAttributedString(string: "Enter Caption",   attributes:[NSForegroundColorAttributeName: UIColor.white])

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        sender.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postToFeed(_ sender: UIButton) {
        // post image to firebase storage
        let postImage = self.imagetoUpload.image
        let caption = self.captionTextField.text
        
        let storage = FIRStorage.storage()
        let data = UIImagePNGRepresentation(postImage!)
        // guard for user id
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let photosRef = storage.reference().child("posts")
        let imageName = NSUUID().uuidString
//        let photoRef = photosRef.child("\(imageName)")
        let photoRef = photosRef.child("\(uid)")
        
        photoRef.child("\(imageName)").put(data!, metadata: nil){(metaData,error) in
            if let error = error {
                print("there was an error")
                print(error.localizedDescription)
                return
            }else{
                // store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                print("DOWNLOD URL SUCCESS \(downloadURL)")
                //store downloadURL at database
                self.databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
            }

        }
        

        
//        let uploadTask =
        
        // store image post with caption in the posts database
        self.captionTextField.text = ""
    }
    
    @IBAction func chooseFromRoll(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if let modalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModalViewController") as? CameraViewController {
            modalVC.delegate = self
            present(modalVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagetoUpload.contentMode = .scaleAspectFit
            self.imagetoUpload.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
