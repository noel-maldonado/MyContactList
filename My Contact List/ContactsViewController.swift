//
//  ContactsViewController.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/1/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit

import CoreData

class ContactsViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {
    
    
    var currentContact: Contact?
    //sets up a reference to the App Delegate to access the Core Data Functionality
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //References
    //View / Edit
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    //Contact Name
    @IBOutlet weak var txtName: UITextField!
    //Contact Address
    @IBOutlet weak var txtAdress: UITextField!
    //Contact City
    @IBOutlet weak var txtCity: UITextField!
    //Contact State
    @IBOutlet weak var txtState: UITextField!
    //Contact Zipcode
    @IBOutlet weak var txtZip: UITextField!
    //Contact Cell Phone
    @IBOutlet weak var txtCell: UITextField!
    //Contact Home Phone
    @IBOutlet weak var txtPhone: UITextField!
    //Contact Email
    @IBOutlet weak var txtEmail: UITextField!
    //Contact Birthdate Label
    @IBOutlet weak var lblBirthdate: UILabel!
    //Contact Birthday Change Button
    @IBOutlet weak var btnChange: UIButton!
    
    //ScrollView
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if currentContact != nil {
            txtName.text = currentContact!.contactName
            txtAdress.text = currentContact!.streetAddress
            txtCity.text = currentContact!.city
            txtState.text = currentContact!.state
            txtZip.text = currentContact!.zipCode
            txtPhone.text = currentContact!.phoneNumber
            txtCell.text = currentContact!.cellNumber
            txtEmail.text = currentContact!.email
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentContact!.birthday != nil {
                lblBirthdate.text = formatter.string(from: currentContact!.birthday!)
            }
        }
        changeEditMode(self)
        
        
        
        
        let textFields: [UITextField] = [txtName, txtAdress, txtCity, txtState, txtZip, txtPhone, txtCell, txtEmail]
        
        for textfield in textFields {
            textfield.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControl.Event.editingDidEnd)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        currentContact?.contactName = txtName.text
        currentContact?.streetAddress = txtAdress.text
        currentContact?.city = txtCity.text
        currentContact?.state = txtState.text
        currentContact?.zipCode = txtZip.text
        currentContact?.cellNumber = txtCell.text
        currentContact?.phoneNumber = txtPhone.text
        currentContact?.email = txtEmail.text
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }
    
    
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtName, txtAdress, txtCity, txtState, txtZip, txtPhone, txtCell, txtEmail]
        
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextField.BorderStyle.none
            }
            btnChange.isHidden = true
        }
        else if sgmtEditMode.selectedSegmentIndex == 1 {
            for textField in textFields {
                textField.isEnabled = true
                navigationItem.rightBarButtonItem = nil
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            //creates a save bar BUtton Item
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveContact))
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications() //method called to listen for notifications that the keyboard has been displayed
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications() // when keyboard is hidden, listenor is stopped
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.keyboardDidShow(notification:)), name:
            UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(ContactsViewController.keyboardWillHide(notification:)), name:
            UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
           NotificationCenter.default.removeObserver(self)
       }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        // Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide (notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    
    
    @objc func saveContact() {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }
    
    func dateChanged(date: Date) {
        if currentContact != nil {
            currentContact?.birthday = date as NSDate? as Date?
            appDelegate.saveContext()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            lblBirthdate.text = formatter.string(from: date)
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueContactDate"){
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
