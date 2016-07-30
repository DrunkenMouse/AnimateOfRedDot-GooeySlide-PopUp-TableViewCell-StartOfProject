//
//  AppDelegate.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

/**
    通过自定义动画来展示刚打开时的动画效果
    一定要在window设置完并makeKeyAndVisible后才展示，否则不显示
 */

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
  
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIWindow *wind = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    self.window = wind;
    
    ViewController *VC = [[ViewController alloc]init];
    VC.navigationController.navigationBar.barTintColor = [self colorFromRGB:0x99CCCC];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
    wind.rootViewController = nav;
  
    [wind makeKeyAndVisible];
    
    [self initLaunchScreenAnimation];
   
    return YES;
}

- (void)initLaunchScreenAnimation {
    
    //以View形式展示背景颜色
    UIView *backgroundView = [[UIView alloc] initWithFrame:_window.bounds];
    backgroundView.backgroundColor = [self colorFromRGB:0x99CCCC];
    [_window addSubview:backgroundView];
    
    //获取主控制器的View并展示
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window.bounds.size.width, _window.bounds.size.height)];
    imageView.image = [self getImageFromView:_window.rootViewController.view];
    [_window addSubview:imageView];
    
    //给View的Layer.mask添加一个Layer
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (id)[UIImage imageNamed:@"loveShape"].CGImage;
    maskLayer.position = CGPointMake(_window.bounds.size.width/2, _window.bounds.size.height/2);
    maskLayer.bounds = CGRectMake(0, 0, 60, 60);
    imageView.layer.mask = maskLayer;
    
//    给View覆盖一层橘黄色View,用于覆盖View的显示
    UIView *maskBackgroundView = [[UIView alloc]initWithFrame:imageView.bounds];
//    maskBackgroundView.backgroundColor = [UIColor whiteColor];
    maskBackgroundView.backgroundColor = [UIColor orangeColor];
    [imageView addSubview:maskBackgroundView];
    [imageView bringSubviewToFront:maskBackgroundView];
    
    //关键帧动画，修改bounds属性
    CAKeyframeAnimation *logoMaskAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    logoMaskAnimation.duration = 1.0f;
    
    //设置动画的初始、第二次、最后显示范围
    CGRect initalBounds = maskLayer.bounds;
    CGRect secondBounds = CGRectMake(0, 0, 30, 30);
    CGRect finalBounds = CGRectMake(0, 0, 2000, 2000);
    //将值设置给动画，并设置三次动画时间
    logoMaskAnimation.values = @[[NSValue valueWithCGRect:initalBounds],[NSValue valueWithCGRect:secondBounds],[NSValue valueWithCGRect:finalBounds]];
    logoMaskAnimation.keyTimes = @[@(0),@(0.5),@(1)];
    //三次动画的形式
    logoMaskAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    logoMaskAnimation.removedOnCompletion = NO;
    logoMaskAnimation.beginTime = CACurrentMediaTime() + 1.0f;
    logoMaskAnimation.fillMode = kCAFillModeForwards;
    //将动画添加到展示控制器主View的View
    [imageView.layer.mask addAnimation:logoMaskAnimation forKey:@"logoMaskAnimation"];

    //1.35秒后在0.5秒内让覆盖的View变透明，完成后移除覆盖的橘黄色View
    [UIView animateWithDuration:0.5 delay:1.35 options:UIViewAnimationOptionCurveEaseIn animations:^{
     
        maskBackgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [maskBackgroundView removeFromSuperview];
    }];

    
    //1秒后让View在0.5秒内扩大后复原然后移除覆盖的橘黄色View与View
    [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
    
        imageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            imageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [backgroundView removeFromSuperview];
        }];
    }];
    
}


- (UIColor *)colorFromRGB:(NSInteger)RGBValue {
    return [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 green:((float)((RGBValue & 0xFF00) >> 8))/255.0 blue:((float)(RGBValue & 0xFF))/255.0 alpha:1.0];
}

- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, UIScreen.mainScreen.scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
