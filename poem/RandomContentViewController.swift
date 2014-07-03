//
//  RandomContentViewController.swift
//  poem
//
//  Created by Sun Xi on 6/26/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class RandomContentViewController: UIViewController,UIActionSheetDelegate {
    
    var poemEntity:PoemEntity?
    
    var pageNum:Int = 0
    
    var favItem:FavItem?
    
    @lazy var synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet var titleLabel:UILabel
    
    @IBOutlet var authorLabel:UILabel
    
    @IBOutlet var contentView:UITextView
    
    @IBOutlet var backgroundImageView:UIImageView
    
    @IBOutlet var menuButton : UIButton
    
    @IBOutlet var shareButton: UIButton
    
    //@IBOutlet var backButton : UIButton
    
    @lazy var butterFly:UIImageView = UIImageView(frame:CGRectMake(0,0,30,30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        menuButton.clipsToBounds = true
        menuButton.titleLabel.font = UIFont(name: kFontIcon, size: 30)
        //backButton.titleLabel.font = UIFont(name: kFontIcon, size: 30)
        shareButton.titleLabel.font = UIFont(name: kFontIcon, size: 30)
        
        var images:NSMutableArray = NSMutableArray()
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
        butterFly.center = CGPointMake(10,CGFloat(rand()%480))
        self.view.addSubview(butterFly)
        butterFly.startAnimating()
        self.initButterFlyAnimation(Int(butterFlyIndex))
        
        // init contents
        self.authorLabel.font = UIFont(name:kFontSong, size:16)
        self.contentView.font = UIFont(name:kFontKai, size:(isBigFont ? 26 : 20))
        self.titleLabel.font = UIFont(name:kFontSong, size: 28)
        self.titleLabel.adjustsLetterSpacingToFitWidth = true
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.text = poemEntity?.title
        self.authorLabel.text = poemEntity?.author
        if poemEntity?.type == 1 {
            self.contentView.textAlignment = .Left
        }
        self.contentView.text = PoemEntity.formatContent(poemEntity!.content)
        self.addParallaxEffect(self.titleLabel, depth: 15)
        self.addParallaxEffect(self.authorLabel, depth: 15)
        self.addParallaxEffect(self.contentView, depth: 15)
    
        if self.parentViewController is UINavigationController {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil
        }
    }
    
    func initButterFlyAnimation(type:Int) {
        var starPoint = CGPointMake(10,CGFloat(rand()%100+340))
        var endPoint = CGPointMake(250, 82)
        switch type {
        case 1: // left to right
            starPoint = CGPointMake(10,CGFloat(rand()%100+340))
            endPoint = CGPointMake(260, 160)
        case 2:
            starPoint = CGPointMake(320,CGFloat(rand()%100+340))
            endPoint = CGPointMake(70, 120)
        case 3:
            starPoint = CGPointMake(320,CGFloat(rand()%80+400))
            endPoint = CGPointMake(53, 250)
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
        //createMenuButton()
        favItem = getFavItem(poemEntity!.rowid)
    }
    
    override func viewDidDisappear(animated: Bool)  {
        //        self.contentView.removeObserver(self , forKeyPath:"contentSize");
        super.viewDidDisappear(animated)
        synthesizer.stopSpeakingAtBoundary(.Word)
    }
    
    override func observeValueForKeyPath(keyPath: String!,
        ofObject object: AnyObject!,
        change: NSDictionary!,
        context: CMutableVoidPointer) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender : AnyObject) {
        if self.parentViewController is UINavigationController {
            self.navigationController.popViewControllerAnimated(true)
        } else {
            self.parentViewController.navigationController.popViewControllerAnimated(true)
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
        let addFavVC = self.storyboard.instantiateViewControllerWithIdentifier("addfavvc") as AddFavViewController
        addFavVC.poemEntity = poemEntity
        addFavVC.favItem = favItem
        self.presentViewController(addFavVC, animated:true, completion:nil)
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
        req.bText = false;
        req.message = message;
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

