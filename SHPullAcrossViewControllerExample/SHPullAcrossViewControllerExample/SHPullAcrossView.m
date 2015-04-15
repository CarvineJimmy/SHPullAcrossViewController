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

@property (nonatomic, weak) SHPullAcrossViewController* controller;

@end

@implementation SHPullAcrossView

#pragma mark - init

-(instancetype)initWithController:(SHPullAcrossViewController*)controller
{
    if(self = [super init])
    {
        self.tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 72, 26, 32)];
        [self addSubview:self.tabView];
        
        self.controller = controller;
    }
    return self;
}

#pragma mark - Setters
-(void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    [self setupFrames];
    [self setupShadows];
}

-(void)setTabView:(UIView *)tabView
{
    _tabView = tabView;
    [self setupFrames];
    [self setupRoundedCorners];
    [self setupShadows];
}

-(void)setController:(SHPullAcrossViewController *)controller
{
    controller.tabView = self.tabView;
    _controller = controller;
}

-(void)didMoveToSuperview
{
    self.greyBackgroundView.frame = self.superview.bounds;
    if(self.greyBackgroundView.superview)
    {
        [self.greyBackgroundView removeFromSuperview];
    }
    [self.superview insertSubview:self.greyBackgroundView belowSubview:self];
    [self.controller setPosition:SHPullAcrossVCPositionClosed];
}

-(void)setupShadows
{
    self.layer.masksToBounds = NO;
    
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowOffset = CGSizeMake(-3.5, 3.5);
    
    UIBezierPath* shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(self.contentView.frame.origin.x, -5)];                                                              //Top left of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.tabView.frame.origin.y)];                                  //Top right of tabView
    [shadowPath addLineToPoint:CGPointMake(0, self.tabView.frame.origin.y)];                                                                //Top left of tabView
    [shadowPath addLineToPoint:CGPointMake(0, self.tabView.frame.origin.y + self.tabView.frame.size.height)];                               //Bottom left of tabView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.tabView.frame.origin.y + self.tabView.frame.size.height)]; //Bottom right of tabView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, self.contentView.frame.size.height)];                           //Bottom left of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.size.width, self.contentView.frame.size.height)];                         //Bottom right of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.size.width, -5)];                                                         //Top right of contentView
    [shadowPath addLineToPoint:CGPointMake(self.contentView.frame.origin.x, -5)];                                                           //Back to top left
    
    self.layer.shadowPath = shadowPath.CGPath;
}

-(void)setupRoundedCorners
{
    CAShapeLayer* mask = [CAShapeLayer layer];
    mask.frame = self.tabView.bounds;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:mask.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(3.0f, 3.0f)];
    mask.fillColor = [[UIColor whiteColor] CGColor];
    mask.backgroundColor = [[UIColor clearColor] CGColor];
    mask.path = [path CGPath];
    
    [self.tabView removeFromSuperview];
    self.tabView.layer.mask = mask;
    [self addSubview:self.tabView];
}

-(void)setupFrames
{
    self.frame = CGRectWidthHeight(self.frame, self.contentView.frame.size.width + self.tabView.frame.size.width, self.contentView.frame.size.height);
    
    self.contentView.frame = CGRectX(self.contentView.frame, self.tabView.frame.size.width - 1);
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super pointInside:point withEvent:event] && ([self.contentView pointInside:[self.contentView convertPoint:point fromView:self] withEvent:event] || [self.tabView pointInside:[self.tabView convertPoint:point fromView:self] withEvent:event]);
}

@end