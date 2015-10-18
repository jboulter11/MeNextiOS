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

@interface AddTrackSearchTableViewController () <UISearchResultsUpdating>
@property NSMutableArray* tracks;
@property UISearchController* searchController;
@property UISearchBar* searchBar;
@end

@implementation AddTrackSearchTableViewController
@synthesize partyId;
@synthesize searchController, searchBar;
@synthesize tracks;
@synthesize currentPartyTracks;

#pragma mark - View Methods

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Add Tracks";
        
        tracks = [[NSMutableArray alloc] init];
        
        searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchBar = searchController.searchBar;
        searchController.searchResultsUpdater = self;
        
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.hidesNavigationBarDuringPresentation = NO;
        
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchController.searchBar.clipsToBounds = YES;
        
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [searchBar setHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [searchBar setHidden:YES];
    [searchController setActive:NO];
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
        
        
        NSString* filteredQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)query, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        NSString* path = [NSString stringWithFormat:@"search?&key=%@&type=video&part=id,snippet&maxResults=15&q=%@&fields=items(id,snippet(title,description))", [SharedData youtubeKey], filteredQuery];
        
        [[SharedData youtubeSessionManager] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            @try {
                NSMutableArray* tempTracks = [[NSMutableArray alloc] init];
                for(NSInteger trackNum = 0; trackNum<15; ++trackNum)
                {
                    [tempTracks addObject:responseObject[@"items"][trackNum]];
                }
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



-(void)updateSearchResultsForSearchController:(UISearchController *)aSearchController
{
    if(aSearchController.searchBar.text.length > 1)
    {
        [self performSearch:aSearchController.searchBar.text];
    }
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
    return NO;
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
                                     kCRToastBackgroundColorKey : [UIColor meNextRedColor],
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
