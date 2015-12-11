//
//  PopupView.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "PopupView.h"

@implementation PopupView

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [_popup dismiss:YES];
}

@end
