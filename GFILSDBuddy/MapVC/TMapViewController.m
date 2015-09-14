#import "TMapViewController.h"
#import "GoogleMaps/GMSCameraPosition.h"
#import "GoogleMaps/GMSProjection.h"
#import "GoogleMaps/GoogleMaps.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

@implementation TMapViewController

@synthesize mapUIView;
@synthesize back;
@synthesize mapView_;
@synthesize locationManager;
@synthesize locAlertView;
@synthesize userLocationPrefs;
@synthesize locationMarker;
@synthesize lsdBuddyMarker;
@synthesize lsdMarkerText;
@synthesize locMarkerText;

static BOOL haveAlreadyReceivedCoordinates = NO;

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenSize = [[UIScreen mainScreen]bounds];
    
    if(screenSize.size.height == 480)
    {
        mapUIView.frame = CGRectMake(mapUIView.frame.origin.x, mapUIView.frame.origin.y-5, mapUIView.frame.size.width, mapUIView.frame.size.height);
        gfiLogoBtn.frame = CGRectMake(gfiLogoBtn.frame.origin.x, gfiLogoBtn.frame.origin.y-85, gfiLogoBtn.frame.size.width, gfiLogoBtn.frame.size.height);
    }
    
    else if(screenSize.size.height == 667)
    {
        gfiLogoBtn.frame = CGRectMake(gfiLogoBtn.frame.origin.x, gfiLogoBtn.frame.origin.y+98, screenSize.size.width, gfiLogoBtn.frame.size.height);
        mapUIView.frame = CGRectMake(mapUIView.frame.origin.x, mapUIView.frame.origin.y-5, screenSize.size.width, screenSize.size.height-60);
    }
    
    else if(screenSize.size.height == 736)
    {
        gfiLogoBtn.frame = CGRectMake(gfiLogoBtn.frame.origin.x, gfiLogoBtn.frame.origin.y+168, screenSize.size.width, gfiLogoBtn.frame.size.height);
        mapUIView.frame = CGRectMake(mapUIView.frame.origin.x, mapUIView.frame.origin.y-5, screenSize.size.width, screenSize.size.height-gfiLogoBtn.frame.size.height);
    }
    
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"])
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.1") == TRUE)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LSDBuddy Warning" message:@"Google Maps iOS SDK supports iOS versions 5.1 and above. Hence please update your iOS software from Settings -> General -> Software Update." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
        [alert show];
        return;
    }
    
    userLocationPrefs = [NSUserDefaults standardUserDefaults];
    
    camera = [[GMSCameraPosition alloc] init];
    mapView_ = [GMSMapView mapWithFrame:self.mapUIView.bounds camera:camera];
    [mapView_ clear];
    mapView_.delegate = self;
    mapView_.myLocationEnabled = YES;
    [self.mapUIView addSubview:mapView_];
    
    //Adding the Direction icon at the bottom right of the Map View
    UIButton *dirButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dirButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    [dirButton setTag:204];
    [dirButton setBackgroundImage:[UIImage imageNamed:@"directions.png"] forState:UIControlStateNormal];
    
    UIButton *transBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if(screenSize.size.height == 480)
    {
        dirButton.frame = CGRectMake(270.0, screenSize.size.height-170.0, 30.0, 30.0);
        [transBtn setFrame:CGRectMake(230, self.mapUIView.frame.size.height-190.0, 110, 105)];
    }
    
    else if(screenSize.size.height == 568)
    {
        dirButton.frame = CGRectMake(270.0, screenSize.size.height-180.0, 30.0, 30.0);
        [transBtn setFrame:CGRectMake(230, self.mapUIView.frame.size.height-100.0, 110, 100)];
    }
    
    else if(screenSize.size.height == 667)
    {
        dirButton.frame = CGRectMake(320.0, screenSize.size.height-175.0, 40, 40);
        [transBtn setFrame:CGRectMake(285, self.mapUIView.frame.size.height-165.0, 110, 100)];
    }
    
    else if(screenSize.size.height == 736)
    {
        dirButton.frame = CGRectMake(354.0, screenSize.size.height-190.0, 40, 40);
        [transBtn setFrame:CGRectMake(334, self.mapUIView.frame.size.height-160.0, 110, 100)];
    }
    
    [mapView_  addSubview:dirButton];
    
    transBtn.tag = 204;
    [transBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [transBtn setBackgroundColor:[UIColor clearColor]];
    [mapView_ addSubview:transBtn];
    
    [self reloadView];
}

