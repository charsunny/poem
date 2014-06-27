//
//  AuthorEntity.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

struct AuthorEntity {
    
    var rowid:Int = 0
    var name:String = ""
    var desc:String = ""
    var icon:String = ""
    
    static var authorMap:Dictionary<String, Array<AuthorEntity>> = Dictionary<String, Array<AuthorEntity>>()
    
    init(let row:EGODatabaseRow) {
        self.rowid = row.stringForColumn("rowid").toInt()!
        self.name = row.stringForColumn("name")
        self.desc = row.stringForColumn("desc")
    }
    
    static func getAllAuthor()->Dictionary<String, Array<AuthorEntity>> {
        
        if authorMap.count > 0 {
            return authorMap
        }

        let query:String = String("SELECT rowid, * FROM author")
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:AuthorEntity = AuthorEntity(row:poemRow!)
                let char:String = poemEntity.name[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if authorMap[key] == nil {
                    var value:Array<AuthorEntity> = []
                    value.append(poemEntity)
                    authorMap[key] = value
                } else {
                    var value:Array<AuthorEntity> = authorMap[key]!
                    value.append(poemEntity)
                    authorMap[key] = value
                }
            }
        }
        return authorMap;
    }
}
