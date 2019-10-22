//
//  InitialViewController.m
//  LearnLanguage
//
//  Created by Hero-Yosemite on 11/2/17.
//  Copyright © 2017 Nguyen The Hung. All rights reserved.
//

#import "InitialViewController.h"
#import "GlobalConstants.h"
#import "PhrasesViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.arrayOfCatalogue = [[NSMutableArray alloc]init];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) init {
	self = [super initWithNibName:@"InitialViewController" bundle:[NSBundle mainBundle]];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	CGFloat cellWidth = (UIScreen.mainScreen.bounds.size.width / 2) - 16;
    [flowLayout setItemSize:CGSizeMake(cellWidth, 200)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
	[flowLayout setSectionInset:insets];
	[flowLayout setMinimumLineSpacing:8];
	[flowLayout setMinimumInteritemSpacing:8];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfCatalogue.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cvCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:98];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.text = [self.arrayOfCatalogue objectAtIndex:indexPath.row];
    
    UIImageView *round = (UIImageView *)[cell viewWithTag:100];
    [round setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Cell_%d.png",indexPath.row]]];
    
    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *catalogueName = [self.arrayOfCatalogue objectAtIndex:indexPath.row];
    PhrasesViewController *view = [[PhrasesViewController alloc] init];
    view.categoryID = indexPath.row+1;
    view.categoryName = catalogueName;
    [self.navigationController pushViewController:view animated:YES];

        
}

-(IBAction)favotire{
    PhrasesViewController *view = [[PhrasesViewController alloc] init];
    view.favoriteScreen = YES;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark search

-(IBAction)clickSearch{
    PhrasesViewController *view = [[PhrasesViewController alloc]init];
    view.searchScreen = YES;
    view.isFromHome = YES;
    [self.navigationController pushViewController:view animated:NO];
}

@end
