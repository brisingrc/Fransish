//
//  EnglishPhraseTableViewCell.m
//  LearnEnglish
//
//  Created by DungTV on 4/23/14.
//  Copyright (c) 2014 dung-tv. All rights reserved.
//

#import "EnglishPhraseTableViewCell.h"
#import "GlobalConstants.h"


@implementation EnglishPhraseTableViewCell

@synthesize delegate;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (delegate) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [delegate cellClicked:self];
    }
}

-(IBAction)Clicked:(id)sender{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [delegate favoriteClicked:(UIButton*)sender];
}


@end
