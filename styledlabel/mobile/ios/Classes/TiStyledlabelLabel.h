/**
 * Ti.StyledLabel Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */
 
#import "TiUIView.h"

@interface TiStyledlabelLabel : TiUIView<UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIWebView* _web;
    NSString* _html;
    float _contentHeight;
//    UIGestureRecognizer *singleTap;
//    CGFloat og;
}

-(void)setHtml_:(NSString *)html;
-(void)createView;
-(float)currentContentHeight;

@end