#pragma mark - Handle Button Actions
- (IBAction)buttonPressed: (id)sender
{
    NSInteger button_tag = [sender tag];
    
    switch (button_tag)
    {
        //Removing location observer when the user presses 'Back' button
        case 200:
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        
        //launching about view when the user presses 'info' button
        case 202:
        {
            AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
            
            if(appDelegate.aboutViewContoller == nil)
            {
                appDelegate.aboutViewContoller = [[TAboutViewController alloc]initWithNibName:@"TAboutViewController" bundle:nil];
            }
            
            appDelegate.aboutViewContoller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            
            [self.navigationController presentViewController:appDelegate.aboutViewContoller animated:YES completion:nil];
        }
            break;
        
        //launching google-maps/app-store when the user presses the 'Direction' button
        case 204:
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
            {
                //showing alert if the user location is not found.
                if(SLAT == 0.00f || SLAN == 0.0f)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Directions Not Found" message:@"User Location is not found. Please Turn on GPS to acquire user location." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                   // ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentLeft;
                    [alert show];
                }
                
                else
                {
                    // redirecting the user to google maps app with the driection
                    NSString* url = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f", SLAT, SLAN, DLAT, DLAN];
                    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
                }
            }
            
            else
            {
                //Showing alert if the google maps app is not installed in iphone.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Google Maps" message:@"This app won't show directions, Since the Google Maps application is missing from your iPhone. \n\n Please install the Google Maps from Apple Store." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Apple Store", nil];
               // ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentLeft;
                [alert show];
            }
            
            break;
            
        //launching Ad view when the user presses 'Bottom Ad' region
        case 201:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TAdViewController *adViewContoller = [storyBoard  instantiateViewControllerWithIdentifier:@"TAdViewControllerSB"];
            [self.navigationController presentViewController:adViewContoller animated:YES completion:nil];
        }
            
        break;
    }
}

#pragma mark - Reload Map
- (void)reloadView
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.1") == TRUE)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LSDBuddy Warning" message:@"Google Maps iOS SDK supports iOS versions 5.1 and above. Hence please update your iOS software from Settings -> General -> Software Update." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
        [alert show];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasCameToForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    haveAlreadyReceivedCoordinates = NO;
    
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
         [self.locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    double lat = [appDelegate.latitude doubleValue];
    double longi = [appDelegate.longitude doubleValue];
    //NSLog(@"Address: %@",appDelegate.address);
    
    DLAT = lat;
    DLAN = longi;
        
    if(camera != nil)
    {
        mapView_.camera = [GMSCameraPosition cameraWithLatitude:lat longitude:longi zoom:2];
        [mapView_ clear];
        mapView_.delegate = self;
    }
    
    /*if(lsdBuddyMarker == nil)
    {
        
    }*/
    
    lsdBuddyMarker = [[GMSMarker alloc] init];
    NSString *bubbleText = nil;
    bubbleText = [[NSString alloc] initWithFormat:@"Location: (%.3f, %.3f)\nAddress: %@", lat, longi, appDelegate.address];
    lsdMarkerText = [@"Searched Location\n" stringByAppendingString:bubbleText];
    lsdBuddyMarker.position = CLLocationCoordinate2DMake(lat, longi);
    lsdBuddyMarker.map = mapView_;
    mapView_.selectedMarker = lsdBuddyMarker;
    
    if(locationMarker == nil)
    {
        locationMarker = [[GMSMarker alloc] init];
    }
    
    [self startTheBackgroundJob];
    [self showErrorDialogIfLocationWiFiUnavailable];
}

