/**
 * Ti.Pageflip Module
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Transition.h"


@interface FadeTransition : NSObject<Transition> {
    UIView* currentView;
    UIView* newView;
    
    PageFlipperDirection flipDirection;
}

@property (nonatomic, assign) float transitionDuration;

@end
