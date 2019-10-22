//
//  EnglishPhraseTableViewCell.h
//  LearnEnglish
//
//  Created by DungTV on 4/23/14.
//  Copyright (c) 2014 dung-tv. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol  MainCellDelegate <NSObject>

-(void)cellClicked:(UITableViewCell*)cell;
-(void)favoriteClicked:(UIButton*)sender;

@end

@interface EnglishPhraseTableViewCell : UITableViewCell

@property (nonatomic, assign) id <MainCellDelegate> delegate;

-(IBAction)Clicked:(id)sender;

@end
