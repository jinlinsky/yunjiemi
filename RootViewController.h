#import <MediaPlayer/MPMoviePlayerController.h>

@interface RootViewController: UIViewController {
	bool mIsConnected;
	MPMoviePlayerController* mMoviePlayerController;
}

- (void)playMovie;
- (void)stopMovie;
- (void)handleTimer;

@end
