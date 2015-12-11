//
//  ReferenceSetterViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 12/24/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "ReferenceConverter.h"

@interface ReferenceSetterViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

//**NOTE** The conversion from what is shown on the reference setter and stored in the database to what is shown in the relatively small
//textfield in the moleViewController must be accounted for as the referenceNames are updated and also in the Reference Converter class

@property IBOutlet UILabel *currentReferenceObjectLabel;
@property IBOutlet UIPickerView *pickerView;
@property IBOutlet UITextField *customReferenceTextField;

@property (nonatomic, strong) NSArray *referencesInPicker;
@property (nonatomic, strong) ReferenceConverter *refConverter;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) Measurement *measurement;

@end
