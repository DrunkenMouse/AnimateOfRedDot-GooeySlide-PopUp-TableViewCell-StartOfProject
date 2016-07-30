//
//  ADGooeySlide.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/29.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADGooeySlide.h"
#import "ADSlideMenuButton.h"

/**
    承载左侧菜单所有信息的View
 
 
 
 
 
    外界调用点击菜单时，通过trigger方法调用动画，如果tigger为NO(Bool默认值)就开启动画
    开启动画时将效果化视图(黑色蒙版,UIVisualEffectView)放在自身显示的View下
    而后通过UIView动画0.3秒内将自身的frame值改成bounds值也就是xy为0
    即将放在屏幕左侧超过边栏的View移动到屏幕左侧，自身的背景颜色初始为clear所以没有背景色
    而后通过beforeAnimation开启DisplayLink，DisplayLink方法里会通过path路径绘制出
    包含圆弧在内的范围，也是最终显示的样式。
    路径经过的关键点大致为：从自身左上角的(0, 0)
    开始addLineTo(_keyWindow.frame.size.width/2,0)，依次为起点绘制一个圆弧，圆弧终
    点为(_keyWindow.frame.size.width/2,_keyWindow.frame.size.height)，最后又画
    到(0,_keyWindow.frame.size.height)闭合路径。
    由于控制曲线弯曲的点是幕中间位置的x+_diff，而diff初始时又为0,所以此时没有圆弧显示
 
    随后通过UIView的弹簧动画修改_helperSideView的x,y值用于圆弧绘制，将控制曲线弯曲的点
    延x增加40， 而后通过结束动画方法停止DisplayLink。
    0.3秒后开启视觉效果化View后开启DisPlayLink，而后让圆弧控制曲线弯曲的点-40，也就是
    让圆弧消失
 
    整体流程为通过UIView的弹簧动画(usingSpringWithDamping)是自身从超出屏幕的左侧部位
    移动到屏幕左侧，并以自身(_keyWindow.frame.size.width/2,0)为原点
    (_keyWindow.frame.size.width/2,_keyWindow.frame.size.height)为终点，中间位
    置(_keyWindow.frame.size.width/2,_keyWindow.frame.size.height/2)+_diff为
    控制曲线弯曲点绘制一个圆弧，_diff为_helperSideView.origin.x —  
    _helperCenterView.origin.x 初始为0，而后通过其增大再减小来控制曲线的弹出到复原动
    画显示。动画完成后给效果化视图添加一个手势用于响应点击事件
 
    而后开启按钮动画效果，让其延x缩小90倍而后通过UIView的弹性动画复原。此处通过按钮的取出
    顺序让每个按钮的隐藏时间都不一样
    让_triggered值为YES，当triggered值为YES在进入时就会跳到点击效果化视图的点击方法
    里，也是按钮被点击后调用的方法:tapToUntrigger
 
    在方法里通过修改View的frame让其返回屏幕左侧，而后如同刚才通过UIView的弹簧动画与自己
    设置的DisplayLink调用让其显示圆弧，返回位置。而后隐藏UIVisualEffectView，通过同样
    的方法让圆弧消失_triggered 赋值为0
 */


static NSInteger kButtonSpace = 30;
static NSInteger kMenuBlankWidth = 50;

@implementation ADGooeySlide{

    CADisplayLink *_displayLink;
    //控制displayLink是否停止
    NSInteger _animationCount;
    //视觉效果化View,背后模板
    UIVisualEffectView *_blurView;
    
    //这两个View用于动画效果中的圆弧绘制
    //左上角一个View
    UIView *_helperSideView;
    //左侧中间一个View
    UIView *_helperCenterView;
    
    //保存主窗口
    UIWindow *_keyWindow;
    //用于供外界调用时判断动画开启的Bool值
    BOOL _triggered;
    //左上角与中间View的x差,用于绘制圆弧的最大x值
    CGFloat _diff;
    //填充颜色
    UIColor *_menuColor;
    //按钮高度
    CGFloat menuButtonHeight;

}

-(instancetype)initWithTitle:(NSArray<NSString *> *)titles{
    
    return [self initWithTitle:titles withButtonHeight:40 withMenuColor:[UIColor colorWithRed:0 green:0.722 blue:1 alpha:1] withBackBlurStyle:UIBlurEffectStyleDark];
    
}

