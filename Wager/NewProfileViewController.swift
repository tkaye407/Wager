//
//  NewProfileViewController.swift
//
//  Created by Michael Swart on 4/10/17.
//

import Foundation
import Firebase
import UIKit


class NewProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  let ref = FIRDatabase.database().reference(withPath: "Profiles")

  @IBOutlet weak var EmailText: UITextField!
  @IBOutlet weak var PasswordText: UITextField!
  @IBOutlet weak var UsernameText: UITextField!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var genderPicker: UISegmentedControl!
  @IBOutlet weak var FirstNameText: UITextField!
  @IBOutlet weak var LastNameText: UITextField!
  @IBOutlet weak var VenmoIdText: UITextField!
  

  @IBAction func SignUpPressed(_ sender: Any) {
    /*purge inputs*/
    if (self.EmailText.text! == "") {errorHandler(errorString: "Email cannot be empty"); return}
    if (self.PasswordText.text!.characters.count < 6) {errorHandler(errorString: "Password must be 6 or more characters"); return}
    if (self.FirstNameText.text! == "") {errorHandler(errorString: "First Name cannot be empty"); return}
    if (self.LastNameText.text! == "") {errorHandler(errorString: "Last Name cannot be empty"); return}
    let usernameStr = self.UsernameText.text!
    if (usernameStr == "") {errorHandler(errorString: "Username cannot be empty"); return}
    if (usernameStr.characters.count < 4) {errorHandler(errorString: "Username must be at least 4 characters"); return}
    let pattern = "^([A-Za-z]|[0-9]|_)+$"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    if (regex.matches(in: usernameStr, options: [], range: NSRange(location: 0, length: usernameStr.characters.count)).count == 0) {
      errorHandler(errorString: "Username must be only alphanumeric or \"_\"")
      return
    }
    /* Trying to get no duplicate usernames
    var isSeen = false
    /*check to make sure the username has not yet been used*/
    let ref = FIRDatabase.database().reference(withPath: "Profiles")
    ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
      if snapshot.hasChild(usernameStr){
        
      }
    })
    if (isSeen) {errorHandler(errorString: "Username is already in use"); return}*/

    FIRAuth.auth()!.createUser(withEmail: self.EmailText.text!, password: self.PasswordText.text!) {user, error in
      if error == nil {
        FIRAuth.auth()!.signIn(withEmail: self.EmailText.text!, password: self.PasswordText.text!)
        
        // change gender to be picker button text
        let newProfRef = self.ref.childByAutoId()
        let profItem = Profile(firstName: self.FirstNameText.text!, lastName: self.LastNameText.text!, email: self.EmailText.text!, pnl: 0, age: 18, venmoID: self.VenmoIdText.text!, gender: "Male", userID: (user?.uid)!, username: self.UsernameText.text!)
        newProfRef.setValue(profItem.toAnyObject())
        
        let storageRef = FIRStorage.storage().reference().child((user?.uid)!)
        let finalImage = UIImagePNGRepresentation(self.profileImageView.image!)
        storageRef.put(finalImage!, metadata: nil, completion: {(metadata, error) in
            if(error != nil) {print("error"); return}
            else{ print("metadata")}
        })
      }
    }
  }
  
  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There was an Error Signing Up", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        profileImageView.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
     
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
            
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
            
            // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // CORNERS ON THE PROFILE IMAGE
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;
    }
}

    extension NewProfileViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
    }
}
