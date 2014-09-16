//
//  ContentViewController.swift
//  poem
//
//  Created by Sun Xi on 6/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import QuartzCore
import CoreData

class ContentViewController: UIViewController,UIActionSheetDelegate {
    
    var poemDic:NSDictionary?
    
    var poemEntity:PoemEntity?
    
    var titleText:String = "返回"
    
    var pageNum:Int = 0
    
    var menuShow:Bool = false
    
    var favItem:FavItem?
    
    lazy var synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet var authorLabel:UILabel!
    
    //@IBOutlet var descLabel: UILabel!
    
    @IBOutlet var descView: UITextView!
    
    @IBOutlet var contentView:UITextView!
    
    @IBOutlet var backgroundImageView:UIImageView!

    @IBOutlet var menuButton : UIButton!
    
    @IBOutlet var shareButton: UIButton!
    
    lazy var butterFly:UIImageView = UIImageView(frame:CGRectMake(0,0,30,30))
    
    var player:AVAudioPlayer?

    override func viewDidLoad() {

        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let bgImageView = UIImageView(image: UIImage(named: darkMode ? "darkbg" : "lightbg"))
        bgImageView.alpha = 1

        for subview in self.view.subviews {
            if subview is UILabel {
                (subview as UILabel).textColor = darkMode ? UIColor.whiteColor() : UIColor.blackColor()
            } else if subview is UITextView {
                (subview as UITextView).textColor = darkMode ? UIColor.whiteColor() : UIColor.blackColor()
            }
        }

        self.view.insertSubview(bgImageView, atIndex: 0)

        // Do any additional setup after loading the view.
        // init backgound music
        let soundFileURL = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("music",ofType:"mp3")!)
        player = AVAudioPlayer(contentsOfURL:soundFileURL,error:nil)
        player!.numberOfLoops = -1; //infinite

        menuButton.clipsToBounds = true
         menuButton.setTitleColor(darkMode ? UIColor.lightTextColor() : UIColor.darkTextColor(), forState: .Normal)
        shareButton.setTitleColor(darkMode ? UIColor.lightTextColor() : UIColor.darkTextColor(), forState: .Normal)
        menuButton.titleLabel?.font = UIFont(name: kFontIcon, size: 30)
        shareButton.titleLabel?.font = UIFont(name: kFontIcon, size: 30)
        
        var butterFlyImages = NSMutableArray()
        let butterFlyIndex = rand()%3+1
        for i:Int in 1...20 {
            let butterImageName:NSString = NSString(format:"FallButterfly%d_%02d",butterFlyIndex,i)
            let butterImage:UIImage? = UIImage(named:butterImageName)
            if butterImage != nil {
                butterFlyImages.addObject(butterImage!)
            }
        }
        butterFly.animationImages = butterFlyImages
        //butterFly.center = CGPointMake(CGFloat(10), CGFloat(rand()%480))
        self.view.addSubview(butterFly)
        butterFly.startAnimating()
        self.initButterFlyAnimation(Int(butterFlyIndex))
        
        // init contents
        self.authorLabel.font = UIFont(name:kFontSong, size:16)
        self.contentView.font = UIFont(name:kFontKai, size: (isBigFont ? 26 : 20))
        self.titleLabel.font = UIFont(name:kFontSong, size: 28)
        //self.descLabel.font = UIFont(name:kFontSong, size:16)
        self.descView.font = UIFont(name:kFontKai, size:14)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.addParallaxEffect(self.titleLabel, depth: 15)
        self.addParallaxEffect(self.authorLabel, depth: 15)
        self.addParallaxEffect(self.contentView, depth: 15)
        self.addParallaxEffect(self.descView, depth: 15)
        //self.addParallaxEffect(self.descLabel, depth: 15)
        
        poemEntity = PoemEntity.getPoemByIndex((poemDic!["index"] as String).toInt()!)
        self.titleLabel.text = poemEntity?.title
        self.authorLabel.text = poemEntity?.author
        if poemEntity?.type == 1 {
            self.contentView.textAlignment = .Left
        }
        
        let contentStr:NSString = PoemEntity.formatContent(poemEntity!.content) as NSString
        self.contentView.text = contentStr
        self.descView.text = poemDic!["desc"] as String
        
