//
//  SecondViewController.swift
//  poem
//
//  Created by Sun Xi on 6/12/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import QuartzCore

class SecondViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchBar : UISearchBar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let spLine:UIView = UIView(frame: CGRectMake(0, 43.5, self.view.bounds.width, 0.5))
        spLine.backgroundColor = UIColor.lightGrayColor()
        searchBar.addSubview(spLine)
        
        let footView:UIView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController.setNavigationBarHidden(true, animated: true);
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
            return 0;
        }
       return 4;
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return nil;
        }
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.font = UIFont(name: kFontSong, size: 24)
        cell.detailTextLabel.font = UIFont(name: kFontKai, size: 18)
        switch indexPath.row {
        case 0 :
            cell.imageView.image = UIImage(named: "libai")
            cell.textLabel.text = "唐诗• 随览"
            cell.detailTextLabel.text = "『漫卷诗书喜欲狂』"
        case 1:
            cell.imageView.image = UIImage(named: "sushi")
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

}

