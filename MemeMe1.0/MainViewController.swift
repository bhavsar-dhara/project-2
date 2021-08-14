//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Dhara Bhavsar on 5/25/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITabBarDelegate  {

    
    
    
    // MARK: UI component variables
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var share: UIBarItem!
    @IBOutlet weak var cancel: UIBarItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomTabBar: UITabBar!
    @IBOutlet weak var camera: UITabBarItem!
    @IBOutlet weak var album: UIBarItem!
    
    var activeField: UITextField?
    var memedImage: UIImage!
    
    
    
    
    // MARK: Default constants
    let topDefaultTxt = "TOP"
    let bottomDefaultTxt = "BOTTOM"
    let imagePicker = UIImagePickerController()
    
    
    
    
    // MARK: required Meme struct
    internal struct Meme {
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    
    
    
    
    // MARK: Inherent Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(1),
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -5.0,
        ]
        
        topTextField.text = topDefaultTxt
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.tintColor = .black
        topTextField.delegate = self
        
        bottomTextField.text = bottomDefaultTxt
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.tintColor = .black
        bottomTextField.delegate = self
        
        bottomTabBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // disabling the camera button if the device doesn't have a camera, eg. simulator
        camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    
        // subscribe to keyboard notifications, to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
        subscribeToKeyboardNotificationsHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe to keyboard notifications
        unsubscribeFromKeyboardNotifications()
        subscribeToKeyboardNotificationsHide()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // testing handle UI on device orientation change
        // print(UIDevice.current.orientation.isLandscape)
    }

    
    
    
    // MARK: Top nav bar methods
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if (item === camera) {
            launchController(sourceType: .camera)
        } else if (item === album) {
            launchController(sourceType: .photoLibrary)
        }
    }
    
    // Combined function to pick an image from an Album or the Camera app
    func launchController(sourceType: UIImagePickerController.SourceType) {
     
        print("LaunchController sourceType = ", sourceType)
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        // added the ability to crop the image
        imagePicker.allowsEditing = true
        // present(imagePicker, animated: true, completion: nil)
        
        //for iPhone
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            present(imagePicker, animated: true, completion: nil)
        }
        //for iPad
        else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            // Change Rect as required
            present(imagePicker, animated: true, completion: nil)
            
            if let popOver = imagePicker.popoverPresentationController {
                popOver.permittedArrowDirections = UIPopoverArrowDirection.up
                popOver.sourceView = self.view
                //popOver.sourceRect =
                //popOver.barButtonItem
            }
        } else {
            print("Not an iPhone or iPad - Unspecified device")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func didCancel(_ sender: Any) {
        
    }
    
    
    
    
    // MARK: Text field functions
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.text == topDefaultTxt || textField.text == bottomDefaultTxt) {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEditing) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // TODO
//    }
    
    
    
    
    // MARK: Keyboard subscription functions called on the text fields
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        //Need to calculate keyboard exact size due to Apple suggestions
        var aRect : CGRect = self.view.frame
        let keyboardHeight = getKeyboardHeight(notification)
        aRect.size.height -= keyboardHeight
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                view.frame.origin.y = -keyboardHeight
            }
        }
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotificationsHide() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotificationsHide() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        //Once keyboard disappears, restore original positions
        view.frame.origin.y = 0
    }
    
    
    
    
    // MARK: Save/Share functions
    func save() {
        
        // Create the meme for saving
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: self.memedImage!)
    }
    
    func generateMemedImage() -> UIImage {

        // TODO: Hide toolbar and navbar
        topNavBar.isHidden = true
        bottomTabBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar
        topNavBar.isHidden = false
        bottomTabBar.isHidden = false
        
        return memedImage
    }
     
    @IBAction func shareMeme(_ sender: Any) {
        
        // generate a memed image
        self.memedImage = generateMemedImage()
        
        // define an instance of the ActivityViewController
        // pass the ActivityViewController a memedImage as an activity item
        let activityController = UIActivityViewController(activityItems: [self.memedImage!], applicationActivities: nil)
                    
        // present the ActivityViewController
        present(activityController, animated: true, completion: nil)
        
        if let popOver = activityController.popoverPresentationController {
            popOver.permittedArrowDirections = UIPopoverArrowDirection.up
            popOver.sourceView = self.view
            //popOver.sourceRect =
            //popOver.barButtonItem
        }

        
        // call methods with completion item handler
        activityController.completionWithItemsHandler = {
            
            (activityType: UIActivity.ActivityType?, completed:
           Bool, arrayReturnedItems: [Any]?, error: Error?) in
               if completed {
                    print("share completed")
                    // save the create meme as an instance of a custom object
                    self.save()
                    activityController.dismiss(animated: true, completion: nil)
                    return
               } else {
                    print("cancel")
               }
               if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
               }
        }
    }
}

