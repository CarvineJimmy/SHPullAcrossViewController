//
//  ViewController.h
//  SHPullAcrossViewControllerExample
//
//  Created by Bob Carson on 1/18/15.
//  Copyright (c) 2015 Skyhouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPullAcrossViewController.h"

@interface MasterViewController : UIViewController<SHPullAcrossViewControllerDelegate>

@property (nonatomic, strong) SHPullAcrossViewController* pullAcrossViewController;

@end

