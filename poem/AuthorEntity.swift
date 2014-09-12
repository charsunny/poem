//
//  AuthorEntity.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

class AuthorEntity {
    
    var rowid:Int = 0
    var name:String = ""
    var desc:String = ""
    var icon:String = ""
    
    init(let row:EGODatabaseRow) {
        self.rowid = row.stringForColumn("rowid").toInt()!
        self.name = row.stringForColumn("name")
        self.desc = row.stringForColumn("desc")
    }
    
    class func getAllAuthor()->NSDictionary {
        
       var authorMap:NSMutableDictionary = NSMutableDictionary()
        
        let query = "SELECT rowid, * FROM author"
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count = result?.count() {
            for idx in 0..<count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:AuthorEntity = AuthorEntity(row:poemRow!)
                let char:String = poemEntity.name[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if (authorMap[key] == nil) {
                    var value:NSMutableArray = NSMutableArray()
                    value.addObject(poemEntity)
                    authorMap[key] = value
                } else {
                    let value = authorMap[key] as NSMutableArray
                    //var value:NSMutableArray = NSMutableArray(array:orginValue)
                    value.addObject(poemEntity)
                    authorMap[key] = value
                }
            }
        }
        return authorMap;
    }
}
