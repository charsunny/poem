//
//  FirstViewController.swift
//  poem
//
//  Created by Sun Xi on 6/12/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import QuartzCore

class FirstViewController: UITableViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var scrollView : UIScrollView
    
    @IBOutlet var pageControl : UIPageControl

    var timer:NSTimer?
    var lastPage = 0
    var lastReady = false
    var dataReady = false
    
    var poemArray:NSArray = NSArray()
    var headPoems:NSArray = NSArray()
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPoems()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:"onTimer", userInfo: nil, repeats:true)
        timer?.fire()
        
        let footView:UIView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
        tableView.contentOffset = CGPointMake(0,44)
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func loadPoems() -> Void {
        
        pageControl.hidden = true
        self.view.userInteractionEnabled = false
        let activiyIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
        activiyIndicator.center = self.view.center
        self.view.addSubview(activiyIndicator)
        activiyIndicator.startAnimating()
        let reqURL = NSURL(string: "http://poetry.duapp.com/?qt=rec")
        let reqTask = NSURLSession.sharedSession().dataTaskWithURL(reqURL, completionHandler: {(data:NSData!, resp:NSURLResponse!, error:NSError!) -> Void in
            activiyIndicator.removeFromSuperview()
            if let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                
                self.poemArray = json["data"] as NSArray
                let headAr:NSMutableArray = NSMutableArray()
                for poem:AnyObject in self.poemArray {
                    let tmp = poem as NSDictionary
                    if (tmp["head"] as String).toInt() > 0 {
                        headAr.addObject(poem)
                    }
                }
                self.dataReady = true
                self.headPoems = headAr
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    self.pageControl.numberOfPages = headAr.count
                    self.pageControl.hidden = false
                    self.initHeadBannerView()
                    self.tableView.reloadData()
                    self.runCellAnimation(1)
                    self.view.userInteractionEnabled = true
                })
            }
        })
        reqTask.resume()

    }
    
    func initHeadBannerView() -> Void {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*CGFloat(self.headPoems.count), scrollView.frame.size.height)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        var orginX:CGFloat = 0
        for var i = 0; i < self.headPoems.count;  i++ {
            var idx:Int32 = rand() % 13 + 1
            let imagePath:String = NSBundle.mainBundle().pathForResource("\(idx)", ofType: "jpg")
            var headBannerView:UIView;
            let poemEntity = headPoems[i] as NSDictionary
            headBannerView = createHeadBannerView(imagePath, text: poemEntity["desc"] as String)
            headBannerView.tag = 100 + i
            headBannerView.frame = CGRectMake(orginX, 0, headBannerView.frame.width, headBannerView.frame.height)
            orginX = orginX + scrollView.frame.size.width
            scrollView.addSubview(headBannerView)
        }
    }
    
    func createHeadBannerView(name:String, text:String) -> UIView {
        let view:UIView = UIView(frame:scrollView.bounds)
        let imageView:UIImageView = UIImageView(frame:scrollView.bounds)
        imageView.image = UIImage(contentsOfFile:name)
        imageView.alpha = 0.3
        imageView.tag = 10
        view.addSubview(imageView)
        let headTextLabel:UILabel = UILabel(frame: CGRectMake(20, 100, scrollView.bounds.size.width - CGFloat(40), 80))
        headTextLabel.backgroundColor = UIColor.clearColor()
        headTextLabel.font = UIFont(name: kFontKai, size: 20)
        headTextLabel.textColor = UIColor.blackColor()
        headTextLabel.numberOfLines = 2
        headTextLabel.text = text
        headTextLabel.tag = 20
        view.addSubview(headTextLabel)
        return view
    }
    
    func onTimer()->Void {
        if !dataReady {
            return
        }
        if lastReady != dataReady {
            lastReady = dataReady
            return
        }
        if poemArray.count == 0 {
            return
        } else {
            pageControl.currentPage = (++pageControl.currentPage)%poemArray.count
        }
        self.scrollView.contentOffset = CGPointMake(CGFloat(pageControl.currentPage)*320, 0)
        //tableView.reloadData()
        self.runHeadAnimation(1)
        //self.runCellAnimation(1)
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
    
    func runHeadAnimation(direction:Int)->Void {
        let animation:CATransition = CATransition()
        animation.type = kCATransitionMoveIn
        animation.duration = 0.3
        if direction == 0 {
            animation.subtype = kCATransitionFromLeft
        } else {
            animation.subtype = kCATransitionFromRight
        }
        self.scrollView.layer.addAnimation(animation, forKey:"animation")
    }
    
    func onTapHeadView() -> Void {
        let contentVC:ContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("songcontentvc") as ContentViewController
        let poem = headPoems[pageControl.currentPage] as NSDictionary
        contentVC.titleText = "诗词推荐"
        //contentVC.poemEntity = poem
        self.navigationController.pushViewController(contentVC, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        timer?.invalidate()
        if scrollView === self.scrollView {
            var page = abs(scrollView.contentOffset.x) / scrollView.frame.size.width
//            var direction = 0
//            if pageControl.currentPage < Int(page) {
//                direction = 1
//            } else if pageControl.currentPage == Int(page) {
//                direction = -1
//            }
                pageControl.currentPage = Int(page)
//            tableView.reloadData()
//            self.runCellAnimation(direction)
        }
    }
    
    @IBAction func pageValueChanged(sender : UIPageControl) {
        
        var direction = 0
        if lastPage < sender.currentPage {
            direction = 1
        } else if lastPage == sender.currentPage {
            direction = -1
        }

        self.scrollView.contentOffset = CGPointMake(CGFloat(sender.currentPage)*320, 0)
        self.runHeadAnimation(direction)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return poemArray.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.imageView.layer.cornerRadius = 10
        
        let poem = poemArray[indexPath.row] as NSDictionary
        cell.textLabel.font = UIFont(name: kFontSong, size: 22)
        cell.textLabel.text = poem["title"] as String
        cell.detailTextLabel.font = UIFont(name:kFontKai, size:14)
        cell.detailTextLabel.numberOfLines = 2
        cell.detailTextLabel.text = poem["desc"] as String
        
        let color = favColorDic.allValues[abs((poem["author"] as String).hashValue)%9] as Int
        cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,60,60))
        if let label = cell.imageView.viewWithTag(1) as? UILabel {
            label.text = poem["author"] as String
        } else {
            let label:UILabel = UILabel(frame:CGRectMake(5,5,50,50))
            label.text = poem["author"] as String
            label.textAlignment = .Center
            label.numberOfLines = 0
            label.tag = 1
            label.font = UIFont(name: kFontSong, size: 20)
            cell.imageView.addSubview(label)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let containerVC:ContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("songcontentvc") as ContentViewController
        let poem = poemArray[indexPath.row] as NSDictionary
        containerVC.titleText = "诗词推荐"
        containerVC.poemDic = poem
            //containerVC.curIdx = indexPath.row
        self.navigationController.pushViewController(containerVC, animated: true)
    }

}

