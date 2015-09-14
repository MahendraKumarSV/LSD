#import <UIKit/UIKit.h>

@interface TAdViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView* webView;
    IBOutlet UIBarButtonItem *back;
}

@property (strong, nonatomic) IBOutlet UIWebView* webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;

- (IBAction)buttonPressed: (id)sender;

@end
