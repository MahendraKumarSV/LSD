//
//  TMapViewController.h
//  LSDBuddy
//
//  Created by DreamOrbit on 3/24/13.
//  Copyright (c) 2013 DreamOrbit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GMSMapView.h>

@interface TMapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    CLLocationManager *locationManager;
    
    GMSMarker *lsdBuddyMarker;
    GMSMarker *locationMarker;
    NSString *lsdMarkerText;
    NSString *locMarkerText;
    GMSMapView *mapView_;
    double SLAT, SLAN, DLAT, DLAN;
    IBOutlet UIView  *mapUIView;
    __weak IBOutlet UIBarButtonItem *back;
    NSTimer *timer;
    float zoomLevel;
    UIAlertView *locAlertView;
    __weak NSUserDefaults *userLocationPrefs;
    GMSCameraPosition *camera;
    UIView *outerView;
    IBOutlet UIButton *gfiLogoBtn;
}

@property(strong, nonatomic) NSString *lsdMarkerText;
@property(strong, nonatomic) NSString *locMarkerText;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMarker *lsdBuddyMarker;
@property (strong, nonatomic) GMSMarker *locationMarker;
@property(strong, nonatomic) GMSMapView *mapView_;
@property(strong, nonatomic) UIView *mapUIView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property(strong, nonatomic) UIAlertView *locAlertView;
@property(weak, nonatomic) NSUserDefaults *userLocationPrefs;

- (IBAction)buttonPressed: (id)sender;
- (void)updateUserLocation: (CLLocation*)currentLocation;
- (void)startTheBackgroundJob;
- (void)requestGeoAddress;
- (void)workDone;
- (void)updateAddressDone:(NSString*)results;
- (void)showLocationWiFiAlert;
- (void)loadUserLastLocation;
- (void)appHasCameToForeground:(UIApplication *)application;
- (void)showErrorDialogIfLocationWiFiUnavailable;
- (void)reloadView;

@end
