//
//  RDAudioPlayer.m
//
//  Created by radar on 2018/7/12.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "RDAudioPlayer.h"

static RDAudioPlayer *_sharedPlayer;


@interface RDAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, strong) NSURL *mAudioFileURL;
@property (nonatomic)         BOOL bLoop;


-(void)shutPlayer;

@end


@implementation RDAudioPlayer


#pragma mark -
#pragma mark system functions

+ (RDAudioPlayer *)sharedPlayer
{
	if (!_sharedPlayer) {
		_sharedPlayer = [[RDAudioPlayer alloc] init];
	}
	return _sharedPlayer;
}


- (void)dealloc
{		
	if(self.avPlayer && self.avPlayer.playing)
	{
		[self.avPlayer stop];
        self.avPlayer = nil;
	}
}




#pragma mark -
#pragma mark in use functions
-(void)shutPlayer
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer stop];
	}
	
	self.avPlayer = nil;
}



#pragma mark -
#pragma mark out use functions
-(void)setAudio:(NSString*)audio withType:(NSString*)type withLoop:(BOOL)bLoop
{
	self.bLoop = bLoop;
	
	NSString *audioPath = [[NSBundle mainBundle] pathForResource:audio ofType:type];
	if(audioPath == nil) 
	{
		self.mAudioFileURL = nil;
		return;
	}
	
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:audioPath];
	self.mAudioFileURL = fileURL;
}
-(void)setLocalURLAudio:(NSString*)audioPath withLoop:(BOOL)bLoop
{
	self.bLoop = bLoop;
	
	if(audioPath == nil) 
	{
		self.mAudioFileURL = nil;
		return;
	}
	
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:audioPath];
	self.mAudioFileURL = fileURL;
}

-(void)play
{    
	if(self.avPlayer && self.avPlayer.url)  //正在播放中 或 pause状态中
	{
        if(self.avPlayer.isPlaying)     //正在播放中
        {
            //中断当前播放，重新播放
            [self stop];
            [self play];
            return;
        }
        else                            //pause状态是没有正在播放的
        {
            [self.avPlayer play];       //resmue播放
        }
	}
	else								   //播放新的
	{
		[self shutPlayer];
		
		//init avPlayer
		if(self.avPlayer == nil)
		{
			AVAudioPlayer *aPlayer = [[AVAudioPlayer alloc] init];
			self.avPlayer = aPlayer;
		}
		self.avPlayer = [_avPlayer initWithContentsOfURL:self.mAudioFileURL error:nil];
		self.avPlayer.delegate = self;
		
		[self.avPlayer play];
	}
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidStartPlaying:)])
	{
		[self.delegate audioPlayerDidStartPlaying:self];
	}

}
-(void)stop
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer stop];
	}

	self.avPlayer = nil;
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
	{
		[self.delegate audioPlayerDidFinishPlaying:self];
	}
}
-(void)pause
{
	if(!self.avPlayer) return;
	if(self.avPlayer.playing)
	{
		[self.avPlayer pause];
	}
	
	//返回给代理
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidPausePlaying:)])
	{
		[self.delegate audioPlayerDidPausePlaying:self];
	}
}



#pragma mark -
#pragma mark delegate functions
//AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if(_bLoop)
	{
		[self.avPlayer play];
		
		//返回给代理
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerReplayStart:)])
		{
			[self.delegate audioPlayerReplayStart:self];
		}
	}
	else
	{
		[self shutPlayer];
		
		//返回给代理
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
		{
			[self.delegate audioPlayerDidFinishPlaying:self];
		}
	}

}




@end
