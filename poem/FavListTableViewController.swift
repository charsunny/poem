//
//  FavListTableViewController.swift
//  poem
//
//  Created by Sun Xi on 6/18/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

class FavListTableViewController: UITableViewController {
    
    var favItems:Array<AnyObject>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        let footView:UIView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        if favItems?.count == 0 {
            let label = UITextView(frame:CGRectMake(0, 0, 200, 60))
            label.text = "暂无归档"
            label.textColor = UIColor.lightGrayColor()
            label.textAlignment = .Center
            label.editable = false
            label.selectable = false
            label.font = UIFont(name: kFontSong, size: 28)
            label.center = CGPointMake(self.view.center.x,self.view.center.y - 100)
            self.view.addSubview(label)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController.setNavigationBarHidden(false, animated: true)
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if favItems == nil {
            return 0
        }
        return favItems!.count
    }

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView!.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let favItem = favItems![indexPath!.row] as FavItem
        // Configure the cell...
        
        let color = favColorDic.allValues[abs(favItem.author.hashValue)%9] as Int
        cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,50,50))
        
        cell.textLabel.font = UIFont(name: kFontSong, size: 20)
        cell.textLabel.text = favItem.title
        cell.detailTextLabel.font = UIFont(name:kFontKai, size:16)
        cell.detailTextLabel.numberOfLines = 2
        cell.detailTextLabel.text = favItem.desc
        
        cell.imageView.layer.cornerRadius = 5
        if let label = cell.imageView.viewWithTag(1) as? UILabel {
            label.text = favItem.author
        } else {
            let label:UILabel = UILabel(frame:CGRectMake(5,5,40,40))
            label.text = favItem.author
            label.textAlignment = .Center
            label.numberOfLines = 0
            label.tag = 1
            label.font = UIFont(name: kFontSong, size: 18)
            cell.imageView.addSubview(label)
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let favItem:FavItem = favItems![indexPath!.row] as FavItem
            favManagedDoc.managedObjectContext.deleteObject(favItem)
            //favItems!.removeAtIndex(indexPath!.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let favItem = favItems![indexPath!.row] as FavItem
        let poemEntity = PoemEntity.getPoemByIndex(favItem.index.integerValue)
        let contentVC:RandomContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("rdcontentvc") as RandomContentViewController
        contentVC.poemEntity = poemEntity
        self.navigationController.pushViewController(contentVC, animated: true)
    }

    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
