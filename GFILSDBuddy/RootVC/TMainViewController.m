#import "TMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TMapViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "TAboutViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <GoogleMaps/GMSGeocoder.h>

@interface TMainViewController ()

@end
@implementation TMainViewController

@synthesize mapViewContoller, spinner;
@synthesize searchField;
@synthesize searchButton;
@synthesize searchButtonLabel, loadingStr;

#define TEXT_FIELD_MAX_LENGTH 15

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"])
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasCameToForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    searchField.returnKeyType = UIReturnKeySearch;
    
    [self showActivity];
    
    searchField.borderStyle = UITextBorderStyleNone;
    searchField.delegate = self;
    
    //show spinner dialog if not internet connection
    [self showSpinnerIfNoInternet];
    
    UIButton *pagingBtnAction = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    CGRect screenSize = [[UIScreen mainScreen]bounds];
    
    if(screenSize.size.height == 480)
    {
        [pagingBtnAction setFrame:CGRectMake(250, 2, 65, 40)];
    }
    
    else if (screenSize.size.height == 568)
    {
        [pagingBtnAction setFrame:CGRectMake(250, 2, 65, 40)];
    }
    
    else if (screenSize.size.height == 667)
    {
        [pagingBtnAction setFrame:CGRectMake(290, 2, 75, 40)];
    }
    
    else if (screenSize.size.height == 736)
    {
        [pagingBtnAction setFrame:CGRectMake(335, 2, 80, 40)];
    }
    
    pagingBtn1.layer.borderWidth = 1;
    pagingBtn1.layer.borderColor = [UIColor whiteColor].CGColor;
    pagingBtn1.layer.cornerRadius = 4;
    [navBar addSubview:pagingBtn1];
    
    pagingBtn2.layer.borderWidth = 1;
    pagingBtn2.layer.borderColor = [UIColor whiteColor].CGColor;
    pagingBtn2.layer.cornerRadius = 4;
    [navBar addSubview:pagingBtn2];
    
    pagingBtn3.layer.borderWidth = 1;
    pagingBtn3.layer.borderColor = [UIColor whiteColor].CGColor;
    pagingBtn3.layer.cornerRadius = 4;
    [navBar addSubview:pagingBtn3];
    
    [pagingBtnAction addTarget:self action:@selector(pagingAction) forControlEvents:UIControlEventTouchUpInside];
    [pagingBtnAction setBackgroundColor:[UIColor clearColor]];
    [navBar addSubview:pagingBtnAction];
}

#pragma mark - showActivityIndicator
-(void)showActivity
{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    float ypos = self.view.frame.size.height - 10;
    [spinner setCenter:CGPointMake((350-spinner.bounds.size.width)/2.0, ypos/2.0)];
    spinner.hidesWhenStopped = TRUE;
    [spinner startAnimating];
    loadingStr = [[UILabel alloc] initWithFrame:CGRectMake(0, ypos/2.0+10, self.view.frame.size.width, 50)];
    loadingStr.text = @"Waiting for active data connection...";
    loadingStr.textColor = [UIColor whiteColor];
    loadingStr.font = [UIFont systemFontOfSize:14];
    loadingStr.backgroundColor = [UIColor clearColor];
    loadingStr.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:spinner];
    [self.view addSubview:loadingStr];
}

#pragma mark - Goto AboutUs Screen
-(void)pagingAction
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TMainViewController *aboutViewContoller = [storyBoard  instantiateViewControllerWithIdentifier:@"TAboutViewControllerSB"];
    aboutViewContoller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:aboutViewContoller animated:YES completion:nil];
}

#pragma mark - TextField Delegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Setting the max length(15) for Search Text Field
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > TEXT_FIELD_MAX_LENGTH) ? NO : YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Setting text alignment to center
    searchField.textAlignment = NSTextAlignmentCenter;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(searchButton.enabled == TRUE)
    {
        //User cilcks on serach button
        [self searchButtonAction];
    }
    
    return YES;
}

#pragma mark - Touch Actions on View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:NO];
}

