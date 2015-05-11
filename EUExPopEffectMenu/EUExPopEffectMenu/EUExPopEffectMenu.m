//
//  EUExPopEffectMenu.m
//  AppCanPlugin
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExPopEffectMenu.h"
#import "JSON.h"
#import "EUtility.h"
#import "LDTumblrMenuView.h"
typedef NS_ENUM(NSUInteger, LDPopEffectType) {
    LDPopEffectTypeTumblr,
    LDPopEffectTypeYiXin,
};
@interface EUExPopEffectMenu()
@property(nonatomic,assign)LDPopEffectType type;
@property(nonatomic,strong)LDTumblrMenuView *menuView;

@end
@implementation EUExPopEffectMenu
-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
    }
    return self;
}
-(void)open:(NSMutableArray *)array{
    if ([array isKindOfClass:[NSMutableArray class]] && [array count]>0) {
        CGFloat x = [[array objectAtIndex:0] floatValue];
        CGFloat y = [[array objectAtIndex:1] floatValue];
    }
    if (self.menuView) {
        self.menuView.frame = CGRectMake(0, 0, [EUtility screenWidth], [EUtility screenHeight]);

        [EUtility brwView:meBrwView addSubview:self.menuView];
        [self.menuView show];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先设置要显示的项目" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)setItems:(NSMutableArray *)array{
    if ([array isKindOfClass:[NSMutableArray class]] && [array count]>0) {
        NSString *jsonString = [array firstObject];
        NSDictionary *inDict = [jsonString JSONValue];
        self.type = [[inDict objectForKey:@"type"] intValue];
        NSArray *inMenuList = [inDict objectForKey:@"popMenuItems"];
        LDTumblrMenuView *menuView = [[LDTumblrMenuView alloc] init];
        menuView.showStyle = self.type;
        for (int i = 0; i < inMenuList.count; i++) {
            NSDictionary *itemDict = [[inMenuList objectAtIndex:i] objectForKey:@"item"];
            NSString *itemImgPath = [EUtility getAbsPath:self.meBrwView path:itemDict[@"imgNormal"]];
            UIImage *itemImg = [UIImage imageWithContentsOfFile:itemImgPath];
            NSString *title = itemDict[@"text"];
            NSString *textColor = itemDict[@"textColor"];
            UIColor *color = [[self class] getColorWithHexColor:textColor];
            [menuView addMenuItemWithTitle:title andIcon:itemImg titleColor:color andSelectedBlock:^{
                [self menuItemClick:i];
            }];
            
        }
        self.menuView = menuView;
    }
}
-(void)close:(NSMutableArray *)array{
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        self.menuView = nil;
    }
}
-(void)menuItemClick:(int)index{
    [self.meBrwView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"uexPopEffectMenu.onItemClick(%d);",index]];
}
-(void)clean{
    self.menuView = nil;
}
#define DEFAULT_VOID_COLOR [UIColor whiteColor]

+(UIColor *)getColorWithHexColor:(NSString*)hexColor
{
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end
