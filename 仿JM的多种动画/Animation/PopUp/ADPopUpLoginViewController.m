//
//  ADPopUpLoginViewController.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/28.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADPopUpLoginViewController.h"

@interface ADPopUpLoginViewController ()<UITextFieldDelegate>

@end

@implementation ADPopUpLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.view.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:0.8];
    
    UIView *signUpView = [[UIView alloc]initWithFrame:CGRectZero];
    signUpView.center = self.view.center;
    signUpView.bounds = CGRectMake(0, 0, self.view.frame.size.width - 80, self.view.frame.size.height - 240);
    signUpView.backgroundColor = [UIColor whiteColor];
    signUpView.layer.cornerRadius = 3;
    signUpView.layer.shadowOpacity = 0.4;
    signUpView.layer.shadowOffset = CGSizeMake(0.2, 0.2);
    [self.view addSubview:signUpView];
    UILabel *signUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, signUpView.bounds.size.width, 44)];
    signUpLabel.text = @"SIGN UP";
    signUpLabel.textAlignment = NSTextAlignmentCenter;
    [signUpView addSubview:signUpLabel];
   
    UITextField *firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, signUpView.bounds.size.width - 40, 44)];
    firstNameTextField.delegate = self;
    firstNameTextField.tag = 100;
    firstNameTextField.placeholder = @"UserID";
    firstNameTextField.clearButtonMode = UITextFieldViewModeNever;
    [self addLineTo:firstNameTextField];
    [signUpView addSubview:firstNameTextField];

    UITextField *lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 120, firstNameTextField.bounds.size.width, 44)];
    lastNameTextField.delegate = self;
    lastNameTextField.tag = 101;
    lastNameTextField.placeholder = @"UserName";
    lastNameTextField.clearButtonMode = UITextFieldViewModeNever;
    [self addLineTo:lastNameTextField];
    [signUpView addSubview:lastNameTextField];

    UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 180, firstNameTextField.bounds.size.width, 44)];
    emailTextField.delegate = self;
    emailTextField.tag = 102;
    emailTextField.placeholder = @"Email";
    emailTextField.clearButtonMode = UITextFieldViewModeNever;
    [self addLineTo:emailTextField];
    [signUpView addSubview:emailTextField];

    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, signUpView.frame.size.height - 44, signUpView.bounds.size.width, 44)];
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [signUpView addSubview:nextButton];

    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = nextButton.bounds;
    gradientLayer.locations = @[@0.3,@0.8];
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:56 / 255.f green:195 / 255.f blue:16 / 255.f alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:16 / 255.f green:156 / 255.f blue:197 / 255.f alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    [nextButton.layer addSublayer:gradientLayer];
}

-(void)addLineTo:(UIView *)view{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1.5, view.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:lineView];

    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 2.0, 0, 2.0)];
    lineView2.backgroundColor = [UIColor redColor];
    [lineView2.layer setAnchorPoint: CGPointMake(0, 0.5)];
    lineView2.tag = view.tag + 100;
    [view addSubview:lineView2];
}

- (void)nextButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
//
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing: (UITextField *)textField {
    //最开始编辑的时候通过动画添加一根红线
    if ([textField.text isEqualToString: @""]) {
        UIView *view = [self.view viewWithTag:textField.tag + 100];
        view.bounds = CGRectMake(0, 0, 1, 2);
        
        CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        basic.duration = 0.3;
        basic.repeatCount = 1;
        basic.removedOnCompletion = NO;
        basic.fromValue =  [NSNumber numberWithFloat:1];
        basic.toValue = [NSNumber numberWithFloat:self.view.frame.size.width - 120];
        basic.fillMode = kCAFillModeForwards;
        basic.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [view.layer addAnimation:basic forKey:nil];
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if ([textField.text isEqualToString:@""]) {
        UIView *view = [self.view viewWithTag:textField.tag + 100];
        [view.layer setAnchorPoint:CGPointMake(0, 0.5)];
        CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        basic.duration = 0.3;
        basic.repeatCount = 1;
        basic.removedOnCompletion = NO;
        basic.fromValue = [NSNumber numberWithFloat:self.view.frame.size.width - 120];
        basic.toValue = [NSNumber numberWithFloat:0];
        basic.fillMode = kCAFillModeForwards;
        basic.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [view.layer addAnimation:basic forKey:nil];
    
        
    }
}




@end
