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
    description.textColor = [UIColor darkGrayColor];
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

+(UIButton *)demoOffButtonWithColor:(UIColor *)color withLabel:(NSString *)label
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.borderColor = [[UIColor clearColor] CGColor];
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:label forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    return button;
}

@end
