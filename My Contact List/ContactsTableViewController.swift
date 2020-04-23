//
//  ContactsTableViewController.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/19/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit
//importss the CoreData Functionallity needed to load the data for the table
import CoreData

class ContactsTableViewController: UITableViewController {
    
    
    
    
    
    // let contacts = ["Jim", "John", "Dana", "Rosie", "Justin", "Jeremy", "Sarah", "Matt", "Joe", "Donald", "Jeff"]
    
    //lets the contact array hold NSManagedObject instance; This allows to hold the COntact objects that will be retrieved from CoreData
    var contacts:[NSManagedObject] = []
    //created a reference to the AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        loadDataFromDatabase()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        //data is reloaded from the database
        loadDataFromDatabase()
        //reloads the data to the table
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //uses this method to populate the contacts array with data
    func loadDataFromDatabase() {
        //Read Settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        let secondField = settings.string(forKey: Constants.kState)
        let sortAscending2 = settings.bool(forKey: Constants.kSortDirectionAscending2)
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //Defines which data to be retrieved from CoreData using the Contact entityName
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        //Specify Sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptor2 = NSSortDescriptor(key: secondField, ascending: sortAscending2)
//        let sortDescriptor2 = NSSortDescriptor(key: secondField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor, sortDescriptor2]
        //to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        
        //execute request; fetch may fail so do-catch helps with error handling
        do {
            //executed the fetch and stores the result in contacts array
            contacts = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contacts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // creates the cell object
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)

        // Configure the cell...
        //A Contact is retrieved
        let contact = contacts[indexPath.row] as? Contact
        //set label to contacts Name
        cell.textLabel?.text = (contact?.contactName)! + " from " + (contact?.city)!
        
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM d, y"
        
        //set subtitle to city
        cell.detailTextLabel?.text = "Born on: " + dateFormatter.string(from: (contact?.birthday)!)
        
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let contact = contacts[indexPath.row] as? Contact
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contact!)
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //grabs the contact object associated with the selected row
        let selectedContact = contacts[indexPath.row] as? Contact
        //assigns the contact name to a constant
        let name = selectedContact!.contactName!
        //executed when the user taps the show details button
        let actionHandler = { (action:UIAlertAction!) -> Void in
//            self.performSegue(withIdentifier: "EditContact", sender: tableView.cellForRow(at: indexPath))
            
            //gets reference to main storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //instantiates an istance of the ContactsViewController
            let controller = storyboard.instantiateViewController(withIdentifier: "ContactController") as? ContactsViewController
            //sets the selected contact to the controller currentContact
            controller?.currentContact = selectedContact
            //navigation controller pushes the ContactsViewController onto the navigation stack, giving the back button to allow the user to go back to the table view
            self.navigationController?.pushViewController(controller!, animated: true)
            print("actionHandler triggered")
        }
        
        let alertController = UIAlertController(title: "Contact selected", message: "Selected row: \(indexPath.row) (\(name))", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actionDetails = UIAlertAction(title: "Show Details", style: .default, handler: actionHandler)
        
        
        //Delete Functionality
        
        let deleteActionHandler = { (action:UIAlertAction!) -> Void in
            let contact = self.contacts[indexPath.row] as? Contact
            let context = self.appDelegate.persistentContainer.viewContext
            context.delete(contact!)
            do {
                try context.save()
            }catch {
                fatalError("Error saving context: \(error)")
            }
            self.loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive, handler: deleteActionHandler)
        
        alertController.addAction(actionCancel)
        
        alertController.addAction(actionDetails)
        
        alertController.addAction(actionDelete)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //checks segue identifier
        if segue.identifier == "EditContact" {
            //gets a reference to the Contact Editing screen view Controller (thats the destination)
            let contactController = segue.destination as? ContactsViewController
            //checks which row was sleccted in the table
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            //gets the reference to the corresponding Contact object from the contacts Array
            let selectedContact = contacts[selectedRow!] as? Contact
            //assigns the slected contact to the currentContant property in ContactsViewController; allows the Controller to populate the user interface with the selected contact
            contactController?.currentContact = selectedContact!
        }
        
        
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
