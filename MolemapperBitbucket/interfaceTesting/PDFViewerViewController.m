//
//  PDFViewerViewContoller.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "PDFViewerViewController.h"


@interface PDFViewerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *pdfWebView;


@end


@implementation PDFViewerViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    self.pdfWebView.delegate = self;
    [self.pdfWebView setDataDetectorTypes:UIDataDetectorTypeAll];
    self.pdfWebView.allowsInlineMediaPlayback = YES;
    
    [self.pdfWebView setScalesPageToFit:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:self.filename ofType:@"pdf"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pathURL];
    [self.pdfWebView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request   navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
