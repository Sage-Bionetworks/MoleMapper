//
//  HelpMovieViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 7/31/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import "HelpMovieViewController.h"

@interface HelpMovieViewController ()

@end

@implementation HelpMovieViewController

@synthesize moviePlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Help Demo";
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self playMovie:self];
}

-(void)playMovie:(id)sender
{
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.helpMovieName ofType:@"mov"]]];
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = 20;
    CGFloat vertOffset = navBarHeight + statusBarHeight;
    CGRect movieFrame = CGRectMake(self.view.frame.origin.x,
                                   self.view.frame.origin.y + vertOffset,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height - vertOffset);
    [self.moviePlayer.view setFrame:movieFrame];
    [self.moviePlayer play];
    [self.view addSubview:self.moviePlayer.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
