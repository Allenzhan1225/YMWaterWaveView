//
//  YMWaveProgressView.m
//  YMWaterWaveView
//
//  Created by Jack on 2016/12/22.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "YMWaveProgressView.h"


@interface YMWaveProgressView ()

/**
  CADisplayLink是一个和屏幕刷新率同步定时器类，通过创建一个CADisplayLink类displayLink，把它添加到runloop，并给它提供一个方法，在屏幕刷新时调用
 */
@property (nonatomic,strong) CADisplayLink * displayLink;



/**
 waveLayer用来绘制波形曲线，并作为gradientLayer的mask，gradientLayer用来呈现背景的渐变色，若不需要渐变色，可以只用waveLayer来实现效果
 */
@property (nonatomic,strong) CAShapeLayer * waveLayer;  //绘制波形
@property (nonatomic,strong) CAGradientLayer * gradientLayer;  //绘制渐变


/**
 colors为渐变色需要用到的颜色数组
 */
@property (nonatomic,strong) NSArray * colors;


/**
 ，percent为整个小球的进度比例,波浪上升的比例
 */
@property (nonatomic,assign) CGFloat  percent;



//绘制波形的变量定义，使用波形曲线y=Asin(ωx+φ)+k进行绘制

/**
 waveAmplitude，波纹振幅，A
 */
@property (nonatomic,assign) CGFloat waveAmplitude;

/**
 waveCycle波纹周期，T = 2π/ω
 */
@property (nonatomic,assign) CGFloat waveCycle;


/**
 offsetX，波浪x位移，φ
 */
@property (nonatomic,assign) CGFloat offsetX;


/**
 currentWavePointY，当前波浪高度，k
 */
@property (nonatomic,assign) CGFloat currentWavePointY;


/**
 waveSpeed波纹速度，用来累加到相位φ上，达到波纹水平移动的效果
 */
@property (nonatomic,assign) CGFloat waveSpeed;

/**
 waveGrowth波纹上升速度，累加到k上，达到波浪高度上升的效果
 */
@property (nonatomic,assign) CGFloat waveGrowth;


@property (nonatomic, assign) BOOL bWaveFinished;   // 上升完成


// 用来计算波峰一定范围内的波动值
@property (nonatomic, assign) BOOL increase;
@property (nonatomic, assign) CGFloat variable;

@end




@implementation YMWaveProgressView

static const CGFloat kExtraHeight = 20;     // 保证水波波峰不被裁剪，增加部分额外的高度



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
        self.backgroundColor = [UIColor colorWithRed:4 / 255.0 green:181 / 255.0 blue:108 / 255.0 alpha:1];
    }
    return self;
}




/**
 初始化属性值
 */
-(void)defaultConfig
{
    // 默认设置一些属性
    self.waveCycle = 1.66 * M_PI / CGRectGetWidth(self.frame);   //影响波长
    self.currentWavePointY = CGRectGetHeight(self.frame) * self.percent; //波纹从下往上升起
    
    self.waveGrowth = 1.0;
    self.waveSpeed = 0.4 / M_PI;
    
    self.offsetX = 0;
    
    
}


/**
 

 @param percent 开始比例
 */
- (void)startWaveToPercent:(CGFloat)percent
{
   
    self.percent = percent;
    
    [self resetProperty];
    [self resetLayer];
    
    if (self.displayLink)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    self.bWaveFinished = NO;
    
    // 启动同步渲染绘制波纹
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCurrentWave:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}



/**
 
 @param growthSpeed 上升速度
 */
- (void)setGrowthSpeed:(CGFloat)growthSpeed
{
     self.waveGrowth = growthSpeed;
    
}

/**
 
 @param colors   设置渐变色
 */
- (void)setGradientColors:(NSArray *)colors
{

    // 必须保证传进来的参数为UIColor*的数组
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor * color in colors)
    {
        
        [array addObject:(__bridge id)color.CGColor];
    }
    
    self.colors = array;
    
}


- (void)setColorsWithArray:(NSArray *)colors
{
    self.colors = colors;
}
- (void)resetProperty
{
    // 重置属性
    self.currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
    self.offsetX = 0;
    
    self.variable = 1.6;
    self.increase = NO;
}

