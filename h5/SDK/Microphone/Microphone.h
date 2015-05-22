
#import <Foundation/Foundation.h>

@interface Microphone : NSObject

//@property(nonatomic) float recordTime;

-(void) showMicrophone;
-(void) stopMicrophone;
//音量大小0-1
-(void) updateVoiceVolume:(float)VoiceVolume;
-(void) Transform:(float)angle;
@end
