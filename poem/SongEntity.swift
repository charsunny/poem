//
//  SongEntity.swift
//  poem
//
//  Created by Sun Xi on 6/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

struct SongEntity {
    var rowid:Int = 0
    var song:String = ""
    var title:String = ""
    var content:String = ""
    //    {
    //    set {
    //       var str:NSString = newValue
    //        str = str.stringByReplacingOccurrencesOfString(" ", withString:"", options: .LiteralSearch, range: NSMakeRange(0, str.length));
    //        str = str.stringByReplacingOccurrencesOfString(" ", withString:"", options: .LiteralSearch, range: NSMakeRange(0, str.length));
    //        str = str.stringByReplacingOccurrencesOfString("？", withString:"？\n", options: .LiteralSearch, range: NSMakeRange(0, str.length));
    //        str = str.stringByReplacingOccurrencesOfString("；", withString:"；\n", options: .LiteralSearch, range: NSMakeRange(0, str.length));
    //        str = str.stringByReplacingOccurrencesOfString("。", withString:"。\n", options: .LiteralSearch, range: NSMakeRange(0, str.length));
    //        self.content = str;
    //    }
    //    get {
    //        return self.content
    //    }
    //    }
    var author:String = ""
    
    init(let row:EGODatabaseRow) {
        self.rowid = row.stringForColumn("rowid").toInt()!
        self.title = row.stringForColumn("title")
        self.song = row.stringForColumn("song")
        self.content = row.stringForColumn("content")
        self.author = row.stringForColumn("author")
    }
    
    static func genRandomSong(var count:Int = 10)->Array<SongEntity> {
        
        var songs:Array<SongEntity> = Array<SongEntity>()
        
        let query:String = String("SELECT rowid, * FROM song ORDER BY RANDOM() LIMIT \(count)")
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let songRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let songEntity:SongEntity = SongEntity(row:songRow!)
                songs.append(songEntity)
            }
        }
        return songs;
    }
    
    static func getSongByName(var name:String) -> Dictionary<String, Array<SongEntity>> {
        
        var poemMap:Dictionary<String, Array<SongEntity>> = Dictionary<String, Array<SongEntity>>()
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase
        
        let query:String = "SELECT rowid, * FROM song WHERE song like '%%\(name)%%'"
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:SongEntity = SongEntity(row:poemRow!)
                let char:String = poemEntity.author[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if poemMap[key] == nil {
                    var value:Array<SongEntity> = []
                    value.append(poemEntity)
                    poemMap[key] = value
                } else {
                    var value:Array<SongEntity> = poemMap[key]!
                    value.append(poemEntity)
                    poemMap[key] = value
                }
            }
        }
        return poemMap;
    }
}
