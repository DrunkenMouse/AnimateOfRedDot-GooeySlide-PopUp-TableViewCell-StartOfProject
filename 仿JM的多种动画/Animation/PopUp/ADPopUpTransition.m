//
//  ADPopUpTransition.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADPopUpTransition.h"

@implementation ADPopUpTransition{
    id<UIViewControllerContextTransitioning> _transitionContext;
    UIViewController *_fromVC;
    UIViewController *_toVC;
    CGFloat _duration;
    UINavigationControllerOperation _operation;
}



-(instancetype)initWithAnimationControllerForOperation:(UINavigationControllerOperation)operation duration:(CGFloat)duration{
    
    self = [ADPopUpTransition new];
    if (self) {
        _operation = operation;
        _duration = duration;
    }
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return _duration;
}


-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    _transitionContext = transitionContext;
    _fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *contView = [transitionContext containerView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m11 = 0.8;
    transform.m22 = 0.8;
    transform.m34 = -1.0/875.0;
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    
    
    CATransform3D transform2 = CATransform3DIdentity;
    transform2.m11 = 0.8;
    transform2.m22 = 0.8;
    transform2.m34 = -1.0 / 875.0;
    transform2 = CATransform3DRotate(transform2, M_PI_2, 0, 1, 0);

    
    if (_operation == UINavigationControllerOperationPush) {
        [UIView animateWithDuration:_duration / 2.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            window.layer.transform = transform;
        } completion:^(BOOL finished) {
            [_fromVC.view removeFromSuperview];
            [contView addSubview:_toVC.view];
            window.layer.transform = transform2;
            [UIView animateWithDuration:_duration / 2.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                window.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0);
            } completion:^(BOOL finished) {
                [_transitionContext completeTransition:![_transitionContext transitionWasCancelled]];
            }];
        }];
    }  else{
        [UIView animateWithDuration:_duration / 2.0 animations:^{
            window.layer.transform = transform2;
        } completion:^(BOOL finished) {
            [_fromVC.view removeFromSuperview];
            [contView addSubview:_toVC.view];
            window.layer.transform = transform;
            [UIView animateWithDuration:_duration / 2.0 animations:^{
                window.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0);
            } completion:^(BOOL finished) {
                [_transitionContext completeTransition:![_transitionContext transitionWasCancelled]];
            }];
        }];
    }
}




@end
