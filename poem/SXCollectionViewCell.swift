//
//  SXCollectionViewCell.swift
//  poem
//
//  Created by Sun Xi on 6/18/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

protocol SXCollectionViewCellDelegate {
    func performEdit(sender:AnyObject, cell:UICollectionViewCell)
    func performDelete(sender:AnyObject, cell:UICollectionViewCell)
}

class SXCollectionViewCell: UICollectionViewCell {
    
    var delegate:SXCollectionViewCellDelegate?
    
    var belongVC:FavCollectionViewController?
    
    @IBOutlet var titleLabel:UILabel!
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        
        let count = belongVC!.collectionView?.numberOfItemsInSection(0)
        if count == 1 {
            if action == "performEdit:" {
                return true
            }
            if belongVC!.cellForMove != nil {
                if action == "paste:" {
                    return true;
                }
            }
        } else {
            if action == "performEdit:" || action == "performDelete:" {
                return true
            }
            if belongVC!.cellForMove == nil {
                if action == "cut:" {
                    return true;
                }
            } else {
                if action == "paste:" {
                    return true;
                }
            }
        }
        
        return false
    }
    
    func performEdit(item:AnyObject) {
        delegate?.performEdit(item, cell: self)
    }
    
    func performDelete(item:AnyObject) {
        delegate?.performDelete(item, cell: self)
    }
    
}
