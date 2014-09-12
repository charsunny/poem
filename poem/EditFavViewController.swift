//
//  EditFavViewController.swift
//  poem
//
//  Created by Sun Xi on 6/18/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit
import CoreData

protocol EditFavViewControllerDelegate {
    func finishEditFavFolder(folder:FavFolder, _ isAdd:Bool)->Void
}

class EditFavViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var selectedSel = 0
    
    var delegate:EditFavViewControllerDelegate?
    
    var favIndex:Int = 0
    
    var favFolder:FavFolder?
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var titleField: UITextField!
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.barStyle = darkMode ? .Black : .Default
        titleField.becomeFirstResponder()
        let spLine = UIView(frame: CGRectMake(20, 106, 280, 0.5))
        spLine.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(spLine)
        titleField.clearButtonMode = .WhileEditing
        if favFolder != nil {
            self.navigationBar?.topItem?.title = "编辑收藏夹"
            titleField.text = favFolder!.name
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func positionForBar(pos:UIBarPositioning)->UIBarPosition {
        return .TopAttached
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func confirmVC(sender: AnyObject) {
        if titleField.text.isEmpty {
            return
        }
        var isAdd = false
        if favFolder == nil {
            isAdd = true
            favFolder = NSEntityDescription.insertNewObjectForEntityForName("FavFolder", inManagedObjectContext: favManagedDoc.managedObjectContext) as? FavFolder
            favFolder!.name = titleField.text
            favFolder!.index = favIndex
            favFolder!.color = selectedSel
        } else {
            favFolder!.color = selectedSel
            favFolder!.name = titleField.text
        }
        FavManager.sharedFavManager.favDocReady()
        self.delegate?.finishEditFavFolder(self.favFolder!, isAdd)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell
        let color:Int = favColorDic.allValues[indexPath.row] as Int
        let bgColor = UIColorFromRGB(color)
        cell.backgroundColor = bgColor
        if indexPath.row == selectedSel {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.redColor().CGColor
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        selectedSel = indexPath.row
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
