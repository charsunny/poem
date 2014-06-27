//
//  SearchDetailViewController.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import QuartzCore

var detailPoemMap:Dictionary<String, Array<PoemEntity>> = Dictionary<String, Array<PoemEntity>>()

class SearchDetailViewController: UITableViewController {
    
    var isSong:Bool = false
    
    var keyword:String = ""
    
    var songNameEntity:SongNameEntity?
    
    var authorEntity:AuthorEntity?
    
    @IBOutlet var titleLabel : UILabel
    
    @IBOutlet var descLabel : UITextView
    
    var activtyIndicator:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footView:UIView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
        
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        titleLabel.font = UIFont(name: kFontSong, size: 32)
        descLabel.font = UIFont(name: kFontKai, size: 16)
        
        if !isSong {
            titleLabel.text = authorEntity!.name
            descLabel.text = authorEntity!.desc
            tableView.reloadData()
        } else {
            titleLabel.text = songNameEntity!.name
            descLabel.text = songNameEntity!.info + "\n" + songNameEntity!.desc
        }
        
        if detailPoemMap.count > 0 {
            detailPoemMap.removeAll(keepCapacity: false)
        }
        
        let color = favColorDic.allValues[abs(titleLabel.text.hashValue)%9] as Int
        titleLabel.backgroundColor = UIColorFromRGB(color)
        
        activtyIndicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
        activtyIndicator!.center = CGPointMake(160,320)
        activtyIndicator!.startAnimating()
        self.view.addSubview(activtyIndicator)
        dispatch_async(dispatch_get_global_queue(0, 0), {[weak self]()->Void in
            if !self!.isSong {
                detailPoemMap = PoemEntity.getPoemByAuthor(self?.authorEntity?.name)
            } else {
                detailPoemMap = PoemEntity.getSongByName(self?.songNameEntity?.name)
            }
            dispatch_async(dispatch_get_main_queue(), { ()->Void in
                self?.activtyIndicator!.stopAnimating()
                self?.tableView.reloadData()
                self?.runCellAnimation(1)
            })
        })
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
        super.viewWillAppear(animated);
        self.navigationController.setNavigationBarHidden(false, animated: true);
    }
    
    override func viewDidDisappear(animated: Bool)  {
        super.viewDidDisappear(animated)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        if detailPoemMap != nil {
            return detailPoemMap.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let keys:Array<String> = Array(detailPoemMap.keys)
        return keys[section]
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView!) -> AnyObject[]! {
        return Array(detailPoemMap.keys)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return 0;
        }
        let key:String = Array(detailPoemMap.keys)[section]
        if let author = detailPoemMap[key] {
            return author.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return nil;
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.font = UIFont(name: kFontSong, size: 18)
        cell.detailTextLabel.font = UIFont(name: kFontKai, size: 14)
        cell.imageView.layer.cornerRadius = 5
        cell.imageView.clipsToBounds = true
        
        let key:String = Array(detailPoemMap.keys)[indexPath.section]
        if let poemSection = detailPoemMap[key] {
            let poem:PoemEntity = poemSection[indexPath.row]
            cell.imageView.image = nil
            cell.textLabel.text = poem.title
            cell.detailTextLabel.text = poem.content
            if isSong {
                cell.textLabel.text = poem.subtitle
                let color = favColorDic.allValues[abs(poem.author.hashValue)%9] as Int
                cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,50,50))
                if let label = cell.imageView.viewWithTag(1) as? UILabel {
                    label.text = poem.author
                } else {
                    let label:UILabel = UILabel(frame:CGRectMake(5,5,40,40))
                    label.text = poem.author
                    label.textAlignment = .Center
                    label.numberOfLines = 0
                    label.tag = 1
                    label.font = UIFont(name: kFontSong, size: 18)
                    cell.imageView.addSubview(label)
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let containerVC:ContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("songcontentvc") as ContentViewController
        
        containerVC.titleText = keyword
        var poems:Array<PoemEntity> = []
        var index:Int = 0
        var i:Int  = 0
        let poemMaps = detailPoemMap.values
        for poemArray in poemMaps {
            if i < indexPath.section {
                index += poemArray.count
            }
            i++
            for poem in poemArray {
                poems.append(poem)
            }
        }
        index += indexPath.row
        containerVC.poemEntity = poems[index]
        self.navigationController.pushViewController(containerVC, animated: true)
    }
}
