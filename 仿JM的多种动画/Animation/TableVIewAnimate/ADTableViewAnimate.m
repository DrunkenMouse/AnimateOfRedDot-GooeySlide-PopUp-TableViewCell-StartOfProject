//
//  ADTableViewAnimate.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADTableViewAnimate.h"

@interface ADTableViewAnimate ()

@end

@implementation ADTableViewAnimate{
    CGFloat _scrollViewY;
    CGFloat _offSetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollViewY = -64;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

    self.tableView.rowHeight = 100;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 200;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.text = @"努力坚持再继续";
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

//cell的动画通常是根据其来设置的,其中根据滚动的正负来判断滚动是上下哪个方向
//而后根据方向设置偏移值
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.layer.transform = CATransform3DMakeTranslation(0, _offSetY, 0);

    [UIView animateWithDuration:0.5 animations:^{
        cell.layer.transform = CATransform3DIdentity;
    }];
}

//cell的高度即为100,所以要滚动超出一个cell时方可设置偏移值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollViewY = scrollView.contentOffset.y;
    
    if (_scrollViewY>scrollViewY) {
        _offSetY = -100;
    }else if(_scrollViewY < scrollViewY){
        _offSetY = 100;
    }
    _scrollViewY = scrollViewY;
}


@end
