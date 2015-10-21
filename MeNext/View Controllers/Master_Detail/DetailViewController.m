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
#import "NSString+HTML.h"
#import "SharedData.h"

@interface DetailViewController ()
{
    NSMutableArray* tracks;
    NSString* partyId;
    NSString* partyName;
    unsigned int loadedCount;
}
@end

@implementation DetailViewController
@synthesize party;

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        tracks = [[NSMutableArray alloc] init];
        partyId = nil;
        partyName = nil;
        
        [self.tableView setAllowsSelection:NO];
        
        // Initialize the refresh control.
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor meNextPurpleColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(loadTracks)
                      forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    tracks = nil;
}

#pragma mark - Loading content

- (void)loadTracks
{
    //tracks = [[NSMutableArray alloc] init];
    [[SharedData sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listVideos&partyId=%@", partyId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse tracks
        //Dictionary, 2kv pairs: status and videos
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            NSMutableArray* _tempTracks = [[NSMutableArray alloc] init];
            [_tempTracks addObjectsFromArray:responseObject[@"videos"]];
            tracks = _tempTracks;
            [self.tableView reloadData];
        }
        else
        {
            //check error, probably need to re-log in.
            [SharedData loginCheck:responseObject withCompletion:^{
                [self loadTracks];
            }];
        }
        [self.refreshControl endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error loading tracks"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    partyId = party[@"partyId"];
    partyName = party[@"name"];
    
    self.title = partyName;
    
    [self loadTracks];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIButton* add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.bounds = CGRectMake(0,0,22,22);
    [add setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addTrackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:add]];
}

#pragma mark - Voting

- (void)vote:(UIButton*)button forDirection:(NSString*)direction
{
    //NSInteger row = button.tag;
    DetailTableViewCell* cell = (DetailTableViewCell *)button.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    
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
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error voting"
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }
    
    
}

#pragma mark - Actions

- (void)upVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"1"];
}

- (void)downVote:(id)sender
{
    [self vote:(UIButton*)sender forDirection:@"-1"];
}

- (void)addTrackButtonPressed:(id)sender
{
    AddTrackSearchTableViewController* atstvc = [[AddTrackSearchTableViewController alloc] init];
    atstvc.partyId = party[@"partyId"];
    atstvc.currentPartyTracks = tracks;
    
    [self.navigationController pushViewController:atstvc animated:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailTableViewCell class])];
    if(!cell)
    {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([DetailTableViewCell class])];
    }
    
    [cell.upVoteButton addTarget:self action:@selector(upVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.downVoteButton addTarget:self action:@selector(downVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell configureForIndexPath:indexPath withTrack:tracks[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
