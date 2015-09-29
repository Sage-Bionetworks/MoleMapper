//
//  DemoKLCPopupHelper.m
//  MoleMapper
//
//  Created by Dan Webster on 9/28/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DemoKLCPopupHelper.h"


@implementation DemoKLCPopupHelper

+(UIView *)contentViewForDemo
{
    UIView* contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12.0;
    return contentView;
}

+(UILabel *)labelForDemoWithFontSize:(float)fontSize andText:(NSString *)text
{
    UILabel* description = [[UILabel alloc] init];
    description.translatesAutoresizingMaskIntoConstraints = NO;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 0;
    description.backgroundColor = [UIColor clearColor];
    description.textColor = [UIColor blackColor];
    description.textAlignment = NSTextAlignmentCenter;
    description.font = [UIFont systemFontOfSize:fontSize];
    description.text = text;
    return description;
}

+(APCButton *)buttonForDemoWithColor:(UIColor *)color withLabel:(NSString *)label  withEdgeInsets:(UIEdgeInsets)insets
{
    APCButton* button = [APCButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.borderColor = [color CGColor];
    button.contentEdgeInsets = insets;
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitle:label forState:UIControlStateNormal];
    return button;
}

@end