#pragma mark - GMSMap Delegate Methods
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker*)marker
{
    // Animate to the marker
    if (marker != mapView.selectedMarker)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.5f];  // short animation
        [mapView animateToLocation:marker.position];
        [mapView animateToBearing:0];
        [mapView animateToViewingAngle:0];
        [CATransaction commit];
    }
    
    return NO;
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker*)marker
{
    int popupWidth = 290;
    int contentWidth = 250;
    int contentPad = 10;
    int popupHeight = 100;
    int popupBottomPadding = 15;
    int popupContentHeight = popupHeight - popupBottomPadding;
    
    if(outerView == nil)
    {
        outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupWidth, popupHeight)];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupWidth, popupContentHeight)];
        [view setBackgroundColor:[UIColor whiteColor]];
        view.layer.borderWidth = 1;
        view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        
        UIImage *icon = [UIImage imageNamed:@"Icon"];
        UIImageView *IconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (popupHeight-35)/2, 30, 30)];
        [IconView setImage:icon];
        
        NSArray *SplitStrs = nil;
        if(marker == lsdBuddyMarker)
        {
            SplitStrs = [lsdMarkerText componentsSeparatedByString:@"\n"];
        }
        
        else
        {
            SplitStrs = [locMarkerText componentsSeparatedByString:@"\n"];
        }
        
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Icon.png"]];
        logo.frame = CGRectMake(5, 40, 35, 35);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentPad, 0, popupWidth, 22)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        titleLabel.text = [SplitStrs objectAtIndex:0];
        
        UILabel *locPoint = [[UILabel alloc] initWithFrame:CGRectMake(45, 24, contentWidth, 20)];
        [locPoint setFont:[UIFont systemFontOfSize:11.0]];
        locPoint.text = [SplitStrs objectAtIndex:1];
        
        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(45, 42, contentWidth-5, 40)];
        [address setFont:[UIFont systemFontOfSize:11.0]];
        address.numberOfLines = 0;
        address.text = [SplitStrs objectAtIndex:2];
        
        [view addSubview:IconView];
        [view addSubview:titleLabel];
        [view addSubview:locPoint];
        [view addSubview:address];
        
        UIImage *bottomImage = [UIImage imageNamed:@"bubble_pointer_down"];
        UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake((popupWidth / 2) - (bottomImage.size.width / 2), (popupContentHeight-3)+1, bottomImage.size.width, bottomImage.size.height)];
        [bottomView setImage:bottomImage];
        [outerView addSubview:view];
        [outerView addSubview:bottomView];
    }
    
    else
    {
        NSArray *SplitStrs = nil;
        if(marker == lsdBuddyMarker)
        {
            SplitStrs = [lsdMarkerText componentsSeparatedByString:@"\n"];
        }
        
        else
        {
            SplitStrs = [locMarkerText componentsSeparatedByString:@"\n"];
        }
        
        UIView *info = [[outerView subviews] objectAtIndex:0];
        ((UILabel*)[[info subviews] objectAtIndex:1]).text = [SplitStrs objectAtIndex:0];
        ((UILabel*)[[info subviews] objectAtIndex:2]).text = [SplitStrs objectAtIndex:1];
        ((UILabel*)[[info subviews] objectAtIndex:3]).text = [SplitStrs objectAtIndex:2];
    }
    
    return outerView;
}

#pragma mark - Background Task
- (void)startTheBackgroundJob
{
    zoomLevel = 8;
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.3f target: self selector: @selector(workDone) userInfo: nil repeats: YES];
}

#pragma mark - Fetch Location Address
- (void)requestGeoAddress
{
    NSString *requestURL = [[NSString alloc] initWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", SLAT, SLAN];
    
    //NSLog(@"url: %@", requestURL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *results = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    [self performSelectorOnMainThread:@selector(updateAddressDone:) withObject:results waitUntilDone:YES];
}

#pragma mark - Update Address
- (void)updateAddressDone: (NSString*)results
{
    NSData* data = [results dataUsingEncoding:NSUTF8StringEncoding];
	
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          options:kNilOptions
                          error:&error];
    
    NSArray* resultsArr = [json objectForKey:@"results"]; //2
    
    for(NSDictionary* thisLocationDict in resultsArr)
    {
        NSString* location = [thisLocationDict objectForKey:@"formatted_address"];
        
        //NSLog(@"address: %@", location);
        if(location != nil)
        {
            locationMarker.map = nil;
            NSString *bubbleText = [[NSString alloc] initWithFormat:@"Location: (%.3f, %.3f)\nAddress: %@", SLAT, SLAN, location];
            //locationMarker.title = @"My Location";
            //locationMarker.snippet = bubbleText;
            locMarkerText = [@"My Location\n" stringByAppendingString:bubbleText];
            locationMarker.position = CLLocationCoordinate2DMake(SLAT, SLAN);
            locationMarker.map = mapView_;
            [userLocationPrefs setObject:[NSString stringWithFormat:@"%f", SLAT] forKey:@"lat"];
            [userLocationPrefs setObject:[NSString stringWithFormat:@"%f", SLAN] forKey:@"lang"];
            [userLocationPrefs setObject:[NSString stringWithFormat:@"%@", location] forKey:@"address"];
            [userLocationPrefs synchronize];
            break;
        }
    }
}

