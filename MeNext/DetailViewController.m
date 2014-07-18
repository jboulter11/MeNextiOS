//
//  DetailViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+WebCache.h"

static NSString* _KEY = @"AIzaSyAbh1CseUDq0NKangT-QRIeyOoZLz6jCII";//MeNext Youtube iOS API Key

@interface DetailViewController ()
{
    NSMutableArray* _tracks;
    NSMutableArray* _thumbnails;
    NSString* _partyId;
    NSString* _partyName;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem)//if group exists
    {
        //self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

-(void)loadThumbnails
{
    //TODO: httpget for track details from youtube (thumbnails)
    for(NSDictionary* track in _tracks)
    {
        NSString* trackId = track[@"youtubeId"];
        AFHTTPSessionManager* manager = _sharedData.youtubeSessionManager;
        [manager GET:[NSString stringWithFormat:@"videos?id=%@&key=%@&part=snippet&fields=items(id,snippet(title,thumbnails(default)))", trackId, _KEY] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //add URLs for thumbnails to the _thumbnails array
            [_thumbnails insertObject:responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"] atIndex:0];
            //TODO: Fix this!
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error with Youtube API"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tracks = [[NSMutableArray alloc] init];
    _thumbnails = [[NSMutableArray alloc] init];
    
    _partyId = _detailItem[@"partyId"];
    _partyName = _detailItem[@"name"];
    
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager GET:[NSString stringWithFormat:@"handler.php?action=listVideos&partyId=%@&token=%@", _partyId, [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionId"]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse tracks into _tracks
        //Dictionary, 2kv pairs: status and videos
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            [_tracks addObjectsFromArray:responseObject[@"videos"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadThumbnails];
                [self.tableView reloadData];
            });
        }
        else
        {
            //check error, probably need to re-log in.
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In"
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
    _tracks = nil;
    _thumbnails = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueCell"];
    
    cell.textLabel.text = _tracks[indexPath.row][@"title"];
    if(_thumbnails.count == _tracks.count)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_thumbnails[indexPath.row]]];
    }
    
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