#pragma mark - Fecthing Location using code
- (void)startLoadingMap
{
    NSString *code = searchField.text;
    
    NSString *requestURL1 = [[NSString alloc] initWithFormat:@"http://reports.gfisystems.ca/GeneralRequest?reqType=LSDBUDDY&req=%@~4035984678~DO", code];
    //NSLog(@"requestURL1: %@",requestURL1);
    
    NSString *urlString = [requestURL1 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //NSLog(@"urlString: %@",urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *results = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    [self performSelectorOnMainThread:@selector(mapLoaded:) withObject:results waitUntilDone:YES];
}

#pragma mark - Pass Location values to GoogleAPI
- (void)mapLoaded:(NSString*)results
{
    searchButton.enabled = TRUE;
    searchButton.backgroundColor = [UIColor clearColor];
    searchField.enabled = TRUE;
    
    //show error if there is an invalid location code
    if(results == nil || [results hasPrefix:@"Exception"])
    {
        NSString *alertmessage = [[NSString alloc] initWithFormat:@"Invalid location code. Please enter a valid code"];
        [self showAlertDialog:@"Error" :alertmessage];
    }
    
    else if(results != nil)
    {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable)
        {
            //NSLog(@"There IS NO internet connection");
            if (spinner != nil)
            {
                [spinner startAnimating];
                spinner.hidden = FALSE;
            }
            
            if(loadingStr != nil)
            {
                loadingStr.hidden = FALSE;
            }
            
            if(searchButton != nil)
            {
                searchButton.enabled = FALSE;
            }
            
            searchField.enablesReturnKeyAutomatically = YES;
        }
        
        else
        {
            //Parse the response to resolve lat & long
            NSArray *SplitStrs = [results componentsSeparatedByString:@","];
            //NSLog(@"SplitStrs: %@",SplitStrs);
            
            if(SplitStrs == nil || SplitStrs.count == 1)
            {
                NSString *alertmessage = [[NSString alloc] initWithFormat:@"Invalid location code. Please enter a valid code"];
                [self showAlertDialog:@"Error" :alertmessage];
            }
            
            else if(SplitStrs.count == 2 || SplitStrs.count == 3)
            {
                // Clear text field
                //searchField.text = @"";
                
                AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
                appDelegate.latitude = [SplitStrs objectAtIndex:0];
                appDelegate.longitude = [SplitStrs objectAtIndex:1];
                
                if(SplitStrs.count == 3)
                {
                    appDelegate.address = [SplitStrs objectAtIndex:2];
                    [self gotoMapScreen];
                }
                
                else if(SplitStrs.count == 2)
                {
                    //if no address found, request geo address
                    NSArray *locationArray = @[appDelegate.latitude, appDelegate.longitude];
                    [self performSelectorOnMainThread:@selector(fetchAddressFromGeoCoder:) withObject:locationArray waitUntilDone:NO];
                }
            }
        }
    }
}

#pragma mark - Request Location Address
-(void)fetchAddressFromGeoCoder: (NSArray*)locationValues
{
    NSMutableArray *addressesTextArray = [[NSMutableArray alloc]init];
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([[locationValues objectAtIndex:0]doubleValue], [[locationValues objectAtIndex:1]doubleValue]) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        //NSLog(@"reverse geocoding results:");
        for(GMSAddress* addressObj in [response results])
        {
            /*NSLog(@"coordinate.latitude=%f", addressObj.coordinate.latitude);
            NSLog(@"coordinate.longitude=%f", addressObj.coordinate.longitude);
            NSLog(@"thoroughfare=%@", addressObj.thoroughfare);
            NSLog(@"locality=%@", addressObj.locality);
            NSLog(@"subLocality=%@", addressObj.subLocality);
            NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
            NSLog(@"postalCode=%@", addressObj.postalCode);
            NSLog(@"country=%@", addressObj.country);
            NSLog(@"lines =%@", [addressObj lines]);*/
            
            //Adding address to array
            [addressesTextArray addObject:addressObj.lines];
        }
                
        //NSLog(@"arr: %@",[[arr objectAtIndex:0] lastObject]);
        
        AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
        appDelegate.address = [[addressesTextArray objectAtIndex:0] lastObject];
        [self gotoMapScreen];
    }];
}

