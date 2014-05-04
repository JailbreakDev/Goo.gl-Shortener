#import "SRShortener.h"

@implementation UIViewController (TopMostViewController)

+ (UIViewController *)topMostController {
    
    UIWindow *topWndow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = topWndow.rootViewController;
    
    if (topController == nil) {

        for (UIWindow *aWndow in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
            topController = aWndow.rootViewController;
            if (topController)
                break;
        }
    }
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end

@implementation SRURLShortener

- (void)shortenURL:(NSString *)url {
    
    HUD = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
    [HUD setText:@"Shortening..."];
    [HUD showInView:[UIViewController topMostController].view];
    
    data = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60] autorelease];
        
    NSString *jsonRequest = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}",url];
        
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
        
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestData];

    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:FALSE] autorelease];
    [connection start];

}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD setText:@"Failed to short URL"];
    [HUD performSelector:@selector(hide) withObject:nil afterDelay:0.5];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)rData {
    
    [data appendData:rData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [HUD setText:@"Done!"];
   
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    [HUD setText:[NSString stringWithFormat:@"URL: %@ - Copied",jsonDict[@"id"]]];
    [[UIPasteboard generalPasteboard] setString:jsonDict[@"id"]];
    [HUD done];
    [HUD performSelector:@selector(hide) withObject:nil afterDelay:1.0];
}

-(void)dealloc {
    
    [data release];
    data = nil;
    [HUD release];
    HUD = nil;
    
    [super dealloc];
}

@end

@implementation UIResponder (SRShortener)

+ (void)load {
    
	id <AMMenuItem> menuItem = [[UIMenuController sharedMenuController] registerAction:@selector(shortenURL) title:@"Goo.gl" canPerform:@selector(canShortenText)];
    menuItem.image = [UIImage imageWithContentsOfFile:([UIScreen mainScreen].scale == 2.0f) ? @"/Library/ActionMenu/Plugins/SRShortener@2x.png" : @"/Library/ActionMenu/Plugins/SRShortener.png"];
}

- (BOOL)canShortenText {
    
	return [[self selectedTextualRepresentation] length] > 0;
}

- (void)shortenURL {
    
    NSString *selection = [self selectedTextualRepresentation];
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    
    NSTextCheckingResult *result = [detect firstMatchInString:selection options:0 range:NSMakeRange(0, [selection length])];
    
    if (result.range.location == NSNotFound) {
        return;
    }
    
    SRURLShortener *shortener = [[SRURLShortener alloc] init];
    [shortener shortenURL:result.URL.absoluteString];
    [shortener release];
    [detect release];
}


@end
