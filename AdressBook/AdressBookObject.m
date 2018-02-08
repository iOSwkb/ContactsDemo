//
//  AdressBookObject.m
//  AdressBook
//
//  Created by JK210 on 2018/1/25.
//  Copyright © 2018年 JK210. All rights reserved.
//

#import "AdressBookObject.h"
#import <Contacts/Contacts.h>

static uploadContactsFinishAction _finishAction;

@implementation AdressBookObject

- (instancetype)initwithFinishAction:(uploadContactsFinishAction)Action
{
    AdressBookObject * object = [[AdressBookObject alloc] init];
    if (object) {
        _finishAction = nil;
        if (Action) {
            _finishAction = Action;
        }
    }
    return object;
}

+ (void)uploadContacts:(uploadContactsFinishAction)finishAction
{
    AdressBookObject * object = [[AdressBookObject alloc] initwithFinishAction:finishAction];
    
    [object GetAdressBookAuth];
}

#pragma mark - 授权信息
- (void)GetAdressBookAuth
{
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"首次同意授权");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self getmyAddressbook];
                });
            } else {
                _finishAction(nil, error);
                NSLog(@"授权失败, error=%@", error);
            }
        }];
    }else if (authorizationStatus == CNAuthorizationStatusAuthorized) {
        //已经同意授权
        NSLog(@"已经同意授权");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getmyAddressbook];
        });
        
    }else if (authorizationStatus == CNAuthorizationStatusDenied) {
        //用户拒绝授权
        NSLog(@"拒绝同意授权,请去设置->隐私->通讯录中允许金氪访问");
    }else if (authorizationStatus == CNAuthorizationStatusRestricted) {
        //家长控制,当前无法获取通讯录
        NSLog(@"家长控制,无法授权");
    }
}


#pragma mark 获取联系人信息
- (void)getmyAddressbook
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    __block int z = 0;
    NSMutableArray * tempArray = [NSMutableArray array];
    // 获取指定的字段,并不是要获取所有字段，需要指定具体的字段
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactOrganizationNameKey, CNContactJobTitleKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactNicknameKey, CNContactPostalAddressesKey, CNContactNoteKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        NSMutableDictionary * contactDict = [NSMutableDictionary dictionary];
        //姓名
        NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
        [contactDict setObject:nameStr forKey:@"name"];
        
        //电话(数组)
        NSMutableArray * phoneTempArray = [NSMutableArray array];
        //手机号放到数组第一个
        BOOL findMobilePhone = NO;
        
        for (CNLabeledValue *labelValue in contact.phoneNumbers) {
            CNPhoneNumber * phoneNumber = labelValue.value;
            NSString * phoneStr = phoneNumber.stringValue;
            //去除空格
            NSArray * delSpaceArr = [phoneStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
            phoneStr = [delSpaceArr componentsJoinedByString:@""];
            
            //去括号
            NSArray * delLeftArr = [phoneStr componentsSeparatedByString:@"("];
            phoneStr = [delLeftArr componentsJoinedByString:@""];
            
            NSArray * delrightArr = [phoneStr componentsSeparatedByString:@")"];
            phoneStr = [delrightArr componentsJoinedByString:@""];
            
            NSArray * delHorizArr = [phoneStr componentsSeparatedByString:@"-"];
            phoneStr = [delHorizArr componentsJoinedByString:@""];
            //剔除开头的"+86"
            if ([[phoneStr substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"+86"]) {
                phoneStr = [phoneStr substringWithRange:NSMakeRange(3, phoneStr.length - 3)];
            }
            if (phoneStr.length == 11&&findMobilePhone ==NO) {
                [phoneTempArray insertObject:phoneStr atIndex:0];
                findMobilePhone = YES;
            }else{
                [phoneTempArray addObject:phoneStr];
            }
        }
        [contactDict setObject:phoneTempArray forKey:@"mobile"];
        
        //邮箱地址
        NSMutableArray * emailTempArray = [NSMutableArray array];
        for (CNLabeledValue *labelValue in contact.emailAddresses) {
            NSString * email = [CNLabeledValue localizedStringForLabel:labelValue.value];
            if (email) {
                [emailTempArray addObject:email];
            }
        }
        [contactDict setObject:emailTempArray forKey:@"email"];

        //住址
        NSMutableArray * adressTempArray = [NSMutableArray array];
        for (CNLabeledValue *labelValue in contact.postalAddresses) {
            CNPostalAddress * postAdress = labelValue.value;
            if (@available(iOS 10.3, *)) {
                NSString * adressStr = [NSString stringWithFormat:@"%@ %@ %@ %@", postAdress.state, postAdress.city,  postAdress.subLocality, postAdress.street];
                if (adressStr) {
                    [adressTempArray addObject:adressStr];
                }
            } else {
                NSString * adressStr = [NSString stringWithFormat:@"%@ %@ %@", postAdress.state, postAdress.city, postAdress.street];
                if (adressStr) {
                    [adressTempArray addObject:adressStr];
                }
            }
        }
        [contactDict setObject:adressTempArray forKey:@"address"];
        
        //生日
        NSNumber * birthDay = [NSNumber numberWithLong:0];
        if (contact.birthday) {
            NSString * birthDayStr = [NSString stringWithFormat:@"%ld-%ld-%ld",contact.birthday.year, contact.birthday.month,contact.birthday.day];
             NSDate * birthDayDate = [formatter dateFromString:birthDayStr];
            long a = [birthDayDate timeIntervalSince1970];
            birthDay = [NSNumber numberWithLong:a];
        }
        [contactDict setObject:birthDay forKey:@"birthday"];
        
        //公司
        NSString * company = @"";
        if (contact.organizationName) {
            company = contact.organizationName;
        }
        [contactDict setObject:company forKey:@"company"];
        
        //职位
        NSString * jobTitle = @"";
        if (contact.jobTitle) {
            jobTitle = contact.jobTitle;
        }
        [contactDict setObject:jobTitle forKey:@"jobTitle"];
        
        //昵称
        NSString * nickName = @"";
        if (contact.nickname) {
            nickName = contact.nickname;
        }
        [contactDict setObject:nickName forKey:@"nickName"];
        
        //备注
        NSString * remark = @"";
        if (contact.note) {
            remark = contact.note;
        }
        [contactDict setObject:remark forKey:@"remark"];
        
        [tempArray addObject:contactDict];
        z++;
    }];
    
    NSLog(@"%@",tempArray);
    _finishAction(tempArray, nil);
}

@end
