//
//  DetailViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "DetailViewController.h"

static NSString* _KEY = @"AIzaSyAbh1CseUDq0NKangT-QRIeyOoZLz6jCII";

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tracks = [[NSMutableArray alloc] init];
    _thumbnails = [[NSMutableArray alloc] init];
    
    _partyId = _detailItem[@"partyId"];
    _partyName = _detailItem[@"name"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //TODO: httpget for tracks from MeNext Server API
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        NSString* _URL = [NSString stringWithFormat:@"http://www.vmutti.com/handler.php?action=listvideos&partyId=%@", _partyId];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_URL]];
        request.HTTPMethod = @"GET";
        //request.HTTPBody = [[NSString stringWithFormat:@"action=listvideos&partyId=%@", _detailItem] dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDataTask* dt = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //completion handler
            if(!error && ((NSHTTPURLResponse*)response).statusCode == 200)
            {
                NSError* jsonError = nil;
                NSArray* results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&jsonError];
                
                if(!jsonError && results)
                {
                    for(NSDictionary* track in results)
                    {
                        [_tracks addObject:track[@"title"]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
            }
        }];
        [dt resume];
    });
    
    
    //TODO: httpget for track details from youtube
    
    //[_activityIndicator startAnimating];
    
//    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
//    
//    //send the actual request asyncronously
//    dispatch_async(queue, ^{
//        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
//        
//        for(NSString* trackId in _tracks)
//        {
//            NSString* _URL = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?id=%@&key=%@&part=snippet&fields=items(id, snippet(title, thumbnails(default)))", trackId, _KEY];
//            
//            NSURLSessionDataTask* dt = [session dataTaskWithURL:[NSURL URLWithString:_URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//            {
//                //completion handler
//                if(!error && ((NSHTTPURLResponse*)response).statusCode == 200)
//                {
//                    NSError* jsonError = nil; //this is to catch an error if we get one back from our JSON Parser
//                    
//                    NSDictionary* results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&jsonError];
//                    
//                    if(!jsonError)
//                    {
//                        
//                        //go get resources needed from Dictionary
//                        NSData* thumbnailAsData = results[@"snippet"][@"thumbnails"][@"default"];
//                        UIImage* thumbnail = [UIImage imageWithData:thumbnailAsData];
//                        [_thumbnails addObject:thumbnail];
//                    }
//                }
//            }];
//            [dt resume];
//            
//        }
//    });
    //[_activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [_tracks[indexPath.row] description];
    [cell.imageView setImage:_thumbnails[indexPath.row]];
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
