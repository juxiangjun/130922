SpeechToText
============

"Fork" of kronik / ZhiShi's iPhone-Speech-To-Text library to access Google's Speech for Chrome that adds more languages and a non-GUI version.

https://github.com/kronik/ZhiShi/tree/master/src/iPhone-Speech-To-Text 

#Locale
##Suported languages
* kLANG_SPANISH @"es-ES"
* kLANG_CATALAN @"ca-ES"
* kLANG_FRENCH @"fr"
* kLANG_ENGLISH @"en-US" (default language)

##Unsuported language
You can use the non-GUI init for unsoported version using a language code from this list: http://msdn.microsoft.com/es-es/library/system.globalization.cultureinfo(v=vs.80).aspx

If you want to use the GUI inits with unsopported laguage, add the changes on both SpeechToTextModule .m and .h and recompile the library.


#Setup
* Add the folder "SpeechToText" to your Project.
* Import SpeechToTextModule.h on your code

Add the following Frameworks:
* AVFoundation.framework
* AudioToolbox.framework


#Example

### On your .h file:
Add UIGestureRecognizerDelegate to your @interface
```objective-c
#import "SpeechToTextModule.h"
@property (nonatomic, strong) SpeechToTextModule *speech;
```

### On your .m file:
Initialize SpeechToTextModule:
```objective-c
self.speech  = [[SpeechToTextModule alloc] initWithLocale:kLANG_SPANISH];
[self.speech setDelegate:self];
```

For the non-GUI version you must use:
```objective-c
self.speech = [[SpeechToTextModule alloc] initWithNoGUIAndLocale:kLANG_SPANISH];
[self.speech setDelegate:self];
```

To start recording:
```objective-c
[self.speech beginRecording];
```

To end recording:
```objective-c
[self.speech stopRecording:YES];
```

Delegates
```objective-c
- (void)didRecognizeResponse:(NSString *)recognizedText
{
    NSLog(@"%@", recognizedText);
}
- (void)speechStartRecording
{
    NSLog(@"REC...");
}
- (void)speechStopRecording
{
    NSLog(@"STOP");
}
```

See the demos for a live example of the library

#ToDo
##Wave form delegate
A delegate with a wave's UIImage