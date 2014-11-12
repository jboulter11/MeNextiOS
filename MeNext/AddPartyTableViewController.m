//
//  AddPartyTableViewController.m
//  MeNext
//
//  Created by Jim Boulter on 10/13/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddPartyTableViewController.h"
#import "AddPartyTableViewCell.h"

@interface AddPartyTableViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    
    UIButton *backButton;
}

@end

@implementation AddPartyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:235/255.0 green:39/255.0 blue:53/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.topItem.title = @"";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editingDone:(id)sender
{
    UITextField* tf = (UITextField*) sender;
    if(tf.text.length != 0)
    {
        [self sendRequestWithId:tf.text];
    }
}

- (IBAction)backQRButtonHit:(id)sender
{
    [_session stopRunning];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO];
    _highlightView.hidden = YES;
    [_prevLayer removeFromSuperlayer];
    backButton.hidden = YES;
}

//Send request
- (void)sendRequestWithId:(NSString*)partyId
{
    NSDictionary* postDictionary = @{@"action": @"joinParty", @"partyId": partyId};
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if(!([responseObject[@"status"] isEqualToString:@"success"]))
        {
            //bad
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Joining Party"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Joining Party"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [_session stopRunning];
    //Getting string from code reader output
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    
    for (AVMetadataObject *metadata in metadataObjects) {
            if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            }
        
        if (detectionString != nil)
        {
            NSRange str = [detectionString rangeOfString:@"partyId="];
            [self sendRequestWithId:[detectionString substringFromIndex:(str.location+str.length)]];
            [_session stopRunning];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    
    _highlightView.frame = highlightViewRect;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0)
    {
        AddPartyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddPartyCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Join using QR";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        [self.view endEditing:YES];
        //SOME CRAZY VIEW CODE TO SHOW CAMERA AND HIGHLIGHT BARCODE, AS WELL AS RUN THE SCANNER
        _highlightView = [[UIView alloc] init];
        _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
        _highlightView.layer.borderWidth = 3;
        [self.view addSubview:_highlightView];
        
        _session = [[AVCaptureSession alloc] init];
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (_input) {
            [_session addInput:_input];
        } else {
            NSLog(@"Error: %@", error);
        }
        
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_session addOutput:_output];
        
        _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
        
        _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _prevLayer.frame = self.view.bounds;
        _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:_prevLayer];
        
        [_session startRunning];
        
        
        backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton addTarget:self
                   action:@selector(backQRButtonHit:)
         forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        backButton.layer.borderWidth = 1;
        backButton.layer.cornerRadius = 4;
        backButton.tintColor = [UIColor whiteColor];
        [backButton.layer setBorderColor:backButton.tintColor.CGColor];
        backButton.layer.hidden = NO;
        //button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
        float X_Co = self.view.frame.size.width - 50.0 - 10.0;
        float Y_Co = self.view.frame.size.height - 30.0 - 10.0;
        [backButton setFrame:CGRectMake(X_Co, Y_Co, 50.0, 30.0)];
        [self.view addSubview:backButton];
        
        [self.view bringSubviewToFront:_highlightView];
        [self.view bringSubviewToFront:backButton];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Manually enter ID:";
    }
    else
    {
        return nil;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.section == 0)
//    {
//        return 60;
//    }
//    else
//    {
//        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//    }
//}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
