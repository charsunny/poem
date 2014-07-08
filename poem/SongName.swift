//
//  AuthorEntity.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

class SongNameEntity {
    
    var rowid:Int = 0
    var name:String = ""
    var info:String = ""
    var desc:String = ""
    var icon:String = ""
    
    init(let row:EGODatabaseRow) {
        self.name = row.stringForColumn("name")
        self.info = row.stringForColumn("info")
        self.desc = row.stringForColumn("desc")
    }
    
    class func getAllName()->NSDictionary  {
        
        var songNameMap:NSMutableDictionary = NSMutableDictionary()
        
        let query:String = String("SELECT * FROM songname")
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase

        if let count:Int = result?.count() {
            for idx in 0..<count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:SongNameEntity = SongNameEntity(row:poemRow!)
                let char:String = poemEntity.name[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if !songNameMap[key] {
                    var value:NSMutableArray = NSMutableArray()
                    value.addObject(poemEntity)
                    songNameMap[key] = value
                } else {
                    let value = songNameMap[key] as NSMutableArray
                    //var value:NSMutableArray = NSMutableArray(array:orginValue)
                    value.addObject(poemEntity)
                    songNameMap[key] = value
                }
            }
        }

        return songNameMap;
    }
}
