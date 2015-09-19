//
//  QuizQuestionViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/27/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "QuizQuestionViewController.h"
#import "AppDelegate.h"

@interface QuizQuestionViewController ()

@end

@implementation QuizQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.answerIcon.image = [UIImage imageNamed:@"wrongAnswer"];
    self.title = @"Testing Your Understanding";
    self.explanation.hidden = YES;
    self.answerIcon.hidden = YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.explanation.hidden = YES;
    self.answerIcon.hidden = YES;
}

-(IBAction)rightAnswerTapped:(id)sender
{
    self.answerIcon.image = [UIImage imageNamed:@"rightAnswer"];
    self.answerIcon.hidden = NO;
    self.explanation.hidden = YES;
}

-(IBAction)wrongAnswerTapped:(id)sender
{
    self.answerIcon.image = [UIImage imageNamed:@"wrongAnswer"];
    self.answerIcon.hidden = NO;
    self.explanation.hidden = NO;
}

-(IBAction)finishQuiz:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"shouldShowInfoScreens"];
    [ud setBool:NO forKey:@"shouldShowQuiz"];
    [ud setBool:YES forKey:@"shouldShowConsent"];
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
