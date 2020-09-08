//
//  KSAudioPlayer.m
//  Telegraph
//
//  Created by saeipi on 2020/9/5.
//

#import "KSAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface KSAudioPlayer()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,assign ) BOOL          playing;
@end

@implementation KSAudioPlayer

-(instancetype)init {
    if (self = [super init]) {
        [self initAudioPlayer];
    }
    return self;
}

- (void)initAudioPlayer {
    NSString *audioFilePath    = [[NSBundle mainBundle] pathForResource:@"mozart" ofType:@"mp3"];
    NSURL *audioFileURL        = [NSURL URLWithString:audioFilePath];
    _audioPlayer               = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    _audioPlayer.numberOfLoops = -1;
    _audioPlayer.volume        = 1.0;
    [_audioPlayer prepareToPlay];
}

- (void)play {
    if (_playing == NO) {
        _playing = YES;
        [_audioPlayer play];
    }
}

- (void)stop {
    if (_playing) {
        _playing = NO;
        [_audioPlayer stop];
    }
}

@end
