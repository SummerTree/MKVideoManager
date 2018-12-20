//
//  MKRefreshHeaderView.m
//  MKVideoManager
//
//  Created by holla on 2018/12/20.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

#import "MKRefreshHeaderView.h"
#import "NSBundle+MJRefresh.h"

@interface MKRefreshHeaderView()
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end


@implementation MKRefreshHeaderView
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = NO;
        
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}
#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    [self setCustomSetting];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    // 箭头的中心点
    CGFloat arrowCenterX = self.mj_w * 0.5;
    
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }
}

- (void)setState:(MJRefreshState)state
{
    
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            [self.loadingView stopAnimating];
        } else {
            [self.loadingView stopAnimating];
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView stopAnimating];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent{
    NSLog(@"pulling down: %@", [NSString stringWithFormat:@"%.2f", pullingPercent]);
}

#pragma mark - custom setting

- (void)setCustomSetting{
    self.stateLabel.hidden = YES;
    self.lastUpdatedTimeLabel.hidden = YES;
}

@end
