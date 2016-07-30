//
//  ViewController.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"
#import "ADRedDotViewController.h"
#import "ADTableViewAnimate.h"
#import "ADPopUpViewController.h"
#import "ADGooeySlideViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController{
    
    UITableView *_tableView;
    NSMutableArray *_titles;
    NSMutableArray *_classes;
    
    
}

- (void)loadView {
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    _titles = @[].mutableCopy;
    _classes = @[].mutableCopy;
    
    ADRedDotViewController *redDot = [[ADRedDotViewController alloc]init];
    [_titles addObject:@"redDotView"];
    [_classes addObject:redDot];
    
     ADTableViewAnimate* ADTable = [[ADTableViewAnimate alloc]init];
    [_titles addObject:@"tableViewCellAnimation"];
    [_classes addObject:ADTable];
    
    ADPopUpViewController *PopUp = [[ADPopUpViewController alloc]init];
    [_titles addObject:@"PopUp"];
    [_classes addObject:PopUp];
    
    ADGooeySlideViewController *gooey = [[ADGooeySlideViewController alloc]init];
    [_titles addObject:@"GooeySlide"];
    [_classes addObject:gooey];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = _titles[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.navigationController pushViewController:_classes[indexPath.row] animated:YES];
    
}




@end
