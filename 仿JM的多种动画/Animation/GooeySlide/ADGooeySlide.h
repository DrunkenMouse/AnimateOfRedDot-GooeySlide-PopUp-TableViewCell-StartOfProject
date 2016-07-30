//
//  ADGooeySlide.h
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MenuButtonClickedBlock) (NSInteger index,NSString *title,NSInteger titleCounts);

@interface ADGooeySlide : UIView

-(instancetype)initWithTitle:(NSArray<NSString *> *)titles;

-(instancetype)initWithTitle:(NSArray<NSString *> *)titles withButtonHeight:(CGFloat)height withMenuColor:(UIColor *)menuColor withBackBlurStyle:(UIBlurEffectStyle)style;

-(void)trigger;

@property(nonatomic, copy) MenuButtonClickedBlock menuClickBlock;

@end


