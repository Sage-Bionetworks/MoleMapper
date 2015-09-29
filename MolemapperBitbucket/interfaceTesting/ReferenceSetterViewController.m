//
//  ReferenceSetterViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 12/24/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "ReferenceSetterViewController.h"

@interface ReferenceSetterViewController ()

//**NOTE** The conversion from what is shown on the reference setter and stored in the database to what is shown in the relatively small
//textfield in the moleViewController must be accounted for as the referenceNames are updated and also in the Reference Converter class

@end

@implementation ReferenceSetterViewController

-(NSArray *)referencesInPicker
{
    if (!_referencesInPicker)
    {
        _referencesInPicker =
        @[@"Penny", @"Nickel", @"Dime", @"Quarter"];
    }
    return _referencesInPicker;
}

-(ReferenceConverter *)refConverter
{
    if (!_refConverter)
    {
        _refConverter = [[ReferenceConverter alloc] init];
    }
    return _refConverter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.customReferenceTextField.delegate = self;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUInteger indexOfRef = [self.referencesInPicker indexOfObject:self.measurement.referenceObject];
    if (indexOfRef != NSNotFound)
    {
        [self.pickerView selectRow:indexOfRef inComponent:0 animated:YES];
    }
    else
    {
        [self.pickerView selectRow:2 inComponent:0 animated:YES];
    }
	
    if (self.measurement)
    {
        self.currentReferenceObjectLabel.text = self.measurement.referenceObject;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *referenceObject = self.currentReferenceObjectLabel.text;
    [standardUserDefaults setValue:referenceObject forKey:@"referenceObject"];
    
    NSNumber *absoluteReferenceDiameter = [self.refConverter millimeterValueForReference:self.currentReferenceObjectLabel.text];
    
    //Save the measurement reference object (leave the rest alone, which is what the nil's are doing)
    [Measurement moleMeasurementForMole:self.measurement.whichMole
                               withDate:nil
                              withPhoto:nil
                withMeasurementDiameter:nil
                       withMeasurementX:nil
                       withMeasurementY:nil
                  withReferenceDiameter:nil
                         withReferenceX:nil
                         withReferenceY:nil
                      withMeasurementID:self.measurement.measurementID
          withAbsoluteReferenceDiameter:absoluteReferenceDiameter
               withAbsoluteMoleDiameter:nil
                    withReferenceObject:self.currentReferenceObjectLabel.text
                 inManagedObjectContext:self.context];
}

//Allows the background view controller to pick up background events and dismiss
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.customReferenceTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textFieldText = textField.text;
    if ([textFieldText isEqualToString:@""])
    {
        textFieldText = @"0.0";
    }
    textFieldText = [textFieldText stringByAppendingString:@" mm"];
    self.currentReferenceObjectLabel.text = textFieldText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        [self.view endEditing:YES];
        return YES;
    }
    else return NO;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.currentReferenceObjectLabel.text = self.referencesInPicker[row];
    //set the reference value here in the label and in the MoleView or measurement core data
}

//This should be re-implemented with returning a view so that the text size and other components can be changed
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.referencesInPicker[row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.referencesInPicker count];
}


@end
