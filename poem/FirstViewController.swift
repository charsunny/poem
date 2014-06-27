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
    
    let colCount = 5
    var timer:NSTimer?
    var lastPage = 0
    var lastReady = false
    var dataReady = false
    
    var poemArray:Array< Array<PoemEntity>? > = []
    var headPoems:Array<PoemEntity> = []
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // init gestures
        addGestures()
        // init poems
        loadPoems()
        let reqURL = NSURL(string: "http://172.22.109.113/poem/")
        let reqTask = NSURLSession.sharedSession().dataTaskWithURL(reqURL, completionHandler: {(data:NSData!, resp:NSURLResponse!, error:NSError!) -> Void in
            if let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                    println("\(json)")
                }
            })
        reqTask.resume()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:"onTimer", userInfo: nil, repeats:true)
        timer?.fire()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func addGestures() -> Void {
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeLeft.direction = .Left
        swipeRight.direction = .Right
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func loadPoems() -> Void {
        pageControl.numberOfPages = colCount
        pageControl.hidden = true
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.tableView)
        progressHud.labelText = "正在加载"
        self.tableView.addSubview(progressHud)
        progressHud.showAnimated(true, {()->Void in
        for i in 0..self.colCount {
            var poem = PoemEntity.genRandomPoem(count: 5)
            self.poemArray.append(poem)
        }
        self.headPoems = PoemEntity.genRandomPoem(count: self.colCount)
        }, {()->Void in
            self.dataReady = true
            progressHud.removeFromSuperview()
            self.pageControl.hidden = false
            self.initHeadBannerView()
            self.tableView.reloadData()
            self.runCellAnimation(1)
        })
    }
    
    func initHeadBannerView() -> Void {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*CGFloat(colCount), scrollView.frame.size.height)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        var orginX:CGFloat = 0
        for var i = 0; i < colCount;  i++ {
            var idx:Int32 = rand() % 13 + 1
            let imagePath:String = NSBundle.mainBundle().pathForResource("\(idx)", ofType: "jpg")
            var headBannerView:UIView;
            let poemEntity = headPoems[i]
            headBannerView = createHeadBannerView(imagePath, text: poemEntity.content)
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
    
    func reloadHeadViewData() -> Void{
        for var i = 0; i < colCount;  i++ {
            let view:UIView? = scrollView.viewWithTag(100+i)
            let imageView:UIImageView? = view?.viewWithTag(10) as UIImageView?
            let textView:UILabel? = view?.viewWithTag(20) as UILabel?
            if headPoems.count > i {
                let poemEntity = headPoems[i]
                if textView {
                    textView!.text = poemEntity.content
                }
            }
        }
        pageControl.currentPage = 0;
        scrollView.contentOffset = CGPointMake(0, 0)
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
        tableView.reloadData()
        self.runHeadAnimation(1)
        self.runCellAnimation(1)
    }
    
    func swipeLeft()->Void {
        if pageControl.currentPage < colCount - 1 {
            lastPage = pageControl.currentPage
            pageControl.currentPage++
            self.pageValueChanged(pageControl)
        }
    }
    
    func swipeRight()->Void {
        if pageControl.currentPage > 0 {
            lastPage = pageControl.currentPage
            pageControl.currentPage--
            self.pageValueChanged(pageControl)
        }
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
        let poem:PoemEntity = headPoems[pageControl.currentPage]
        contentVC.titleText = "诗词推荐"
        contentVC.poemEntity = poem
        self.navigationController.pushViewController(contentVC, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        timer?.invalidate()
        if scrollView === self.scrollView {
            var page = abs(scrollView.contentOffset.x) / scrollView.frame.size.width
            var direction = 0
            if pageControl.currentPage < Int(page) {
                direction = 1
            } else if pageControl.currentPage == Int(page) {
                direction = -1
            }
            pageControl.currentPage = Int(page)
            tableView.reloadData()
            self.runCellAnimation(direction)
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
        tableView.reloadData()
        self.runHeadAnimation(direction)
        self.runCellAnimation(direction)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if poemArray.count > pageControl.currentPage {
            if let poems = poemArray[pageControl.currentPage] {
                return poems.count
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.imageView.layer.cornerRadius = 10
        
        if poemArray.count > pageControl.currentPage {
            if let poems:Array<PoemEntity> = poemArray[pageControl.currentPage] {
                let poem:PoemEntity = poems[indexPath.row]
                cell.textLabel.font = UIFont(name: kFontSong, size: 22)
                cell.textLabel.text = poem.title
                cell.detailTextLabel.font = UIFont(name:kFontKai, size:14)
                cell.detailTextLabel.numberOfLines = 2
                cell.detailTextLabel.text = poem.content
                
                let color = favColorDic.allValues[abs(poem.author.hashValue)%9] as Int
                cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,60,60))
                if let label = cell.imageView.viewWithTag(1) as? UILabel {
                    label.text = poem.author
                } else {
                    let label:UILabel = UILabel(frame:CGRectMake(5,5,50,50))
                    label.text = poem.author
                    label.textAlignment = .Center
                    label.numberOfLines = 0
                    label.tag = 1
                    label.font = UIFont(name: kFontSong, size: 20)
                    cell.imageView.addSubview(label)
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let containerVC:ContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("songcontentvc") as ContentViewController
        if let poems:Array<PoemEntity> = poemArray[pageControl.currentPage] {
            containerVC.titleText = "诗词推荐"
            containerVC.poemEntity = poems[indexPath.row]
            //containerVC.curIdx = indexPath.row
        }
        self.navigationController.pushViewController(containerVC, animated: true)
    }

}

