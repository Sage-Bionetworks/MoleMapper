//
//  DemoKLCPopupHelper.m
//  MoleMapper
//
//  Created by Dan Webster on 9/28/15.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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
