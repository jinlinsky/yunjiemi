#import <MediaPlayer/MPMoviePlayerController.h>

@interface RootViewController: UIViewController {
	bool mIsConnected;
	MPMoviePlayerController* mMoviePlayerController;
	UILabel*   mWaitingLabel;
}

- (void)playMovie;
- (void)stopMovie;
- (void)MessageReceiverTimer;

@end
