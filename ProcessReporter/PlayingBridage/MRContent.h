//
//  MRContent.h
//  ProcessReporter
//
//  Created by Innei on 2023/7/2.
//

@interface MRContentItemMetadata : NSObject
@property CGFloat calculatedPlaybackPosition;
@end

@interface MRContentItem : NSObject
@property (retain) MRContentItemMetadata *metadata;
- (instancetype)initWithNowPlayingInfo:(NSDictionary *)nowPlayingInfo;
@end
