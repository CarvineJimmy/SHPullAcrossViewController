//
//  SHPullAcrossViewController.m
//  Skyhouse
//
//  Created by Bob Carson on 12/9/14.
//  Copyright (c) 2014 Skyhouse. All rights reserved.
//

#import "SHPullAcrossViewController.h"
//Utils
#import "SHCGRectUtils.h"
//Views
#import "SHPullAcrossView.h"
#import "SHPullAcrossViewControllerPanGestureRecognizer.h"

@interface SHPullAcrossViewController ()

@property (nonatomic, strong) SHPullAcrossView* pullAcrossView;
@property (nonatomic) BOOL panGesturesExist;
@property (nonatomic) BOOL tapGestureExists;
@property (nonatomic) BOOL animating;
@property (nonatomic) CGFloat lastXMovement;
@property (nonatomic) CGFloat minimumPanVelocity;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) CGFloat shadowWidth;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic) CGFloat backgroundMaxFade;

//TODO: implement this
@property (nonatomic, strong) UITapGestureRecognizer* greyTap;

@end

@implementation SHPullAcrossViewController

#pragma mark - Inits

-(instancetype)init
{
    return [self initWithViewController:nil];
}

-(instancetype)initWithViewController:(UIViewController*)viewController
{
    if(self = [super init])
    {
        [self _initDefaults];
        
        self.pullAcrossView = [[SHPullAcrossView alloc] init];
        self.pullAcrossView.delgate = self;
        self.view = self.pullAcrossView;
        self.pullAcrossView.contentViewController = viewController;
        [self addChildViewController:self.pullAcrossView.contentViewController];
        self.pullAcrossView.contentView = self.pullAcrossView.contentViewController.view;
        [self.pullAcrossView addSubview:self.pullAcrossView.contentView];
        
        [self setupPanGestureRecognizers];
        [self setupTapGestureRecognizer];
    }
    return self;
}

-(void)_initDefaults
{
    _position = SHPullAcrossVCPositionOpen;
    _panGesturesExist = NO;
    _tapGestureExists = NO;
    _animating = NO;
    _minimumPanVelocity = 500;
    _animationDuration = .3f;
    _shadowWidth = 5;
    _hidden = NO;
    _backgroundMaxFade = .5f;
    _maskColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    _tabViewYPosition = 72;
    _tabViewSize = CGSizeMake(26, 32);
}

#pragma mark - Getters and Setters

-(UIView*) tabView
{
    if(self.pullAcrossView)
    {
        return self.pullAcrossView.tabView;
    }
    else
    {
        return nil;
    }
}

-(void) setTabViewYPosition:(CGFloat)tabViewYPosition
{
    _tabViewYPosition = tabViewYPosition;
    [self _updateTabViewFrame];
}

-(void) setTabViewSize:(CGSize)tabViewSize
{
    _tabViewSize = tabViewSize;
    [self _updateTabViewFrame];
}

#pragma mark - Positioning

-(void)setPosition:(SHPullAcrossVCPosition)position
{
    [self setPosition:position animated:NO];
}

-(void)setPosition:(SHPullAcrossVCPosition)position animated:(BOOL)animated
{
    NSTimeInterval animationDuration;
    if(animated)
    {
        animationDuration = self.animationDuration;
    }
    else
    {
        animationDuration = 0;
    }
    [self _setPosition:position withDuration:animationDuration];
}

-(void)closePullAcrossView
{
    [self setPosition:SHPullAcrossVCPositionClosed animated:YES];
}

