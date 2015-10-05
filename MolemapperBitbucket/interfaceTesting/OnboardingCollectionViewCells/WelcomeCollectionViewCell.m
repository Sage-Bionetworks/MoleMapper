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
    mailComposeVC.mailComposeDelegate = _parentViewController       ;
    
    /*[mailComposeVC addAttachmentData:[self PDFDataOfConsent] mimeType:@"application/pdf" fileName:@"Consent"];
    [mailComposeVC setSubject:kConsentEmailSubject];*/
    [_parentViewController presentViewController:mailComposeVC animated:YES completion:NULL];
}



@end
