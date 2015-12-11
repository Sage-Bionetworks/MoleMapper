//
//  PopupView.h
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "KLCPopup.h"

@interface PopupView : UIView

@property KLCPopup *popup;
@property (retain, nonatomic) IBOutlet UILabel *descriptionText;
- (IBAction)closeButtonPressed:(UIButton *)sender;

@end
