//
//  ADRedDot.m
//  仿JM的多种动画
//
//  Created by 王奥东 on 16/7/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADRedDot.h"


/**
 
    此类用于设置画板

 
    画板是一个View，有两个对象方法，一个是创建画板指定黏贴颜色与画板大小，一个是保存要黏贴的View与是否爆炸及之后的Block操作。
    画板何时添加到窗口界面由画板自身所决定，在其内部通过手势开始时调用的setup方法将自身添加到Window窗口并开启交互
 
    无论是Cell还是Cell上的内容，其实都是添加到一个画板。
    而后由画板来执行爆炸回弹移动的操作
 
    画板初始化时保存有最大距离与黏贴颜色，size是屏幕的bouds
    画板带有一个字典用来保存黏贴的View与View对应的block。
 
    黏贴的View通过ValueWithNonretainedObject：返回的NSValue值保存。
    如果View的分离block操作没有保存在字典里，就给View添加一个手势操作开启用户交互。
    如果View爆炸后的block不为空，就将block作为值存储在字典里
    如果为空就创建一个什么都不操作的block存储 
    因此，字典里键为[NSValue valueWithNonretainedObject:] 值为block操作
 
    view的手势操作方法里，先获取到当前手势位于画板的Point，而后判断手势
    手势开始时，获取触发手势的View与位于View上的Point
    而后保存拖动坐标与原始坐标的距离差后调用setup方法
 
    setup：
    setup方法里将画板添加到window窗口上，
    并获取被手势拖动的View位于画板的左上角Point
    获取方法：[_touchView convertPoint:CGPointMake(0, 0) toView:self]
    而后根据Point与View的size创建出一个临时View并保存View的显示内容后添加到自身
    黏贴效果通过layer显示，所以给全局变量Layer声明开辟空间
    并创建出Layer的路径所需要的width、颜色、拖动与临时View的圆心距离
    获取原始View的中心坐标，拖动View的半径与通过半径计算出的圆弧效果CGFloat值
    并隐藏触摸时的View设置此时的黏贴State
 
    手势改变时通过改变临时View的center产生View跟着手指滑动而移动
    而后通过勾股定理获取此时临时View中心与原View中心的距离
    而后判断此时的黏贴状态，若是已分力不做任何操作。
    若是此时的中心距离大于最大距离则修改黏贴状态，改变Layer路径的填充颜色并移除Layer
    否则就通过刚才setup时获取的值进行一系列的数学运算来生成Layer的路径
    具体包括两端与中间路径的形状大小，计算太过繁琐，看着头疼因而直接粘贴了。
    随后给Layer设置路径并填充路径颜色，将设置的Layer添加到画板的layer上
 
    手势结束时，判断此时临时View与原View的中心距离是否大于设置的最大距离  
    如果大于就取出爆炸效果的Block操作，如果Block存在就获取Block操作返回的Bool值判断是否
    爆炸，允许爆炸就移除临时View，并在临时View的位置产生爆炸效果，不允许爆炸就就让临时
    View产生回弹效果。如果中心距离小于设置的最大距离就移除Layer，让填充颜色为Clear，让临
    时View执行回弹操作。
    以上爆炸回弹的操作都是通过画板的对象方法操作。
 
    爆炸动画是通过UIImageView的动画效果实现，产生时需要传来一个效果中心与范围半径
    效果中心即为临时View的中心，范围半径是在手势开始时通过Min
    (临时VIew.width,临时View.height)-1获取，爆炸效果结束后让临时View隐藏并移除
 
    回弹效果是接收一个Point与View，Point为原View的中心
    通过UIView的animate动画效果为EaseInOut
    在0.25秒内让View的中心移到Point并在结束后显示原View移除临时View
  
 */


typedef NS_ENUM(NSUInteger,AdhesivePlateStatus) {
    
    AdhesivePlateStickers,//粘上
    AdhesivePlateSeparate //分离
};

