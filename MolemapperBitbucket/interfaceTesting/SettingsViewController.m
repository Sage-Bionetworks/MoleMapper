//
//  SettingsViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 1/26/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *gender;
@property (nonatomic, strong) NSArray *first;
@property (nonatomic, strong) NSArray *last;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *activateDemoSwitch;

//This is a comment
@end

@implementation SettingsViewController

-(NSArray *)gender
{
    if (!_gender)
    {
        _gender = @[@"Random",@"Male",@"Female"];
    }
    return _gender;
}

-(NSArray *)first
{
    if (!_first)
    {
        _first = @[@"17th Century",@"Honorifics"];
    }
    return _first;
}

-(NSArray *)last
{
    if (!_last)
    {
        _last = @[@"Military Phonetic"];
    }
    return _last;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.emailForExport.delegate = self;
    self.namingPicker.delegate = self;
    self.namingPicker.dataSource = self;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *emailForExport = [standardUserDefaults valueForKey:@"emailForExport"];
    NSString *selectedGender = [standardUserDefaults valueForKey:@"moleNameGender"];
    if (emailForExport)
    {
        self.emailForExport.text = emailForExport;
    }
    
    if ([selectedGender isEqualToString:@"Random"])
    {
        self.genderSegmentedControl.selectedSegmentIndex = 0;
    }
    else if ([selectedGender isEqualToString:@"Male"])
    {
        self.genderSegmentedControl.selectedSegmentIndex = 1;
    }
    else if ([selectedGender isEqualToString:@"Female"])
    {
        self.genderSegmentedControl.selectedSegmentIndex = 2;
    }
    else
    {
        self.genderSegmentedControl.selectedSegmentIndex = 0;
    }
    
    BOOL showDemo = [[standardUserDefaults valueForKey:@"showDemoInfo"] boolValue];
    [self.activateDemoSwitch setOn:showDemo animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *emailForExport = self.emailForExport.text;
    if (![emailForExport isEqualToString:@""])
    {
        [standardUserDefaults setValue:emailForExport forKey:@"emailForExport"];
    }
    NSString *selectedGender = self.gender[self.genderSegmentedControl.selectedSegmentIndex];
    [standardUserDefaults setValue:selectedGender forKey:@"moleNameGender"];
}

//Allows the background view controller to pick up background events and dismiss
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.emailForExport resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textFieldText = textField.text;
    self.emailForExport.text = textFieldText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //This will be saved upon viewWillDisappear
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *title = (UILabel *)view;
    if (!title)
    {
        title = [[UILabel alloc] init];
        title.font = [title.font fontWithSize:14];
    }
    
    if (component == 0)
    {
        title.text = self.gender[row];
    }
    else if (component == 1)
    {
        title.text = self.first[row];
    }
    else if (component == 2)
    {
        title.text = self.last[row];
    }
    return title;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger *rows = 0;
    if (component == 0)
    {
        rows = [self.gender count];
    }
    else if (component == 1)
    {
        rows = [self.first count];
    }
    else if (component == 2)
    {
        rows = [self.last count];
    }
    return rows;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: return 60;
        case 1: return 100;
        case 2: return 120;
    }
    return 100;
}

- (IBAction)demoSwitchHasBeenSwitched:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL activateDemoSwitch = self.activateDemoSwitch.isOn;
    [ud setValue:[NSNumber numberWithBool:activateDemoSwitch] forKey:@"showDemoInfo"];
}





@end
