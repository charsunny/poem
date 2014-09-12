//
//  FavManager.swift
//  poem
//
//  Created by Sun Xi on 6/20/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation
import CoreData

class FavManager {
    
    class var sharedFavManager: FavManager {
        struct Singleton {
            static let instance = FavManager()
        }
        return Singleton.instance
    }
    
    init() {
        self.initFavItems()
    }
    
    func initFavItems() {
        
        if NSFileManager.defaultManager().fileExistsAtPath(favItemPath) {
            favManagedDoc.openWithCompletionHandler({Bool -> Void in
                self.favDocReady()
                })
        } else {
            let favFolder = NSEntityDescription.insertNewObjectForEntityForName("FavFolder", inManagedObjectContext: favManagedDoc.managedObjectContext) as FavFolder
            favFolder.name = "默认归档"
            favFolder.index = 0
            favFolder.color = 0
            favManagedDoc.saveToURL(NSURL(fileURLWithPath: favItemPath), forSaveOperation: .ForCreating, completionHandler: {Bool -> Void in
                self.favDocReady()
                })
        }
    }
    
    func favDocReady() {
        if favManagedDoc.documentState == .Normal {
            let request = NSFetchRequest(entityName:"FavFolder")
            let predicate = NSSortDescriptor(key:"index", ascending:true)
            request.sortDescriptors = [predicate]
            favFolders = favManagedDoc.managedObjectContext.executeFetchRequest(request, error: nil) as Array<FavFolder>
        }
    }
}