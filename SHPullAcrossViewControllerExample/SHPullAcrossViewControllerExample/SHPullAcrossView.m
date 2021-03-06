//
//  SHPullAcrossView.m
//  Skyhouse
//
//  Created by Bob Carson on 12/11/14.
//  Copyright (c) 2014 Skyhouse. All rights reserved.
//

#import "SHPullAcrossView.h"
//Utils
#import "SHCGRectUtils.h"
//Controllers
#import "SHPullAcrossViewController.h"

@interface SHPullAcrossView ()

@end

@implementation SHPullAcrossView

#pragma mark - init

-(instancetype)init
{
    if(self = [super init])
    {
        [self _initDefaults];
    }
    return self;
}

-(void)_initDefaults
{
    self.tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 72, 26, 32)];
    self.tabView.backgroundColor = [UIColor whiteColor];
    
    self.tabViewCornerRadius = 3.0f;
    
    [self _setupFrames];
    [self _setupRoundedCorners];
    
    [self addSubview:self.tabView];
}

#pragma mark - Setters
-(void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    [self _setupFrames];
}

-(void)setTabView:(UIView *)tabView
{
    _tabView = tabView;
}

-(void)setTabViewCornerRadius:(CGFloat)tabViewCornerRadius
{
    _tabViewCornerRadius = tabViewCornerRadius;
    [self _setupRoundedCorners];
    [self _setupFrames];
}

#pragma mark -
-(void)setTabViewFrame:(CGRect)frame
{
    self.tabView.frame = frame;
    [self _setupFrames];
}

-(void)didMoveToSuperview
{
    if(self.delgate)
    {
        [self.delgate pullAcrossViewWasAddedToSuperview:self.superview];
    }
}

-(void)_setupRoundedCorners
{
    CAShapeLayer* mask = [CAShapeLayer layer];
    mask.frame = self.tabView.bounds;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:mask.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(self.tabViewCornerRadius, self.tabViewCornerRadius)];
    mask.fillColor = [[UIColor whiteColor] CGColor];
    mask.backgroundColor = [[UIColor clearColor] CGColor];
    mask.path = [path CGPath];
    
    [self.tabView removeFromSuperview];
    self.tabView.layer.mask = mask;
    [self addSubview:self.tabView];
}

-(void)_setupFrames
{
    self.frame = CGRectWidthHeight(self.frame, self.contentView.frame.size.width + self.tabView.frame.size.width, self.contentView.frame.size.height);
    
    self.contentView.frame = CGRectX(self.contentView.frame, self.tabView.frame.size.width - 1);
    
    self.layer.masksToBounds = NO;
    
    //The offset in both directions (x and y) from the unrounded corner to the rounded corner.
    CGFloat roundedCornerOffset = self.tabViewCornerRadius * (1 - (1 / sqrt(2)));
    
    UIBezierPath* shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(self.contentView.frame.origin.x, -5)];                                                              //Top left of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.tabView.frame.origin.y)];                                  //Top right of tabView
    
    //Top left of tabView (follows rounded corner)
    [shadowPath addLineToPoint:CGPointMake(self.tabViewCornerRadius, self.tabView.frame.origin.y)];
    [shadowPath addLineToPoint:CGPointMake(roundedCornerOffset, self.tabView.frame.origin.y + roundedCornerOffset)];
    [shadowPath addLineToPoint:CGPointMake(0, self.tabView.frame.origin.y + self.tabViewCornerRadius)];
    
    //Bottom left of tabView (follows rounded corner)
    [shadowPath addLineToPoint:CGPointMake(0, self.tabView.frame.origin.y + self.tabView.frame.size.height - self.tabViewCornerRadius)];
    [shadowPath addLineToPoint:CGPointMake(roundedCornerOffset, self.tabView.frame.origin.y + self.tabView.frame.size.height - roundedCornerOffset)];
    [shadowPath addLineToPoint:CGPointMake(self.tabViewCornerRadius, self.tabView.frame.origin.y + self.tabView.frame.size.height)];
    
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.tabView.frame.origin.y + self.tabView.frame.size.height)]; //Bottom right of tabView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.contentView.frame.size.height)];                           //Bottom left of contentView
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.contentView.frame.size.height)];                                     //Bottom right of contentView
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, -5)];                                                                     //Top right of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, -5)];                                                           //Back to top left
    
    self.layer.shadowPath = shadowPath.CGPath;
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super pointInside:point withEvent:event] && ([self.contentView pointInside:[self.contentView convertPoint:point fromView:self] withEvent:event] || [self.tabView pointInside:[self.tabView convertPoint:point fromView:self] withEvent:event]);
}

@end
