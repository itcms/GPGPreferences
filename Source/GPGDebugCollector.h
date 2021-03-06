#import <Foundation/Foundation.h>

@interface GPGDebugCollector : NSObject <NSStreamDelegate> {
	NSMutableDictionary *debugInfos;
	NSString *gpgHome;
}

- (NSDictionary *)debugInfos;
- (NSString *)runShellCommand:(NSString *)command;

@end
