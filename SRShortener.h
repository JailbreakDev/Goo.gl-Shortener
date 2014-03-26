#import "ActionMenu/ActionMenu.h"
#import "UIProgressHUD.h"

@class UIProgressHUD;

@interface SRURLShortener : NSObject <NSURLConnectionDelegate> {
    NSMutableData *data;
    UIProgressHUD *HUD;
}
@end

@interface UIResponder (SRShortener)
- (BOOL)canShortenText;
- (void)shortenURL;
@end

@interface UIViewController (TopMostViewController)
+ (UIViewController *)topMostController;
@end