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

@interface MasterViewController () {
    NSMutableArray* _objects;
}
@end

@implementation MasterViewController
@synthesize detailViewController;

-(instancetype)init
{
    if(self = [super init])
    {
        [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return self;
}

#pragma mark - Misc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _objects = nil;
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
    
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showJoinParty)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTable];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if([[SharedData sharedData] splashView] != nil)
    {
        [[[SharedData sharedData] splashView] removeFromSuperview];
    }
}

#pragma mark - Table View

-(void) refreshTable
{
    _objects = [[NSMutableArray alloc] init];
    
    [[SharedData sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listJoinedParties"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(![_objects isEqual:((NSDictionary*)responseObject)[@"parties"]])
        {
            //parse parties into _objects
            //Dictionary with one KeyValue, value is array of party Dictionaries
            if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
            {
                [_objects addObjectsFromArray:((NSDictionary*)responseObject)[@"parties"]];
                [self.tableView reloadData];
            }
            else
            {
                [SharedData loginCheck:responseObject withCompletion:^{
                    [self refreshTable];
                }];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Joined Parties"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    NSString* text = _objects[indexPath.row][@"name"];
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
    [detailViewController setDetailItem:_objects[indexPath.row]];
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
