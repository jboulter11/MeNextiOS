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

@interface MasterViewController () {
    NSMutableArray* _objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(_sharedData.splashView != nil)
    {
        [_sharedData.splashView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIImage* logoImage = [UIImage imageNamed:@"MeNextLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _objects = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager GET:[NSString stringWithFormat:@"handler.php?action=listJoinedParties"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse parties into _objects
        //Dictionary with one KeyValue, value is array of party Dictionaries
        [_objects addObjectsFromArray:((NSDictionary*)responseObject)[@"parties"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Joined Parties"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _objects = nil;
}

#pragma mark - Table View

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
        dst.sharedData = self.sharedData;
    }
    else if([[segue identifier] isEqualToString:@"showSettings"])
    {
        //do nothing, just segue
    }
    else if([[segue identifier] isEqualToString:@"joinParty"])
    {
        AddPartyTableViewController* vc = [segue destinationViewController];
        vc.sharedData = self.sharedData;
    }
}

@end
