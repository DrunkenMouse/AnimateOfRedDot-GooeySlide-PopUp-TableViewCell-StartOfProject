//
//  ADGooeySlideViewController.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADGooeySlideViewController.h"
#import "ADGooeySlide.h"

@interface ADGooeySlideViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ADGooeySlideViewController {
    
    ADGooeySlide *_menu;
    UITableView *_tableView;
}

-(void)loadView{
 
    [super loadView];
    
    _menu = [[ADGooeySlide alloc] initWithTitle:@[@"首页", @"消息", @"发布", @"发现", @"个人", @"设置",@"关于"] withButtonHeight:44 withMenuColor:[self colorFromRGB:0x99CCCC] withBackBlurStyle:UIBlurEffectStyleDark];
    
    _menu.menuClickBlock = ^(NSInteger index, NSString *title, NSInteger titleCounts){
        NSLog(@"index:%ld title:%@ titleCounts:%ld",index,title,titleCounts);
        NSLog(@"操作在此执行");
    };
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(buttonTrigger:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"No.%ld",indexPath.row];
    return cell;
}

-(void)buttonTrigger:(UIButton *)sender{
    [_menu trigger];
}


- (UIColor *)colorFromRGB:(NSInteger)RGBValue {
    return [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 green:((float)((RGBValue & 0xFF00) >> 8))/255.0 blue:((float)(RGBValue & 0xFF))/255.0 alpha:1.0];
}

@end
