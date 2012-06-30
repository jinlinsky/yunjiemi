#import <MediaPlayer/MPMoviePlayerController.h>
#include <string.h>

@interface RootViewController: UIViewController {
	MPMoviePlayerController* mMoviePlayerController;
	
	NSString* mIp; 
	NSString* mPort;
}   

- (void)playMovie;
- (void)stopMovie;
- (void)MessageReceiverTimer;

@end