@implementation ADRedDot{

    NSMutableDictionary *_separateBlockDictionary;//存储view消失时触发的Block的字典
    UIPanGestureRecognizer *_gesture;//手势监控
    UIBezierPath *_cutePath;//画黏贴效果的贝塞尔曲线
    UIColor *_fillColorForCute;//填充黏贴效果的颜色
    UIView *_touchView;//被手势拖动的view
    UIColor *_bubbleColor;//黏贴效果的颜色
    CGFloat _bubbleWidth; //被拖动的view的最小边长
    UIImageView *_prototypeView;//替换被拖动View的ImageView
 
    CGFloat _R1, _R2, _X1, _X2, _Y1,_Y2;//原始view和拖动的view的半径和圆心坐标
    CGFloat _centerDistance;//原始view和拖动的view圆心距离
    CGFloat _maxDistance;//黏贴效果最大距离
    CGFloat _cosDigree;//两圆心所在直线和Y轴夹角的cosine值
    CGFloat _sinDigree;//两圆心所在直线和Y轴夹角的sine值
    
    //圆的关键点A,B,E是初始位置上圆的左右后三点，C,D,F是移动位置上的圆的三点，O,P两个圆之间画弧线所需要的点，_pointTemp是辅助点
    CGPoint _pointA,_pointB,_pointC,_pointD,_pointE,_pointF,_pointO,_pointP,_pointTemp,_pointTemp2;
    
    //画圆弧的辅助点
    CGPoint _pointDF1, _pointDF2,_pointFC1,_pointFC2,_pointBE1,_pointBE2,_pointEA1,_pointEA2,_pointAO1,_pointAO2,_pointOD1,_pointOD2,_pointCP1,_pointCP2,_pointPB1,_pointPB2;
    
    //offset 指的是 _pointA - _pointEA2, _pointEA1-_pointE..的距离，当该值设置为正方形边长的1/3.6倍时，画出来的圆弧近似贴合1/4圆;
    CGFloat _offset1, _offset2;
    CGFloat _percentage; //_centerDistance / _maxDistance;
    
    
    CGPoint _deviationPoint;//拖动坐标和原始view中心的距离差
    CGPoint _oldBackViewCenter; //原始View的中心坐标
    CAShapeLayer * _shapeLayer; //黏贴效果的形状
    AdhesivePlateStatus _status;//黏贴状态
    
}

-(instancetype)initWithMaxDistance:(CGFloat)maxDistance bubbleColor:(UIColor *)bubleColor{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _bubbleColor = bubleColor;
        _maxDistance = maxDistance;
//        替换被拖动View的ImageView
        _prototypeView = [[UIImageView alloc] init];
        //存储view消失时触发的Block的字典
        _separateBlockDictionary = [[NSMutableDictionary alloc] init];
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}


-(void)attach:(UIView *)item withSeparateBlocl:(SeparateBlock)separateBlock{
    
    NSValue *viewValue = [NSValue valueWithNonretainedObject:item];
    
    if (!_separateBlockDictionary[viewValue]) {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
        item.userInteractionEnabled = YES;
        [item addGestureRecognizer:gesture];
    }
    if (separateBlock) {
        [_separateBlockDictionary setObject:separateBlock forKey:[NSValue valueWithNonretainedObject:item]];
    }else {
        SeparateBlock block = ^BOOL(UIView *view){
            return NO;
        };
        
        [_separateBlockDictionary setObject:block forKey:[NSValue valueWithNonretainedObject:item]];
    }
    
}


-(void)handleDragGesture:(UIPanGestureRecognizer *)gesture{
    
    CGPoint dragPoint = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _touchView = gesture.view;
        CGPoint dragPountInView = [gesture locationInView:gesture.view];
        //拖动坐标和原始view中心的距离差
        _deviationPoint = CGPointMake(dragPountInView.x - gesture.view.frame.size.width/2, dragPountInView.y - gesture.view.frame.size.height/2);
        [self setUp];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
      
        _prototypeView.center = CGPointMake(dragPoint.x - _deviationPoint.x, dragPoint.y - _deviationPoint.y);
        [self drawRect];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed){
      
        if (_centerDistance > _maxDistance) {
            SeparateBlock block = _separateBlockDictionary[[NSValue valueWithNonretainedObject:_touchView]];
            if (block) {
                BOOL animationEnable = block(_touchView);
                if (animationEnable) {
                    [_prototypeView removeFromSuperview];
                    [self explosion:_prototypeView.center radius:_bubbleWidth];
                }else{
                    [self springBack:_prototypeView point:_oldBackViewCenter];
                }
            }
        }else{
            
            _fillColorForCute = [UIColor clearColor];
            [_shapeLayer removeFromSuperlayer];
            [self springBack:_prototypeView point:_oldBackViewCenter];
            
        }
        
    }
    
}


