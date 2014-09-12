//
//  FavFolder.swift
//  poem
//
//  Created by Sun Xi on 8/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation
import CoreData

class FavFolder: NSManagedObject {

    @NSManaged var color: NSNumber
    @NSManaged var index: NSNumber
    @NSManaged var name: String
    @NSManaged var items: NSMutableSet

}
