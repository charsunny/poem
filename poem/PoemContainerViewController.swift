//
//  PoemContainerViewController.swift
//  poem
//
//  Created by Sun Xi on 6/14/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class PoemContainerViewController: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    
    var type:Int = 0
    
    var pageViewController:UIPageViewController?
    
    var poems:Array<PoemEntity> = []
    
    var curIdx:Int = 0
    
    var showLoadingText:String?
    
    var titleText:String = "返回"
    
    var player:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let soundFileURL = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("bg",ofType:"mp3"))
        player = AVAudioPlayer(contentsOfURL:soundFileURL,error:nil)
        player!.volume = 0.5
        player!.numberOfLoops = -1; //infinite
        if showLoadingText == nil {
            initPageVC()
        } else {
            let textView:UITextView = UITextView(frame: CGRectMake(0, 0, 100, 300))
            textView.center = self.view.center
            textView.font = UIFont(name: kFontSong, size: 36)
            textView.textAlignment = .Center
            textView.editable = false
            textView.selectable = false
            textView.text = showLoadingText
            self.view.addSubview(textView)
            dispatch_async(dispatch_get_global_queue(0, 0), {()->Void in
                self.poems = PoemEntity.genRandomPoem(count: 100, type:self.type)
                dispatch_async(dispatch_get_main_queue(), { ()->Void in
                    UIView.animateWithDuration(1, animations: {() -> Void in
                        textView.alpha = 0
                        //textView.transform = CGAffineTransformMakeScale(2, 2)
                        //textView.transform = CGAffineTransformMakeRotation(Float(2*M_PI))
                        }, completion: {(finish:Bool)->Void in
                        self.initPageVC()
                    })
                })
            })
        }
        self.navigationController.interactivePopGestureRecognizer.delegate = nil
    }
    
    func initPageVC() -> Void {
        self.pageViewController = UIPageViewController(transitionStyle:.Scroll, navigationOrientation: .Vertical, options: nil)
        if let contentVC:RandomContentViewController = contentVCAtIndex(curIdx) {
            self.pageViewController?.setViewControllers([contentVC], direction:.Forward, animated: false, completion: nil)
        }
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController!.view)
        //self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController.setNavigationBarHidden(true, animated: false);
        player!.play()
    }
    
    deinit {
        player!.stop()
    }
    
    func contentVCAtIndex(index:Int) -> RandomContentViewController? {
        
        if poems.count == 0 {
            return nil
        }
        
        let contentVC:RandomContentViewController = self.storyboard.instantiateViewControllerWithIdentifier("rdcontentvc") as RandomContentViewController
        contentVC.pageNum = index + 1
        let poem:PoemEntity = poems[index]
        contentVC.poemEntity = poem
        return contentVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
        let currentViewController = self.pageViewController!.viewControllers[0] as UIViewController
        let viewControllers: NSArray = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
        
        self.pageViewController!.doubleSided = false
        return .Min
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerBeforeViewController viewController: UIViewController!) -> UIViewController! {
        if curIdx == 0 {
            return nil
        }
        curIdx--
        return self.contentVCAtIndex(curIdx)
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerAfterViewController viewController: UIViewController!) -> UIViewController! {
        
        if curIdx == (poems.count-1) {
            return nil
        }
        curIdx++
        return self.contentVCAtIndex(curIdx)
    }
}
