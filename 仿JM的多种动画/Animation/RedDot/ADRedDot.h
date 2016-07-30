//
//  ADRedDot.h
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADRedDot : UIView

typedef BOOL (^SeparateBlock)(UIView *view);
/**
 *  初始化黏贴板
 *
 *  @param maxDistance 最大距离
 *  @param bubbleColor 黏贴效果颜色
 *
 *  @return 一个黏贴板
 */
- (instancetype)initWithMaxDistance:(CGFloat)maxDistance bubbleColor:(UIColor *)bubleColor;

/**
 *  黏上这个 view ,
 *
 *  @param item           被黏住的 view 。
 *  @param separateBlock  分离后执行的 block，返回 YES 执行爆炸动画。
 */
- (void)attach:(UIView *)item withSeparateBlocl:(SeparateBlock)separateBlock;

@end
