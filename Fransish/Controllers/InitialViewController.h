//
//  InitialViewController.h
//  LearnLanguage
//
//  Created by Hero-Yosemite on 11/2/17.
//  Copyright © 2017 Nguyen The Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InitialViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *arrayOfCatalogue;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
-(IBAction)clickSearch;
-(IBAction)favotire;
@end