-(void)setHidden:(BOOL)hidden
{
    [self setHidden:hidden animated:NO];
}

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if(self.hidden != hidden)
    {
        _hidden = hidden;
        void(^completion)(BOOL finished) = ^(BOOL finished){
            self.pullAcrossView.hidden = hidden;
            self.backgroundView.hidden = YES;
        };
        CGRect finalFrame;
        if(hidden)
        {
            finalFrame = CGRectX(self.pullAcrossView.frame, self.view.superview.frame.size.width + self.shadowWidth);
        }
        else
        {
            finalFrame = CGRectX(self.pullAcrossView.frame, [self closedXPosition]);
        }
        if(animated)
        {
            NSTimeInterval duration;
            if(self.position == SHPullAcrossVCPositionOpen)
            {
                duration = self.animationDuration;
                _position = SHPullAcrossVCPositionClosed;
            }
            else
            {
                duration = .2;
            }
            if(!hidden)
            {
                completion(YES);
                completion = nil;
            }
            [UIView animateWithDuration:duration animations:^{
                self.pullAcrossView.frame = finalFrame;
            } completion:completion];
        }
        else
        {
            self.pullAcrossView.frame = finalFrame;
            completion(YES);
        }
    }
}

-(void) swapPosition
{
    if(self.position == SHPullAcrossVCPositionClosed)
    {
        [self setPosition:SHPullAcrossVCPositionOpen animated:YES];
    }
    else
    {
        [self setPosition:SHPullAcrossVCPositionClosed animated:YES];
    }
}

#pragma mark - Gesture Recognizers

-(void)setupPanGestureRecognizers
{
    if(!self.panGesturesExist)
    {
        UIPanGestureRecognizer* tabPan = [[SHPullAcrossViewControllerPanGestureRecognizer alloc]initWithTarget:self action:@selector(_handlePanGesture:)];
        UIPanGestureRecognizer* contentPan = [[SHPullAcrossViewControllerPanGestureRecognizer alloc]initWithTarget:self action:@selector(_handlePanGesture:)];
        tabPan.delegate = contentPan.delegate = self;
        [self.pullAcrossView.tabView addGestureRecognizer:tabPan];
        [self.pullAcrossView.contentView addGestureRecognizer:contentPan];
        self.panGesturesExist = YES;
    }
}

-(void)setupTapGestureRecognizer
{
    if(!self.tapGestureExists)
    {
        UITapGestureRecognizer* tabTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_handleTapGesture:)];
        tabTap.delegate = self;
        [self.pullAcrossView.tabView addGestureRecognizer:tabTap];
        self.tapGestureExists = YES;
    }
}

-(void)_handleTapGesture:(UITapGestureRecognizer*)recognizer
{
    [self swapPosition];
}

-(void)_handlePanGesture:(UIPanGestureRecognizer*)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.lastXMovement = 0;
            self.backgroundView.hidden = NO;
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat xMovement = [recognizer translationInView:self.pullAcrossView].x;
            
            CGFloat currentLocation = self.pullAcrossView.frame.origin.x;
            CGFloat newLocation = currentLocation + xMovement - self.lastXMovement;
            
            if(newLocation < [self openXPosition])
            {
                newLocation = [self openXPosition];
            }
            else if(newLocation > [self closedXPosition])
            {
                newLocation = [self closedXPosition];
            }
            
            self.pullAcrossView.frame = CGRectX(self.pullAcrossView.frame, newLocation);
            self.lastXMovement = xMovement;
            self.backgroundView.backgroundColor = [self determineBackgroundColorForPan];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            [self _handlePanGestureEnded:recognizer];
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        {
            [self _handlePanGestureEnded:recognizer];
            break;
        }
            
        default:
        {
            break;
        }
    }
}

-(void)_handlePanGestureEnded:(UIPanGestureRecognizer*)recognizer
{
    BOOL middleOnScreen = self.pullAcrossView.frame.origin.x + (self.pullAcrossView.frame.size.width / 2) < self.view.superview.frame.size.width;
    CGFloat velocity = [recognizer velocityInView:self.pullAcrossView].x;
    NSTimeInterval duration;
    SHPullAcrossVCPosition position;
    if(fabs(velocity) > self.minimumPanVelocity)
    {
        if(velocity < 0)
        {
            position = SHPullAcrossVCPositionOpen;
        }
        else
        {
            position = SHPullAcrossVCPositionClosed;
        }
        duration = fabs([self _distanceRemainingToPosition:position] / velocity);
    }
    else
    {
        //Middle is off the screen
        if(middleOnScreen)
        {
            position = SHPullAcrossVCPositionOpen;
        }
        else //Middle is on screen
        {
            position = SHPullAcrossVCPositionClosed;
        }
        duration = fabs([self _distanceRemainingToPosition:position] / (self.pullAcrossView.frame.size.width / 2) * (self.animationDuration * .75));
    }
    [self _setPosition:position withDuration:duration];
}

