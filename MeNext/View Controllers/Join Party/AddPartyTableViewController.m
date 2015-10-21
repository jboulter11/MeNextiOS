//
//  AddPartyTableViewController.m
//  MeNext
//
//  Created by Jim Boulter on 10/13/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddPartyTableViewController.h"
#import "AddPartyTableViewCell.h"

@interface AddPartyTableViewController () <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
}

@end

@implementation AddPartyTableViewController

#pragma mark - Init

- (instancetype)init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.title = @"Join Parties";
        //Register Cells
        [self.tableView registerClass:[AddPartyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AddPartyTableViewCell class])];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length != 0)
    {
        [textField resignFirstResponder];
        [self sendRequestWithId:textField.text];
    }
    return YES;
}

#pragma mark - Joining Parties

//Send request
- (void)sendRequestWithId:(NSString*)partyId
{
    NSDictionary* postDictionary = @{@"action": @"joinParty", @"partyId": partyId};
    [[SharedData sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(![((NSString*)[responseObject objectForKey:@"status"])  isEqual: @"failed"])
        {
            //success
        }
        else
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error joining party"
                                                                           message:[responseObject objectForKey:@"status"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            [SharedData loginCheck:responseObject withCompletion:^{
                [self sendRequestWithId:partyId];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error joining party"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - QR

-(void)startScanner
{
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
    
    [self.view bringSubviewToFront:_highlightView];
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
                _highlightView.frame = highlightViewRect;
            }
        
        if (detectionString != nil)
        {
            NSRange str = [detectionString rangeOfString:@"partyId="];
            [self sendRequestWithId:[detectionString substringFromIndex:(str.location+str.length)]];
            break;
        }
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
        AddPartyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddPartyTableViewCell class])];
        if(!cell)
        {
            cell = [[AddPartyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([AddPartyTableViewCell class])];
        }
        [cell.textField becomeFirstResponder];
        [cell.textField setDelegate:self];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setText:@"Join using QR"];
        [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell.contentView.mas_centerX);
            make.centerY.equalTo(cell.contentView.mas_centerY);
        }];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        [self startScanner];
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
