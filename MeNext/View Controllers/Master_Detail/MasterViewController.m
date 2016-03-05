//
//  MasterViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AddPartyTableViewController.h"
#import "SettingsViewController.h"
#import "NSString+HTML.h"
#import "SharedData.h"

@interface MasterViewController ()
@property NSMutableArray* parties;
@property BOOL animateNavBar;
@end

@implementation MasterViewController
@synthesize detailViewController;
@synthesize parties;
@synthesize animateNavBar;

-(instancetype)init
{
    if(self = [super init])
    {
        [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        self.animateNavBar = YES;
    }
    return self;
}

#pragma mark - Misc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Nav Bar Logo
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MeNextLogo"]];
    
    //Nav Bar Buttons
    UIButton* gear = [UIButton buttonWithType:UIButtonTypeCustom];
    gear.bounds = CGRectMake(0, 0, 22, 22);
    [gear setImage:[UIImage imageNamed:@"Gear"] forState:UIControlStateNormal];
    [gear addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:gear]];
    
    UIButton* add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.bounds = CGRectMake(0,0,22,22);
    [add setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(showJoinParty) forControlEvents:UIControlEventTouchUpInside];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:add]];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor meNextPurpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTable];
    if(animateNavBar)
    {
        [self.navigationController setNavigationBarHidden:YES];
        animateNavBar = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    if([self.navigationController isNavigationBarHidden])
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - Table View

-(void) refreshTable
{
    parties = [[NSMutableArray alloc] init];
    
    [[SharedData sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listJoinedParties"] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if(![parties isEqual:((NSDictionary*)responseObject)[@"parties"]])
        {
            //parse parties into _objects
            //Dictionary with one KeyValue, value is array of party Dictionaries
            if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
            {
                [parties addObjectsFromArray:((NSDictionary*)responseObject)[@"parties"]];
                [self.tableView reloadData];
            }
            else
            {
                [SharedData loginCheck:responseObject withCompletion:^{
                    [self refreshTable];
                }];
            }
        }
        [self.refreshControl endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error loading joined parties"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return parties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSString* text = parties[indexPath.row][@"name"];
    cell.textLabel.text = text.kv_decodeHTMLCharacterEntities;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    detailViewController = [[DetailViewController alloc] init];
    [detailViewController setParty:parties[indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Navigation

- (void)showSettings
{
    [[self navigationController] pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (void)showJoinParty
{
    [[self navigationController] pushViewController:[[AddPartyTableViewController alloc] init] animated:YES];
}

@end
