//
//  PostViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/6/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class PostViewController: UIViewController, ModalViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imagetoUpload: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var takePhotoButton: HomeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.captionTextField.attributedPlaceholder = NSAttributedString(string: "Enter Caption",   attributes:[NSForegroundColorAttributeName: UIColor.white])
    }
    
    func sendValue(value: UIImage) {
        self.imagetoUpload.image = value
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        sender.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postToFeed(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
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
        let usersRef = FIRDatabase.database().reference().child("users")
        var currentNumPosts: Int?
        // increase post count
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // get user value
            let value = snapshot.value as? NSDictionary
            currentNumPosts = value?["postCount"] as? Int
            self.updateNumPosts(currentNumPosts: currentNumPosts!, uid: uid)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let imageName = NSUUID().uuidString
        let photoRef = photosRef.child("\(uid)")
        
        photoRef.child("\(imageName)").put(data!, metadata: nil) { (metaData,error) in
            if let error = error {
                print("there was an error")
                print(error.localizedDescription)
                return
            } else {
                // store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                let values: Dictionary<String, Any> = ["uid": uid, "caption": caption ?? "", "download_url": downloadURL, "timestamp": FIRServerValue.timestamp()]
                
                // store downloadURL at database
                let databaseRef = FIRDatabase.database().reference()
                let path = databaseRef.child("posts").childByAutoId()
                path.setValue(values) { (error, ref) -> Void in
                    if error != nil {
                        print("error saving post in db")
                    } else {
                        // reset caption field
                        self.captionTextField.text = ""
                        // reset placeholder image
                        self.imagetoUpload.image = UIImage(named: "filterPlaceholder")
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }
            }
        }
    }
    
    func updateNumPosts(currentNumPosts: Int, uid: String) {
        let usersRef = FIRDatabase.database().reference().child("users")
        let newCount = currentNumPosts + 1
        let values = ["postCount": newCount]
        usersRef.child(uid).updateChildValues(values)
    }
    
    @IBAction func chooseFromRoll(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        // check for simulator
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            // alert
            let message: String = "Please run on a device to use the camera!"
            let alertView = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alertView.addAction(UIAlertAction(title: "Ok ", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        #else
        if let modalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModalViewController") as? CameraViewController {
            modalVC.delegate = self
            present(modalVC, animated: true, completion: nil)
        }
        #endif
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
