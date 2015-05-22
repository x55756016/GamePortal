
#import "Microphone.h"
#import "MicrophoneHud.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - <DEFINES>

//#define WAVE_UPDATE_FREQUENCY   0.05

#pragma mark - <CLASS> LCVoice

@interface Microphone () <AVAudioRecorderDelegate>
{
//    NSTimer * timer_;
    
    LCVoiceHud * voiceHud_;    
}

@end

@implementation Microphone


#pragma mark - Publick Function

-(void) showMicrophone
{
    [self showVoiceHudOrHide:YES];

}

-(void) stopMicrophone
{
//    [self resetTimer];
    [self showVoiceHudOrHide:NO];

}

#pragma mark - Timer Update

-(void) updateVoiceVolume:(float)VoiceVolume {
 
    if (voiceHud_)
    {
         [voiceHud_ setProgress:VoiceVolume];
    }
}
-(void)Transform:(float)angle{
    
  CGFloat f=angle;
  voiceHud_.transform = CGAffineTransformMakeRotation(f);
}
#pragma mark - Helper Function

-(void) showVoiceHudOrHide:(BOOL)yesOrNo{
    
    @try {
        
        if (voiceHud_) {
            [voiceHud_ hide];
            voiceHud_ = nil;
        }
        
        if (yesOrNo) {
            
            voiceHud_ = [[LCVoiceHud alloc] init];
            voiceHud_.transform =CGAffineTransformIdentity;
            [voiceHud_ show];
            
        }
    }
    @catch (NSException *exception) {
        
    }
}
@end
