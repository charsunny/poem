//
//  PoemEntity.swift
//  poem
//
//  Created by Sun Xi on 6/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation

struct PoemEntity {
    
    var rowid:Int = 0
    var title:String = ""
    var subtitle:String = ""
    var content:String = ""
    var author:String = ""
    var type:Int = 0
    
    init(let row:EGODatabaseRow) {
        self.rowid = row.stringForColumn("rowid").toInt()!
        self.title = row.stringForColumn("title")
        self.subtitle = row.stringForColumn("subtitle")
        self.type = row.stringForColumn("type").toInt()!
        self.content = row.stringForColumn("content")
        self.author = row.stringForColumn("author")
    }
    
    static func formatContent(str:String)->String {
        var cont:NSMutableString = NSMutableString(string:str)
        cont.replaceOccurrencesOfString("，", withString: "，\n", options: .LiteralSearch, range: NSMakeRange(0, cont.length))
        cont.replaceOccurrencesOfString("。", withString: "。\n", options: .LiteralSearch, range: NSMakeRange(0, cont.length))
        cont.replaceOccurrencesOfString("；", withString: "；\n", options: .LiteralSearch, range: NSMakeRange(0, cont.length))
        cont.replaceOccurrencesOfString("？", withString: "？\n", options: .LiteralSearch, range: NSMakeRange(0, cont.length))
        return cont
    }
    
    static func genRandomPoem(count:Int = 10, type:Int = -1)->Array<PoemEntity> {
        
        var poems:Array<PoemEntity> = Array<PoemEntity>()
        
        var query:String = String("SELECT rowid, * FROM poetry where type = \(type) ORDER BY RANDOM() LIMIT \(count)")
        
        if type < 0 {
            query = String("SELECT rowid, * FROM poetry ORDER BY RANDOM() LIMIT \(count)")
        }
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:PoemEntity = PoemEntity(row:poemRow!)
                poems.append(poemEntity)
            }
        }
        return poems;
    }
    
    static func getPoemByIndex(index:Int) -> PoemEntity? {
        var query:String = String("SELECT rowid, * FROM poetry where rowid = \(index) ")
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if result?.count() > 0 {
            let poemRow:EGODatabaseRow? = result?.rowAtIndex(0)
            let poemEntity:PoemEntity = PoemEntity(row:poemRow!)
            return poemEntity
        }
        return nil
    }
    
    static func getPoemByAuthor(var author:String?) -> Dictionary<String, Array<PoemEntity>> {
        if author == nil {
            return [:]
        }
        var poemMap:Dictionary<String, Array<PoemEntity>> = Dictionary<String, Array<PoemEntity>>()
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase
        
        let query:String = "SELECT rowid, * FROM poetry WHERE type = 0 AND author like '%%\(author)%%'"
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:PoemEntity = PoemEntity(row:poemRow!)
                let char:String = poemEntity.title[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if poemMap[key] == nil {
                    var value:Array<PoemEntity> = []
                    value.append(poemEntity)
                    poemMap[key] = value
                } else {
                    var value:Array<PoemEntity> = poemMap[key]!
                    value.append(poemEntity)
                    poemMap[key] = value
                }
            }
        }
        return poemMap;
    }
    
    static func getSongByName(var name:String?) -> Dictionary<String, Array<PoemEntity>> {
        
        if name == nil {
            return [:]
        }
        
        var poemMap:Dictionary<String, Array<PoemEntity>> = Dictionary<String, Array<PoemEntity>>()
        
        var pyFormat:HanyuPinyinOutputFormat = HanyuPinyinOutputFormat()
        pyFormat.toneType = ToneTypeWithoutTone
        pyFormat.vCharType = VCharTypeWithV
        pyFormat.caseType = CaseTypeUppercase
        
        let query:String = "SELECT rowid, * FROM poetry WHERE type = 1 AND title like '%%\(name)%%'"
        
        let result:EGODatabaseResult? = PoemDB?.executeQuery(query)
        if let count:Int = result?.count() {
            for idx in 0..count {
                let poemRow:EGODatabaseRow? = result?.rowAtIndex(idx)
                let poemEntity:PoemEntity = PoemEntity(row:poemRow!)
                let char:String = poemEntity.author[0]
                let pyStr:String = PinyinHelper.toHanyuPinyinStringWithNSString(char, withHanyuPinyinOutputFormat: pyFormat, withNSString:"")
                let key = pyStr[0]
                if poemMap[key] == nil {
                    var value:Array<PoemEntity> = []
                    value.append(poemEntity)
                    poemMap[key] = value
                } else {
                    var value:Array<PoemEntity> = poemMap[key]!
                    value.append(poemEntity)
                    poemMap[key] = value
                }
            }
        }
        return poemMap;
    }
}
