//
//  HeaderAddedTVC.m
//  MoleMapper
//
//  Created by Dan Webster on 9/14/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "HeaderAddedTVC.h"
#import "AppDelegate.h"

@implementation HeaderAddedTVC

-(void)viewDidLoad
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ohsu.edu/xd/health/services/dermatology/melanoma-community-registry/"]];
    }
}

@end
