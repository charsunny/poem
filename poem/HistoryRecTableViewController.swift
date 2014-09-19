//
//  HistoryRecTableViewController.swift
//  poem
//
//  Created by Sun Xi on 6/30/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import QuartzCore

class HistoryRecTableViewController: UITableViewController {
    
    var sectionArray:NSArray!

    var poemDic:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        self.view.userInteractionEnabled = false
        let activiyIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
        activiyIndicator.center = self.view.center
        self.view.addSubview(activiyIndicator)
        activiyIndicator.startAnimating()

        let reqURL = NSURL(string: "http://poetry.duapp.com/?qt=his")
        let reqTask = NSURLSession.sharedSession().dataTaskWithURL(reqURL, completionHandler: {(data:NSData!, resp:NSURLResponse!, error:NSError!) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    activiyIndicator.stopAnimating()
                    activiyIndicator.removeFromSuperview()
                    self.tableView.reloadData()
                    self.view.userInteractionEnabled = true
                })
            }

            if let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                
                self.poemDic = json["data"] as NSDictionary
                self.sectionArray = (self.poemDic.allKeys as NSArray).sortedArrayUsingComparator({(s1:AnyObject!, s2:AnyObject!)->NSComparisonResult in
                    return (s1 as NSString).compare(s2 as String)
                })
                
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    activiyIndicator.removeFromSuperview()
                    self.tableView.reloadData()
                    self.runCellAnimation(1)
                    self.view.userInteractionEnabled = true
                    })
            }
            })
        reqTask.resume()
    }
    
    func runCellAnimation(direction:Int)->Void {
        if direction < 0 {
            return
        }
        var i:Int = 0
        for cell:AnyObject in self.tableView.visibleCells() {
            if cell is UITableViewCell {
                i++;
                let animation:CATransition = CATransition()
                animation.type = kCATransitionMoveIn
                animation.duration = 0.1 + 0.05*Double(i)
                if direction == 0 {
                    animation.subtype = kCATransitionFromLeft
                } else {
                    animation.subtype = kCATransitionFromRight
                }
                (cell as UITableViewCell).layer.addAnimation(animation, forKey:"animation")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if (self.sectionArray != nil) {
            return self.sectionArray.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return self.sectionArray[section] as? String
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let key = sectionArray[section] as String
        let poems = poemDic[key] as NSArray
        return poems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.clipsToBounds = true
        
        let key = sectionArray[indexPath.section] as String
        let poems = poemDic[key] as NSArray
        let poem = poems[indexPath.row] as NSDictionary
        cell.textLabel?.font = UIFont(name: kFontSong, size: 22)
        cell.textLabel?.text = poem["title"] as? String
        cell.detailTextLabel?.font = UIFont(name:kFontKai, size:14)
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = poem["desc"] as? String
        
        let color = favColorDic.allValues[abs((poem["author"] as String).hashValue)%9] as Int
        cell.imageView?.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,60,60))
        if let label = cell.imageView?.viewWithTag(1) as? UILabel {
            label.text = poem["author"] as? String
        } else {
            let label:UILabel = UILabel(frame:CGRectMake(5,5,50,50))
            label.text = poem["author"] as? String
            label.textAlignment = .Center
            label.numberOfLines = 0
            label.tag = 1
            label.font = UIFont(name: kFontSong, size: 20)
            cell.imageView?.addSubview(label)
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let containerVC:ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("contentvc") as ContentViewController
        let key = sectionArray[indexPath.section] as String
        let poems = poemDic[key] as NSArray
        let poem = poems[indexPath.row] as NSDictionary
        //containerVC.titleText = "诗词推荐"
        containerVC.poemEntity = PoemEntity.getPoemByIndex((poem["index"] as String).toInt()!)
        //containerVC.curIdx = indexPath.row
        self.navigationController?.pushViewController(containerVC, animated: true)
    }
}
