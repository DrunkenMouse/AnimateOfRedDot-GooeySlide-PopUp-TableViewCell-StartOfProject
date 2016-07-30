//
//  ADSlideMenuButton.h
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADSlideMenuButton : UIView


-(instancetype)initWithTitle:(NSString *)title;

@property(nonatomic,strong) UIColor *buttonColor;
@property(nonatomic,copy)void(^buttonClickBlock)(void);

@end
