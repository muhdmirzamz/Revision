//
//  RevisionViewController.swift
//  Revision
//
//  Created by Muhd Mirza on 17/4/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import UIKit
import CoreData

class RevisionViewController: UIViewController {

	@IBOutlet var label: UILabel!
	
	var subjectName: String?
	var context: NSManagedObjectContext?
	var questionArr, questionDisplayedArr: NSMutableArray?
	

    override func viewDidLoad() {
        super.viewDidLoad()

		self.questionArr = NSMutableArray()
		self.questionDisplayedArr = NSMutableArray()

        let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: self.context!)
		let sortDescriptor = NSSortDescriptor.init(key: "question", ascending: true)
		let fetchReq = NSFetchRequest()
		fetchReq.entity = entity
		fetchReq.sortDescriptors = [sortDescriptor]
		
		let fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try fetchResController.performFetch()
			
			for object in fetchResController.fetchedObjects! {
				let subjectName = object.valueForKey("subjectName") as? String
				
				if subjectName == self.subjectName {
					self.questionArr?.addObject(object)
				}
			}
		} catch {
			print("Unable to fetch!\n")
		}
		
		let randInt = Int(arc4random()) % (self.questionArr?.count)!
		self.label.text = self.questionArr![randInt].valueForKey("question") as? String
		
		self.questionDisplayedArr = NSMutableArray()
		self.questionDisplayedArr?.addObject(randInt)
    }

	@IBAction func generateNextQuestion() {
		if self.questionArr?.count == self.questionDisplayedArr?.count {
			let alertController = UIAlertController.init(title: "Alert", message: "All questions done. Restarting", preferredStyle: .Alert)
			let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
				let randInt = Int(arc4random()) % (self.questionArr?.count)!
				self.label.text = self.questionArr![randInt].valueForKey("question") as? String
				
				self.questionDisplayedArr = NSMutableArray()
				self.questionDisplayedArr?.addObject(randInt)
			})
			alertController.addAction(okAction)
			self.presentViewController(alertController, animated: true, completion: nil)
		} else {
			var number = NSNumber.init(unsignedInt: arc4random())
			var randInt = number.integerValue % (self.questionArr?.count)!
			
			var numberNotFound = true
			var counter = 0;
			
			while numberNotFound {
				if randInt == self.questionDisplayedArr![counter] as! Int {
					number = NSNumber.init(unsignedInt: arc4random())
					randInt = number.integerValue % (self.questionArr?.count)!
					
					counter = 0
				} else {
					counter += 1
					
					if counter == self.questionDisplayedArr?.count {
						numberNotFound = false
					}
				}
			}
			
			self.label.text = self.questionArr![randInt].valueForKey("question") as? String
			self.questionDisplayedArr?.addObject(randInt)
		}
	}

	@IBAction func dismiss() {
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
