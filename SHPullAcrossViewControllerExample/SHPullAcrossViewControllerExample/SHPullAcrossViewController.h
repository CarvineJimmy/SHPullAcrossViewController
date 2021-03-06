//
//  SHPullAcrossViewController.h
//  Skyhouse
//
//  Created by Bob Carson on 12/9/14.
//  Copyright (c) 2014 Skyhouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPullAcrossView.h"

typedef NS_ENUM(NSInteger, SHPullAcrossVCPosition)  {
    SHPullAcrossVCPositionClosed,
    SHPullAcrossVCPositionOpen
};

@class SHPullAcrossViewController;

@protocol SHPullAcrossViewControllerDelegate <NSObject>

@optional

-(void)pullAcrossViewController:(SHPullAcrossViewController*)controller didChangePosition:(SHPullAcrossVCPosition)position hidden:(BOOL)hidden;

@end

@interface SHPullAcrossViewController : UIViewController <UIGestureRecognizerDelegate, SHPullAcrossViewDelegate>

#pragma mark - Properties
#pragma mark SHPullAcrossView Offsets

/*
 How far onto the screen the edge of the content view controller is when the pull across controller is closed. Positive numbers move it onto the screen. Negative number move it furtherer off the screen.
 
 Defaults to 0.
 */
@property (nonatomic) CGFloat closedXOffset;

/*
 How much further the SHPullAcrossView will open than the size of the content view controller. Zero will open until all content is on the screen. Positive numbers will open further, leaving empty space on the right. Negative numbers will open less, hiding part of the content view
 
 Defaults to 0.
 */
@property (nonatomic) CGFloat openXOffset;

/*
 The offset of the SHPullAcrossView from the top of the screen.
 
 Defaults to 0
 */
@property (nonatomic) CGFloat yOffset;

#pragma mark Tabview

/*
 This is the view that sticks out while the controller is in the closed state. It is what the user pulls or taps to extend the SHPullAcrossViewController. This view is created by SHPullAcrossViewController but can be altered safely.
 
 Do not change the frame for this view. Instead use tabViewYPosition and tabViewSize.
*/
@property (nonatomic, readonly) UIView* tabView;

/*
 The Y postition of the tab view. Use this rather than setting the frame of the tabView.
 
 Defaults to 72.
 */
@property (nonatomic) CGFloat tabViewYPosition;

/*
 The size of the tab view. Use this rather than setting the frame of the tabView.
 
 Defaults to (26, 32).
 */
@property (nonatomic) CGSize tabViewSize;

/*
 The radius of the rounded corners for the tab view.  Zero for unrounded corners.
 
 Defaults to 3.
 */
@property (nonatomic) CGFloat tabViewCornerRadius;

#pragma mark Content View

/*
 The background color of the content view.  The content view will not be visible unless the content view controller has transparency.
 
 Defaults to white.
 */
@property (nonatomic, strong) UIColor* contentViewBackgroundColor;

#pragma mark Superview Mask
/*
 When true, places a mask over the SHPullAcrossView's superview when the SHPullAcrossView is extended or being extended. This prevents touches to the superview and can also fade to darken the superview.
 
 Defaults to YES.
 */
@property (nonatomic) BOOL showSuperviewMaskWhenOpen;

/*
 The color that will be shown over the parent view when the menu is pulled out. The alpha of this color will be changed programmatically to an appropriate value thus the alpha of this color will be disregarded.

 Defaults to 10% grey.
 */
@property (nonatomic, copy) UIColor* superviewMaskColor;

/*
 The alpha of the superview mask when SHPullAcrossView is fully extended.
 
 A value between 0 and 1, inclusive.
 
 Defaults to 0.5f.
 */
@property (nonatomic) CGFloat superviewMaskMaxAlpha;

/*
 These are the SHPullAcrossView layer's shadow properties. They behave the same as any CGLayer's shadow properties.
 */
#pragma mark Shadows

/*
 Set to 0 to hide the shadow.
 
 Defaults to 0.75f.
*/
@property (nonatomic) CGFloat shadowOpacity;

//Defaults to black.
@property (nonatomic) CGColorRef shadowColor;

//Defaults to 2.5f.
@property (nonatomic) CGFloat shadowRadius;

//Defaults to CGSizeMake(-3.5, 3.5)
@property (nonatomic) CGSize shadowOffset;

#pragma mark Positioning and Visibility
/*
 See the setter methods below for details on position and hidden.
 */
@property (nonatomic) SHPullAcrossVCPosition position;
@property (nonatomic) BOOL hidden;

#pragma mark Delegate
@property (nonatomic, weak) id<SHPullAcrossViewControllerDelegate> delegate;

#pragma mark - Methods
#pragma mark Init
/*
 The only way SHPullAcrossViewController should be initialized.
 
 The passed in UIViewController's view will be displayed in the SHPullAcrossView
 */
-(instancetype)initWithViewController:(UIViewController*)viewController;

#pragma mark Positioning and Visibility
/*
 Sets the position of the SHPullAcrossView to open or closed with the option to animate the change.
 
 Defaults to SHPullAcrossVCPositionClosed
 */
-(void)setPosition:(SHPullAcrossVCPosition)position;
-(void)setPosition:(SHPullAcrossVCPosition)position animated:(BOOL)animated;

/*
 Sets the visibility of the SHPullAcrossView the option to animate the change.
 
 Defaults to NO.
 */
-(void)setHidden:(BOOL)hidden;
-(void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end

