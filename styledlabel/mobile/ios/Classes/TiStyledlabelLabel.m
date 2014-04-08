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

@end

@implementation TiStyledlabelLabel

#pragma mark -
#pragma mark Initialization and Memory Management

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

-(void)dealloc
{
    RELEASE_TO_NIL(_html);
    RELEASE_TO_NIL(_web);
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
        [self addSubview:_web];
        singleTap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [[self web].scrollView addGestureRecognizer:singleTap];
         NSLog(@"ya set tap 0 agin");
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
    [self web].scrollView.delegate= self;
    
    singleTap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [[self web].scrollView addGestureRecognizer:singleTap];
    NSLog(@"set tap 1 again");


}

#pragma mark -
#pragma mark Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
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
        }
    }
    
    [self.proxy fireEvent:@"click" withObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                               [url absoluteString], @"url",
                                               nil]];}

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
    NSLog(@"in og");
    og = scrollView.bounds.origin.y;
    NSLog(@"og is: %f", og);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //CGFloat z = [self web].bounds.origin.y - scrollView.bounds.origin.y;
    NSLog(@"sv origin %f", scrollView.bounds.origin.y);
    NSLog(@"sv height %f", scrollView.bounds.size.height);
    CGFloat z = scrollView.contentOffset.y;
    [[self proxy] fireEvent:@"ui.scroll.wv" withObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f", z] , @"data", nil]];
    scrollView.bounds = [self web].bounds;
}

- (void)singleTapGestureCaptured:(UIGestureRecognizer *)gesture
{
    NSLog(@"tap registered");
    CGPoint touchPoint=[gesture locationInView:[self web].scrollView];
    NSLog(@"here is touchpt %f", touchPoint.y);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"should reg");
    if([touch.view isKindOfClass:[UIScrollView class]]) return YES; else return NO;
}


@end
