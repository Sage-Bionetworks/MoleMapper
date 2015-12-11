//
//  EmailVerifyViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/22/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "EmailVerifyViewController.h"
#import "UIAlertController+Helper.h"
#import "AppDelegate.h"
#import "ThankYouViewController.h"
#import "BridgeManager.h"
#import <BridgeSDK/BridgeSDK.h>
#import "APCLog.h"
#import "APCConstants.h"
#import "SBBUserProfile+MoleMapper.h"

@interface EmailVerifyViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *resendEmailButton;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;

@property (nonatomic, strong) UIAlertController *pleaseCheckEmailAlert;

typedef void (^APCStuffToDoAfterSpinnerAppears) (void);
typedef void (^APCAlertDismisser) (void);

@end

@implementation EmailVerifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set up a locally available bridgeManager instance to get/set usernames, passwords, profile attributes
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.logoImageView.image = [UIImage imageNamed:@"sunIcon"];
    NSString *email = ad.user.bridgeSignInEmail;
    self.emailLabel.text = email;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    [self hideSpinnerUsingAnimation: NO andThenDoThis: nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *email = ad.user.bridgeSignInEmail;
    self.emailLabel.text = email;
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Hide/cancel all the modal views which might be showing.
    //[self cancelPleaseCheckEmailAlertUsingAnimation: NO];
    [self hideSpinnerUsingAnimation: NO andThenDoThis: nil];
    
    [super viewWillDisappear: animated];
}

- (IBAction)backButtonTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding]; //go back to the BridgeSignUpVC
}

- (IBAction)changeEmailAddressTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding]; //go back to the BridgeSignUpVC

}

- (IBAction)continueTapped:(id)sender
{
    [self showSpinnerAndThenDoThis: ^{
        [self checkSignInOnce];
    }];
}

- (void) checkSignInOnce
{
    NSLog(@"Email verification: checking with Sage to see if user has clicked email-verification link.");
    
    //Strangeness from the APCEmailViewController, don't exactly understand it
    __weak EmailVerifyViewController * weakSelf = self;
    
    //From APCUser+Bridge
    [self signInOnCompletion: ^(NSError *error) {
        [weakSelf handleSigninResponseWithError: error];
    }];
}

/**
 We're on some random background thread.  That's probably ok,
 but keep an eye out for issues.
 */

- (void) handleSigninResponseWithError: (NSError *) error
{
    //[self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        if (error)
        {
            if (error.code == kSBBServerPreconditionNotMet)
            {
                [self getServerConsent];
            }
            
            else if (error.code == kAPCSigninErrorCode_NotSignedIn)
            {
                [self showPleaseCheckEmailAlert];
            }
            
            else
            {
                [self showSignInError: error];
            }
        }
        else
        {
            [self updateProfileOnCompletion: ^(NSError *error) {
                APCLogError2 (error);
            }];
            
            [self showThankYouPage];
        }

        
    //}];

    }

- (void) showThankYouPage
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        // load the thank you view controller
        UIStoryboard *sbOnboarding = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
        ThankYouViewController *thankYou = (ThankYouViewController *)[sbOnboarding instantiateViewControllerWithIdentifier:@"thankYouAfterSignup"];
        
        [self presentViewController:thankYou animated:YES completion:nil];
        
    }];
}

//Derived from APCUser+Bridge
- (void) updateProfileOnCompletion:(void (^)(NSError *))completionBlock
{
    /*if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {*/
    
    SBBUserProfile *profile = [SBBUserProfile new];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    profile.email = ad.user.bridgeSignInEmail;
    profile.username = ad.user.bridgeSignInEmail;
    profile.firstName = ad.user.firstName;
    profile.lastName = ad.user.lastName;
    
    [SBBComponent(SBBUserManager) updateUserProfileWithProfile: profile
                                                    completion: ^(id __unused responseObject,
                                                                         NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error)
                 {
                     NSLog(@"User Profile Updated To Bridge");
                 }
                 if (completionBlock)
                 {
                     completionBlock(error);
                 }
             });
         }];
    
}


- (void) showEmailResent: (NSError *) error
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Email Verification Re-sent", @"") message:error.localizedDescription];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

- (void) showSignInError: (NSError *) error
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Sign In Error", @"") message:error.localizedDescription];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

- (void) showPleaseCheckEmailAlert
{
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        NSString *message = @"\nYour email address has not yet been verified.\n\nPlease check your email for a message from Mole Mapper, and click the link in that message. You may also want to check your email account spam folder.";
        
        self.pleaseCheckEmailAlert = [UIAlertController alertControllerWithTitle: @"Please Check Your Email"
                                                                         message: message
                                                                  preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle: @"Please Check Your Email"
                                                             style: UIAlertActionStyleDefault
                                                           handler: ^(UIAlertAction * __unused action)
                                     {
                                         [self cancelPleaseCheckEmailAlertUsingAnimation: YES];
                                     }];
        
        [self.pleaseCheckEmailAlert addAction: okayAction];
        
        [self presentViewController: self.pleaseCheckEmailAlert
                           animated: YES
                         completion: nil];
    }];
}

