//
//  ContactsTableViewCell.m
//  AdressBook
//
//  Created by JK210 on 2018/1/29.
//  Copyright © 2018年 JK210. All rights reserved.
//

#import "ContactsTableViewCell.h"

@interface ContactsTableViewCell ()
/** 手机号 */
@property (nonatomic, strong) UILabel * phoneLabel;
/** 姓名 */
@property (nonatomic, strong) UILabel * nameLabel;
/** 头像 */
@property (nonatomic, strong) UIImageView * iconImageView;
/** 按钮 */
@property (nonatomic, strong) UILabel * operationButton;

@end

@implementation ContactsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    
}


@end