#pragma mark - Animate Map
- (void)workDone
{
    if (zoomLevel < 12)
    {
        zoomLevel += 1;
        [mapView_ animateToZoom:zoomLevel];
    }
    
    else
    {
        [timer invalidate];
    }
}

#pragma mark - Load User Current Location
- (void)loadUserLastLocation
{
    NSString *latString = [userLocationPrefs stringForKey:@"lat"];
    NSString *langString = [userLocationPrefs stringForKey:@"lang"];
    NSString *addressString = [userLocationPrefs stringForKey:@"address"];
    if(latString == nil || langString == nil || addressString == nil)
    {}
    
    else
    {
        locationMarker.map = nil;
        double mlat = [latString doubleValue];
        double mlongi = [langString doubleValue];
        SLAT = mlat;
        SLAN = mlongi;
        NSString *bubbleText = [[NSString alloc] initWithFormat:@"Location: (%.3f, %.3f)\nAddress: %@", mlat, mlongi, addressString];
        //locationMarker.snippet = bubbleText;
        //locationMarker.title = @"User Last Location";
        locMarkerText = [@"User Last Location\n" stringByAppendingString:bubbleText];
        locationMarker.position = CLLocationCoordinate2DMake(mlat, mlongi);
        locationMarker.map = mapView_;
    }
}

#pragma mark - Alert View Button Actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
    {
        //going back to main screen when there is a LSDbuudy warning
        if([alertView.title hasPrefix:@"LSDBuddy Warning"])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    else if (buttonIndex == 1)
    {
        //launching apple store google maps page
        NSString* url = [NSString stringWithFormat: @"itms://itunes.apple.com/us/app/google-maps/id585027354?mt=8&uo=4"];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

#pragma mark - Fetch Updated Location
- (void)updateUserLocation: (CLLocation*)currentLocation
{
    locationMarker.map = nil;
    
    if(currentLocation != nil)
    {
        double mlat = currentLocation.coordinate.latitude;
        double mlongi = currentLocation.coordinate.longitude;
        
        SLAT = mlat;
        SLAN = mlongi;
    
        [self performSelectorInBackground:@selector(requestGeoAddress) withObject:nil];
    }
}

#pragma mark - Location Manager Delgate Methods
- (void)locationManager:(CLLocationManager *)manage didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError");
}

//location manager overiride method
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(haveAlreadyReceivedCoordinates)
    {
        return;
    }
    
    [self updateUserLocation:newLocation];
    [locationManager stopUpdatingLocation]; // string Value
    haveAlreadyReceivedCoordinates = YES;
}

//showing error dialog if the user location is not found
- (void)showErrorDialogIfLocationWiFiUnavailable
{
    // if location services are on
    BOOL isShow = FALSE;
    
    if([CLLocationManager locationServicesEnabled])
    {
        // if location services are restricted do nothing
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            isShow = TRUE;
        }
        else
        {
            isShow = FALSE;
        }
    }
    
    else
    {
        isShow = TRUE;
    }
    
    if(isShow)
    {
        [self showLocationWiFiAlert];
    }
}

#pragma mark - Show Alert
- (void)showLocationWiFiAlert
{
    [self loadUserLastLocation];
    if (locAlertView == nil)
    {
        locAlertView = [[UIAlertView alloc] initWithTitle:@"My Location Not Found" message:[NSString stringWithFormat: @"To enhance your LSDBuddy experience, Please Turn on GPS\n\n1. Go to 'Settings' application\n2. Tap on 'Privacy'\n3. Tap on 'Location Services'\n4. Turn 'On' Location Services\n5. Make sure LSDBuddy is 'On'"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        ((UILabel*)[[locAlertView subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
    }
    
    if (locAlertView.isVisible  == FALSE)
    {
        [locAlertView show];
    }
}

#pragma mark - App is in Foreground Scenario
- (void)appHasCameToForeground:(UIApplication *)application
{
    [self showErrorDialogIfLocationWiFiUnavailable];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
