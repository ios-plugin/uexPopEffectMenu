//
//  LDTumblrMenuView.h
//  AppCanPlugin
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, LDMenuShowStyle) {
    LDMenuShowStyleFromBottom = 1,
    LDMenuShowStyleFromTop    = 2
};
typedef void (^LDMenuViewSelectedBlock)(void);

@interface LDTumblrMenuView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, readonly)UIImageView *backgroundImgView;
@property(nonatomic,assign)LDMenuShowStyle showStyle;
- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon titleColor:(UIColor*)titleColor andSelectedBlock:(LDMenuViewSelectedBlock)block;
- (void)show;


@end
