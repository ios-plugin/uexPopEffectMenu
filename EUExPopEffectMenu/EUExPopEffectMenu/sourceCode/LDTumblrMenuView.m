//
//  LDTumblrMenuView.m
//  AppCanPlugin
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "LDTumblrMenuView.h"

#define LDMenuViewTag 1999
#define LDMenuViewImageHeight 90
#define LDMenuViewTitleHeight 20
#define LDMenuViewVerticalPadding 10
#define LDMenuViewHorizontalMargin 10
#define LDMenuViewRriseAnimationID @"LDMenuViewRriseAnimationID"
#define LDMenuViewDismissAnimationID @"LDMenuViewDismissAnimationID"
#define LDMenuViewDropAnimationID @"LDMenuViewDropAnimationID"

#define LDMenuViewAnimationTime 0.36
#define LDMenuViewAnimationInterval (LDMenuViewAnimationTime / 5)

#define TumblrBlue [UIColor colorWithRed:45/255.0f green:68/255.0f blue:94/255.0f alpha:1.0]

@interface LDMenuItemButton : UIButton
+ (id)TumblrMenuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon titleColor:(UIColor*)titleColor andSelectedBlock:(LDMenuViewSelectedBlock)block;
@property(nonatomic,copy)LDMenuViewSelectedBlock selectedBlock;
@end

@implementation LDMenuItemButton

+ (id)TumblrMenuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon titleColor:(UIColor*)titleColor andSelectedBlock:(LDMenuViewSelectedBlock)block
{
    LDMenuItemButton *button = [LDMenuItemButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    button.selectedBlock = block;
    
    return button;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, LDMenuViewImageHeight, LDMenuViewImageHeight);
    self.titleLabel.frame = CGRectMake(0, LDMenuViewImageHeight, LDMenuViewImageHeight, LDMenuViewTitleHeight);
}
@end

@implementation LDTumblrMenuView
{
    UIImageView *backgroundView_;
    NSMutableArray *buttons_;
}
@synthesize backgroundImgView = backgroundView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        self.backgroundColor = [UIColor clearColor];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView_.backgroundColor = TumblrBlue;
        backgroundView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView_];
        buttons_ = [[NSMutableArray alloc] initWithCapacity:6];
        
        
    }
    return self;
}

- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon titleColor:(UIColor*)titleColor andSelectedBlock:(LDMenuViewSelectedBlock)block
{
    LDMenuItemButton *button = [LDMenuItemButton TumblrMenuItemButtonWithTitle:title andIcon:icon  titleColor:(UIColor*)titleColor andSelectedBlock:block];
    
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [buttons_ addObject:button];
}

- (CGRect)frameForButtonAtIndex:(NSUInteger)index
{
    NSUInteger columnCount = 3;
    NSUInteger columnIndex =  index % columnCount;
    
    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);
    NSUInteger rowIndex = index / columnCount;
    
    CGFloat itemHeight = (LDMenuViewImageHeight + LDMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * LDMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) / 2.0;
    CGFloat verticalPadding = (self.bounds.size.width - LDMenuViewHorizontalMargin * 2 - LDMenuViewImageHeight * 3) / 2.0;
    
    CGFloat offsetX = LDMenuViewHorizontalMargin;
    offsetX += (LDMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (LDMenuViewImageHeight + LDMenuViewTitleHeight + LDMenuViewVerticalPadding) * rowIndex;
    
    
    return CGRectMake(offsetX, offsetY, LDMenuViewImageHeight, (LDMenuViewImageHeight+LDMenuViewTitleHeight));
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < buttons_.count; i++) {
        LDMenuItemButton *button = buttons_[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[LDMenuItemButton class]]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView* subview in buttons_) {
        if (CGRectContainsPoint(subview.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

- (void)dismiss:(id)sender
{
    [self dismissAnimation];
    double delayInSeconds = LDMenuViewAnimationTime  + LDMenuViewAnimationInterval * (buttons_.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}


- (void)buttonTapped:(LDMenuItemButton*)btn
{
    [self dismiss:nil];
    double delayInSeconds = LDMenuViewAnimationTime  + LDMenuViewAnimationInterval * (buttons_.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"呵呵呵呵");
        btn.selectedBlock();
        
    });
}


- (void)riseAnimation
{
    NSUInteger columnCount = 3;
    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);
    
    
    for (NSUInteger index = 0; index < buttons_.count; index++) {
        LDMenuItemButton *button = buttons_[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        
        CGPoint fromPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * LDMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += LDMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += LDMenuViewAnimationInterval * 2;
        }
        
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = LDMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:LDMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
        
        
        
    }
}
-(void)dropAnimation{
    NSUInteger columnCount = 3;
    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);
    
    
    for (NSUInteger index = 0; index < buttons_.count; index++) {
        LDMenuItemButton *button = buttons_[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        CGPoint fromPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y -  (rowCount - rowIndex + 2)*200 - (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * LDMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += LDMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += LDMenuViewAnimationInterval * 2;
        }
        
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = LDMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:LDMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"dropAnimation"];
        
    }
}
- (void)dismissAnimation
{
    NSUInteger columnCount = 3;
    for (NSUInteger index = 0; index < buttons_.count; index++) {
        LDMenuItemButton *button = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        CGPoint fromPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * LDMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += LDMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += LDMenuViewAnimationInterval * 2;
        }
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
        positionAnimation.duration = LDMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:LDMenuViewDismissAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
        
        
        
    }
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSUInteger columnCount = 3;
    if([anim valueForKey:LDMenuViewRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:LDMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }
    else if([anim valueForKey:LDMenuViewDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:LDMenuViewDismissAnimationID] unsignedIntegerValue];
        NSUInteger rowIndex = index / columnCount;
        
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0);
        
        view.layer.position = toPosition;
    }else if([anim valueForKey:LDMenuViewDropAnimationID]) {
        NSUInteger index = [[anim valueForKey:LDMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + LDMenuViewImageHeight / 2.0,frame.origin.y + (LDMenuViewImageHeight + LDMenuViewTitleHeight) / 2.0 - 50);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;

    }
}


- (void)show
{

    if (self.showStyle == LDMenuShowStyleFromBottom) {
        [self riseAnimation];
    }else{
        [self dropAnimation];
        self.backgroundImgView.backgroundColor = [UIColor whiteColor];

    }
}


@end
