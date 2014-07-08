//
//  MoreTableViewController.swift
//  poem
//
//  Created by Sun Xi on 6/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class MoreTableViewController: UITableViewController,MFMailComposeViewControllerDelegate ,SKStoreProductViewControllerDelegate,
    UIActionSheetDelegate {

    @IBOutlet var fontNameCell: UITableViewCell

    @IBOutlet var fontSizeCell: UITableViewCell

    @IBOutlet var NotifCell: UITableViewCell
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let nameSwitch:UISwitch = UISwitch()
        nameSwitch.center = CGPointMake(280, 22)
        nameSwitch.tag = 1
        nameSwitch.on = isTraditionalChar
        nameSwitch.addTarget(self, action: "valueDidChanged:", forControlEvents: .ValueChanged)
        fontNameCell.contentView.addSubview(nameSwitch)
        
        let sizeSwitch:UISwitch = UISwitch()
        sizeSwitch.center = CGPointMake(280, 22)
        sizeSwitch.on = isBigFont
        sizeSwitch.tag = 2
        sizeSwitch.addTarget(self, action: "valueDidChanged:", forControlEvents: .ValueChanged)
        fontSizeCell.contentView.addSubview(sizeSwitch)
        
        let notifSwitch:UISwitch = UISwitch()
        notifSwitch.tag = 3
        notifSwitch.on = !bgMusicOff
        notifSwitch.center = CGPointMake(280, 22)
        notifSwitch.addTarget(self, action: "valueDidChanged:", forControlEvents: .ValueChanged)
        NotifCell.contentView.addSubview(notifSwitch)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func valueDidChanged(swtch:UISwitch) -> Void {
        switch swtch.tag {
        case 1:
            isTraditionalChar = swtch.on
            kFontSong = isTraditionalChar ? fontFSong : fontSong
            kFontKai = isTraditionalChar ? fontFKai : fontKai
            NSUserDefaults.standardUserDefaults().setBool(swtch.on, forKey: "tradchar")
            NSNotificationCenter.defaultCenter().postNotificationName("tradchar", object: nil)
        case 2:
            isBigFont = swtch.on
            NSUserDefaults.standardUserDefaults().setBool(swtch.on, forKey: "bigfont")
        case 3:
            bgMusicOff = !swtch.on
            NSUserDefaults.standardUserDefaults().setBool(swtch.on, forKey: "musicoff")
        default:
            println()
        }
    }
    
    override func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                let mailVC:MFMailComposeViewController = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setToRecipients(["charsunny@gmail.com"])
                mailVC.setSubject("应用问题反馈")
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailVC, animated: true, completion: nil)
                }
            case 1:
                let storeVC:SKStoreProductViewController = SKStoreProductViewController()
                storeVC.delegate = self
                storeVC.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier : "870428896"], completionBlock : {(result:Bool, error:NSError?) -> Void in
                    })
                self.presentViewController(storeVC, animated: true, completion: nil)
            default:
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
        case 2:
            switch indexPath.row {
            case 0:
                println("bug report")
            case 1:
                println("xxx report")
            default:
                println("xx")
            }
        default:
            println("xx")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
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
        message.title = "一款有品质的应用"
        message.description = "唐诗宋词"
        let ext:WXAppExtendObject = WXAppExtendObject()
        ext.url = "https://itunes.apple.com/cn/app/tap-tap-num/id870428896?l=en&mt=8"
        message.mediaObject = ext
        let req:SendMessageToWXReq = SendMessageToWXReq()
        req.bText = false
        req.message = message
        if circle {
            req.scene = 1
        } else {
            req.scene = 0
        }
        WXApi.sendReq(req)
    }
    
    func sendContentToWeibo() {
        let message:WBMessageObject = WBMessageObject()
        message.text = "一款有品质的应用,哈哈,https://itunes.apple.com/cn/app/tap-tap-num/id870428896?l=en&mt=8"
        let imageObject:WBImageObject = WBImageObject()
        //        imageObject.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tt1" ofType:@"png"]];
        //        message.imageObject = imageObject;
        let request = WBSendMessageToWeiboRequest()
        request.message = message
        request.userInfo = ["ShareMessageFrom": "SXViewController"]
        WeiboSDK.sendRequest(request);
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
