//
//  DetailTextViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 10/5/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTextViewController : UIViewController
- (IBAction)cancelButtonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
