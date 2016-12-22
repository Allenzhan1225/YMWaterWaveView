//
//  ViewController.m
//  YMWaterWaveView
//
//  Created by Jack on 2016/12/22.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "YMWaveProgressView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat d = 160;
    CGRect rect = CGRectMake(0, 0, d, d);
    YMWaveProgressView *waterWaveView = [[YMWaveProgressView alloc] initWithFrame:rect];
    
    waterWaveView.center = self.view.center;
    waterWaveView.layer.cornerRadius = d / 2;
    waterWaveView.clipsToBounds = YES;
    
    [self.view addSubview:waterWaveView];
    
    [waterWaveView startWaveToPercent:0.2];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
