//
//  AddFavViewController.swift
//  poem
//
//  Created by Sun Xi on 6/20/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

class AddFavViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, EditFavViewControllerDelegate {
    
    var poemEntity:PoemEntity?
    
    var favFolder:FavFolder?
    
    var favItem:FavItem?

    @IBOutlet var navigationBar: UINavigationBar
    
    @IBOutlet var titleLabel: UILabel
    
    @IBOutlet var authorLabel: UILabel
    
    @IBOutlet var descField: UITextField
    
    @IBOutlet var collectionView: UICollectionView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = poemEntity?.title
        titleLabel.font = UIFont(name: kFontSong, size: 18)
        
        let color = favColorDic.allValues[abs(poemEntity!.author.hashValue)%9] as Int
        authorLabel.backgroundColor = UIColorFromRGB(color)
        authorLabel.layer.cornerRadius = 5
        authorLabel.text = poemEntity?.author
        authorLabel.font = UIFont(name: kFontSong, size: 20)
        
        descField.becomeFirstResponder()
        let spLine = UIView(frame: CGRectMake(0, 148, 320, 0.5))
        spLine.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(spLine)
        descField.clearButtonMode = .WhileEditing
        
        if favItem == nil {
            if favFolder == nil && favFolders.count > 0{
                favFolder = favFolders[0]
            }
        } else {
            favFolder = favItem!.folder
            descField.text = favItem!.desc
            self.navigationBar.topItem.title = "编辑归档"
        }
    }

    func positionForBar(pos:UIBarPositioning)->UIBarPosition {
        return .TopAttached
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        descField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        self.dismissModalViewControllerAnimated(true)
    }
    
    @IBAction func confirmVC(sender: AnyObject) {
        if favItem == nil {
            favItem = NSEntityDescription.insertNewObjectForEntityForName("FavItem", inManagedObjectContext: favManagedDoc.managedObjectContext) as? FavItem
            NSNotificationCenter.defaultCenter().postNotificationName("addfav", object: nil)
        }
        favItem!.type = poemEntity?.type
        favItem!.title = poemEntity?.title
        favItem!.time = NSDate()
        favItem!.desc = descField.text
        favItem!.folder = favFolder
        favItem!.index = poemEntity?.rowid
        favItem!.author = poemEntity?.author
        self.dismissModalViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView?, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return favFolders.count + 1
    }
    
    func collectionView(collectionView: UICollectionView?, cellForItemAtIndexPath indexPath: NSIndexPath?) -> UICollectionViewCell? {
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as SXCollectionViewCell
        // Configure the cell
        if indexPath!.row == favFolders.count {
            let color:Int = favColorDic.allValues[8] as Int
            let bgColor = UIColorFromRGB(color)
            cell.backgroundColor = bgColor
            cell.titleLabel.font = UIFont(name: kFontIcon, size: 48)
            cell.titleLabel.text = "N"
            return cell
        }
        
        let favItem = favFolders[indexPath!.row]
        cell.titleLabel.font = UIFont(name: kFontSong, size: 22)
        cell.titleLabel.text = favItem.name
        let color:Int = favColorDic.allValues[favItem.color.integerValue] as Int
        let bgColor = UIColorFromRGB(color)
        cell.backgroundColor = bgColor
        
        if favItem === favFolder {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.redColor().CGColor
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        if indexPath!.row == favFolders.count {
            let addFavFolderVC = self.storyboard.instantiateViewControllerWithIdentifier("editfavvc") as EditFavViewController
            addFavFolderVC.delegate = self
            addFavFolderVC.favIndex = favFolders.count
            self.presentViewController(addFavFolderVC, animated: true, completion: nil)
            
        } else {
            favFolder = favFolders[indexPath.row]
            collectionView.reloadData()
        }
    }
    
    func finishEditFavFolder(folder:FavFolder, _ isAdd:Bool)->Void {
        collectionView.reloadData()
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