- (void)resetLayer
{
    // 动画开始之前重置layer
    if (self.waveLayer)
    {
        [self.waveLayer removeFromSuperlayer];
        self.waveLayer = nil;
    }
    self.waveLayer = [CAShapeLayer layer];
    
    // 设置渐变
    if (self.gradientLayer)
    {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    self.gradientLayer = [CAGradientLayer layer];
    
    self.gradientLayer.frame = [self gradientLayerFrame];
    [self setupGradientColor];
    
    [self.gradientLayer setMask:self.waveLayer];
    [self.layer addSublayer:self.gradientLayer];
}

- (void)setupGradientColor
{
    // gradientLayer设置渐变色
    if ([self.colors count] < 1)
    {
        self.colors = [self defaultColors];
    }
    
    self.gradientLayer.colors = self.colors;
    
    //设定颜色分割点
    NSInteger count = [self.colors count];
    CGFloat d = 1.0 / count;
    
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++)
    {
        NSNumber *num = @(d + d * i);
        [locations addObject:num];
    }
    NSNumber *lastNum = @(1.0f);
    [locations addObject:lastNum];
    
    self.gradientLayer.locations = locations;
    
    // 设置渐变方向，从上往下
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
}

- (CGRect)gradientLayerFrame
{
    // gradientLayer在上升完成之后的frame值，如果gradientLayer在上升过程中不断变化frame值会导致一开始绘制卡顿，所以只进行一次赋值
    
    CGFloat gradientLayerHeight = CGRectGetHeight(self.frame) * self.percent + kExtraHeight;
    
    if (gradientLayerHeight > CGRectGetHeight(self.frame))
    {
        gradientLayerHeight = CGRectGetHeight(self.frame);
    }
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.frame) - gradientLayerHeight, CGRectGetWidth(self.frame), gradientLayerHeight);
    
    return frame;
}
- (NSArray *)defaultColors
{
    // 默认的渐变色
    UIColor *color0 = [UIColor colorWithRed:164 / 255.0 green:216 / 255.0 blue:222 / 255.0 alpha:1];
    UIColor *color1 = [UIColor colorWithRed:105 / 255.0 green:192 / 255.0 blue:154 / 255.0 alpha:1];
    
    NSArray *colors = @[(__bridge id)color0.CGColor, (__bridge id)color1.CGColor];
    return colors;
}






- (void)stopWave
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)setCurrentWave:(CADisplayLink *)displayLink
{
    if ([self waveFinished])
    {
        self.bWaveFinished = YES;
        [self amplitudeReduce];
        
        // 减小到0之后动画停止。
        if (self.waveAmplitude <= 0)
        {
            [self stopWave];
            return;
        }
    }
    else
    {
        // 波浪高度未到指定高度 继续上涨
        [self amplitudeChanged];
        self.currentWavePointY -= self.waveGrowth;
    }
    
    self.offsetX += self.waveSpeed;
    [self setCurrentWaveLayerPath];
}

- (BOOL)waveFinished
{
    // 波浪上升动画是否完成
    CGFloat d = CGRectGetHeight(self.frame) - CGRectGetHeight(self.gradientLayer.frame);
    CGFloat extraH = MIN(d, kExtraHeight);
    BOOL bFinished = self.currentWavePointY <= extraH;
    
    return bFinished;
}

- (void)setCurrentWaveLayerPath
{
    // 通过正弦曲线来绘制波浪形状
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = self.currentWavePointY;
    
    CGPathMoveToPoint(path, nil, 0, y);
    CGFloat width = CGRectGetWidth(self.frame);
    for (float x = 0.0f; x <= width; x++)
    {
        // 正弦波浪公式
        y = self.waveAmplitude * sin(self.waveCycle * x + self.offsetX) + self.currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, width, CGRectGetHeight(self.frame));
    CGPathAddLineToPoint(path, nil, 0, CGRectGetHeight(self.frame));
    CGPathCloseSubpath(path);
    
    self.waveLayer.path = path;
    CGPathRelease(path);
}

- (void)amplitudeChanged
{
    // 波峰在一定范围之内进行轻微波动
    
    // 波峰该继续增大或减小
    if (self.increase)
    {
        self.variable += 0.01;
    }
    else
    {
        self.variable -= 0.01;
    }
    
    // 变化的范围
    if (self.variable <= 1)
    {
        self.increase = YES;
    }
    
    if (self.variable >= 1.6)
    {
        self.increase = NO;
    }
    
    // 根据variable值来决定波峰
    self.waveAmplitude = self.variable * 5;
}

- (void)amplitudeReduce
{
    // 波浪上升完成后，波峰开始逐渐降低
    self.waveAmplitude -= 0.066;
}




@end






















