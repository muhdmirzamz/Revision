//
//  TableViewController.swift
//  Revision
//
//  Created by Muhd Mirza on 14/4/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
	
	let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var fetchResController: NSFetchedResultsController?
	var subjectArr: NSMutableArray?
	
	@IBOutlet var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		self.subjectArr = self.fetchObjects()
		
		print("Startup amount: \(self.subjectArr!.count)")
    }

	@IBAction func addSubject(sender: UIBarButtonItem) {
		let alertController = UIAlertController.init(title: "Enter subject name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) in
			let subjectName = alertController.textFields![0].text
			
			let currentSubjectArr = self.fetchObjects()
			
			var isDuplicate = false
			
 			for object in currentSubjectArr! {
				if object.valueForKey!("name") as? String == subjectName {
					let alert = UIAlertController.init(title: "Error", message: "Subject already exists", preferredStyle: .Alert)
					let ok = UIAlertAction.init(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
						alertController.textFields![0].text = ""
					})
					
					isDuplicate = true
					
					alert.addAction(ok)
					self.presentViewController(alert, animated: true, completion: nil)
					
					break
				}
			}
			
			if !isDuplicate {
				let subjectEntity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: self.context)
				let subject = NSManagedObject.init(entity: subjectEntity!, insertIntoManagedObjectContext: self.context)
				subject.setValue(subjectName, forKey: "name")
				do {
					try self.context.save()
					
					self.subjectArr?.addObject(subject)
					
					print("Amount after add: \(self.subjectArr!.count)")
					
					self.tableView.reloadData()
				} catch {
					print("Unable to save!\n")
				}
			}
		}
		let cancelHandler = {(action: UIAlertAction!) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Default, handler: cancelHandler)
		alertController.addTextFieldWithConfigurationHandler(nil)
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}

	func fetchObjects() -> NSMutableArray? {
		var subjectArr: NSMutableArray?
	
		let entity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: self.context)
		let sortDescriptors = NSSortDescriptor.init(key: "name", ascending: true)
		
		let fetchReq = NSFetchRequest()
		fetchReq.entity = entity
		fetchReq.sortDescriptors = [sortDescriptors]
		
		self.fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try self.fetchResController?.performFetch()
			
			subjectArr = NSMutableArray.init(array: self.fetchResController!.fetchedObjects!)
		} catch {
			print("Unable to fetch data!\n")
		}
		
		return subjectArr
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing {
			self.addButton.enabled = false
		} else {
			self.addButton.enabled = true
		}
	}
	

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let subjectArr = self.subjectArr {
			return subjectArr.count
		} else {
			return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
		cell.accessoryType = .DisclosureIndicator
		
		let object = self.subjectArr?[indexPath.row]
		if object != nil {
			cell.textLabel?.text = object!.valueForKey!("name") as? String
		}

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		self.navigationItem.rightBarButtonItem?.enabled = false
	
        if editingStyle == .Delete {
			if let object = self.subjectArr?[indexPath.row] as? NSManagedObject {
				let subjectName = object.valueForKey("name") as? String
			
				self.context.deleteObject(object)
				do {
					try self.context.save()
					
					self.subjectArr?.removeObject(object)
					
					self.tableView.reloadData()
				} catch {
					print("Unable to save!\n")
				}
				
				var subjectArr: NSMutableArray?
				
				let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: self.context)
				let sortDescriptors = NSSortDescriptor.init(key: "subjectName", ascending: true)
				
				let fetchReq = NSFetchRequest()
				fetchReq.entity = entity
				fetchReq.sortDescriptors = [sortDescriptors]
				
				self.fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
				do {
					try self.fetchResController?.performFetch()
					
					subjectArr = NSMutableArray.init(array: self.fetchResController!.fetchedObjects!)
				} catch {
					print("Unable to fetch data!\n")
				}
				
				for object in subjectArr! {
					let subject = object.valueForKey("subjectName") as? String
					
					if subject == subjectName {
						self.context.deleteObject(object as! NSManagedObject)
					}
				}
			}
        }
    }
	
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "subjectPass" {
			let indexPath = self.tableView.indexPathForSelectedRow
			let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
			
			let qtvc = segue.destinationViewController as? QuestionTableViewController
			if let qtvc = qtvc {
				qtvc.context = self.context
				qtvc.subjectName = cell?.textLabel?.text
			}
		}
    }
}
