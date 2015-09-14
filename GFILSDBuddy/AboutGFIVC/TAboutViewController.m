	#import "TAboutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import<CoreTelephony/CTCallCenter.h>
#import<CoreTelephony/CTCall.h>
#import<CoreTelephony/CTCarrier.h>
#import<CoreTelephony/CTTelephonyNetworkInfo.h>

@interface TAboutViewController ()

@end

@implementation TAboutViewController

@synthesize aboutView, contactUsView, back;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
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
}

#pragma mark - Autolayout Subviews
-(void)viewDidLayoutSubviews
{
    if(self.view.frame.size.width > 320)
    {
        lsdbuddyLblHorizantalSpaceConstraint.constant = 80;
        [lsdbuddyHeadingLbl updateConstraints];
    }
}

#pragma mark - Handle Button Actions
- (IBAction)buttonPressed: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Handle touch events on labels
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    
    switch (touch.view.tag)
    {
        case 602:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gfi4gps.com"]];
        }
            break;
            
        case 603:
        {
            BOOL isSimCardAvailable = YES;
            
            CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier* carrier = info.subscriberCellularProvider;
            
            //Checking whether sim card is available or not
            if(carrier.mobileNetworkCode == nil || [carrier.mobileNetworkCode isEqualToString:@""])
            {
                isSimCardAvailable = NO;
            }
            
            if(isSimCardAvailable == NO)
            {
                UIAlertView *noSimAvailableAlert = [[UIAlertView alloc]initWithTitle:nil message:@"No SIM Card Installed"delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [noSimAvailableAlert show];
            }
            
            else
            {
                //Calling TOLLFREE
                NSString *phone = @"1-855-434-4477";
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
            
            break;
            
        case 604:
        {   //Invoking Email
            NSString *stringURL = @"mailto:support@gfisystems.ca";
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
