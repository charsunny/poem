//
//  SecondViewController.swift
//  poem
//
//  Created by Sun Xi on 6/12/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import QuartzCore

class SecondViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate ,UISearchDisplayDelegate{
    
    var searchResult:NSArray!
    
    @IBOutlet var searchBar : UISearchBar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let spLine:UIView = UIView(frame: CGRectMake(0, 43.5, self.view.bounds.width, 0.5))
        spLine.backgroundColor = UIColor.lightGrayColor()
        searchBar.addSubview(spLine)
        searchBar.delegate = self
        let footView:UIView = UIView()
        self.searchDisplayController.delegate = self
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fontnamechanged", name: "tradchar", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "tradchar", object: nil)
    }

    func fontnamechanged() -> Void {
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController.setNavigationBarHidden(true, animated: true);
    }
    
    func positionForBar(pos:UIBarPositioning)->UIBarPosition {
        return .TopAttached
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
                animation.duration = 0.2 + 0.1*Double(i)
                if direction == 0 {
                    animation.subtype = kCATransitionFromLeft
                } else {
                    animation.subtype = kCATransitionFromRight
                }
                (cell as UITableViewCell).layer.addAnimation(animation, forKey:"animation")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // D'ispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.searchDisplayController.searchResultsTableView {
            if searchResult {
                return searchResult.count;
            }
            return 0
        }
       return 4;
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
         if tableView === self.searchDisplayController.searchResultsTableView {
            return 64
         } else {
            return 76
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView === self.searchDisplayController.searchResultsTableView {
            var cell:UITableViewCell? =  tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style:.Subtitle, reuseIdentifier: "cell")
            }
            let poem:PoemEntity = searchResult[indexPath.row] as PoemEntity
            cell!.textLabel.text = poem.title
            cell!.detailTextLabel.text = poem.content
            cell!.textLabel.font = UIFont(name: kFontSong, size: 18)
            cell!.detailTextLabel.font = UIFont(name: kFontKai, size: 14)
            let color = favColorDic.allValues[abs(poem.author.hashValue)%9] as Int
            cell!.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,50,50))
            cell!.imageView.layer.cornerRadius = 5
            cell!.imageView.clipsToBounds = true
            if let label = cell!.imageView.viewWithTag(1) as? UILabel {
                label.text = poem.author
            } else {
                let label:UILabel = UILabel(frame:CGRectMake(5,5,40,40))
                label.text = poem.author
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.tag = 1
                label.font = UIFont(name: kFontSong, size: 18)
                cell!.imageView.addSubview(label)
            }
            return cell
        }
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.font = UIFont(name: kFontSong, size: 24)
        cell.detailTextLabel.font = UIFont(name: kFontKai, size: 18)
        switch indexPath.row {
        case 0 :
            cell.imageView.image = UIImage(named: "wander1")
            cell.textLabel.text = "唐诗• 随览"
            cell.detailTextLabel.text = "『漫卷诗书喜欲狂』"
        case 1:
            cell.imageView.image = UIImage(named: "wander2")
            cell.textLabel.text = "宋词• 漫游"
            cell.detailTextLabel.text = "『一曲新词酒一杯』"
        case 2:
            cell.imageView.image = UIImage(named: "libai")
            cell.textLabel.text = "诗人• 略志"
            cell.detailTextLabel.text = "『众里寻她千百度』"
        case 3:
            cell.imageView.image = UIImage(named: "sushi")
            cell.textLabel.text = "词牌• 格律"
            cell.detailTextLabel.text = "『水调数声持酒听』"
        case 4:
            cell.imageView.image = UIImage(named: "libai")
            cell.textLabel.text = "太白• 独韵"
            cell.detailTextLabel.text = "『人生得意须尽欢』"
        case 5:
            cell.imageView.image = UIImage(named: "sushi")
            cell.textLabel.text = "东坡• 志林"
            cell.detailTextLabel.text = "『一蓑烟雨任平生』"
        default:
            cell.textLabel.text = "词牌"
            cell.detailTextLabel.text = "随便看看词牌"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if tableView === self.searchDisplayController.searchResultsTableView {
            let poem:PoemEntity = searchResult[indexPath.row] as PoemEntity
            let containerVC:RandomContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("rdcontentvc") as RandomContentViewController
            containerVC.poemEntity = poem
            self.navigationController.pushViewController(containerVC, animated: true)
            return
        }
        switch indexPath.row {
        case 0:
            let containerVC:PoemContainerViewController = self.storyboard.instantiateViewControllerWithIdentifier("containervc") as PoemContainerViewController
            containerVC.titleText = "唐诗• 随览"
            containerVC.type = 0
            containerVC.showLoadingText = "唐\n诗\n•\n随\n览"
            self.navigationController.pushViewController(containerVC, animated: true)
        case 1:
            let containerVC:PoemContainerViewController = self.storyboard.instantiateViewControllerWithIdentifier("containervc") as PoemContainerViewController
            containerVC.titleText = "宋词• 漫游"
            containerVC.type = 1
            containerVC.showLoadingText = "宋\n词\n•\n漫\n游"
            self.navigationController.pushViewController(containerVC, animated: true)
        case 2:
            let searchListVC:SearchListViewController = self.storyboard.instantiateViewControllerWithIdentifier("searchlistvc") as SearchListViewController
            searchListVC.isSong = false
            searchListVC.showLoadingText = "诗\n人\n•\n略\n志"
            self.navigationController.pushViewController(searchListVC, animated: true)
        case 3:
            let searchListVC:SearchListViewController = self.storyboard.instantiateViewControllerWithIdentifier("searchlistvc") as SearchListViewController
            searchListVC.isSong = true
            searchListVC.showLoadingText = "词\n牌\n•\n格\n律"
            self.navigationController.pushViewController(searchListVC, animated: true)
        default:
            NSLog("xx")
        }
    }
    
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        if !searchText.isEmpty {
            self.searchDisplayController.searchResultsTableView.hidden = true
            dispatch_async(dispatch_get_global_queue(0, 0), {()->Void in
                self.searchResult = PoemEntity.getPoemByKeyword(searchText, scope:searchBar.selectedScopeButtonIndex)
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    self.searchDisplayController.searchResultsTableView.reloadData()
                    })
                })
        } else {
            searchResult = NSArray()
            self.searchDisplayController.searchResultsTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        if !searchBar.text.isEmpty {
            searchResult = PoemEntity.getPoemByKeyword(searchBar.text, scope:searchBar.selectedScopeButtonIndex)
        } else {
            searchResult = NSArray()
        }
        self.searchDisplayController.searchResultsTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar!, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if !searchBar.text.isEmpty {
            dispatch_async(dispatch_get_global_queue(0, 0), {()->Void in
                self.searchResult = PoemEntity.getPoemByKeyword(searchBar.text, scope:selectedScope)
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    self.searchDisplayController.searchResultsTableView.reloadData()
                })
            })
        } else {
            searchResult = NSArray()
            self.searchDisplayController.searchResultsTableView.reloadData()
        }
        
    }
}

