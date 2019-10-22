//
//  DetailView.h
//  LearnLanguage
//
//  Created by Nguyen The Hung on 4/22/14.
//  Copyright (c) 2014 Nguyen The Hung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <AVFoundation/AVFoundation.h>

@interface PhrasesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>{
    AVAudioPlayer *soundRead;
    NSString *strSoundPath1;
}


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, assign) int categoryID;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;

@property (nonatomic, strong) IBOutlet UIButton *favouriteBTN;
@property (nonatomic, strong) IBOutlet UIButton *searchBTN;

@property (nonatomic, readwrite) BOOL favoriteScreen;
@property (nonatomic, readwrite) BOOL searchScreen;

-(IBAction)clickBack;
-(IBAction)favotire:(id)sender;
-(IBAction)clickSearch:(id)sender;

@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) IBOutlet UIButton *playAllBTN;
@property (nonatomic, assign) BOOL isFromHome;




@end
