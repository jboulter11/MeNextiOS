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
    NSMutableDictionary* thumbnails;
    NSString* partyId;
    NSString* partyName;
    unsigned int loadedCount;
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
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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

//-(void)loadThumbnails
//{
//    loadedCount=0;
//    //httpget for track details from youtube (thumbnails)
//    for(NSDictionary* track in tracks)
//    {
//        [[SharedData youtubeSessionManager] GET:[NSString stringWithFormat:@"videos?id=%@&key=%@&part=snippet&fields=items(id,snippet(title,thumbnails(high)))", track[@"youtubeId"],
//                      [[SharedData sharedData]KEY]] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//            //add URLs for thumbnails to the _thumbnails array
//            [thumbnails setObject:responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"high"][@"url"] forKey:track[@"youtubeId"]];
//            NSLog(@"%@", [thumbnails objectForKey:track[@"youtubeId"]]);
//            ++loadedCount;
//            if(loadedCount == tracks.count)
//            {
//                [self.tableView reloadData];
//            }
//            
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error with Youtube API"
//                                                            message:[error localizedDescription]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }];
//    }
//}

- (void)loadTracks
{
    //tracks = [[NSMutableArray alloc] init];
    [[SharedData sessionManager] GET:[NSString stringWithFormat:@"handler.php?action=listVideos&partyId=%@", partyId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //parse tracks into _tracks
        //Dictionary, 2kv pairs: status and videos
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            NSMutableArray* _tempTracks = [[NSMutableArray alloc] init];
            [_tempTracks addObjectsFromArray:responseObject[@"videos"]];
            tracks = _tempTracks;
            //[self loadThumbnails];
            [self.tableView reloadData];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addTrackButtonPressed:)];
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
    atstvc.partyId = detailItem[@"partyId"];
    
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

- (DetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailTableViewCell class])];
    if(!cell)
    {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([DetailTableViewCell class])];
    }
    
    NSString* songTitle = tracks[indexPath.row][@"title"];
    cell.titleTextView.text = songTitle.kv_decodeHTMLCharacterEntities;
    
    //Make string to get thumbnail
    NSMutableString* thumbnailURL = [NSMutableString stringWithString:@"https://i.ytimg.com/vi/"];
    [thumbnailURL appendString:tracks[indexPath.row][@"youtubeId"]];
    [thumbnailURL appendString:@"/mqdefault.jpg"];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailURL]];
    
    cell.upVoteButton.tag = indexPath.row;
    cell.downVoteButton.tag = indexPath.row;
    
    [cell.upVoteButton addTarget:self action:@selector(upVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.downVoteButton addTarget:self action:@selector(downVote:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString* rating = tracks[indexPath.row][@"userRating"];
    if(!(rating == (id)[NSNull null] || rating.length == 0))
    {
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
    }
    
    [cell.ratingLabel setText:tracks[indexPath.row][@"rating"]];
    
    cell.layer.shadowColor = [[UIColor grayColor] CGColor];
    cell.layer.shadowOpacity = .2;
    cell.layer.shadowRadius = 0;
    cell.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    
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
