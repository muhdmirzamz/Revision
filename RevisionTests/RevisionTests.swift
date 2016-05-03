//
//  RevisionTests.swift
//  RevisionTests
//
//  Created by Muhd Mirza on 3/5/16.
//  Copyright © 2016 muhdmirzamz. All rights reserved.
//

import XCTest
import CoreData

class RevisionTests: XCTestCase {
	
	var context: NSManagedObjectContext?
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		self.context = self.createInMemoryManagedObjectContext()
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
