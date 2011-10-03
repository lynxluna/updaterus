//
//  LUCuteCaptcha.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/3/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUCuteCaptcha.h"

static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderWidth = 10;
static CGFloat kTransitionDuration = 0.3;

@interface LUCuteCaptcha(Private)
- (void) close;
@end

@implementation LUCuteCaptcha

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _captchaView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _captchaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _captchaView.delegate = self;
        [self addSubview:_captchaView];
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *closeImage = [UIImage imageNamed:@"close"];
        UIColor* color = [UIColor colorWithRed:167.0/255 green:167.0/255 blue:267.0/255 alpha:1];
        
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_closeButton setImage:closeImage forState:UIControlStateNormal];
        [_closeButton setTitleColor:color forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
        if ([_closeButton respondsToSelector:@selector(titleLabel)]) {
            _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        } else {
            // to prevent deprecation warning, thus setFont: executed using performSelector on iOS 2.x
            [_closeButton performSelector:@selector(setFont:) withObject:[UIFont boldSystemFontOfSize:12]];
        }
        
        _closeButton.showsTouchWhenHighlighted = YES;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self addSubview:_closeButton];
        
        _delegate = delegate;
    }
    return self;
}

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    if (radius == 0) {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
    } else {
        rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
        CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    if (fillColors) {
        CGContextSaveGState(context);
        CGContextSetFillColor(context, fillColors);
        if (radius) {
            [self addRoundedRectToPath:context rect:rect radius:radius];
            CGContextFillPath(context);
        } else {
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    
    CGColorSpaceRelease(space);
}

- (void) drawRect:(CGRect)rect
{
    CGRect grayRect = CGRectOffset(rect, -0.5, -0.5);
    [self drawRect:grayRect fill:kBorderGray radius:10];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *htmlString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    if (!htmlString  || htmlString.length == 0) {

        
        if (_delegate && [_delegate respondsToSelector:@selector(cuteCaptcha:cuteGivenToUserWithId:)]) {
            [_delegate performSelector:@selector(cuteCaptcha:cuteGivenToUserWithId:)
                            withObject:self
                            withObject:_currId];
        }
        [self close];
    }
}

- (CGAffineTransform)transformForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void) show: (NSString*) userId
{
    
    CGFloat innerWidth = self.frame.size.width - (kBorderWidth+1)*2;
    CGFloat innerHeight = self.frame.size.height - (kBorderWidth+1)*2;
    
    [_closeButton sizeToFit];
    CGSize csz = _closeButton.frame.size;
    _closeButton.frame = CGRectMake(innerWidth - csz.width - 10, 
                                    kBorderWidth, 
                                    csz.width + 10, 
                                    csz.height + 10);
    
    _captchaView.frame = CGRectMake(kBorderWidth+1, kBorderWidth + _closeButton.frame.size.height + 5, 
                                    innerWidth, innerHeight - _closeButton.frame.size.height);
    
    NSString *urlReq = [NSString stringWithFormat:@"http://www.updaterus.com/index/get_captcha/%@?i", userId];
    NSURLRequest *uidReq = [NSURLRequest requestWithURL:[NSURL URLWithString:urlReq]];
    [_captchaView loadRequest:uidReq];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    [_currId release];
    _currId = [userId retain];
}

- (void) close
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    self.alpha = 0;
    [UIView commitAnimations];
}

- (void) dealloc
{
    [_currId release];
    [_captchaView release];
    [super dealloc];
}

@end
