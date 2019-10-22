//
//  FrenchPhraseTableViewCell.m
//  LearnEnglish
//
//  Created by DungTV on 4/23/14.
//  Copyright (c) 2014 dung-tv. All rights reserved.
//

#import "FrenchPhraseTableViewCell.h"

@implementation FrenchPhraseTableViewCell

@synthesize delegate;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)recordPress:(id)sender{
    if (delegate) {
        [delegate recordButton:(UIButton*)sender];
    }
}

- (IBAction)playPress:(id)sender{
    if (delegate) {
        [delegate playerButton:(UIButton*)sender];
    }
}

- (IBAction)playSlowPress:(id)sender{
    if (delegate) {
        [delegate playSlowButton:(UIButton*)sender];
    }
}

- (IBAction)playDefaultPress:(id)sender{
    if (delegate) {
        [delegate playDefaultButton:(UIButton*)sender];
    }
}

@end
