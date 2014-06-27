//
//  AuthorEntity.swift
//  poem
//
//  Created by Sun Xi on 6/16/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

struct SongNameEntity {
    
    var rowid:Int = 0
    var name:String = ""
    var info:String = ""
    var desc:String = ""
    var icon:String = ""
    
    static var songNameMap:Dictionary<String, Array<SongNameEntity>> = Dictionary<String, Array<SongNameEntity>>()
    
    init(let row:EGODatabaseRow) {
        self.name = row.stringForColumn("name")
        self.info = row.stringForColumn("info")
        self.desc = row.stringForColumn("desc")
    }
    
    static func getAllName()->Dictionary<String, Array<SongNameEntity>>  {
        
        if songNameMap.count > 0 {
            return songNameMap
        }
        
        let query:String = String("SELECT * FROM songname")
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase

        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:SongNameEntity = SongNameEntity(row:poemRow!)
                let char:String = poemEntity.name[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if songNameMap[key] == nil {
                    var value:Array<SongNameEntity> = []
                    value.append(poemEntity)
                    songNameMap[key] = value
                } else {
                    var value:Array<SongNameEntity> = songNameMap[key]!
                    value.append(poemEntity)
                    songNameMap[key] = value
                }
            }
        }

        return songNameMap;
    }
}
