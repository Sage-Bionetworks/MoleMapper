//
//  PopupManager.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
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


#import "PopupManager.h"
#import "PopupView.h"
#import "DemoKLCPopupHelper.h"

@implementation PopupManager

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;

    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void) createPopupWithText:(NSString *)text
{
    PopupView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"PopupView" owner:self options:nil] lastObject];
    
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    CGSize size = containerView.bounds.size;
    contentView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [contentView addSubview:containerView];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView];
    containerView.popup = popup;
    containerView.descriptionText.text = text;
    
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    containerView.layer.cornerRadius = 5;
    containerView.layer.masksToBounds = YES;
    
    popup.shouldDismissOnBackgroundTouch = YES;
    [popup show];
}

- (void) createPopupWithText:(NSString *)text andSize:(CGFloat)fontSize
{
    PopupView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"PopupView" owner:self options:nil] lastObject];
    
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    CGSize size = containerView.bounds.size;
    contentView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [contentView addSubview:containerView];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView];
    containerView.popup = popup;
    containerView.descriptionText.text = text;
    containerView.descriptionText.textColor = [UIColor darkGrayColor];
    containerView.descriptionText.font = [UIFont systemFontOfSize:fontSize];
    
    
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    containerView.layer.cornerRadius = 5;
    containerView.layer.masksToBounds = YES;
    
    popup.shouldDismissOnBackgroundTouch = YES;
    popup.shouldDismissOnContentTouch = YES;
    popup.maskType = KLCPopupMaskTypeDimmed;
    [popup show];
}


@end
