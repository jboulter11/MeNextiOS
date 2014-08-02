//
//  DetailViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailTableViewCell.h"
#import "AddTrackSearchTableViewController.h"
#import "UIImageView+WebCache.h"

@interface DetailViewController ()
{
    NSMutableArray* _tracks;
    NSMutableDictionary* _thumbnails;
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
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

-(void)loadThumbnails
{
    //httpget for track details from youtube (thumbnails)
    for(NSDictionary* track in _tracks)
    {
        NSString* trackId = track[@"youtubeId"];
        AFHTTPSessionManager* manager = _sharedData.youtubeSessionManager;
        [manager GET:[NSString stringWithFormat:@"videos?id=%@&key=%@&part=snippet&fields=items(id,snippet(title,thumbnails(default)))", trackId, _sharedData.KEY] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //add URLs for thumbnails to the _thumbnails array
            [_thumbnails setObject:responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"] forKey:trackId];
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

- (void)loadTracks
{
    if(_tracks.count != 0)
    {
        [_tracks removeAllObjects];
        [_thumbnails removeAllObjects];
    }
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tracks = [[NSMutableArray alloc] init];
    _thumbnails = [[NSMutableDictionary alloc] init];
    
    _partyId = _detailItem[@"partyId"];
    _partyName = _detailItem[@"name"];
    
    self.title = _partyName;
    
    [self loadTracks];
}

- (void)vote:(UIButton*)button forDirection:(NSString*)direction
{
    NSInteger row = button.tag;
    NSLog([_tracks[row] description]);
    
    if([direction isEqualToString:_tracks[row][@"userRating"]])
    {
        direction = @"0";//we're un-voting
    }
    
    NSString* submissionId = _tracks[row][@"submissionId"];
    NSDictionary* postDictionary = @{@"action": @"vote", @"direction": direction, @"submissionId":submissionId, @"sessionId":[[NSUserDefaults standardUserDefaults] stringForKey:@"sessionId"]};
    
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog([responseObject description]);
        //re-fetch data on tracks to reflect new order
        [self loadTracks];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Voting"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)upVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"1"];
}

- (IBAction)downVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"-1"];
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

- (DetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"QueueCell"];
    
    cell.textLabel.text = _tracks[indexPath.row][@"title"];
    if(_thumbnails.count == _tracks.count)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_thumbnails[_tracks[indexPath.row][@"youtubeId"]]]];
    }
    cell.upVoteButton.tag = indexPath.row;
    cell.downVoteButton.tag = indexPath.row;
    
    NSString* rating = _tracks[indexPath.row][@"userRating"];
    if(!(rating == (id)[NSNull null] || rating.length == 0))
    {
        NSLog([rating description]);
        if([rating isEqualToString:@"1"])
        {
            cell.upVoteButton.imageView.image = [UIImage imageNamed:@"UpArrowColor"];
            cell.downVoteButton.imageView.image = [UIImage imageNamed:@"DownArrow"];
        }
        else if([rating isEqualToString:@"-1"])
        {
            cell.downVoteButton.imageView.image = [UIImage imageNamed:@"DownArrowColor"];
            cell.upVoteButton.imageView.image = [UIImage imageNamed:@"UpArrow"];
        }
        else
        {
            cell.downVoteButton.imageView.image = [UIImage imageNamed:@"DownArrow"];
            cell.upVoteButton.imageView.image = [UIImage imageNamed:@"UpArrow"];
        }
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddTrackSearchTableViewController* dst = [segue destinationViewController];
    dst.sharedData = self.sharedData;
    dst.partyId = _detailItem[@"partyId"];
}

@end