-(instancetype)initWithTitle:(NSArray<NSString *> *)titles withButtonHeight:(CGFloat)height withMenuColor:(UIColor *)menuColor withBackBlurStyle:(UIBlurEffectStyle)style{
    
    self = [super init];
    if (self) {
        _keyWindow = [[UIApplication sharedApplication]keyWindow];
        //视觉效果View,背景模板
        _blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:style]];
        _blurView.frame = _keyWindow.frame;
        _blurView.alpha = 0;
        
        //
        _helperSideView = [[UIView alloc] initWithFrame:CGRectMake(-40, 0, 40, 40)];
        _helperSideView.backgroundColor = [self colorFromRGB:0x99CCCC];
        _helperSideView.hidden = YES;
        [_keyWindow addSubview:_helperSideView];
   
        _helperCenterView = [[UIView alloc] initWithFrame:CGRectMake(-40, CGRectGetHeight(_keyWindow.frame)/2-20, 40, 40)];
        _helperCenterView.backgroundColor = [UIColor yellowColor];
        _helperCenterView.hidden = YES;
        [_keyWindow addSubview:_helperCenterView];
        
        self.frame = CGRectMake(-_keyWindow.frame.size.width/2 - kMenuBlankWidth, 0, _keyWindow.frame.size.width/2+kMenuBlankWidth, _keyWindow.frame.size.height);
        self.backgroundColor = [UIColor clearColor];
        [_keyWindow insertSubview:self belowSubview:_helperCenterView];
        
        _menuColor = menuColor;
        menuButtonHeight = height;
        [self addButtons:titles];
        
    }
    
    return self;
    
}

#pragma mark - 添加按钮
-(void)addButtons:(NSArray *)titles{
 
    //如果所需按钮数为偶数
    //通过window窗口的中间位置开始向上下两个方向布局
    if (titles.count % 2 == 0) {
        //用于计算添加Button的Y值
        NSInteger indexDown = titles.count/2;
        NSInteger indexUp = -1;
        
        for (NSInteger i=0; i < titles.count; i++) {
            NSString *title = titles[i];
            ADSlideMenuButton *homeButton = [[ADSlideMenuButton alloc]initWithTitle:title];
            if (i >= titles.count/2) {
                indexUp++;
                homeButton.center = CGPointMake(_keyWindow.frame.size.width/4, _keyWindow.frame.size.height/2 + (menuButtonHeight + kButtonSpace)*(indexUp + 0.5));
            }else{
                indexDown--;
                homeButton.center = CGPointMake(_keyWindow.frame.size.width/4, _keyWindow.frame.size.height/2 - (menuButtonHeight + kButtonSpace)*(indexDown + 0.5));
            }
            //统一设置宽高与Block事件
            homeButton.bounds = CGRectMake(0, 0, _keyWindow.frame.size.width /2-20*2, menuButtonHeight);
            homeButton.buttonColor = _menuColor;
            [self addSubview:homeButton];
            __weak typeof(self) weakSelf = self;
            homeButton.buttonClickBlock = ^(){
                [weakSelf tapToUntrigger];
                weakSelf.menuClickBlock(i,title,titles.count);
            };
        }
    }else{
        //否则就通过index的正负值排布在正中间按钮位置上下
        //正中间的按钮排布在窗口中间位置-20
        //在此之前的位于上方，在此之后的位于下方
        
        NSInteger index = (titles.count - 1)/2+1;
        for (NSInteger i = 0; i < titles.count; i++) {
            index--;
            NSString *title = titles[i];
            ADSlideMenuButton *homeButton = [[ADSlideMenuButton alloc] initWithTitle:title];
            //Y值小的位于上方
            homeButton.center = CGPointMake(_keyWindow.frame.size.width/4, _keyWindow.frame.size.height/2 - menuButtonHeight*index - 20*index);
            homeButton.bounds = CGRectMake(0, 0, _keyWindow.frame.size.width/2 - 20*2, menuButtonHeight);
            homeButton.buttonColor = _menuColor;
            [self addSubview:homeButton];
            __weak typeof(self) weakSelf = self;
            homeButton.buttonClickBlock = ^(){
                [weakSelf tapToUntrigger];
                weakSelf.menuClickBlock(i,title,titles.count);
            };
        }
        
    }
}



#pragma mark - 供外界调用
-(void)trigger{
    
    if (!_triggered) {
        
        [_keyWindow insertSubview:_blurView belowSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = self.bounds;
        }];
        [self beforeAnimation];
        //弹簧动画
        //从当前状态开始允许用户交互,弹开压制0.5秒,速度0.9
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.9 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            
            _helperSideView.center = CGPointMake(_keyWindow.center.x, _helperSideView.frame.size.height/2);
            
        } completion:^(BOOL finished) {
            [self finishAnimation];
        }];
        [UIView animateWithDuration:0.3 animations:^{
            _blurView.alpha = 1.0;
        }];
        [self beforeAnimation];
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:2.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _helperCenterView.center = _keyWindow.center;
        } completion:^(BOOL finished) {
            if (finished) {
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToUntrigger)];
                [_blurView addGestureRecognizer:tapGestureRecognizer];
                [self finishAnimation];
            }
        }];
        [self animateButtons];
        _triggered = YES;
    }else{
        [self tapToUntrigger];
    }
}


