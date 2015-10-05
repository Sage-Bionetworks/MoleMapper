//
//  ZoneViewController.h
//
//


#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "SMCalloutView.h"
#import "CMPopTipView.h"
#import <AVFoundation/AVCaptureDevice.h>

@class MolePin;

@interface ZoneViewController : UIViewController <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate,
                                                  UIGestureRecognizerDelegate,
                                                  UIScrollViewDelegate,
                                                  UIActionSheetDelegate,
                                                  MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMolePin;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteMolePin;
@property BOOL zoomedByDoubleTapping;
@property (strong, nonatomic) NSString *zoneTitle;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic) BOOL hasValidImageData;
@property (strong, nonatomic) MolePin *moleToBeDeleted;
@property (strong, nonatomic) CMPopTipView *popTipViewGoToMeasure;

@property BOOL isDeleted;


- (IBAction)openCamera:(id)sender;
- (IBAction)addMolePinButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)deleteMolePinButtonTapped:(MolePin *)sender;

- (void)addToMolePinsOnImageArray:(MolePin *)molePin;
- (void)updateMolePinBarButtonStates;

- (void)handleSingleTapOnZoneImageBackground;
- (void)handleDoubleTapOnZoneImageBackground;
- (void)handleZoneViewZoomScale:(float)newZoomScale;
- (void)showPopTipViewGoToMeasure:(UIView *)viewToPointAt;
- (void)showMeasurePopup:(id)sender;
- (void)dismissAllPopTipViews;

@end
