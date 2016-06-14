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
	var fetchResController: NSFetchedResultsController?
	var subjectArr: NSMutableArray?
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		// setup core data
		self.context = self.createInMemoryManagedObjectContext()
    }

	func testAlertController() {
		let tvc = TableViewController()
		let navController = UINavigationController.init(rootViewController: tvc)
		UIApplication.sharedApplication().keyWindow?.rootViewController = navController

		let barButton = UIBarButtonItem.init(title: "", style: .Plain, target: self, action: nil)
		tvc.addSubject(barButton)

		XCTAssertNotNil(tvc.presentedViewController, "There should be an alert here!\n")
		XCTAssertTrue(tvc.presentedViewController!.isKindOfClass(UIAlertController), "Presented view controller should be a UIAlertController")
	}
	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		
		self.context = nil
    }

	func fetchObjects() -> NSMutableArray? {
		var subjectArr: NSMutableArray?
		
		let entity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: self.context!)
		let sortDescriptors = NSSortDescriptor.init(key: "name", ascending: true)
		
		let fetchReq = NSFetchRequest()
		fetchReq.entity = entity
		fetchReq.sortDescriptors = [sortDescriptors]
		
		let fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try fetchResController.performFetch()
			
			subjectArr = NSMutableArray.init(array: fetchResController.fetchedObjects!)
		} catch {
			print("Unable to fetch data!\n")
		}
		
		return subjectArr
	}
	
	func fetchObjects(WithContext context: NSManagedObjectContext, andSubject subject: String) -> NSMutableArray? {
		var subjectArr: NSMutableArray?
		
		let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: context)
		let sortDescriptors = NSSortDescriptor.init(key: "question", ascending: true)
		
		let fetchReq = NSFetchRequest()
		fetchReq.entity = entity
		fetchReq.sortDescriptors = [sortDescriptors]
		
		let fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try fetchResController.performFetch()
			
			subjectArr = NSMutableArray.init(array: fetchResController.fetchedObjects!)
			
			for object in subjectArr! {
				let subjectName = object.valueForKey("subjectName") as? String
				if subjectName != "English" {
					subjectArr?.removeObject(object)
				}
			}
			
		} catch {
			print("Unable to fetch data!\n")
		}
		
		return subjectArr
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
