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

class MoreTableViewController: UITableViewController,MFMailComposeViewControllerDelegate ,SKStoreProductViewControllerDelegate{

    @IBOutlet var fontNameCell: UITableViewCell

    @IBOutlet var fontSizeCell: UITableViewCell

    @IBOutlet var NotifCell: UITableViewCell
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let nameSwitch:UISwitch = UISwitch()
        nameSwitch.center = CGPointMake(280, 22)
        fontNameCell.contentView.addSubview(nameSwitch)
        
        let sizeSwitch:UISwitch = UISwitch()
        sizeSwitch.center = CGPointMake(280, 22)
        fontSizeCell.contentView.addSubview(sizeSwitch)
        
        let notifSwitch:UISwitch = UISwitch()
        notifSwitch.setOn(true, animated: false)
        notifSwitch.center = CGPointMake(280, 22)
        NotifCell.contentView.addSubview(notifSwitch)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                println("xx")
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
        controller.dismissModalViewControllerAnimated(true)
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        viewController.dismissModalViewControllerAnimated(true)
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