-(void)setUp{
    //将自身添加到主窗口
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    
    //被手势拖动的view位于画板的左上角point
    CGPoint animationViewOrigin = [_touchView convertPoint:CGPointMake(0, 0) toView:self];
    _prototypeView.frame = CGRectMake(animationViewOrigin.x, animationViewOrigin.y, _touchView.frame.size.width, _touchView.frame.size.height);
    _prototypeView.image = [self getImageFromView:_touchView];
    [self addSubview:_prototypeView];

    _shapeLayer = [CAShapeLayer layer];
    _bubbleWidth = MIN(_prototypeView.frame.size.width, _prototypeView.frame.size.height) - 1;
    //    拖动的view的半径
    _R2 = _bubbleWidth / 2;
    //当该值设置为正方形边长的1/3.6倍时，画出来的圆弧近似贴合1/4圆
    _offset2 = _R2 * 2 / 3.6;
    //原始view和拖动的view圆心距离
    _centerDistance = 0;
    //原始View的中心坐标
    _oldBackViewCenter = CGPointMake(animationViewOrigin.x + _touchView.frame.size.width/2, animationViewOrigin.y + _touchView.frame.size.height/2);
    _X1 = _oldBackViewCenter.x;
    _Y1 = _oldBackViewCenter.y;
    
    _fillColorForCute = _bubbleColor;
    
    _touchView.hidden = YES;
    self.userInteractionEnabled = YES;
    _status = AdhesivePlateStickers;
    
}

