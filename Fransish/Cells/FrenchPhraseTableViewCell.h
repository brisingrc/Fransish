//
//  FrenchPhraseTableViewCell.h
//  LearnEnglish
//
//  Created by DungTV on 4/23/14.
//  Copyright (c) 2014 dung-tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailtCellDelegate <NSObject>

-(void)recordButton:(UIButton*)button;
-(void)playerButton:(UIButton*)button;
-(void)playSlowButton:(UIButton*)button;
-(void)playDefaultButton:(UIButton*)button;

@end

@interface FrenchPhraseTableViewCell : UITableViewCell

@property (nonatomic, assign) id <DetailtCellDelegate> delegate;

@end
