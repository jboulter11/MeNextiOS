//
//  AddTrackDetailViewController.m
//  MeNext
//
//  Created by Jim Boulter on 7/11/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddTrackDetailViewController.h"
#import "DetailViewController.h"
#import "SharedData.h"

@interface AddTrackDetailViewController ()

@end
@implementation AddTrackDetailViewController
@synthesize titleLabel;
@synthesize descTextView;
@synthesize previewImageView;

#pragma mark - Add Track

- (void)addButtonTapped:(id)sender
{
    [[SharedData sessionManager] POST:@"handler.php"parameters:@{@"action":@"addVideo", @"partyId":_partyId, @"youtubeId":_youtubeId} success:^(NSURLSessionDataTask *task, id responseObject) {
        if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
        {
            DetailViewController* detVC = nil;
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController* vc in allViewControllers) {
                if ([vc isKindOfClass:[DetailViewController class]]) {
                    detVC = (DetailViewController*)vc;
                }
            }
            if(detVC)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popToViewController:detVC animated:YES];});
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];});
            }
        }
        else
        {
            [SharedData loginCheck:responseObject withCompletion:^{
                [self addButtonTapped:sender];
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


#pragma mark - View Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"Details";
    
    
    self.titleLabel.text = _track[@"title"];
    self.descTextView.text = _track[@"description"];
    self.previewImageView.image = _track[@"image"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
