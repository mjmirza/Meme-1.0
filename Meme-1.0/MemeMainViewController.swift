//
//  ViewController.swift
//  Meme-1.0
//
//  Created by Mirza Iqbal on 04.06.20.
//  Copyright © 2020 Mirza Iqbal. All rights reserved.
//

import UIKit

// MARK: - MemeMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
class MemeMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var buttonOfcamera: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var botoomTextField: UITextField!
    @IBOutlet weak var toolBar: UINavigationBar!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // MARK: - Defult Text Attribute (memeTextAttributes)
    let memeTextAttributes:[ NSAttributedString.Key : Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -0.5 ]
    
    // MARK: - Defult text value
    let defaultTopText = " TOP "
    let defaultBotoomText = " BOTOOM "
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check and set the avilabilty of the camera button (based on the running device)
        buttonOfcamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // TopTextField properties
        setStyle(toTextField: topTextField)
        topTextField.text = defaultTopText
        topTextField.tag = 0
        
        
        //BotoomTextField properties
        setStyle(toTextField:  botoomTextField)
        botoomTextField.text = defaultBotoomText
        botoomTextField.tag = 1
        
        //Set the top, bottom text feild  and sharebutton to be disable while there is no meme image
        self.setTheMemeArguments()
        
    }
    //MARK:- viewWillAppear(_ animated: Bool)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Update the top, bottom text feild  and sharebutton to be Enable while there is meme image
        self.setTheMemeArguments()
    }
    
    //MARK:- setStyle(toTextField textField: UITextField)
    func setStyle(toTextField textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
    }
    
    // MARK: - pickAnImageFromAlbum (_ sender: Any)
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        openImagePicker(.photoLibrary)
    }
    
    // MARK: - pickAnImageFromCamera (_ sender:Any)
    @IBAction func pickAnImageFromCamera(_ sender:Any){
        openImagePicker(.camera)
    }
    
    // MARK: - openImagePicker(_ type: UIImagePickerController.SourceType)
    func openImagePicker(_ type: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - pickAnImageFromCamera (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
        }
    }
    
    // MARK: - textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear the 2 defualt texts
        if textField.text == defaultTopText || textField.text == defaultBotoomText
        {
            textField.text = ""
        }
        // handel the keyboard position during typing
       if textField.tag == 0{
            self.unsubscribeFromKeyboardNotifications()
        }
        else{
        self.subscribeToKeyBoardNotification()}
      
    }
    
    //MARK:- textFieldShouldReturn(_ textField: UITextField) -> Bool
    func  textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- keyboardWillShow( notification:Notification ) -Setting the keyboard size-
    @objc func keyboardWillShow( notification:Notification ){
        self.view.frame.origin.y = -getKeyboardHight(notification)
    }
    
    //MARK:- keyboardWillHide ( notification:Notification ) -ReSetting the keyboard size-
    @objc func keyboardWillHide( notification:Notification ){
        self.view.frame.origin.y = 0
    }
    
    //MARK:- getKeyboardHight(_ notification:Notification) -> CGFloat
    func getKeyboardHight(_ notification:Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //MARK:- ubscribeToKeyBoardNotification()
    func subscribeToKeyBoardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK:- unsubscribeFromKeyboardNotifications()
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK:- save() -Save a meme image-
    func save() {
        // Create the meme
        _ = Meme(topTextField: topTextField.text!, botoomTextField: botoomTextField.text!, orignalImage: imagePickerView.image, memedImage: generateMemedImage())
    }
    
    //MARK:- generateMemedImage() -> UIImage
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.hideToolbars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        self.hideToolbars(false)
        
        return memedImage
    }
    
    //MARK:- isTherememe() -> Bool
    func isTherememe() -> Bool{
        return ((imagePickerView?.image) != nil)
    }
    
    //MARK:- setTheMemeArguments()
    func setTheMemeArguments(){
        topTextField.isEnabled = isTherememe()
        botoomTextField.isEnabled = isTherememe()
        shareButton.isEnabled = isTherememe()
    }
    
    //MARK:- func shareAction(_ sender: Any)
    @IBAction func shareAction(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController ( activityItems: [memedImage], applicationActivities: nil)
        
        present(activityViewController, animated:  true, completion: nil)
        activityViewController .completionWithItemsHandler = { activityViewController , success, items, error in
            if (success){
                //save meme
                self.save()
            }
        }
    }
    
    //MARK:-  cancelTheMeme(_ sender: Any)
    @IBAction func cancelTheMeme(_ sender: Any) {
        if isTherememe(){
            imagePickerView?.image = nil
            topTextField.text = defaultTopText
            botoomTextField.text = defaultBotoomText
            topTextField.isEnabled = isTherememe()
            botoomTextField.isEnabled = isTherememe()
            shareButton.isEnabled = isTherememe()
        }
    }
    
    //MARK:- hideToolbars(_ hide: Bool)
    func hideToolbars(_ hide: Bool) {
        toolBar.isHidden = hide
        navBar.isHidden =  hide
    }
}


