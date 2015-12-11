//
//  PDFViewerViewContoller.h
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewerViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *filename;

@end

