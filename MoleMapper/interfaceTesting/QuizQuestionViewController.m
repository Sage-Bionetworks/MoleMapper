//
//  QuizQuestionViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/27/15.
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
