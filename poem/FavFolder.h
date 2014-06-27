//
//  FavFolder.h
//  poem
//
//  Created by Sun Xi on 6/22/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FavItem;

@interface FavFolder : NSManagedObject

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@end

@interface FavFolder (CoreDataGeneratedAccessors)

- (void)addItemsObject:(FavItem *)value;
- (void)removeItemsObject:(FavItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
