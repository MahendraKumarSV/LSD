#import <UIKit/UIKit.h>
#import "TAboutViewController.h"
#import "TAdViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *latitude;
    NSString *Longitude;
    NSString *address;
    TAboutViewController *aboutViewContoller;
    TAdViewController *adViewController;
}

@property(strong, nonatomic) NSString *latitude; //LSDBuddy lat
@property(strong, nonatomic) NSString *longitude; //LSDBuddy long

@property(strong, nonatomic) NSString *address; //LSDBuddy address

@property(strong, nonatomic) TAboutViewController *aboutViewContoller; //About View

@property(strong, nonatomic) TAdViewController *adViewController; //Ad View

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;


@end

