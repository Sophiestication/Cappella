//
//  KeyCodeHelper.m
//  Cappella
//
//  Created by Sophiestication Software on 9/11/24.
//


// KeyCodeHelper.m
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

NSString * NSStringFromMASKeyCode(unsigned short keyCode) {
    if (keyCode < 0) return nil;

//    NSString *unmappedString = [keyCodeToStringDict objectForKey:@(keyCode)];
//    if (unmappedString != nil) return unmappedString;

    BOOL isPadKey = NO; // [padKeysArray containsObject:@(keyCode)];

    OSStatus err;
    TISInputSourceRef tisSource = TISCopyCurrentKeyboardInputSource();
    if (!tisSource) return nil;

    CFDataRef layoutData;
    UInt32 keysDown = 0;
    layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
    if (!layoutData) return nil;

    const UCKeyboardLayout *keyLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

    UniCharCount length = 4, realLength;
    UniChar chars[4];

    err = UCKeyTranslate(keyLayout,
                         keyCode,
                         kUCKeyActionDisplay,
                         0,
                         LMGetKbdType(),
                         kUCKeyTranslateNoDeadKeysBit,
                         &keysDown,
                         length,
                         &realLength,
                         chars);

    if (err != noErr) return nil;

    NSString *keyString = [[NSString stringWithCharacters:chars length:1] uppercaseString];

    return isPadKey ? [NSString stringWithFormat:@"Pad %@", keyString] : keyString;
}
