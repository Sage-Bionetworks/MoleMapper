//
//  PopupManager.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "PopupManager.h"
#import "PopupView.h"

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

@end
