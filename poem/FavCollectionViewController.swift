//
//  FavCollectionViewController.swift
//  poem
//
//  Created by Sun Xi on 6/17/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

class FavCollectionViewController: UICollectionViewController,UICollectionViewDataSource, SXCollectionViewCellDelegate, EditFavViewControllerDelegate, UIActionSheetDelegate {
    
    var cellForMove:FavFolder?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.destinationViewController is FavListTableViewController {
            
            let desVC = segue.destinationViewController as FavListTableViewController
            let cell = sender as SXCollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            let favItems = favFolders[indexPath.row].items
            desVC.favItems = favItems.allObjects
            desVC.navigationItem.title = cell.titleLabel.text
            
        } else if segue.destinationViewController is EditFavViewController {
            
            let desVC = segue.destinationViewController as EditFavViewController
            desVC.delegate = self
            desVC.favIndex = favFolders.count
            if sender is UICollectionViewCell {
                let indexPath = collectionView.indexPathForCell(sender as UICollectionViewCell)
                desVC.favFolder = favFolders[indexPath.row]
                desVC.selectedSel = desVC.favFolder!.color.integerValue
                desVC.favIndex = indexPath.row
            }
        }
    }
    
    func finishEditFavFolder(folder:FavFolder, _ isAdd:Bool)->Void {
        collectionView.reloadData()
    }

    // #pragma mark UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView?, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return favFolders.count
    }

    override func collectionView(collectionView: UICollectionView?, cellForItemAtIndexPath indexPath: NSIndexPath?) -> UICollectionViewCell? {
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as SXCollectionViewCell
        // Configure the cell
        let favItem = favFolders[indexPath!.row]
        cell.titleLabel.font = UIFont(name: kFontSong, size: 24)
        cell.titleLabel.text = favItem.name
        let color:Int = favColorDic.allValues[favItem.color.integerValue] as Int
        let bgColor = UIColorFromRGB(color)
        cell.backgroundColor = bgColor
        cell.belongVC = self
        cell.delegate = self
        return cell
    }

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView?, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
        let menuEdit:UIMenuItem = UIMenuItem(title:"编辑", action: "performEdit:")
        let menuDelete:UIMenuItem = UIMenuItem(title:"删除" , action:"performDelete:")
        UIMenuController.sharedMenuController().menuItems = [menuEdit, menuDelete]
        return true
    }
    
    override func collectionView(collectionView: UICollectionView!, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView!, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) {
        
        if action == "cut:" {
            let moveCell = favFolders[indexPath.row]
            self.cellForMove = moveCell
            favFolders.removeAtIndex(indexPath.row)
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            collectionView.deleteItemsAtIndexPaths([indexPath])
        } else if action == "paste:" {
            favFolders.insert(self.cellForMove!, atIndex:indexPath.row)
            self.cellForMove = nil
            collectionView.insertItemsAtIndexPaths([indexPath])
        }
    }
    
    func performDelete(sender: AnyObject?, cell: UICollectionViewCell) {
        let myActionSheet:UIActionSheet = UIActionSheet()
        myActionSheet.title  = "删除收藏夹"
        myActionSheet.delegate = self
        myActionSheet.addButtonWithTitle("删除并保留诗作")
        myActionSheet.addButtonWithTitle("删除不保留诗作")
        myActionSheet.addButtonWithTitle("取消")
        myActionSheet.destructiveButtonIndex = 1
        myActionSheet.cancelButtonIndex = 2
        myActionSheet.showInView(self.view)
        let indexPath = collectionView.indexPathForCell(cell)
        myActionSheet.tag = indexPath.row
    }
    
    func performEdit(sender: AnyObject?, cell: UICollectionViewCell) {
        self.performSegueWithIdentifier("editsegue", sender: cell)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        let row = actionSheet.tag
        let indexPath = NSIndexPath(forRow:row ,inSection:0)
        switch buttonIndex {
        case 0:
            var favFolder:FavFolder
            if row != 0 {
                favFolder = favFolders[0]
            } else {
                favFolder = favFolders[1]
            }
            let delFolder = favFolders[row]
            favFolder.addItems(delFolder.items)
            favManagedDoc.managedObjectContext.deleteObject(delFolder)
            favFolders.removeAtIndex(row)
            self.collectionView.deleteItemsAtIndexPaths([indexPath])
        case 1:
            favManagedDoc.managedObjectContext.deleteObject(favFolders[row])
            favFolders.removeAtIndex(row)
        self.collectionView.deleteItemsAtIndexPaths([indexPath])
        default:
            println("xx")
        }
    }
}
