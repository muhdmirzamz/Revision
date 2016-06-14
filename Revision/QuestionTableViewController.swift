//
//  QuestionTableViewController.swift
//  Revision
//
//  Created by Muhd Mirza on 16/4/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import UIKit
import CoreData

class QuestionTableViewController: UITableViewController, dataReload {

	var questionArr: NSMutableArray?
	var subjectName: String?
	var context: NSManagedObjectContext?
	var fetchResController: NSFetchedResultsController?
	
	@IBOutlet var addBtn: UIBarButtonItem!
	@IBOutlet var revisionBtn: UIBarButtonItem!

	var editBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		self.editBtn = self.editButtonItem()
		self.navigationItem.rightBarButtonItems?.append(self.editBtn)
		
		self.questionArr = self.fetchObjects(WithContext: self.context!, andSubject: self.subjectName!)
		
		if self.questionArr?.count == 0 {
			self.revisionBtn.enabled = false
		} else {
			self.revisionBtn.enabled = true
		}
    }

	func fetchObjects(WithContext context: NSManagedObjectContext, andSubject subject: String) -> NSMutableArray? {
		var tmpQuestionArr: NSMutableArray?
	
		let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: context)
		let sortDescriptors = NSSortDescriptor.init(key: "question", ascending: true)
		
		let fetchReq = NSFetchRequest()
		fetchReq.entity = entity
		fetchReq.sortDescriptors = [sortDescriptors]
		
		self.fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try self.fetchResController?.performFetch()
		
			tmpQuestionArr = NSMutableArray()
		
			for object in self.fetchResController!.fetchedObjects! {
				let subjectName = object.valueForKey("subjectName") as? String
				
				if subjectName! == subject {
					tmpQuestionArr!.addObject(object)
				}
			}
			
		} catch {
			print("Unable to fetch data!\n")
		}
		
		return tmpQuestionArr
	}
	
	func reloadTableData(withContext context: NSManagedObjectContext, andSubjectName subject: String) {
		self.questionArr = self.fetchObjects(WithContext: context, andSubject: subject)
		
		if self.questionArr?.count == 0 {
			self.revisionBtn.enabled = false
		} else {
			self.revisionBtn.enabled = true
		}
		
		self.tableView.reloadData()
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing {
			self.addBtn.enabled = false
			self.revisionBtn.enabled = false
		} else {
			self.addBtn.enabled = true
			
			if self.questionArr?.count == 0 {
				self.revisionBtn.enabled = false
			} else {
				self.revisionBtn.enabled = true
			}
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let questionArr = self.questionArr {
			return questionArr.count
		} else {
			return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
		if let questionArr = self.questionArr {
			let object = questionArr[indexPath.row]
			cell.textLabel?.text = object.valueForKey("question") as? String
		}

        return cell
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
			if let object = self.questionArr?[indexPath.row] as? NSManagedObject {
				self.context?.deleteObject(object)
				do {
					try self.context?.save()
					
					self.questionArr?.removeObject(object)
					
					self.tableView.reloadData()
				} catch {
					print("Unable to save!\n")
				}
			}
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "addQuestion" {
			let navController = segue.destinationViewController as? UINavigationController
			let aqvc = navController?.topViewController as? AddQuestionViewController
			
			aqvc?.context = self.context
			aqvc?.subjectName = self.subjectName
			aqvc?.delegate = self
		}
		
		if segue.identifier == "startRevision" {
			let navController = segue.destinationViewController as? UINavigationController
			let rvc = navController?.topViewController as? RevisionViewController
			
			rvc?.context = self.context
			rvc?.subjectName = self.subjectName
		}
    }
}
