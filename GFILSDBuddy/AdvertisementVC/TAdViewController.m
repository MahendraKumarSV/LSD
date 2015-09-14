#import <QuartzCore/QuartzCore.h>
#import "TAdViewController.h"
#import "TAboutViewController.h"
#import "AppDelegate.h"

@interface TAdViewController ()

@end

@implementation TAdViewController

@synthesize webView, back;

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
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    //loading Ad URL in a WEB view
    NSURL *url = [NSURL URLWithString: @"http://gfisystems.ca"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest: request];
}

#pragma mark - Handle Button Touches
- (IBAction)buttonPressed: (id)sender
{
    NSInteger button_tag = [sender tag];
    
    switch (button_tag)
    {
        case 700:
            // Going back to previous screen when the user presses 'Back' Button
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
            
        case 702:
        {   // Launching About screen when the user presses 'info' Button
            AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
            
            if(appDelegate.aboutViewContoller == nil)
            {
                appDelegate.aboutViewContoller = [[TAboutViewController alloc]initWithNibName:@"TAboutViewController" bundle:nil];
            }
            
            appDelegate.aboutViewContoller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:appDelegate.aboutViewContoller animated:YES completion:nil];
        }
            break;
    }
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
