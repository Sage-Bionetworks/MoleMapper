//
//  MenuTVC.m
//  MoleMapper
//
//  Created by Dan Webster on 1/5/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import "learnMoreViewController.h"
#import "StatisticsTVC.h"
#import "BodyMapViewController.h"

@interface learnMoreViewController ()

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation learnMoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *)menuItems
{
    if (!_menuItems)
    {
        _menuItems = @[@"About Us", @"Export", @"FAQ", @"Reminders", @"Settings", @"Stats"];
    }
    return _menuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];

    self.tableView.sectionHeaderHeight = 3.0;
    self.tableView.sectionFooterHeight = 3.0;
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.menuItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.layer setCornerRadius:15.0f];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderWidth:0.5f];
    [cell.layer setBorderColor:[[UIColor grayColor] CGColor]];
    NSInteger section = indexPath.section;
    cell.textLabel.text = [self.menuItems objectAtIndex:section];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 9.0f;
    return 3.0f;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Stats"])
    {
        [self performSegueWithIdentifier:@"menuToStatsSegue" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"menuToStatsSegue"])
    {
        StatisticsTVC *destVC = segue.destinationViewController;
        BodyMapViewController *bmvc = [self.navigationController.viewControllers objectAtIndex:0];
        destVC.context = bmvc.context;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
