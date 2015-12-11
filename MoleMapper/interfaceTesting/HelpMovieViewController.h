//
//  HelpMovieViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 7/31/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HelpMovieViewController : UIViewController

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) NSString *helpMovieName;
//Note, if you are using something other than .mov, you will need to specify this

@end
