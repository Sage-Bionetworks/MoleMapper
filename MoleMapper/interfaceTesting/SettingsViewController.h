//
//  SettingsViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 1/26/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property IBOutlet UITextField *emailForExport;
@property IBOutlet UIPickerView *namingPicker;

@end
