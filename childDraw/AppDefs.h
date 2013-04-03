//
//  AppDefs.h
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#ifndef childDraw_AppDefs_h
#define childDraw_AppDefs_h


#define M_APPLEID 626129422

#define CUSTOM_NAV_HEIGHT 40.0f
#define ZIPPREFIX @"http://babylearn.b0.upaiyun.com/"
///////////////////////////////////////////////////////////////////////////////////////////////////

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:(a)]

#define RGBA(r,g,b,a) (r)/255.0f, (g)/255.0f, (b)/255.0f, (a)


#define BGCOLOR [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]
#define BLUECOLOR [UIColor colorWithRed:70.0f/255.0f green:93.0f/255.0f blue:121.0f/255.0f alpha:1]
#define GREENCOLOR [UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1]
#define REDCOLOR [UIColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:1]
#define GRAYCOLOR [UIColor colorWithRed:158.0f/255.0f green:158.0f/255.0f blue:158.0f/255.0f alpha:1]
#define HANDLEBORDERCOLOR [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1].CGColor
#define HANDLEBGCOLOR [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1]
#define DARKCOLOR [UIColor colorWithRed:57.0f/255.0f green:57.0f/255.0f blue:57.0f/255.0f alpha:1]

#define TOTAL_WIDTH 320.0f
#define BIG_BUTTON_WIDTH 128.0f

#define DOWNLOADFINISH @"DownloadFinish"

// font
#define BIGCUSTOMFONT [UIFont fontWithName:@"Museo" size:40.0f]
#define CUSTOMFONT [UIFont fontWithName:@"Museo" size:16.0f]
#define LITTLECUSTOMFONT [UIFont fontWithName:@"Museo" size:13.0f]
#define TINYCUSTOMFONT [UIFont fontWithName:@"Museo" size:11.0f]

///////////////////////////////////////////////////////////////////////////////////////////////////
// add by mactive
#define T(a)    NSLocalizedString((a), nil)

#define INT(a)  [NSNumber numberWithInt:(a)]
#define NUM_BOOL(a) [NSNumber numberWithBool:(a)]
#define STR(a)  [NSString stringWithFormat:@"%@", (a)]
#define STR_INT(a)  [NSString stringWithFormat:@"%d", (a)]

#define NUMBER_OR_NIL(a)	\
(((a) && [(a) isKindOfClass:[NSNumber class]]) ? (a) : nil)

#define STRING_OR_NIL(a)	\
(((a) && [(a) isKindOfClass:[NSString class]]) ? (a) : nil)

#define STRING_OR_EMPTY(a)	\
(((a) && [(a) isKindOfClass:[NSString class]]) ? (a) : @"")

#define kDateFormat  @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z"


#define UIKeyboardNotificationsObserve() \
NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; \
[notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];\
[notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

#define NotificationsUnobserve() \
[[NSNotificationCenter defaultCenter] removeObserver:self];

#pragma mark - Core Data

#define MOCSave(managedObjectContext) { \
NSError __autoreleasing *error = nil; \
NSAssert([managedObjectContext save:&error], @"-[NSManagedObjectContext save] error:\n\n%@", error); }

#define MOCCountAll(managedObjectContext, entityName) \
MOCCount(_managedObjectContext, [NSFetchRequest fetchRequestWithEntityName:entityName])

//#define MOCCount(managedObjectContext, fetchRequest) \
//NSManagedObjectContextCount(self, _cmd, managedObjectContext, fetchRequest)
//
//NS_INLINE NSUInteger NSManagedObjectContextCount(id self, SEL _cmd, NSManagedObjectContext *managedObjectContext, NSFetchRequest *fetchRequest) {
//    NSError __autoreleasing *error = nil;
//    NSUInteger objectsCount = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
//    NSAssert(objectsCount != NSNotFound, @"-[NSManagedObjectContext countForFetchRequest:error:] error:\n\n%@", error);
//    return objectsCount;
//}

NS_INLINE BOOL StringHasValue(NSString * str) {
    return (str != nil) && (![str isEqualToString:@""]);
}



#endif
