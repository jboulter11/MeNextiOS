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
#import "SharedData.h"

@interface DetailViewController ()
{
    NSMutableArray* tracks;
    NSMutableDictionary* thumbnails;
    NSString* partyId;
    NSString* partyName;
}
@end

@implementation DetailViewController
@synthesize detailItem;

#pragma mark - Init

- (instancetype)init
{
    if(self = [super init])
    {
        tracks = nil;
        thumbnails = nil;
        partyId = nil;
        partyName = nil;
        
        [self.tableView setAllowsSelection:NO];
    }
    return self;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    tracks = nil;
    thumbnails = nil;
}

#pragma mark - Loading content

-(void)loadThumbnails
{
    //httpget for track details from youtube (thumbnails)
    for(NSDictionary* track in tracks)
    {
        [[SharedData youtubeSessionManager] GET:[NSString stringWithFormat:@"videos?id=%@&key=%@&part=snippet&fields=items(id,snippet(title,thumbnails(default)))", track[@"youtubeId"],
                      [[SharedData sharedData]KEY]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //add URLs for thumbnails to the _thumbnails array
            [thumbnails setObject:responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"] forKey:track[@"youtubeId"]];
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
    [[SharedData sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listVideos&partyId=%@", partyId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse tracks into _tracks
        //Dictionary, 2kv pairs: status and videos
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            NSMutableArray* _tempTracks = [[NSMutableArray alloc] init];
            [_tempTracks addObjectsFromArray:responseObject[@"videos"]];
            tracks = _tempTracks;
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

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    tracks = [[NSMutableArray alloc] init];
    thumbnails = [[NSMutableDictionary alloc] init];
    
    partyId = detailItem[@"partyId"];
    partyName = detailItem[@"name"];
    
    self.title = partyName;
    
    [self loadTracks];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Voting

- (void)vote:(UIButton*)button forDirection:(NSString*)direction
{
    NSInteger row = button.tag;
    
    if(tracks.count >= row)
    {
        if([direction isEqualToString:tracks[row][@"userRating"]])
        {
            direction = @"0";//we're un-voting
        }
        
        NSString* submissionId = tracks[row][@"submissionId"];
        NSDictionary* postDictionary = @{@"action": @"vote", @"direction": direction, @"submissionId":submissionId};
        
        [[SharedData sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
            //re-fetch data on tracks to reflect new order
            if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
            {
                [self loadTracks];
            }
            else
            {
                [SharedData loginCheck:responseObject withCompletion:^{
                    [self vote:button forDirection:direction];
                }];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Voting"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    
    
}

- (void)upVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"1"];
}

- (void)downVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"-1"];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tracks.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (DetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailTableViewCell class])];
    if(!cell)
    {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([DetailTableViewCell class])];
    }
    
    cell.titleTextView.text = tracks[indexPath.row][@"title"];
    if((indexPath.row <= thumbnails.count) && (thumbnails[tracks[indexPath.row][@"youtubeId"]] != nil))
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnails[tracks[indexPath.row][@"youtubeId"]]]];
    }
    cell.upVoteButton.tag = indexPath.row;
    cell.downVoteButton.tag = indexPath.row;
    
    NSString* rating = tracks[indexPath.row][@"userRating"];
    if(!(rating == (id)[NSNull null] || rating.length == 0))
    {
        if([rating isEqualToString:@"1"])
        {
            cell.upVoteButton.imageView.image = [UIImage imageNamed:@"UpArrowColor"];
        }
        else if([rating isEqualToString:@"-1"])
        {
            cell.downVoteButton.imageView.image = [UIImage imageNamed:@"DownArrowColor"];
        }
    }
    
    [cell.ratingLabel setText:tracks[indexPath.row][@"rating"]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddTrackSearchTableViewController* dst = [segue destinationViewController];
    dst.partyId = detailItem[@"partyId"];
}

@end
