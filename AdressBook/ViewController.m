//
//  ViewController.m
//  AdressBook
//
//  Created by JK210 on 2018/1/23.
//  Copyright © 2018年 JK210. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import "MineTableViewCell.h"
#import "AdressBookObject.h"
@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * tempArray;
@property (nonatomic, strong) NSMutableArray * titleArray;
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"获取" style:UIBarButtonItemStylePlain target:self action:@selector(getmyAddressbook)];
    self.navigationItem.rightBarButtonItem = item;
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary * dict = self.dataArray[indexPath.section][indexPath.row];
    cell.nameLabel.text = dict[@"name"];
    cell.phoneLabel.text = dict[@"phone"];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.titleArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleArray[section];
}

- (void)getmyAddressbook
{
    self.dataArray = [NSMutableArray array];
    self.tempArray = [NSMutableArray array];
    self.titleArray = [NSMutableArray array];
    [AdressBookObject uploadContacts:^(NSArray *dictArray, NSError *error) {
        for (int i = 'A'; i<='Z'; i++) {
            [self.titleArray addObject:[NSString stringWithFormat:@"%c",i]];
            NSLog(@"%@",[NSString stringWithFormat:@"%c",i]);
            NSMutableArray * tempArray = [NSMutableArray array];
            [self.dataArray addObject:tempArray];
        }
        
        NSMutableArray * tempArray = [NSMutableArray array];
        [self.titleArray addObject:@"#"];
        [self.dataArray addObject:tempArray];
        
        for (NSDictionary * dic in dictArray) {
            NSString * name = dic[@"name"];
            int m = [[self firstCharactor:name] characterAtIndex:0];
            if (m - 'A' < 26) {
                NSMutableArray * tempArray = self.dataArray[m - 'A'];
                [tempArray addObject:dic];
            }else{
                NSMutableArray * tempArray = self.dataArray['Z'-'A'+1];
                [tempArray addObject:dic];
            }
            
        }
        
        for (NSInteger i = self.dataArray.count-1; i >= 0; i--) {
            NSMutableArray * tempArray = self.dataArray[i];
            if (tempArray.count == 0) {
                [self.dataArray removeObjectAtIndex:i];
                [self.titleArray removeObjectAtIndex:i];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)tempArray
{
    if (!_tempArray) {
        _tempArray = [NSMutableArray array];
    }
    return _tempArray;
}

- (NSMutableArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"MineTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
