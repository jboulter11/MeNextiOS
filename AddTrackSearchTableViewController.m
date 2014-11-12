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

@interface AddTrackSearchTableViewController ()
{
    NSMutableArray* _thumbnails;
    NSMutableArray* _tracks;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation AddTrackSearchTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //reset our stuff
    [_tracks removeAllObjects];
    [_thumbnails removeAllObjects];
    
    if(![searchBar.text isEqualToString:@""])
    {
        //TODO: transform query string to Google Standard!
        NSString* query = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)searchBar.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        
        AFHTTPSessionManager* manager = _sharedData.youtubeSessionManager;
        [manager GET:[NSString stringWithFormat:@"search?&key=%@&type=video&part=id,snippet&maxResults=25&q=%@&fields=items(id,snippet(title,thumbnails(default)))", _sharedData.KEY, query] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //add URLs for thumbnails to the _thumbnails array
            @try {
                for(NSInteger trackNum = 0; trackNum<25;++trackNum)
                {
                    [_tracks addObject:responseObject[@"items"][trackNum]];
                    [_thumbnails insertObject:responseObject[@"items"][trackNum][@"snippet"][@"thumbnails"][@"default"][@"url"] atIndex:trackNum];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [searchBar resignFirstResponder];
                    [self.tableView reloadData];
                });
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
    }
}

- (IBAction)addTrack:(id)sender
{
    UIButton* button = (UIButton*) sender;
    //send request to add track to party
    
    NSDictionary* postDictionary = @{@"action":@"addVideo", @"partyId":_partyId, @"youtubeId":_tracks[button.tag][@"id"][@"videoId"]};
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];            });
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _thumbnails = [[NSMutableArray alloc] init];
    _tracks = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:235/255.0 green:39/255.0 blue:53/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return _tracks.count;
}

- (AddTrackTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTrackCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.addTrackButton.tag = indexPath.row;
    cell.textLabel.text = _tracks[indexPath.row][@"snippet"][@"title"];
    if(_thumbnails.count == _tracks.count)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_thumbnails[indexPath.row]]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
