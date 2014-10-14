//
//  AddPartyTableViewController.m
//  MeNext
//
//  Created by Jim Boulter on 10/13/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddPartyTableViewController.h"
#import "AddPartyTableViewCell.h"

@interface AddPartyTableViewController ()
{
    ZBarReaderViewController *reader;
}

@end

@implementation AddPartyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editingDone:(id)sender
{
    UITextField* tf = (UITextField*) sender;
    [self sendRequestWithId:tf.text];
}

//Send request
- (void)sendRequestWithId:(NSString*)partyId
{
    NSDictionary* postDictionary = @{@"action": @"joinParty", @"partyId": partyId};
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Voting"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - Protocol Methods for ZBarReaderDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //parse and call other method to send request
    NSString* qrCode = [info objectForKey: ZBarReaderControllerResults];
    
    NSRange range = [qrCode rangeOfString:@"partyId="];
    if (!(range.location == NSNotFound))
    {
        [self sendRequestWithId: [qrCode substringFromIndex:(range.location + range.length)]];
    }
    
    //Dismiss reader
    [reader dismissViewControllerAnimated:YES completion: nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0)
    {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0)
    {
        AddPartyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddPartyCell" forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        if(indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Join using QR";
        
        return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Back";
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        [reader.scanner setSymbology: ZBAR_QRCODE
                              config: ZBAR_CFG_ENABLE
                                  to: 0];
        reader.readerView.zoom = 1.0;
        reader.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:reader animated:YES completion:nil];
    }
    else if(indexPath.row == 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 60;
    }
    else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

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
