//
//  HeadDetailView.m
//  BodyMapAsImage
//
//

#import "HeadDetailView.h"
#import "VariableStore.h"

@implementation HeadDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VariableStore *vars = [VariableStore sharedVariableStore];
        self.image = [UIImage imageNamed:@"headDetail.png"];
        [self setUserInteractionEnabled:YES];
        
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect backgroundFrame = self.frame;
        backgroundFrame.origin.y -= 50;
        backgroundFrame.size.height += 50;
        
        backgroundButton.frame = backgroundFrame;
        [self addSubview:backgroundButton];
        [backgroundButton addTarget:vars.myViewController
                             action:@selector(backgroundTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        
        _tagZones = [vars BuildTagZoneDictionaryAndButtonsWithStructureData:[self tagZoneStructureData] forView:self];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}


- (NSArray *)tagZoneStructureData
// LEGEND:
//   tzData[tagID][0] = tagID
//   tzData[tagID][1] = [originX, originY]
//   tzData[tagID][2] = titleBarText
//   tzData[tagID][3] = baseZoneID
{
    NSArray *tzData;
    tzData = @[
               
               @[@3150, @[ @43.25f, @102.5f ], @"Face: Right Side", @15],
               @[@3151, @[ @130.75f, @102.5f ], @"Face: Left Side", @15],
               @[@3170, @[ @90.25f, @54.5f ], @"Top of Head", @17],
               @[@3171, @[ @90.25f, @102.5f ], @"Face: Front", @17],
               @[@3172, @[ @90.25f, @150.5f ], @"Back of Head", @17],
               
               ];
    return tzData;
}

@end
