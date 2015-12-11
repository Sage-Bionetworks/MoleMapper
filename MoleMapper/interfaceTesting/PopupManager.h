//
//  PopupManager.h
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopupManager : NSObject

+(id)sharedInstance;

-(void)createPopupWithText:(NSString*)text;

-(void)createPopupWithText:(NSString *)text andSize:(CGFloat)fontSize;

@end