#pragma mark - Goto Map Screen
- (void)gotoMapScreen
{
    if(self.mapViewContoller == nil)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.mapViewContoller = [storyBoard  instantiateViewControllerWithIdentifier:@"TMapViewControllerSB"];
    }
    
    else
    {
        [self.mapViewContoller reloadView];
    }
    
    [self.navigationController pushViewController:self.mapViewContoller animated:TRUE];
}

#pragma mark - Search Button Action
- (void)searchButtonAction
{
    NSString *trimmedString = [searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([trimmedString isEqualToString:@""])
    {
        [self showAlertDialog:nil :@"Location field is blank"];
        return;
    }
    
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSRange numberRange = [trimmedString rangeOfCharacterFromSet:numberSet];
    
    if (numberRange.location == NSNotFound)
    {
        [self showAlertDialog:nil :@"Please enter valid location"];
        return;
    }
    
    [self showSpinnerIfNoInternet];
    
    searchButton.enabled = FALSE;
    searchButton.backgroundColor = [UIColor clearColor];
    searchField.enabled = FALSE;
    searchButtonLabel.text = @"Searching ...";
    
    // Hide keyword
    [searchField resignFirstResponder];
    
    [self performSelectorInBackground:@selector(startLoadingMap) withObject:nil];
}

#pragma mark - Handle Button Actions
- (void)buttonPressed: (id)sender
{
    NSInteger button_tag = [sender tag];
    
    switch (button_tag)
    {
        case 100:
            // Search Button action
        {
            [self searchButtonAction];
        }
            break;
            
        case 102:
            //Launching about screen when the user presses 'info' button
        {
            
        }
            break;
            
        case 101:
            //Launching Ad screen when the user presses 'Bootom Ad' region
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TAdViewController *adViewContoller = [storyBoard  instantiateViewControllerWithIdentifier:@"TAdViewControllerSB"];
            [self.navigationController presentViewController:adViewContoller animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Connection Succeeded
- (void)connectionSucceeded:(NSMutableData*)data
{
    // data contains response, e.g. JSON to be parsed
    if(data != nil)
    {
        //NSLog(@"Result recevied");
    }
}

#pragma mark - Connection Failed
- (void)connectionFailed:(NSError*)error
{
    // error contains reason for failure
    if(error != nil)
    {
        //NSLog(@"Result recevied");
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Clear text field
        //searchField.text = @"";
        searchButtonLabel.text = @"Search";
        searchField.text = @"";
        [searchField becomeFirstResponder];
    }
    
    else if (buttonIndex == 1)
    {
        //Continue clicked
    }
}

#pragma mark - Spinner with Text
- (void)showSpinnerIfNoInternet
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable)
    {
        //NSLog(@"There IS NO internet connection");
        if (spinner != nil)
        {
            [spinner startAnimating];
            spinner.hidden = FALSE;
        }
        
        if(loadingStr != nil)
        {
            loadingStr.hidden = FALSE;
        }
        
        if(searchButton != nil)
        {
            searchButton.enabled = FALSE;
        }
        
        searchField.enablesReturnKeyAutomatically = YES;
    }
    
    else
    {
        //NSLog(@"There IS internet connection");
        if (spinner != nil)
        {
            [spinner stopAnimating];
            spinner.hidden = TRUE;
        }
        
        if(loadingStr != nil)
        {
            loadingStr.hidden = TRUE;
        }
        
        if(searchButton != nil)
        {
            searchButton.enabled = TRUE;
        }
        
        searchField.enablesReturnKeyAutomatically = NO;
        [searchField becomeFirstResponder];
    }
}

#pragma mark - App Foreground Scenario
- (void)appHasCameToForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSLog(@"Application comes to Foreground - Resume >>>>>>>>>>>");
    [self showSpinnerIfNoInternet];
}

#pragma mark - View Life Cycle Methods
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [searchField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self performSelector:@selector(changeText) withObject:self afterDelay:1.0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if([searchButtonLabel.text isEqualToString:@"Searching ..."])
    {
        searchButtonLabel.text = @"Search";
    }
}

#pragma mark - Show Alert
- (void)showAlertDialog:(NSString*)title_ :(NSString*)message_
{
    if(alertView == nil)
    {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:nil  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    }
    
    [alertView setTitle:title_];
    [alertView setMessage:message_];
    [alertView show];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
