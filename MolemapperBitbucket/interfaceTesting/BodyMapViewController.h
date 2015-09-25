//
//  BodyMapViewController.h
//  
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BodyMapViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;

@property BOOL shouldShowSurveyCompletedThanks;
@property BOOL shouldShowMoleRemovedPopup;

@property (strong, nonatomic) NSManagedObjectContext *context;

//Returns the imageView (BodyFrontView, BodyBackView, HeadDetailView) for a given ZoneID
//BodyFront is defined as having zoneID bewteen 1000 - 2000, back between 2000 - 3000, head between 3000 - 4000
- (UIImageView *)imageViewForZoneID:(NSString *)zoneID;

- (IBAction) flipButtonTapped:(UIButton *)sender;

@end
