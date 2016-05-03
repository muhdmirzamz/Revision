//
//  AddQuestionViewController.swift
//  Revision
//
//  Created by Muhd Mirza on 17/4/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import UIKit
import CoreData

protocol dataReload {
	func reloadTableData(withContext context: NSManagedObjectContext, andSubjectName subject: String)
}

class AddQuestionViewController: UIViewController {
	
	var subjectName: String?
	var context: NSManagedObjectContext?
	var delegate: dataReload?
	
	@IBOutlet var textfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	@IBAction func dismissViewController() {
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func addQuestion() {
		let alertController = UIAlertController.init(title: "Hold on", message: "Are you sure?", preferredStyle: .Alert)
		let yesAction = UIAlertAction.init(title: "YES", style: .Default, handler: { (action: UIAlertAction!) in
			let question = self.textfield.text
			let object = NSEntityDescription.insertNewObjectForEntityForName("Question", inManagedObjectContext: self.context!)
			object.setValue(self.subjectName!, forKey: "subjectName")
			object.setValue(question!, forKey: "question")
			do {
				try self.context?.save()
				
				self.dismissViewController()
				self.delegate?.reloadTableData(withContext: self.context!, andSubjectName: self.subjectName!)
			} catch {
				print("Unable to save question!")
			}
		})
		let noAction = UIAlertAction.init(title: "NO", style: .Default) { (action: UIAlertAction!) in
			self.dismissViewController()
		}
		alertController.addAction(yesAction)
		alertController.addAction(noAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
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
