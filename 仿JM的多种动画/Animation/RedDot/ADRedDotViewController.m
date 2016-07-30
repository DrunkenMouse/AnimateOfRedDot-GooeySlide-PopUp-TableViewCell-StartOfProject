//
//  ADRedDotViewController.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADRedDotViewController.h"
#import "ADRedDotCell.h"
#import "ADRedDotCellModel.m"
#import "ADRedDot.h"

@interface ADRedDotViewController ()<UITableViewDelegate,UITableViewDataSource>

@end


@implementation ADRedDotViewController{

    UITableView *_tableView;
    NSArray *_array;
    ADRedDot *_redDotView;
    ADRedDot *_redDotView2;
    
}
-(void)loadView {
    [super loadView];
    
    
    _redDotView = [[ADRedDot alloc]initWithMaxDistance:75 bubbleColor:[self colorFromRGB:0x99CCCC]];
    _redDotView2 = [[ADRedDot alloc] initWithMaxDistance:150 bubbleColor:[self colorFromRGB:0x99CCCC]];
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    _tableView.rowHeight = 55;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[ADRedDotCell class] forCellReuseIdentifier:@"cell"];
    
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    rightLabel.text = @"菜单";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightLabel];
   
    __weak typeof(self) weakSelf = self;
    [_redDotView attach:rightLabel withSeparateBlocl:^BOOL(UIView *view) {
        weakSelf.navigationItem.rightBarButtonItem = nil;
        return YES;
    }];
    
//    
    [self.view addSubview:_tableView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor orangeColor];
   
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i ++) {
        ADRedDotCellModel *model = [[ADRedDotCellModel alloc] init];
        model.name = @"name";
        model.message = @"这是一条信息";
        model.time = @"19:00";
        model.messageCount = @99;
        model.avatar = [UIImage imageNamed:@"avatar.jpg"];
        [array addObject:model];
    }
    _array = array.copy;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ADRedDotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    
    ADRedDotCellModel *model = _array[indexPath.row];
    cell.cellModel = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Block返回YES代表拖动结束后可以执行爆炸效果
    //返回为NO时代表拖动结束后只能执行回弹效果
    //Block为Nil则画板会自动创建一个返回为NO的Block操作
    [_redDotView attach:cell.avatarView withSeparateBlocl:^BOOL(UIView *view) {
        return YES;
    }];

    [_redDotView attach:cell.nameLabel withSeparateBlocl:nil];
    
    [_redDotView attach:cell.messageLabel withSeparateBlocl:^BOOL(UIView *view) {
        model.message = nil;
        return NO;
    }];

    
    [_redDotView attach:cell.timeLabel withSeparateBlocl:^BOOL(UIView *view) {
        model.time = nil;
        return YES;
    }];

    
    [_redDotView attach:cell.redDotLabel withSeparateBlocl:^BOOL(UIView *view) {
        model.messageCount = nil;
        return YES;
    }];
    

    [_redDotView2 attach:cell withSeparateBlocl:^BOOL(UIView *view) {
        model.contentViewHidden = YES;
        return YES;
    }];
    
    return cell;
}


- (UIColor *)colorFromRGB:(NSInteger)RGBValue {
    return [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 green:((float)((RGBValue & 0xFF00) >> 8))/255.0 blue:((float)(RGBValue & 0xFF))/255.0 alpha:1.0];
}







@end
