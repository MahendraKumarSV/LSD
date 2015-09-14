//
//  TAboutViewController.h
//  LSDBuddy
//
//  Created by DreamOrbit on 4/14/13.
//  Copyright (c) 2013 DreamOrbit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAboutViewController : UIViewController
{
    IBOutlet UIView *contactUsView;
    IBOutlet UILabel *contactEmail;
    IBOutlet UIBarButtonItem *back;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIImageView *blurBG;
    
    IBOutlet UIImageView *lsdbuddyImg;
    IBOutlet UILabel *lsdbuddyHeadingLbl;
    IBOutlet UILabel *lsdbuddyTextLbl;
    IBOutlet UILabel *separatorLine1;
    
    IBOutlet UIImageView *websiteImg;
    IBOutlet UILabel *websiteHeadingLbl;
    IBOutlet UILabel *websiteTextLbl;
    IBOutlet UILabel *separatorLine2;
    
    IBOutlet UIImageView *contactusImg;
    IBOutlet UILabel *contactusHeadingLbl;
    IBOutlet UILabel *contactTextLbl;
    IBOutlet UILabel *separatorLine3;
    
    IBOutlet UIImageView *supportImg;
    IBOutlet UILabel *supportHeadingLbl;
    IBOutlet UILabel *supportTextLbl;
    IBOutlet UILabel *separatorLine4;
    
    IBOutlet UIImageView *copyrightsImg;
    IBOutlet UILabel *copyrightsHeadingLbl;
    IBOutlet UILabel *copyirghtsTextLbl;
    IBOutlet UIImageView *gfiLogo;
    
    IBOutlet NSLayoutConstraint *lsdbuddyLblHorizantalSpaceConstraint;
}

@property(strong, nonatomic) UIView *aboutView;
@property(strong, nonatomic) UIView *contactUsView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;

- (IBAction)buttonPressed: (id)sender;

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

@end
