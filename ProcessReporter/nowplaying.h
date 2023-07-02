//
//  nowplaying.h
//  ProcessReporter
//
//  Created by Innei on 2023/7/2.
//

#import <Foundation/Foundation.h>

@interface NowPlaying : NSObject

+ (NSString *)processCommandWithArgc:(int)argc argv:(char **)argv;

@end
