//
//  YMWaveProgressView.h
//  YMWaterWaveView
//
//  Created by Jack on 2016/12/22.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMWaveProgressView : UIView
- (void)startWaveToPercent:(CGFloat)percent; //当前比例

- (void)setGrowthSpeed:(CGFloat)growthSpeed;    // 设置上升速度
- (void)setGradientColors:(NSArray *)colors;    // 设置渐变色
@end
