//
//  HeaderAddedTVC.m
//  MoleMapper
//
//  Created by Dan Webster on 9/14/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "HeaderAddedTVC.h"
#import "AppDelegate.h"
#import "FeedbackRKModule.h"
#import "ProfileRKLaunchPad.h"
#import "PopupManager.h"

@implementation HeaderAddedTVC

-(void)viewDidLoad
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ohsu.edu/xd/health/services/dermatology/melanoma-community-registry/"]];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"feedback"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowFeedback = YES;
    }
}

@end
