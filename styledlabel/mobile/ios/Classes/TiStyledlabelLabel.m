/**
 * Ti.StyledLabel Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiStyledlabelLabel.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiUtils.h"

@interface TiStyledlabelLabel (Private)

-(void)updateTextViewsHtml;
-(void)keyboardWillShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;


@end

@implementation TiStyledlabelLabel

#pragma mark -
#pragma mark Initialization and Memory Management

- (id)init {
	if ((self = [super init])) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	}
	return self;
}

-(void)dealloc
{
    RELEASE_TO_NIL(_html);
    RELEASE_TO_NIL(_web);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark View management

-(UIWebView*)web {
    if (!_web) {
        _web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        UIView *v = [[_web subviews] lastObject];
        [v setBackgroundColor:[UIColor clearColor]];
        [v setOpaque:NO];
        [_web setBackgroundColor:[UIColor clearColor]];
        [_web setOpaque:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        if([v isKindOfClass:[UIScrollView class]])
        {
            [v setScrollEnabled:NO];
        }
        _web.delegate = self;
        _web.scrollView.delegate = self;
        [_web.scrollView setScrollEnabled:NO];
        
        [self addSubview:_web];

    }
    [_web setBackgroundColor:[UIColor clearColor]];
    [_web setOpaque:NO];
    return _web;
}

-(void)createView
{
    [self web];
}


-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self web] positionRect:bounds];
    if (_html != nil) {
        [[self web] loadHTMLString:_html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    [super frameSizeChanged:frame bounds:bounds];
}

-(CGFloat)autoHeightForWidth:(CGFloat)value
{
	return _contentHeight;
}
 
-(CGFloat)autoWidthForWidth:(CGFloat)value
{
	return value;
}


#pragma mark -
#pragma mark Public APIs

-(float)currentContentHeight
{
    return _contentHeight;
}

-(void)setHtml_:(NSString *)html
{
    NSString* head =
    @"<meta name=viewport content=\"user-scalable=0\" /><style type=text/css>body{ margin: 0; padding: 0 }</style>";
    
    NSString* onload =
    @"<br clear=all/><script type=text/javascript>\
    window.onload = function() { window.location.href = 'ready://' + document.body.offsetHeight; };\
    </script>";
    
    RELEASE_TO_NIL(_html);
    _html = [[NSString stringWithFormat:@"%@%@%@", head, html, onload] retain];

    [[self web] loadHTMLString:_html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    
    [self web].scrollView.scrollEnabled = NO;
    [self web].scrollView.delegate = self;
    
}

#pragma mark -
#pragma mark Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSLog(@"load request with navtype: %d and scheme: %@", navigationType, [url scheme]);
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[url scheme] isEqualToString:@"ready"]) {
            _contentHeight = [[url host] floatValue];
            [((TiViewProxy*)[self proxy]) willEnqueue];
            [[((TiViewProxy*)[self proxy]) parent] willChangeSize];
            return NO;
        } else if ([[url scheme] isEqualToString:@"about"]) {
            return YES;
        } else if ([[url scheme] isEqualToString:@"blankify"]) {
            [[self proxy] fireEvent:@"blankify.answer.updated" withObject:[[NSDictionary alloc] initWithObjectsAndKeys:[url host], @"data", nil]];
            return NO;
        } else if ([[url scheme] isEqualToString:@"selected"]) {
            [[self proxy] fireEvent:@"blankify.answer.selected" withObject:[[NSDictionary alloc] initWithObjectsAndKeys:[url host], @"data", nil]];
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    scrollView.bounds = [self web].bounds;
}

- (void)singleTapGestureCaptured:(UIGestureRecognizer *)gesture
{

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardBeginFrame = [self.web convertRect:beginFrameValue.CGRectValue fromView:nil];
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.web convertRect:endFrameValue.CGRectValue fromView:nil];
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    [[self proxy] fireEvent:@"ti.styledlabel.keyboard.will.show" withObject:[[NSDictionary alloc]
                                                                             initWithObjectsAndKeys:curveValue, @"curveValue",
                                                                             durationValue, @"durationValue",
                                                                             [NSNumber numberWithFloat:beginFrameValue.CGRectValue.origin.y], @"beginFrameValue_origin_y",
                                                                             [NSNumber numberWithFloat:endFrameValue.CGRectValue.origin.y], @"endFrameValue_origin_y",
                                                                             [NSNumber numberWithFloat:keyboardBeginFrame.origin.y], @"keyboardBeginFrame_origin_y",
                                                                             [NSNumber numberWithFloat:keyboardEndFrame.origin.y], @"keyboardEndFrame_origin_y",                                                                                                    nil]];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;

    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardBeginFrame = [self.web convertRect:beginFrameValue.CGRectValue fromView:nil];
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.web convertRect:endFrameValue.CGRectValue fromView:nil];

    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    [[self proxy] fireEvent:@"ti.styledlabel.keyboard.will.hide" withObject:[[NSDictionary alloc]
                                                                             initWithObjectsAndKeys:curveValue, @"curveValue",
                                                                             durationValue, @"durationValue",
                                                                             [NSNumber numberWithFloat:beginFrameValue.CGRectValue.origin.y], @"beginFrameValue_origin_y",
                                                                             [NSNumber numberWithFloat:endFrameValue.CGRectValue.origin.y], @"endFrameValue_origin_y",
                                                                             [NSNumber numberWithFloat:keyboardBeginFrame.origin.y], @"keyboardBeginFrame_origin_y",
                                                                             [NSNumber numberWithFloat:keyboardEndFrame.origin.y], @"keyboardEndFrame_origin_y",
                                                                                                    nil]];
}


@end
