//
//  ADPopUpViewController.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADPopUpViewController.h"
#import "ADPopUpTransition.h"
#import "ADPopUpLoginViewController.h"

/**
     
     ADPopUpViewController：
     通过UINav的代理方法来调用自定义的上下文转场动画
     调用之前先判断一下，如果是自己跳到另一个页面或者是从自己返回到上一个页面
     则调用自己的上下文动画
     
     ADPopUpTransition:
     重定义上下文动画需要签署UIViewControllerAnimatedTransitioning协议
     并设置一个UIViewControllerContextTransitioning代理对象
     而后定义两个UIViewController属性用来接收传过来与跳到的控制器
     在自定义初始化方法里接收并保存此时的NavControllerOpertaion(NavigationController跳转方式)与要求的动画时间
     而后通过代理方法返回transition时间
     在代理方法animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext里自定义上下文转场操作
     先保存此时的转场上下文，并通过转场上下文保存转场前与转场后的ViewController，并获取转场舞台与Window窗口。
     设置一个3D旋转动画，而后判断此时的NavControllerOperation是Push还是Pop进行不同的操作
     push操作下通过UIView动画修改window.layer.transform为自定义transform，旋转角度为—M_PI_2围绕Y轴，旋转结束后再通过UIView动画修改window.layer.transform让其围绕Y轴旋转到0度
     旋转结束后根据转场上下文操作是否结束来决定是否关闭上下文。
     上下文一定要关闭，否则会出现奇葩的问题，尤其在collectionCell的动画效果时
     Pop操作下同理通过UIView动画修改window.layer.transform，只是修改了一下旋转角度为原始角度到M_PI_2到0度
     
     ADPopUpLoginViewController
     通过textFieldDelegate实现开始编辑和结束编辑时的动画效果
     初始化时创建textField并给每个textField添加两根线，一根灰色，一根红色
     其中红色的线要用于后续动画操作，所以设置tag值为textField.tag + 100方便后续获取
     开始编辑时，若textField.text是@“”代表此时输入框内没有值且要开始输入
     则创建一个View用于获取textField上自己添加的红色线
     重定义Bounds修改宽高后创建一个基础动画BasicAnimation用于修改transform.scale.x值
     也就是x轴上放大的倍数，定义动画时间、重复次数、完成后是否移除、完成后的值、填充模式与动画效果后作用于红线的layer
     结束编辑时若textFiled.text为@“”表明此时输入框没有任何内容
     则同理创建一个动画作用于textField的红线，只是值从原始值变成0
     其中Next的显示颜色是使用了梯度显示:CAGradientLayer
 
 */

@interface ADPopUpViewController ()<UINavigationControllerDelegate>

@end

@implementation ADPopUpViewController{
    UIButton *_popButton;
}

-   (void)viewWillAppear:(BOOL)animated{
    self.navigationController.delegate = self;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    _popButton = [[UIButton alloc]initWithFrame:CGRectZero];
    _popButton.center = self.view.center;
    _popButton.bounds = CGRectMake(0, 0, 100, 44);
    _popButton.layer.borderColor = [UIColor orangeColor].CGColor;
    _popButton.layer.borderWidth = 1;
    [_popButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_popButton setTitle:@"button" forState:UIControlStateNormal];
    [_popButton addTarget:self action:@selector(popButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_popButton];
}

-(void)popButtonAction{

    ADPopUpLoginViewController *VC = [[ADPopUpLoginViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}



#pragma mark - UINavigationControllerDelegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{

    if ((fromVC == self && operation == UINavigationControllerOperationPush)||(toVC == self && operation == UINavigationControllerOperationPop)) {
    
        ADPopUpTransition *popUpTransition = [[ADPopUpTransition alloc] initWithAnimationControllerForOperation:operation duration:0.6];
        return popUpTransition;
    }
    
    return nil;
}


@end
