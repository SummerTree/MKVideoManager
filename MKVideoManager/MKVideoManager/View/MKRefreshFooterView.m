//
//  MKRefreshFooterView.m
//  MKVideoManager
//
//  Created by holla on 2018/12/20.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

#import "MKRefreshFooterView.h"
#import "NSBundle+MJRefresh.h"

@interface MKRefreshFooterView()
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation MKRefreshFooterView
#pragma mark - 懒加载子控件
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
    
    if (self.loadingView.constraints.count) return;
    
    // 圈圈
    CGFloat loadingCenterX = self.mj_w * 0.5;
    CGFloat loadingCenterY = self.mj_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 防止动画结束后，状态已经不是MJRefreshStateIdle
                if (state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
            }];
        } else {
            
            [self.loadingView stopAnimating];
            
        }
    } else if (state == MJRefreshStatePulling) {
        
        [self.loadingView stopAnimating];
        
    } else if (state == MJRefreshStateRefreshing) {
        
        [self.loadingView startAnimating];
    } else if (state == MJRefreshStateNoMoreData) {
        
        [self.loadingView stopAnimating];
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent{
    NSLog(@"pulling up: %@", [NSString stringWithFormat:@"%.2f", pullingPercent]);
}

#pragma mark - custom setting

- (void)setCustomSetting{
    self.stateLabel.hidden = YES;
    self.loadingView.hidden = NO;
}
@end
