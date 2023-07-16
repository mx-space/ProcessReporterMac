// nowplaying.m
// ProcessReporter
// Created by Innei on 2023/7/2.
#import "nowplaying.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "Enums.h"
#import "MRContent.h"

typedef void (*MRMediaRemoteGetNowPlayingInfoFunction)(dispatch_queue_t queue, void (^handler)(NSDictionary* information));
typedef Boolean (*MRMediaRemoteSendCommandFunction)(MRMediaRemoteCommand cmd, NSDictionary* userInfo);

typedef enum {
    GET,
    GET_RAW,
    MEDIA_COMMAND

} Command;

@implementation NowPlaying

+ (NSString *)processCommandWithArgc:(int)argc argv:(char **)argv  {
    static NSDictionary<NSString*, NSNumber*> *cmdTranslate = @{
        @"play": @(MRMediaRemoteCommandPlay),
        @"pause": @(MRMediaRemoteCommandPause),
        @"togglePlayPause": @(MRMediaRemoteCommandTogglePlayPause),
        @"next": @(MRMediaRemoteCommandNextTrack),
        @"previous": @(MRMediaRemoteCommandPreviousTrack),
    };

    __block NSString *result = @"";

    Command command = GET;
    NSString *cmdStr = [NSString stringWithUTF8String:argv[1]];

    int numKeys = argc - 2;
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    if(strcmp(argv[1], "get") == 0) {
        for(int i = 2; i < argc; i++) {
            NSString *key = [NSString stringWithUTF8String:argv[i]];
            [keys addObject:key];
        }
        command = GET;
    }
    else if(strcmp(argv[1], "get-raw") == 0) {
        command = GET_RAW;
    }
    else if(cmdTranslate[cmdStr] != nil) {
        command = MEDIA_COMMAND;
    }
    else {
        return result;
    }

    @autoreleasepool {

        CFURLRef ref = (__bridge CFURLRef) [NSURL fileURLWithPath:@"/System/Library/PrivateFrameworks/MediaRemote.framework"];
        CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, ref);

        MRMediaRemoteSendCommandFunction MRMediaRemoteSendCommand = (MRMediaRemoteSendCommandFunction) CFBundleGetFunctionPointerForName(bundle, CFSTR("MRMediaRemoteSendCommand"));
        if(command == MEDIA_COMMAND) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand) [cmdTranslate[cmdStr] intValue], nil);
        }

        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);

        MRMediaRemoteGetNowPlayingInfoFunction MRMediaRemoteGetNowPlayingInfo = (MRMediaRemoteGetNowPlayingInfoFunction) CFBundleGetFunctionPointerForName(bundle, CFSTR("MRMediaRemoteGetNowPlayingInfo"));
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(NSDictionary* information) {
            if(command == MEDIA_COMMAND) {
                return;
            }
            

            NSString *data = [information description];
            if(command == GET_RAW) {
                result = [result stringByAppendingFormat:@"%@\n", data];
                dispatch_group_leave(group);
                return;
            }

            for(int i = 0; i < numKeys; i++) {
                NSString *propKey = [keys[i] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[keys[i] substringToIndex:1] capitalizedString]];
                NSString *key = [NSString stringWithFormat:@"kMRMediaRemoteNowPlayingInfo%@", propKey];
                NSObject *rawValue = [information objectForKey:key];
                if(rawValue == nil) {
                    result = [result stringByAppendingString:@"null\n"];
                }
                else if([key isEqualToString:@"kMRMediaRemoteNowPlayingInfoArtworkData"] || [key isEqualToString:@"kMRMediaRemoteNowPlayingInfoClientPropertiesData"]) {
                    NSData *data = (NSData *) rawValue;
                    NSString *base64 = [data base64EncodedStringWithOptions:0];
                    result = [result stringByAppendingFormat:@"%@\n", base64];
                }
                else if([key isEqualToString:@"kMRMediaRemoteNowPlayingInfoElapsedTime"]) {
                    MRContentItem *item = [[objc_getClass("MRContentItem") alloc] initWithNowPlayingInfo:information];
                    NSString *value = [NSString stringWithFormat:@"%f", item.metadata.calculatedPlaybackPosition];
                    result = [result stringByAppendingFormat:@"%@\n", value];
                }
                else {
                    NSString *value = [NSString stringWithFormat:@"%@", rawValue];
                    result = [result stringByAppendingFormat:@"%@\n", value];
                }
            }
            
            

            dispatch_group_leave(group);
        });

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    
    return result;
}
@end
