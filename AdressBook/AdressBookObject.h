//
//  AdressBookObject.h
//  AdressBook
//
//  Created by JK210 on 2018/1/25.
//  Copyright © 2018年 JK210. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^uploadContactsFinishAction)(NSArray * dictArray, NSError * error);

@interface AdressBookObject : NSObject

+ (void)uploadContacts:(uploadContactsFinishAction)finishAction;

@end
