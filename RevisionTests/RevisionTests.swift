//
//  RevisionTests.swift
//  RevisionTests
//
//  Created by Muhd Mirza on 3/5/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import XCTest
import CoreData

@testable import Revision

class RevisionTests: XCTestCase {
	
	var context: NSManagedObjectContext?
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		self.context = self.createInMemoryManagedObjectContext()
    }

	func testAlertController() {
		let tvc = TableViewController()
		let navController = UINavigationController.init(rootViewController: tvc)
		UIApplication.sharedApplication().keyWindow?.rootViewController = navController
		
		let alertController = UIAlertController.init(title: "Enter subject name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
		let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Default, handler:nil)
		alertController.addTextFieldWithConfigurationHandler(nil)
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		
		tvc.presentViewController(alertController, animated: true, completion: nil)
		
		XCTAssertTrue(tvc.presentedViewController == alertController, "Alert is presented\n")
	}
	
	func DISABLED_testAddSubject() {
		let tvc = TableViewController()
		let navController = UINavigationController.init(rootViewController: tvc)
		UIApplication.sharedApplication().keyWindow?.rootViewController = navController
		
		let alertController = UIAlertController.init(title: "Enter subject name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) in
			let subjectName = alertController.textFields![0].text
			
			let currentSubjectArr = tvc.fetchObjects()
			
			var isDuplicate = false
			
			for object in currentSubjectArr! {
				if object.valueForKey!("name") as? String == subjectName {
					let alert = UIAlertController.init(title: "Error", message: "Subject already exists", preferredStyle: .Alert)
					let ok = UIAlertAction.init(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
						alertController.textFields![0].text = ""
					})
					
					isDuplicate = true
					
					alert.addAction(ok)
					tvc.presentViewController(alert, animated: true, completion: nil)
					
					break
				}
			}
			
			if !isDuplicate {
				let subjectEntity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: self.context!)
				let subject = NSManagedObject.init(entity: subjectEntity!, insertIntoManagedObjectContext: self.context)
				subject.setValue(subjectName, forKey: "name")
				do {
					try self.context!.save()
					
					tvc.subjectArr?.addObject(subject)
					
					print("Amount after add: \(tvc.subjectArr!.count)")
					
					tvc.tableView.reloadData()
				} catch {
					print("Unable to save!\n")
				}
			}
		}
		let cancelHandler = {(action: UIAlertAction!) -> Void in
			tvc.dismissViewControllerAnimated(true, completion: nil)
		}
		let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Default, handler: cancelHandler)
		alertController.addTextFieldWithConfigurationHandler(nil)
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		
		tvc.presentViewController(alertController, animated: true, completion: nil)
		
		XCTAssertTrue(tvc.presentedViewController == alertController, "Alert is presented\n")
	}
	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		
		self.context = nil
    }

	func createInMemoryManagedObjectContext() -> NSManagedObjectContext? {
		let objectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
		let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: objectModel!)
		
		do {
			try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
		} catch {
			print("Adding in-memory persistent store failed!\n")
		}
		
		let context = NSManagedObjectContext.init(concurrencyType: .MainQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		
		return context
	}
}