#pragma mark - 显示页面时按钮的动画显示
-(void)animateButtons{
  
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        
        UIView *menuButton = self.subviews[i];
        
        if ([menuButton isKindOfClass:[ADSlideMenuButton class]]) {
            
            menuButton.transform = CGAffineTransformMakeTranslation(-90, 0);
            
            [UIView animateWithDuration:0.7 delay:i*(0.3/self.subviews.count) usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
                
                menuButton.transform = CGAffineTransformIdentity;
           
            } completion:NULL];
        }
    }
    
}

#pragma mark - 按钮被点击、UIVisualEffectView被点击、_triggered为YES后点击右上角菜单时
-(void)tapToUntrigger{
    
    //修改自身frame回到屏幕左侧
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(-_keyWindow.frame.size.width/2-menuButtonHeight, 0, _keyWindow.frame.size.width/2 + kMenuBlankWidth, _keyWindow.frame.size.height);
    }];
    
    //而后通过此方法开启DisplayLink
    //在执行方法里绘制圆弧与背景
    [self beforeAnimation];
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.9 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        //修改左上角的View中心
        _helperSideView.center = CGPointMake(-_helperSideView.frame.size.width/2, _helperSideView.frame.size.height/2);
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    //隐藏视觉效果化View，UIVisualEffectView
    [UIView animateWithDuration:0.3 animations:^{
        _blurView.alpha = 0.0f;
    }];
    //再度开启DisplayLink
    [self beforeAnimation];
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:2.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
      
        _helperCenterView.center = CGPointMake(-_helperSideView.frame.size.height/2, CGRectGetHeight(_keyWindow.frame)/2);
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    _triggered = NO;
}

#pragma mark - 动画开始前的准备
-(void)beforeAnimation{
    _animationCount++;
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark - 动画结束
-(void)finishAnimation{
    _animationCount--;
    if (_animationCount == 0) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}


#pragma mark - displayLink的执行方法
-(void)displayLinkAction:(CADisplayLink *)displayLink{
    
    //最上方的
    CALayer *sideHelperPresentationLayer = [_helperSideView.layer presentationLayer];
    //中间的
    CALayer *centerHelperPresentationLayer = [_helperCenterView.layer presentationLayer];
   
    CGRect sideRect = [[sideHelperPresentationLayer valueForKeyPath:@"frame"] CGRectValue];
    CGRect centerRect = [[centerHelperPresentationLayer valueForKeyPath:@"frame"] CGRectValue];
  
    _diff = sideRect.origin.x - centerRect.origin.x;
    [self setNeedsDisplay];
    
}
#pragma mark - 图形绘制drawRect
-(void)drawRect:(CGRect)rect{
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //对于Window而言
    //从(-_keyWindow.frame.size.width/2 - kMenuBlankWidth,0)移动到了
    //(-kMenuBlankWidth,0)
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width - kMenuBlankWidth, 0)];
   
    
    //从(-kMenuBlankWidth,0)开始绘制一个圆弧，结束点是window窗口的最下方
    //(-kMenuBlankWidth,_keyWindow.frame.size.height)
    //控制曲线弯曲的点是幕中间位置的x+_diff
    //(-kMenuBlankWidth+_diff,_keyWindow.frame.size.height/2)
    //_diff初始值为0,但动画进行时其值不断改变,从0到屏幕的宽度一般+40
    [path addQuadCurveToPoint:CGPointMake(self.frame.size.width-kMenuBlankWidth, self.frame.size.height) controlPoint:CGPointMake(_keyWindow.frame.size.width/2+_diff, _keyWindow.frame.size.height/2)];
    //路径最后的终点是(0,_keyWindow.frame.size.height/2)
    //所以path的路径关键点大致为：从自身左上角的(0, 0)开始
    //addLineTo(_keyWindow.frame.size.width/2,0)
    //依次为起点绘制一个圆弧，圆弧终点为(_keyWindow.frame.size.width/2,_keyWindow.frame.size.height)
    // 最后又画到(0,_keyWindow.frame.size.height)闭合路径
    //这个路径内的颜色即为填充的颜色也就是显示时的颜色
   [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path closePath];
    //获取当前上下文添加路径并填充颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    [_menuColor set];
    CGContextFillPath(context);
    
}

- (UIColor *)colorFromRGB:(NSInteger)RGBValue {
    return [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 green:((float)((RGBValue & 0xFF00) >> 8))/255.0 blue:((float)(RGBValue & 0xFF))/255.0 alpha:1.0];
}

@end
