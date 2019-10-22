//
//  GlobalConstants.h
//  FairyTaleUniversal
//
//  Created by Nguyen The Hung on 4/13/13.
//  Copyright (c) 2013 Nguyen The Hung. All rights reserved.
//

#ifndef BarnyardBabiesHD_CommonDefine_h
#define BarnyardBabiesHD_CommonDefine_h

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define IS_IPHONE_XS (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XR (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
#define IS_IPHONE_MAX (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)

//#define encryptPassWord @"Whats ert IDS ADospd 12dhk D9oLk kdsd"
#define encryptPassWord @"How aRe you bAby KutE 12321 lalalagh"
#define DBName @"French.sqlite"
//----

#endif
