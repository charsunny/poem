//
//  FavItem.swift
//  poem
//
//  Created by Sun Xi on 8/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation
import CoreData

class FavItem: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var desc: String
    @NSManaged var index: NSNumber
    @NSManaged var time: NSDate
    @NSManaged var title: String
    @NSManaged var type: NSNumber
    @NSManaged var folder: poem.FavFolder

}
