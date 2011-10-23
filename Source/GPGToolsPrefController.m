//
//  UpdateButton.m
//  GPGTools
//
//  Created by Alexander Willner on 04.08.10.
//  Edited by Roman Zechmeister 11.07.2011
//  Copyright 2010 GPGTools Project Team. All rights reserved.
//

#import "GPGToolsPrefController.h"
#import <Libmacgpg/Libmacgpg.h>

@implementation GPGToolsPrefController




/*
 * Returns a list of possible keyservers.
 */
- (NSArray *)keyservers {
    GPGOptions *options = [GPGOptions sharedOptions];
    
    NSURL *keyserversPlistURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Keyservers" withExtension:@"plist"];
    NSMutableSet *keyservers = [NSMutableSet setWithArray:[NSArray arrayWithContentsOfURL:keyserversPlistURL]];
    [keyservers addObjectsFromArray:[options allValuesInGPGConfForKey:@"keyserver"]];
    return [keyservers allObjects];
}


/*
 * Returns all secret keys.
 *
 * @todo	Support for gpgController:keysDidChangedExernal:
 */
- (NSArray *)secretKeys {
	if (!secretKeys) {
		secretKeys = [[[GPGController gpgController] allSecretKeys] allObjects];
	}
	return secretKeys;
}


/*
 * Displays a simple sheet.
 */
- (void)simpleSheetWithTitle:(NSString *)title informativeText:(NSString *)informativeText {
	NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", informativeText];
	[alert setIcon:[[NSImage alloc] initWithContentsOfFile:[self.myBundle pathForImageResource:@"GPGTools"]]];
	[alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];	
}

/*
 * The NSBundle for GPGPreferences.prefPane.
 */
- (NSBundle *)myBundle {
	if (!myBundle) {
		myBundle = [NSBundle bundleForClass:[self class]];
	}
	return myBundle;
}



/*
 * Remove GPGMail plug-in.
 *
 * @todo	Is there a method that returns the bundle path?
 */
- (IBAction)gpgmailRemove:(id)sender {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path;
	
	
	path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Mail/Bundles/GPGMail.mailbundle"];	
	NSLog(@"Removing '%@'...", path);
	[fileManager removeItemAtPath: path error:NULL];
	
	path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.gpgmail.plist"];	
	NSLog(@"Removing '%@'...", path);
	[fileManager removeItemAtPath: path error:NULL];
	
	[self simpleSheetWithTitle:@"GPGMail removed" informativeText:@"GPGMail removed."];
}


/*
 * Fix GPGTools.
 *
 * @todo	Do not use shell script, implement it using objective-c instead
 */
- (IBAction)gpgFix:(id)sender {
	NSString *path = [self.myBundle pathForResource:@"gpgtools-autofix" ofType:@"sh"];	
	NSLog(@"Starting '%@'...", path);
	NSTask *task=[[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *file = [pipe fileHandleForReading];
	[task setStandardOutput:pipe];
	[task setLaunchPath:path];
	[task launch];
	[task waitUntilExit];
	NSData *data = [file readDataToEndOfFile];
	NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	[self simpleSheetWithTitle:@"GPGTools fix result:" informativeText:result];
}

/*
 * Open FAQ.
 *
 */
- (IBAction)openFAQ:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/faq.html"]];
}

/*
 * Open Contact.
 *
 */
- (IBAction)openContact:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/about.html"]];
}

/*
 * Open Donate.
 *
 */
- (IBAction)openDonate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/donate.html"]];
}


/*
 * Give the credits from Credits.rtf.
 */
- (NSAttributedString *)credits {
	return [[[NSAttributedString alloc] initWithPath:[self.myBundle pathForResource:@"Credits" ofType:@"rtf"] documentAttributes:nil] autorelease];
}

/*
 * Returns the bundle version.
 */
- (NSString *)bundleVersion {
	return [self.myBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
}

/*
 * Array of readable descriptions of the secret keys.
 */
- (NSArray *)secretKeyDescriptions {
	NSArray *keys = self.secretKeys;
	NSMutableArray *decriptions = [NSMutableArray arrayWithCapacity:[keys count]];
	for (GPGKey *key in keys) {
		[decriptions addObject:[NSString stringWithFormat:@"%@ – %@", key.userID, key.shortKeyID]];
	}
	return decriptions;
}

/*
 * Index of the default key.
 */
- (NSUInteger)indexOfSelectedSecretKey {
	GPGOptions *options = [GPGOptions sharedOptions];
	NSString *defaultKey = [options valueForKey:@"default-key"];
	if ([defaultKey length] == 0) {
		return 0;
	}
	
	NSArray *keys = self.secretKeys;
	
	NSUInteger i, count = [keys count];
	for (i = 0; i < count; i++) {
		GPGKey *key = [keys objectAtIndex:i];
		if ([key.textForFilter rangeOfString:defaultKey options:NSCaseInsensitiveSearch].length > 0) {
			return i;
		}		
	}
	
	return 0;
}
- (void)setIndexOfSelectedSecretKey:(NSUInteger)index {
	NSArray *keys = self.secretKeys;
	if (index < [keys count]) {
		GPGOptions *options = [GPGOptions sharedOptions];
		[options setValue:[[keys objectAtIndex:index] fingerprint] forKey:@"default-key"];
	}
}

@end