        if self.parentViewController is UINavigationController {
            self.navigationController?.interactivePopGestureRecognizer.delegate = nil
        }
    }
    
    func initButterFlyAnimation(type:Int) {
        var starPoint = CGPointFromString("{10,\(rand()%100+340)}")
        var endPoint = CGPointMake(250, 82)
        switch type {
        case 1: // left to right
            starPoint = CGPointFromString("{10,\(rand()%100+340)}")
            endPoint = CGPointMake(260, 120)
        case 2:
            starPoint = CGPointFromString("{320,\(rand()%100+340)}")
            endPoint = CGPointMake(120, 40)
        case 3:
            starPoint = CGPointFromString("{320,\(rand()%100+340)}")
            endPoint = CGPointMake(70, 290)
        default:
            println()
        }

        let pathAnimation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath:"position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        let curvedPath:CGMutablePath = CGPathCreateMutable()
        CGPathMoveToPoint(curvedPath, nil, starPoint.x, starPoint.y)
        CGPathAddCurveToPoint(curvedPath, nil, endPoint.x, starPoint.y, endPoint.x, starPoint.y, endPoint.x, endPoint.y)
        pathAnimation.path = curvedPath
        pathAnimation.duration = 6
        butterFly.layer.addAnimation(pathAnimation, forKey:"savingAnimation")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        //navHidden = self.navigationController.navigationBarHidden
        self.navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !bgMusicOff {
            player!.play()
        }
        //createMenuButton()
        favItem = getFavItem(poemEntity!.rowid)
    }
    
    override func viewDidDisappear(animated: Bool)  {
        super.viewDidDisappear(animated)
        synthesizer.stopSpeakingAtBoundary(.Word)
    }

    override func prefersStatusBarHidden()->Bool {
        return true;
    }
    
    deinit {
        if !bgMusicOff {
            player!.stop()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        let txtview = object as UITextView
        var topoffset =  (txtview.bounds.size.height - txtview.contentSize.height * txtview.zoomScale)/2.0;
        topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
        txtview.contentOffset = CGPointMake(0, -topoffset)
    }
    
    func getFavItem(idx:Int) -> FavItem? {
        let request = NSFetchRequest(entityName:"FavItem")
        let predicate = NSPredicate(format:"index == \(idx)")
        request.predicate = predicate
        request.fetchLimit = 1
        let context = favManagedDoc.managedObjectContext
        let favItems = context.executeFetchRequest(request, error: nil) as Array<FavItem>
        if favItems.count > 0 {
            menuButton.setTitleColor(UIColor.redColor(),forState:.Normal)
            return favItems[0]
        }
        return nil
    }
    
    func createMenuButton() {
        
        let pt:CGPoint = menuButton.center
        for i:Int in 1...5 {
            let menuButton = UIButton(frame:CGRectMake(0,0,36,36))
            menuButton.center = pt
            menuButton.layer.cornerRadius = 18
            menuButton.alpha = 0
            menuButton.tag = 100 + i
            
            let color = favColorDic!.allValues[9-i] as Int
            menuButton.setBackgroundImage(UIImage.colorImage(UIColorFromRGB(color), rect:menuButton.bounds), forState:.Normal)
            menuButton.clipsToBounds = true
            switch i {
            case 1:
                menuButton.setTitle("L", forState:.Normal)
            case 2:
                menuButton.setTitle("S", forState:.Normal)
            case 3:
                menuButton.setTitle("T", forState:.Normal)
            case 4:
                menuButton.setTitle("H", forState:.Normal)
            case 5:
                menuButton.setTitle("P", forState:.Normal)
            default:
                println()
            }
            menuButton.titleLabel?.font = UIFont(name: kFontIcon, size: 28)
            menuButton.addTarget(self, action: "onClick:", forControlEvents:.TouchUpInside)
            self.view.insertSubview(menuButton, belowSubview:self.menuButton)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender : AnyObject) {
        if self.parentViewController is UINavigationController {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.parentViewController?.navigationController?.popViewControllerAnimated(true)
        }
    }

    @IBAction func shareBtnClicked(sender: AnyObject) {
        let myActionSheet:UIActionSheet = UIActionSheet()
        myActionSheet.title  = "分享"
        myActionSheet.delegate = self
        myActionSheet.addButtonWithTitle("分享到微博")
        myActionSheet.addButtonWithTitle("分享给微信好友")
        myActionSheet.addButtonWithTitle("分享到微信朋友圈")
        myActionSheet.addButtonWithTitle("取消")
        myActionSheet.cancelButtonIndex = 3
        myActionSheet.showInView(self.view)
    }
    
    @IBAction func touchMenuDown(sender : UIButton) {
        let addFavVC = self.storyboard?.instantiateViewControllerWithIdentifier("addfavvc") as AddFavViewController
        addFavVC.poemEntity = poemEntity
        addFavVC.favItem = favItem
        self.presentViewController(addFavVC, animated:true, completion:nil)
    }
    
    func onClick(sender:UIButton)->Void {
        switch sender.tag {
        case 101:
            println()
        case 102:
            let myActionSheet:UIActionSheet = UIActionSheet()
            myActionSheet.title  = "分享"
            myActionSheet.delegate = self
            myActionSheet.addButtonWithTitle("分享到微博")
            myActionSheet.addButtonWithTitle("分享给微信好友")
            myActionSheet.addButtonWithTitle("分享到微信朋友圈")
            myActionSheet.addButtonWithTitle("取消")
            myActionSheet.cancelButtonIndex = 3
            myActionSheet.showInView(self.view)
        case 103:
            
            let addFavVC = self.storyboard?.instantiateViewControllerWithIdentifier("addfavvc") as AddFavViewController
            addFavVC.poemEntity = poemEntity
            addFavVC.favItem = favItem
            self.presentViewController(addFavVC, animated:true, completion:nil)
            
        case 105:
            if sender.titleForState(.Normal) == "P" {
                sender.setTitle("Q", forState:.Normal)
                if !synthesizer.paused {
                    readContent()
                } else {
                    synthesizer.continueSpeaking()
                }
            } else {
                sender.setTitle("P", forState:.Normal)
                synthesizer.pauseSpeakingAtBoundary(.Word)
            }
        default:
            NSLog("do nothing")
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        
        switch buttonIndex {
        case 0:
            sendContentToWeibo()
        case 1:
            sendContentToWechat(false)
        case 2:
            sendContentToWechat(true)
        default:
            println("xx")
        }
    }
    
    func sendContentToWechat(circle:Bool) {
        
        let message:WXMediaMessage = WXMediaMessage()
        message.title = poemEntity!.title
        message.description = poemEntity!.content
        let ext:WXAppExtendObject = WXAppExtendObject()
        ext.extInfo = "<xml>test</xml>"
        ext.url = "http://www.baidu.com"
        message.mediaObject = ext
        let req:SendMessageToWXReq = SendMessageToWXReq()
        req.bText = true
        req.text = poemEntity!.title + "\n" + poemEntity!.content;
        if circle {
            req.scene = 1
        } else {
            req.scene = 0
        }
        WXApi.sendReq(req)
    }
    
    func sendContentToWeibo() {
        let message:WBMessageObject = WBMessageObject()
        message.text = poemEntity!.title + "\n" + poemEntity!.content
        let imageObject:WBImageObject = WBImageObject()
//        imageObject.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tt1" ofType:@"png"]];
//        message.imageObject = imageObject;
        let request = WBSendMessageToWeiboRequest()
        request.message = message
        request.userInfo = ["ShareMessageFrom": "SXViewController"]
        WeiboSDK.sendRequest(request);
    }
    
    func readContent() {
        var readContent:String = ""
        readContent = poemEntity!.content
        let utterance:AVSpeechUtterance =  AVSpeechUtterance(string:readContent)
        utterance.voice = AVSpeechSynthesisVoice(language:"zh_CN")
        utterance.rate = 0.01;
        synthesizer.speakUtterance(utterance)
    }
    
    func addParallaxEffect(view:UIView, depth:CGFloat) {
        let effectX:UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath:"center.x", type:.TiltAlongHorizontalAxis)
        var effectY:UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath:"center.y", type:.TiltAlongVerticalAxis)
        effectX.maximumRelativeValue = depth
        effectX.minimumRelativeValue = -depth
        effectY.maximumRelativeValue = depth
        effectY.minimumRelativeValue = -depth
        view.addMotionEffect(effectX)
        view.addMotionEffect(effectY)
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
