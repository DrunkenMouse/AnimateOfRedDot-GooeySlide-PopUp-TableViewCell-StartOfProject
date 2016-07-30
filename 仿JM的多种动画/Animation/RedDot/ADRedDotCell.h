//
//  ADRedDotCell.h
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADRedDotCellModel.h"

@interface ADRedDotCell : UITableViewCell

@property(nonatomic,strong) ADRedDotCellModel *cellModel;

@property(nonatomic,strong)UIImageView *avatarView;

@property(nonatomic,strong)UILabel *nameLabel;

@property(nonatomic,strong)UILabel *messageLabel;

@property(nonatomic,strong)UILabel *timeLabel;

@property(nonatomic,strong)UILabel *redDotLabel;

@end