- (void) cancelPleaseCheckEmailAlertUsingAnimation: (BOOL) shouldAnimate
{
    __weak EmailVerifyViewController *weakSelf = self;
    
    [self.pleaseCheckEmailAlert dismissViewControllerAnimated: shouldAnimate completion:^{
        weakSelf.pleaseCheckEmailAlert = nil;
    }];
}


- (void)signInOnCompletion:(void (^)(NSError *))completionBlock
{
    /*
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {*/
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                password: ad.user.bridgeSignInPassword
                                              completion: ^(NSURLSessionDataTask * __unused task,
                                                            id responseObject,
                                                            NSError *signInError)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!signInError)
                 {
                     ad.user.hasEnrolled = YES;
                     NSLog(@"User Successfully Signed In");
                 }
                 else
                 {
                     NSDictionary *reponseObject = (NSDictionary *)reponseObject;
                     NSLog(@"User did NOT sign in because of error: %@",signInError);
                 }
                 
                 if (completionBlock)
                 {
                     completionBlock(signInError);
                 }
                 //This is replacing code from top of the method for server disabled 
                 else
                 {
                     completionBlock(nil);
                 }
             });
         }
        ];
}



- (IBAction)resendEmail:(id)sender
{
    /*
    {
        if ([self serverDisabled]) {
            if (completionBlock) {
                completionBlock(nil);
            }
        }
        else
        {*/
    [self showSpinnerAndThenDoThis:^{
   
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        NSString *email = ad.user.bridgeSignInEmail;
        if (email.length > 0)
        {
            [SBBComponent(SBBAuthManager) resendEmailVerification:email
                                                       completion: ^(NSURLSessionDataTask * __unused task,id __unused responseObject,NSError *error){
                                                           if (!error)
                                                           {
                                                               NSLog(@"Bridge Server Asked to resend email verification email");
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self hideSpinnerUsingAnimation:NO andThenDoThis:nil];
                                                                   [self showEmailResent:nil];
                                                               });
                                                           }
                                                           
                                                       }];
        }
        else
        {
            NSLog(@"Email length is zero, no email verification sent");
            [self hideSpinnerUsingAnimation:YES andThenDoThis:nil];
        }
        

    }];
}

- (void) showSpinnerAndThenDoThis: (APCStuffToDoAfterSpinnerAppears) callbackBlock
{
    self.spinnerView.alpha = 0;
    self.spinnerView.hidden = NO;
    
    [UIView animateWithDuration: 0.5
                     animations: ^{
                         
                         self.spinnerView.alpha = 1;
                         
                     } completion: ^(BOOL __unused finished) {
                         
                         // Conceptually, this callback needs to go on
                         // the main thread (even though we're probably
                         // not gonna do a main-thread thing with it).
                         // However, since we're currently in an *animation*
                         // completion block, and this is iOS, we're guaranteed
                         // to already be on the main thread.  So we can
                         // just call it.
                         
                         if (callbackBlock != nil)
                         {
                             callbackBlock ();
                         }
                     }];
}

- (void) hideSpinnerUsingAnimation: (BOOL) shouldAnimate
                     andThenDoThis: (APCStuffToDoAfterSpinnerAppears) callbackBlock
{
    if (shouldAnimate)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             
                             self.spinnerView.alpha = 0;
                             
                         } completion: ^(BOOL __unused finished) {
                             
                             self.spinnerView.hidden = YES;
                             
                             // See matching comment in -showSpinner.
                             callbackBlock ();
                         }];
    }
    else
    {
        self.spinnerView.hidden = YES;
        
        if (callbackBlock != nil)
        {
            callbackBlock ();
        }
    }
}

- (void) getServerConsent
{
    __weak EmailVerifyViewController * weakSelf = self;
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (ad.user.hasConsented) {
        [ad.bridgeManager sendUserConsentedToBridgeOnCompletion: ^(NSError *error) {
            [weakSelf handleConsentResponseWithError: error];
        }];
    }
    else
    {
        // What happens here?  And what should?
    }
}

- (void) handleConsentResponseWithError: (NSError *) error
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (error)
    {
        [self showConsentError: error];
    }
    else
    {
        ad.user.hasConsented = YES;
        [self checkSignInOnce];
    }
}

- (void) showConsentError: (NSError *) error
{
    APCLogError2(error);
    
    [self hideSpinnerUsingAnimation: YES andThenDoThis:^{
        
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Consent Error", @"") message:error.localizedDescription];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}


@end
