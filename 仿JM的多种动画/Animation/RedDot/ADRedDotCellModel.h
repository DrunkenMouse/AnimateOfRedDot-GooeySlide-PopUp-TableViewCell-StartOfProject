//
//  ADRedDotCellModel.h
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADRedDotCellModel : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *message;
@property(nonatomic,strong)NSNumber *messageCount;
@property(nonatomic,strong)UIImage *avatar;
@property(nonatomic,assign)BOOL contentViewHidden;


@end
