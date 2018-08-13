//
//  RDAudioPlayer.h
//
//  Created by radar on 2018/7/12.
//  Copyright © 2018年 radar. All rights reserved.
//
// PS: 需要添加两个FrameWork :  AudioToolbox.framework 和 AVFoundation.framework


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



@class RDAudioPlayer;
@protocol AudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerDidStartPlaying:(RDAudioPlayer*)RDAudioPlayer;
- (void)audioPlayerDidPausePlaying:(RDAudioPlayer*)RDAudioPlayer;
- (void)audioPlayerDidFinishPlaying:(RDAudioPlayer*)RDAudioPlayer;

- (void)audioPlayerReplayStart:(RDAudioPlayer*)RDAudioPlayer;
@end


@interface RDAudioPlayer : NSObject <AVAudioPlayerDelegate> 

@property (assign) id<AudioPlayerDelegate> delegate;

+ (RDAudioPlayer *)sharedPlayer; //可以不用单实例，alloc方式也可以


//这两个函数分别使用，看参数是什么
-(void)setAudio:(NSString*)audio withType:(NSString*)type withLoop:(BOOL)bLoop; //type里边不带“.” 
-(void)setLocalURLAudio:(NSString*)audioPath withLoop:(BOOL)bLoop; //only can support the local file URL, not support the http URL

-(void)play;
-(void)stop;
-(void)pause;


@end
