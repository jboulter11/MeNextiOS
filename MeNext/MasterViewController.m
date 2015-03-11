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
#import "SharedData.h"

@interface MasterViewController () {
    NSMutableArray* _objects;
}
@end

@implementation MasterViewController

#pragma mark - Misc

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

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
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MeNextLogo.png"]];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
    
    [[[SharedData sharedData] sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listJoinedParties"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse parties into _objects
        //Dictionary with one KeyValue, value is array of party Dictionaries
        if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
        {
            [_objects addObjectsFromArray:((NSDictionary*)responseObject)[@"parties"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else
        {
            [SharedData loginCheck:responseObject];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    cell.textLabel.text = _objects[indexPath.row][@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //tell detail controller
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        DetailViewController* dst = [segue destinationViewController];
        [dst setDetailItem:object];
    }
}

@end
