#import "RootViewController.h"

@interface YunJieMiApplication: UIApplication <UIApplicationDelegate> {
	UIWindow *_window;
	RootViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation YunJieMiApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[RootViewController alloc] init];
	[_window addSubview:_viewController.view];
	[_window makeKeyAndVisible];
}

- (void)dealloc {
	[_window release];
	[super dealloc];
}
@end

// vim:ft=objc
