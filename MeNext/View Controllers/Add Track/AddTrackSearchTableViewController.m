//
//  AddTrackSearchTableViewController.m
//  MeNext
//
//  Created by Jim Boulter on 7/11/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddTrackSearchTableViewController.h"
#import "AddTrackTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SharedData.h"
#import "CRToast.h"

@interface AddTrackSearchTableViewController ()
@property NSMutableArray* tracks;
@property UISearchBar* searchBar;
@end

@implementation AddTrackSearchTableViewController
@synthesize partyId;
@synthesize searchBar;
@synthesize tracks;
@synthesize currentPartyTracks;

#pragma mark - View Methods

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Add Tracks";
        
        tracks = [[NSMutableArray alloc] init];
        
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        
        [self.searchBar sizeToFit];
        
        self.tableView.tableHeaderView = self.searchBar;
        
        [self.tableView setAllowsSelection:NO];
        [self.tableView registerClass:[AddTrackTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AddTrackTableViewCell class])];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Delegate & Protocol Methods

-(void)performSearch:(NSString*)query
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        
        NSString* query = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)searchBar.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        
        [[SharedData youtubeSessionManager] GET:[NSString stringWithFormat:@"search?&key=%@&type=video&part=id,snippet&maxResults=15&q=%@&fields=items(id,snippet(title,description))", [[SharedData sharedData] KEY], query] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            @try {
                NSMutableArray* tempTracks = [[NSMutableArray alloc] init];
                for(NSInteger trackNum = 0; trackNum<15;++trackNum)
                {
                    [tempTracks addObject:responseObject[@"items"][trackNum]];
                }
                //[tracks addObjectsFromArray:responseObject[@"items"]];
                //[searchBar resignFirstResponder];
                if(![tracks isEqualToArray:tempTracks])
                {
                    //reset our stuff
                    tracks = tempTracks;
                    [self.tableView reloadData];
                }
            }
            @catch (NSException *exception) {
                //empty items
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error with Youtube API"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    if(aSearchBar.text.length > 1)
    {
        [self performSearch:searchBar.text];
    }
}

-(void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
    if(aSearchBar.text.length > 1)
    {
        [self performSearch:searchText];
    }
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
    if(aSearchBar.text.length > 1)
    {
        [self performSearch:searchBar.text];
    }
    return YES;
}

#pragma mark - Action Methods

- (void)addTrack:(id)sender
{
    UIButton* button = (UIButton*) sender;
    AddTrackTableViewCell* cell = (AddTrackTableViewCell*)button.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    //send request to add track to party
    
    NSDictionary* postDictionary = @{@"action":@"addVideo", @"partyId":partyId, @"youtubeId":tracks[row][@"id"][@"videoId"]};
    [[SharedData sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
        {
            NSDictionary* options = @{
                                     kCRToastTextKey : @"Added!",
                                     kCRToastFontKey : [UIFont boldSystemFontOfSize:16],
                                     kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                     kCRToastBackgroundColorKey : [[SharedData sharedData] meNextRed],
                                     kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                     kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                     kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                     kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                     kCRToastStatusBarStyleKey : @(UIStatusBarStyleLightContent)
                                     };
            
            [CRToastManager showNotificationWithOptions:options completionBlock:nil];
            [UIButton transitionWithView:button
                                duration:.3
                                 options:UIViewAnimationOptionTransitionCrossDissolve
                              animations:^{
                                [button setImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
                              }
                              completion:nil];
        }
        else
        {
            [SharedData loginCheck:responseObject withCompletion:^{
                [self addTrack:sender];
            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Adding Track"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tracks.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddTrackTableViewCell class])];
    if(!cell)
    {
        cell = [[AddTrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([AddTrackTableViewCell class])];
    }
    @try {
        // Configure the cell...
        NSArray* currentSearchTracks;
        if((currentSearchTracks = tracks) && currentSearchTracks)
        {
            cell.titleTextView.text = currentSearchTracks[indexPath.row][@"snippet"][@"title"];
            [cell.addTrackButton addTarget:self action:@selector(addTrack:) forControlEvents:UIControlEventTouchUpInside];
            
            //Get correct button for videos already added
            NSString* buttonImageName;
            for(NSDictionary* track in currentPartyTracks)
            {
                NSLog(@"%@ ? %@", track[@"youtubeId"], currentSearchTracks[indexPath.row][@"id"][@"videoId"]);
                if([(NSString*)track[@"youtubeId"] isEqualToString:(NSString*)currentSearchTracks[indexPath.row][@"id"][@"videoId"]])
                {
                    buttonImageName = @"Check";
                    [cell.addTrackButton setUserInteractionEnabled:NO];
                    break;
                }
            }
            if(!buttonImageName)
            {
                buttonImageName = @"AddColor";
                [cell.addTrackButton setUserInteractionEnabled:YES];
            }
            
            [cell.addTrackButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
            
            //Make string to get thumbnail
            NSMutableString* thumbnailURL = [NSMutableString stringWithString:@"https://i.ytimg.com/vi/"];
            [thumbnailURL appendString:currentSearchTracks[indexPath.row][@"id"][@"videoId"]];
            [thumbnailURL appendString:@"/mqdefault.jpg"];
            
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailURL]];
        }
        else
        {
            return [[UITableViewCell alloc] init];
        }

    }
    @catch (NSException *exception) {
        //Some crazy race condition or something, boo hoo
        return [[UITableViewCell alloc] init];
    }
        return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    CGRect searchBarFrame = self.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}

@end
