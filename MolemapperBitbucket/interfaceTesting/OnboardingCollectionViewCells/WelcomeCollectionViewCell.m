//
//  WelcomeCollectionViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "WelcomeCollectionViewCell.h"

@implementation WelcomeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)btnPressed:(UIButton *)sender {
    MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
    mailComposeVC.mailComposeDelegate = self;
    
    /*[mailComposeVC addAttachmentData:[self PDFDataOfConsent] mimeType:@"application/pdf" fileName:@"Consent"];
    [mailComposeVC setSubject:kConsentEmailSubject];*/
    [_parentViewController presentViewController:mailComposeVC animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    controller.mailComposeDelegate = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