//求出所有关键点，用贝塞尔曲线绘制出黏贴效果。
-(void)drawRect{
    
    _X2 = _prototypeView.center.x;
    _Y2 = _prototypeView.center.y;
    _centerDistance = sqrtf((_X2 - _X1) * (_X2 - _X1) + (_Y2 - _Y1) * (_Y2 - _Y1));
    
   if(_status == AdhesivePlateSeparate){
        return;
    }
    if (_centerDistance > _maxDistance) {
        _status = AdhesivePlateSeparate;
        _fillColorForCute = [UIColor clearColor];
        [_shapeLayer removeFromSuperlayer];
        return;
    }
    if (_centerDistance == 0) {
        _cosDigree = 1;
        _sinDigree = 0;
    }else{
        _cosDigree = (_Y2 - _Y1) / _centerDistance;
        _sinDigree = (_X2 - _X1) / _centerDistance;
    }
        _percentage = _centerDistance/_maxDistance;
        _R1 = (2 - _percentage/2)*_bubbleWidth/4;
        _offset1 = _R1*2/3.6;
        _offset2 = _R2*2/3.6;
        _pointA = CGPointMake(_X1 - _R1*_cosDigree, _Y1 + _R1*_sinDigree);
        _pointB = CGPointMake(_X1 + _R1*_cosDigree, _Y1 - _R1*_sinDigree);
        _pointE = CGPointMake(_X1 - _R1*_sinDigree, _Y1 - _R1*_cosDigree);
        _pointC = CGPointMake(_X2 + _R2*_cosDigree, _Y2 - _R2*_sinDigree);
        _pointD = CGPointMake(_X2 - _R2*_cosDigree, _Y2 + _R2*_sinDigree);
        _pointF = CGPointMake(_X2 + _R2*_sinDigree, _Y2 + _R2*_cosDigree);
    
        _pointEA2 = CGPointMake(_pointA.x - _offset1*_sinDigree, _pointA.y - _offset1*_cosDigree);
        _pointEA1 = CGPointMake(_pointE.x - _offset1*_cosDigree, _pointE.y + _offset1*_sinDigree);
        _pointBE2 = CGPointMake(_pointE.x + _offset1*_cosDigree, _pointE.y - _offset1*_sinDigree);
        _pointBE1 = CGPointMake(_pointB.x - _offset1*_sinDigree, _pointB.y - _offset1*_cosDigree);
    
        _pointFC2 = CGPointMake(_pointC.x + _offset2*_sinDigree, _pointC.y + _offset2*_cosDigree);
        _pointFC1 = CGPointMake(_pointF.x + _offset2*_cosDigree, _pointF.y - _offset2*_sinDigree);
        _pointDF2 = CGPointMake(_pointF.x - _offset2*_cosDigree, _pointF.y + _offset2*_sinDigree);
        _pointDF1 = CGPointMake(_pointD.x + _offset2*_sinDigree, _pointD.y + _offset2*_cosDigree);
    
        _pointTemp = CGPointMake(_pointD.x + _percentage*(_X2 - _pointD.x), _pointD.y + _percentage*(_Y2 - _pointD.y));//关键点
        _pointTemp2 = CGPointMake(_pointD.x + (2 - _percentage)*(_X2 - _pointD.x), _pointD.y + (2 - _percentage)*(_Y2 - _pointD.y));
    
        _pointO = CGPointMake(_pointA.x + (_pointTemp.x - _pointA.x)/2, _pointA.y + (_pointTemp.y - _pointA.y)/2);
        _pointP = CGPointMake(_pointB.x + (_pointTemp2.x - _pointB.x)/2, _pointB.y + (_pointTemp2.y - _pointB.y)/2);
    
        _offset1 = _centerDistance/8;
        _offset2 =_centerDistance/8;
    
        _pointAO1 = CGPointMake(_pointA.x + _offset1*_sinDigree, _pointA.y + _offset1*_cosDigree);
        _pointAO2 = CGPointMake(_pointO.x - (3*_offset2-_offset1)*_sinDigree, _pointO.y - (3*_offset2-_offset1)*_cosDigree);
        _pointOD1 = CGPointMake(_pointO.x + 2*_offset2*_sinDigree, _pointO.y + 2*_offset2*_cosDigree);
        _pointOD2 = CGPointMake(_pointD.x - _offset2*_sinDigree, _pointD.y - _offset2*_cosDigree);
    
        _pointCP1 = CGPointMake(_pointC.x - _offset2*_sinDigree, _pointC.y - _offset2*_cosDigree);
        _pointCP2 = CGPointMake(_pointP.x + 2*_offset2*_sinDigree, _pointP.y + 2*_offset2*_cosDigree);
        _pointPB1 = CGPointMake(_pointP.x - (3*_offset2-_offset1)*_sinDigree, _pointP.y - (3*_offset2-_offset1)*_cosDigree);
        _pointPB2 = CGPointMake(_pointB.x + _offset1*_sinDigree, _pointB.y + _offset1*_cosDigree);
    
        _cutePath = [UIBezierPath bezierPath];
        [_cutePath moveToPoint:_pointB];
        [_cutePath addCurveToPoint:_pointE controlPoint1:_pointBE1 controlPoint2:_pointBE2];
        [_cutePath addCurveToPoint:_pointA controlPoint1:_pointEA1 controlPoint2:_pointEA2];
        [_cutePath addCurveToPoint:_pointO controlPoint1:_pointAO1 controlPoint2:_pointAO2];
        [_cutePath addCurveToPoint:_pointD controlPoint1:_pointOD1 controlPoint2:_pointOD2];
    
        [_cutePath addCurveToPoint:_pointF controlPoint1:_pointDF1 controlPoint2:_pointDF2];
        [_cutePath addCurveToPoint:_pointC controlPoint1:_pointFC1 controlPoint2:_pointFC2];
        [_cutePath addCurveToPoint:_pointP controlPoint1:_pointCP1 controlPoint2:_pointCP2];
        [_cutePath addCurveToPoint:_pointB controlPoint1:_pointPB1 controlPoint2:_pointPB2];
        
        _shapeLayer.path = [_cutePath CGPath];
        _shapeLayer.fillColor = [_fillColorForCute CGColor];
        [self.layer insertSublayer:_shapeLayer below:_prototypeView.layer];
    
}


//爆炸效果
-(void)explosion:(CGPoint)explosionPoint radius:(CGFloat)radius {
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 1; i < 6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"red_dot_image_%d",i]];
        [array addObject:image];
    }
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(0, 0, radius*2, radius*2);
    imageView.center = explosionPoint;
    imageView.animationImages = array;
    [imageView setAnimationDuration:0.25];
    [imageView setAnimationRepeatCount:1];
    [imageView startAnimating];
    [self addSubview:imageView];
    [self performSelector:@selector(explosionComplete) withObject:nil afterDelay:0.25 inModes:@[NSDefaultRunLoopMode]];
}



//爆炸动画结束
-(void)explosionComplete{
    _touchView.hidden = YES;
    [self removeFromSuperview];
}

//回弹效果
-(void)springBack:(UIView *)view point:(CGPoint)point{
    
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.center = point;
    } completion:^(BOOL finished) {
        if (finished) {
            _touchView.hidden = NO;
            self.userInteractionEnabled = NO;
            [view removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
    
}

//将 view 的显示效果转成一张 image
-(UIImage *)getImageFromView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, UIScreen.mainScreen.scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}



@end
