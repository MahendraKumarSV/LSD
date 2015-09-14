#import <UIKit/UIKit.h>

#import <GoogleMaps/GMSMapView.h>

@class TMapViewController;

@interface TMainViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    TMapViewController *mapViewContoller;
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UIButton *searchButton;
    __weak IBOutlet UILabel *searchButtonLabel;
    UIActivityIndicatorView *spinner;
    UILabel *loadingStr;
    UIAlertView *alertView;
    IBOutlet UIButton *pagingBtn1;
    IBOutlet UIButton *pagingBtn2;
    IBOutlet UIButton *pagingBtn3;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIButton *gfiLogoBtn;
}

@property(strong, nonatomic) TMapViewController *mapViewContoller;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *searchButtonLabel;
@property(strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UILabel *loadingStr;

- (IBAction)buttonPressed: (id)sender;
- (void)startLoadingMap;
- (void)showSpinnerIfNoInternet;
- (void)mapLoaded:(NSString*)results;
- (void)appHasCameToForeground:(UIApplication *)application;
- (void)searchButtonAction;
- (void)gotoMapScreen;
- (void)showAlertDialog:(NSString*)title :(NSString*)message;

@end
