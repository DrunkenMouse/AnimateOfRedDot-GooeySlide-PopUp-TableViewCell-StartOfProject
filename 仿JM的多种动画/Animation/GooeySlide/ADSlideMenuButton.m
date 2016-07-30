//
//  ADSlideMenuButton.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADSlideMenuButton.h"

/**
    左侧页面中的按钮
 
 */

@implementation ADSlideMenuButton {
    NSString *_buttonTitle;
}



-(instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        _buttonTitle = title;
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, rect);
    //设置笔画和填充颜色
    [_buttonColor set];
    CGContextFillPath(context);
    
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, 1) cornerRadius:rect.size.height / 2];
    //先设置填充颜色并填充
    [_buttonColor setFill];
    [roundedRectanglePath fill];
    
    //再设置路径颜色与宽度并绘制
    [[UIColor whiteColor]setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
  
    //设置短文
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    //短文字体大小与颜色设置
    NSDictionary *attributeString = @{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont systemFontOfSize:24],NSForegroundColorAttributeName:[UIColor whiteColor]};
    //通过字符串与封装好的短文设置获取所需大小
    CGSize size = [_buttonTitle sizeWithAttributes:attributeString];
    
    //也可简单设置
//    CGSize size = [_buttonTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    CGRect buttonRect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - size.height) / 2.0, rect.size.width, size.height);
    [_buttonTitle drawInRect:buttonRect withAttributes:attributeString];
    
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            _buttonClickBlock();
            break;
            
        default:
            break;
    }
    
}


@end