#pragma mark - SHPullAcrossViewDelegate

-(void) pullAcrossViewWasAddedToSuperView:(UIView*)superView
{
    [self _setupBackgroundView:superView];
}

#pragma mark -

-(void)_updateTabViewFrame
{
    [self.pullAcrossView setTabViewFrame:CGRectMake(0, self.tabViewYPosition, self.tabViewSize.width, self.tabViewSize.height)];
}

-(void)_setupBackgroundView:(UIView*)superView
{
    self.backgroundView = [[UIView alloc] init];
    
    self.backgroundView.frame = superView.bounds;
    if(self.backgroundView.superview)
    {
        [self.backgroundView removeFromSuperview];
    }
    [superView insertSubview:self.backgroundView belowSubview:self.pullAcrossView];
    
    self.position = SHPullAcrossVCPositionClosed;
}

-(CGFloat)_distanceRemainingToPosition:(SHPullAcrossVCPosition)position
{
    CGFloat distanceRemaining;
    if(position == SHPullAcrossVCPositionOpen)
    {
        distanceRemaining = self.pullAcrossView.frame.origin.x + self.pullAcrossView.frame.size.width - (self.view.superview.frame.size.width + self.shadowWidth);
    }
    else
    {
        distanceRemaining = self.view.superview.frame.size.width + self.shadowWidth - self.pullAcrossView.frame.origin.x;
    }
    return distanceRemaining;
}

-(void)_setPosition:(SHPullAcrossVCPosition)position withDuration:(NSTimeInterval)duration
{
    void(^animations)() = ^{
        self.pullAcrossView.frame = [self determineFinalPosition:position];
        self.backgroundView.backgroundColor = [self determineBackgroundColorForPosition:position];
    };
    
    void(^completion)(BOOL finished) = ^(BOOL finished){
        self.backgroundView.hidden = position == SHPullAcrossVCPositionClosed;
        if([self.delegate respondsToSelector:@selector(pullAcrossViewController:didChangePosition:hidden:)])
        {
            [self.delegate pullAcrossViewController:self didChangePosition:position hidden:self.hidden];
        }
        _position = position;
    };
    if(position == SHPullAcrossVCPositionOpen)
    {
        self.backgroundView.hidden = NO;
    }
    if(duration > 0)
    {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

-(CGRect)determineFinalPosition:(SHPullAcrossVCPosition)position
{
    CGRect finalPosition;
    if(position == SHPullAcrossVCPositionClosed)
    {
        finalPosition = CGRectX(self.pullAcrossView.frame, [self closedXPosition]);
    }
    else
    {
        finalPosition = CGRectX(self.pullAcrossView.frame, [self openXPosition]);
    }
    return finalPosition;
}

-(UIColor*)determineBackgroundColorForPosition:(SHPullAcrossVCPosition)position
{
    CGFloat finalAlpha;
    if(position == SHPullAcrossVCPositionClosed)
    {
        finalAlpha = 0;
    }
    else
    {
        finalAlpha = self.backgroundMaxFade;
    }
    return [self.maskColor colorWithAlphaComponent:finalAlpha];
}

-(UIColor*)determineBackgroundColorForPan
{
    CGFloat pullAcrossPercentage = 1 - ((self.pullAcrossView.frame.origin.x - [self openXPosition]) / (self.pullAcrossView.frame.size.width - [self openXPosition]));
    return [self.maskColor colorWithAlphaComponent:pullAcrossPercentage * self.backgroundMaxFade];
}

-(CGFloat)closedXPosition
{
    return self.view.superview.frame.size.width + self.shadowWidth - self.pullAcrossView.tabView.frame.size.width;
}

-(CGFloat)openXPosition
{
    return self.view.superview.frame.size.width + self.shadowWidth - self.pullAcrossView.frame.size.width;
}
@end
