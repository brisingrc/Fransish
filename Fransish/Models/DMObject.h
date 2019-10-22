//
//  DMObject.h
//  LearnLanguage
//
//  Created by Nguyen The Hung on 4/22/14.
//  Copyright (c) 2014 Nguyen The Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMObject : NSObject

@property (nonatomic, strong) NSString *idOB;
@property (nonatomic, assign) int catagory_id;
@property (nonatomic, strong) NSString *english;
@property (nonatomic, strong) NSString *tips;
@property (nonatomic, strong) NSString *pronouciation;
@property (nonatomic, strong) NSString *translation;
@property (nonatomic, strong) NSString *voice;
@property (nonatomic, strong) NSString *favorite;

@end
