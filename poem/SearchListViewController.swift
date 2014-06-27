//
//  SearchListViewController.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

class SearchListViewController: UITableViewController,UITableViewDelegate, UITableViewDataSource {
    
    var isSong:Bool = false
    
    var showLoadingText:String?
    
    var titleText:String = "返回"
    
    var loadFinish:Bool = false

    @IBOutlet var searchBar : UISearchBar

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = isSong ? "词牌" : "诗人"
        
        let spLine:UIView = UIView(frame: CGRectMake(0, 43.5, 320, 0.5))
        spLine.backgroundColor = UIColor.lightGrayColor()
        searchBar.addSubview(spLine)
        
        let footView:UIView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
        tableView.contentOffset = CGPointMake(0,44)
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        let textView:UITextView = UITextView(frame: CGRectMake(0, 0, 100, 300))
        textView.center = self.view.center
        textView.font = UIFont(name: kFontSong, size: 36)
        textView.textAlignment = .Center
        textView.editable = false
        textView.selectable =  false
        textView.text = showLoadingText
        self.view.addSubview(textView)
        
        self.view.userInteractionEnabled = false
        
        dispatch_async(dispatch_get_global_queue(0, 0), {()->Void in
            if !self.isSong {
                AuthorEntity.getAllAuthor()
            } else {
                SongNameEntity.getAllName()
            }
            dispatch_async(dispatch_get_main_queue(), {[weak self] ()->Void in
                UIView.animateWithDuration(1, animations: {() -> Void in
                    textView.alpha = 0
                    //textView.transform = CGAffineTransformMakeScale(2, 2)
                    //textView.transform = CGAffineTransformMakeRotation(Float(2*M_PI))
                    }, completion: {(finish:Bool)->Void in
                        if self == nil {
                            return
                        }
                        self!.loadFinish = true
                        self!.view.userInteractionEnabled = true
                        self?.tableView.reloadData()
                        self!.navigationController.setNavigationBarHidden(false, animated: false);
                    })
                })
            })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        if !loadFinish {
            return 0
        }
        if isSong {
            return SongNameEntity.songNameMap.count
        } else {
            return AuthorEntity.authorMap.count
        }
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        if isSong {
            let keys:Array<String> = Array(SongNameEntity.songNameMap.keys)
            return keys[section]
        } else {
            let keys:Array<String> = Array(AuthorEntity.authorMap.keys)
            return keys[section]
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView!) -> AnyObject[]! {
        if !loadFinish {
            return nil
        }
        if isSong {
            let keys = SongNameEntity.songNameMap.keys
            return  Array(keys)
        } else {
            return Array(AuthorEntity.authorMap.keys)
        }
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return 0;
        }
        if isSong {
            let key:String = Array(SongNameEntity.songNameMap.keys)[section]
            let songSection = SongNameEntity.songNameMap[key]
            return songSection!.count
        } else {
            let key:String = Array(AuthorEntity.authorMap.keys)[section]
            let author = AuthorEntity.authorMap[key]
            return author!.count
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return nil;
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.font = UIFont(name: kFontSong, size: 20)
        cell.detailTextLabel.font = UIFont(name: kFontKai, size: 14)
        if isSong {
            let key:String = Array(SongNameEntity.songNameMap.keys)[indexPath.section]
            let songSection = SongNameEntity.songNameMap[key]
            let songName:SongNameEntity = songSection![indexPath.row]
            
            let color = favColorDic.allValues[abs(songName.name.hashValue)%9] as Int
            cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,50,50))
            if let label = cell.imageView.viewWithTag(1) as? UILabel {
                label.text = songName.name
            } else {
                let label:UILabel = UILabel(frame:CGRectMake(5,5,40,40))
                label.text = songName.name
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.tag = 1
                label.font = UIFont(name: kFontSong, size: 18)
                cell.imageView.addSubview(label)
            }
            
            cell.textLabel.text = songName.name
            cell.detailTextLabel.text = songName.info
        } else {
            let key:String = Array(AuthorEntity.authorMap.keys)[indexPath.section]
            let authorSection = AuthorEntity.authorMap[key]
            let author:AuthorEntity = authorSection![indexPath.row]
            
            let color = favColorDic.allValues[abs(author.name.hashValue)%9] as Int
            cell.imageView.image = UIImage.colorImage(UIColorFromRGB(color), rect:CGRectMake(0,0,50,50))
            if let label = cell.imageView.viewWithTag(1) as? UILabel {
                label.text = author.name
            } else {
                let label:UILabel = UILabel(frame:CGRectMake(5,5,40,40))
                label.text = author.name
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.tag = 1
                label.font = UIFont(name: kFontSong, size: 18)
                cell.imageView.addSubview(label)
            }
            
            cell.textLabel.text = author.name
            cell.detailTextLabel.text = author.desc
        }
        return cell
    }
    
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let searchDetailVC:SearchDetailViewController = segue?.destinationViewController as? SearchDetailViewController {
            if let cell:UITableViewCell = sender as? UITableViewCell {
                searchDetailVC.isSong = isSong
                searchDetailVC.keyword = cell.textLabel.text
                if isSong {
                    let key:String = Array(SongNameEntity.songNameMap.keys)[tableView.indexPathForCell(cell).section]
                    let songSection = SongNameEntity.songNameMap[key]
                    let songName:SongNameEntity = songSection![tableView.indexPathForCell(cell).row]
                    searchDetailVC.songNameEntity = songName
                } else {
                    let key:String = Array(AuthorEntity.authorMap.keys)[tableView.indexPathForCell(cell).section]
                    let authorSection = AuthorEntity.authorMap[key]
                    let author:AuthorEntity = authorSection![tableView.indexPathForCell(cell).row]
                    searchDetailVC.authorEntity = author
                }
            }
        }
    }

}