//
//  ZZFileChannelOutput.h
//  ZipZap
//
//  Created by Glen Low on 12/01/13.
//
//

#import <Foundation/Foundation.h>

#import "ZZChannelOutput.h"

@interface ZZFileChannelOutput : NSObject <ZZChannelOutput>

@property (nonatomic) uint32_t offset;

- (instancetype)initWithFileDescriptor:(int)fileDescriptor NS_DESIGNATED_INITIALIZER;

- (uint32_t)offset;
- (BOOL)seekToOffset:(uint32_t)offset
			   error:(out NSError**)error;

- (BOOL)writeData:(NSData*)data
			error:(out NSError**)error;
- (BOOL)truncateAtOffset:(uint32_t)offset
				   error:(out NSError**)error;

- (void)close;

@end
