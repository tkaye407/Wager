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



  @IBOutlet weak var signUpButton: UIButton!
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
      
        var gender = ""
        if (self.genderPicker.selectedSegmentIndex == 0)
        {      gender = "Male"}
        else { gender = "Female"}
        
        let newProfRef = self.ref.childByAutoId()
        let profItem = Profile(firstName: self.FirstNameText.text!, lastName: self.LastNameText.text!, email: self.EmailText.text!, pnl: 0, age: 18, venmoID: self.VenmoIdText.text!, gender: gender, userID: (user?.uid)!, username: self.UsernameText.text!)
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
    guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    
    if (selectedImage.size.width != selectedImage.size.height) {
      print("no way")
      dismiss(animated: true, completion: nil)
      let alertController = UIAlertController(title: "Profile Image Not Square!", message: "You did not fit your image to the box. Rechoose the image and crop it into the square", preferredStyle: .alert)
      present(alertController, animated: true, completion: nil)
      let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(callOK)
      return
    }
    // Set photoImageView to display the selected image.
    profileImageView.image = self.resizeImage(image: selectedImage, targetSize: CGSize(width:100.0, height:100.0))
    
    // Dismiss the picker.
    dismiss(animated: true, completion: nil)
  }
  
  //Copied this function from stack overflow
  func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
    } else {
      newSize = CGSize(width:size.width * widthRatio,  height:size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
    //MARK: Actions
  @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
      // UIImagePickerController is a view controller that lets a user pick media from their photo library.
      let imagePickerController = UIImagePickerController()
      
      // Only allow photos to be picked, not taken.
      imagePickerController.sourceType = .photoLibrary
      imagePickerController.allowsEditing = true;
      
      // Make sure ViewController is notified when the user picks an image.
      imagePickerController.delegate = self
      
      present(imagePickerController, animated: true, completion: nil)
      
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.signUpButton.layer.cornerRadius = 5;
      self.profileImageView.clipsToBounds = true
        // CORNERS ON THE PROFILE IMAGE
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;
        
        self.navigationController?.navigationBar.isHidden = true
      
        // to resign keyboard on outside touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
      
      // work around to change height of the nice looking textfields since you cant do in storyboard
      FirstNameText.borderStyle = .roundedRect
      LastNameText.borderStyle = .roundedRect
      EmailText.borderStyle = .roundedRect;
      UsernameText.borderStyle = .roundedRect;
      PasswordText.borderStyle = .roundedRect;
      VenmoIdText.borderStyle = .roundedRect;
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func unwindToLogin(_ sender: Any) {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
}
    extension NewProfileViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          
            switch textField {
            case FirstNameText:
                LastNameText.becomeFirstResponder()
                break
            case LastNameText:
                EmailText.becomeFirstResponder()
                break
            case EmailText:
                UsernameText.becomeFirstResponder()
                break
            case UsernameText:
                PasswordText.becomeFirstResponder()
                break
            case PasswordText:
                VenmoIdText.becomeFirstResponder()
            case VenmoIdText:
                VenmoIdText.resignFirstResponder()
                break
            default:
                textField.resignFirstResponder()

            }
            return true
    }
}
