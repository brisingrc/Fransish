//
//  DetailView.m
//  LearnLanguage
//
//  Created by Nguyen The Hung on 4/22/14.
//  Copyright (c) 2014 Nguyen The Hung. All rights reserved.
//

#import "PhrasesViewController.h"
#import "DMObject.h"
#import "GlobalConstants.h"
#import <AVFoundation/AVFoundation.h>
#import "FrenchPhraseTableViewCell.h"
#import "EnglishPhraseTableViewCell.h"
#import "FBEncryptorAES.h"

@interface PhrasesViewController ()<AVAudioPlayerDelegate, AVAudioRecorderDelegate, DetailtCellDelegate, MainCellDelegate> {
    sqlite3 *catalogueDB;
    NSString *dbPathString;
    NSMutableArray *arrayOfObject;
    
    NSString *strSoundPath;
    
    int indexClick;
    
    NSString *searchString;
    
}

@end
int numberOfClick;
int numberOfClickSearch;
@implementation PhrasesViewController {
    NSMutableArray *index;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSTimer *myTimer;
    NSTimer *myTimerRecord;
    
    BOOL playerFinished;
    BOOL checkRecord;//return yes if exist file record
    
    float timeRecord;
    
    UIButton *recordButton;
    
    NSInteger detailtCellTag;
    NSString *source;
    
    BOOL checkAutoPlay;

    NSTimer *myTimerAutoPlay;
    
    
}

@synthesize favoriteScreen;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) init {
	self = [super initWithNibName:@"PhrasesViewController" bundle:[NSBundle mainBundle]];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mySearchBar setHidden:YES];
    if(self.searchScreen)   [self.mySearchBar setHidden:NO];
    if (self.isFromHome)    [self.myTableView setHidden:YES];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.mySearchBar.frame = CGRectMake(0, -44, self.mySearchBar.frame.size.width,self.mySearchBar.frame.size.height);
    self.searchScreen = NO;
    [self.searchBTN setTag:0];
    
    indexClick = 0;
    
    if (self.favoriteScreen) {
        [self.favouriteBTN setHidden:YES];
    }else{
        [self.favouriteBTN setHidden:NO];
    }
	
//	[self.nameLbl setFont:[UIFont boldSystemFontOfSize:17]];
    self.nameLbl.adjustsFontSizeToFitWidth = YES;
    self.nameLbl.text = self.categoryName;
    arrayOfObject = [NSMutableArray array];
    index = [NSMutableArray array];
    [self createOrOpenDB];
    [self makeArrayOfObject];
    
    if(arrayOfObject.count <= 0){
        [self.playAllBTN setHidden:YES];
    }else{
        [self.playAllBTN setHidden:NO];
    }
    
    //NSLog(@"number of Array:%d",arrayOfObject.count);
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"RecordFile.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark Database handle
//create or open DB method
-(void)createOrOpenDB{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    dbPathString = [docPath stringByAppendingPathComponent:DBName];//name of db file hungnt
    char *error;
    NSError *error1;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    //copy db
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBName];
    [fileManage copyItemAtPath:defaultDBPath toPath:dbPathString error:&error1];
    
    if (![fileManage fileExistsAtPath:dbPathString]){
        const char *dbPath =[dbPathString UTF8String];
        //ceate database here
        if(sqlite3_open(dbPath,&catalogueDB) == SQLITE_OK){
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS RECIPES (_id INTEGER PRIMARY KEY AUTOINCREMENT, category_id INTEGER, english TEXT, tips_male TEXT,tips_female TEXT, trans_p_male TEXT, trans_p_female TEXT, trans_n_male TEXT, trans_n_female TEXT, favorite TEXT,voice TEXT, status TEXT)";
            sqlite3_exec(catalogueDB, sql_stmt, NULL, NULL, &error);
            sqlite3_close(catalogueDB);
        }
    }
    
}

- (void)makeArrayOfObject{
    
    //hungnt fix arabic
    //if(self.categoryID >=11) self.categoryID++;
    
    sqlite3_stmt *statement;
    if(sqlite3_open([dbPathString UTF8String], &catalogueDB) == SQLITE_OK){
        [arrayOfObject removeAllObjects];
        [index removeAllObjects];
        NSString *querySql;
        
        if (favoriteScreen) {
            querySql = [NSString stringWithFormat:@"SELECT * FROM phrase WHERE favorite = 1"];
        }else if (self.searchScreen){
            querySql = [NSString stringWithFormat:@"SELECT * FROM phrase"];
        }
        else {
            querySql = [NSString stringWithFormat:@"SELECT * FROM phrase WHERE category_id = %d",self.categoryID];
        }
        
        const char *query_sql = [querySql UTF8String];
        if(sqlite3_prepare(catalogueDB, query_sql, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW){
                
                //get infor from the database, the column 1 and 2 in structor sql table
                
                const char* idChar   = (const char*)sqlite3_column_text(statement, 0);
                NSString *idOB = idChar == NULL ? nil: [[NSString alloc]initWithUTF8String:idChar];
                
                const char* englishChar   = (const char*)sqlite3_column_text(statement, 2);
                NSString *english = englishChar == NULL ? nil: [[NSString alloc]initWithUTF8String:englishChar];
                NSString* decryptEnglish = [FBEncryptorAES decryptBase64String:english keyString:encryptPassWord];
                
                /*
                const char* tipsChar   = (const char*)sqlite3_column_text(statement, 4);
                NSString *tips = tipsChar == NULL ? nil: [[NSString alloc]initWithUTF8String:tipsChar];
                */
                const char* pronoChar   = (const char*)sqlite3_column_text(statement, 6);
                NSString *pronouciation = pronoChar ==NULL ? nil: [[NSString alloc]initWithUTF8String:pronoChar];
                NSString* decryptProno = [FBEncryptorAES decryptBase64String:pronouciation keyString:encryptPassWord];
                //hungnt
                
                const char* transChar   = (const char*)sqlite3_column_text(statement, 7);
                NSString *translation = transChar == NULL ? nil: [[NSString alloc]initWithUTF8String:transChar];
                NSString* decryptTrans = [FBEncryptorAES decryptBase64String:translation keyString:encryptPassWord];
				
                const char* voiceChar   = (const char*)sqlite3_column_text(statement, 10);
                NSString *voice = voiceChar == NULL ? nil: [[NSString alloc]initWithUTF8String:voiceChar];
                
                const char* favoriteChar   = (const char*)sqlite3_column_text(statement, 9);
                NSString *favorite = favoriteChar == NULL ? nil: [[NSString alloc]initWithUTF8String:favoriteChar];
                
                DMObject *obj = [[DMObject alloc]init];
                
                
                [obj setIdOB:idOB];
                [obj setEnglish:decryptEnglish];
                //[obj setTips:tips];hungnt
                [obj setPronouciation:decryptProno];
                [obj setTranslation:decryptTrans];
                [obj setVoice:voice];
                [obj setFavorite:favorite];
                
                if(!self.searchScreen){
                    [arrayOfObject addObject:obj];
                    [index addObject:@"1"];
                }else{//searchScreen
                    NSRange stringRanger;
                    
                    stringRanger= [obj.english rangeOfString:searchString options:NSCaseInsensitiveSearch];
                    if(stringRanger.location != NSNotFound){
                        [arrayOfObject addObject:obj];
                        [index addObject:@"1"];
                    }
                    
                    
                    stringRanger= [obj.translation rangeOfString:searchString options:NSCaseInsensitiveSearch];
                    if(stringRanger.location != NSNotFound){
                        [arrayOfObject addObject:obj];
                        [index addObject:@"1"];
                    }
                }
            }
        }
    }
    sqlite3_close(catalogueDB);
}

#pragma mark tableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrayOfObject count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([(index)[indexPath.row] isEqualToString:@"2"]) {
		return 180;
	}
	return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView;
    UILabel *headerLabel;
	sectionHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, 44)];
	headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, sectionHeaderView.frame.size.width-20, 44)];
	[headerLabel setFont:[UIFont boldSystemFontOfSize:20]];
    headerLabel.adjustsFontSizeToFitWidth = YES;
    sectionHeaderView.backgroundColor = [UIColor clearColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.numberOfLines = 0;
    headerLabel.textColor = [UIColor whiteColor];
    
    [sectionHeaderView addSubview:headerLabel];
    if(self.searchScreen)   headerLabel.text = @"Search Results";
    else if (self.favoriteScreen) headerLabel.text = @"Favourites";
    else    headerLabel.text = self.categoryName;
    
    
    //adding playAll Button
    /*
    UIButton *playAllBTN = [[UIButton alloc]initWithFrame:CGRectMake(290, 2, 25, 25)];
    [playAllBTN setTag:22];
    [playAllBTN setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playAllBTN addTarget:self action:@selector(playAll:) forControlEvents:UIControlEventTouchUpInside];
    
    [sectionHeaderView addSubview:playAllBTN];
     */
    return sectionHeaderView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DMObject *obj;
    obj = [arrayOfObject objectAtIndex:indexPath.row];
    if ([(index)[indexPath.row] isEqualToString:@"2"]) {
        detailtCellTag = indexPath.row;
        FrenchPhraseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrenchPhraseTableViewCell"];
        if (cell == nil) {
            NSArray *topLevelObjects;
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FrenchPhraseTableViewCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[FrenchPhraseTableViewCell class]])
                {
                    cell = (FrenchPhraseTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        UILabel *label = (UILabel*)[cell viewWithTag:100];
        label.adjustsFontSizeToFitWidth = YES;
        label.text = obj.translation;
        
        UILabel *prono = (UILabel*)[cell viewWithTag:108];
        prono.adjustsFontSizeToFitWidth = YES;
        prono.text = obj.pronouciation;
        
        cell.delegate = self;
//		cell.contentView.backgroundColor = [UIColor clearColor];
//		cell.backgroundColor = [UIColor clearColor];
		return cell;
    }
    else {
        EnglishPhraseTableViewCell *cell = nil;
        if (cell == nil) {
            NSArray *topLevelObjects;
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EnglishPhraseTableViewCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[EnglishPhraseTableViewCell class]])
                {
                    cell = (EnglishPhraseTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        UILabel *label = (UILabel*)[cell viewWithTag:100];
        label.adjustsFontSizeToFitWidth = YES;
        label.text = obj.english;
        
        cell.tag = indexPath.row;
        
        UIButton *bt = (UIButton*)[cell viewWithTag:1000000];
        bt.tag = indexPath.row;
        
        if ([obj.favorite isEqualToString:@"1"]) {
            [bt setImage:[UIImage imageNamed:@"StarIcon"] forState:UIControlStateNormal];
        }
        else {
            [bt setImage:[UIImage imageNamed:@"unStarIcon"] forState:UIControlStateNormal];
        }
		
//		cell.contentView.backgroundColor = [UIColor clearColor];
//		cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        return cell;
    }
}

//select row --> change to detail view hungnt
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    [myTimerRecord invalidate];
    myTimerRecord = nil;
    
    indexClick = indexPath.row;
    
    playerFinished = YES;
    [myTimer invalidate];
    myTimer = nil;
    NSInteger i = 0;
    NSIndexPath *tempIndexPath;
    if (![(index)[indexPath.row] isEqualToString:@"2"]) {
        
        //if autoplay is running, we are turn off
        [myTimerAutoPlay invalidate];
        myTimerAutoPlay = nil;
        checkAutoPlay = NO;
        
        DMObject *obj;
        obj =[arrayOfObject objectAtIndex:indexPath.row];
        strSoundPath= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",obj.voice] ofType:@"m4a"];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath] error:&error];
        player.delegate = self;
        //player.volume = 3.0;
#pragma mark audioOutPut
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];
        [player play];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(checkPlaybackTime:)
                                                 userInfo:nil
                                                  repeats:YES];
        //init value for loop
        BOOL check = FALSE;
        
        [self checkDataInIndexArr:YES :indexPath.row];
        
        //if current cell is 3, do nothing
        if (![(index)[indexPath.row] isEqualToString:@"3"]) {
            checkRecord = NO;
            //check in array index, if have 2, break out loop
            for (NSString *str in index) {
                if ([str isEqualToString:@"2"]) {
                    check = TRUE;
                    break;
                }
                i++;
            }
            if (check) {
#pragma mark fixCrashSearch deo biet tai sao
               
                    [index removeObjectAtIndex:i];
                    [arrayOfObject removeObjectAtIndex:i];
                    tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView deleteRowsAtIndexPaths:@[tempIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
            if (indexPath.row > i) i=indexPath.row;
            else i=indexPath.row + 1;
            DMObject *obj;
            obj = [arrayOfObject objectAtIndex:i-1];
            [arrayOfObject insertObject:obj atIndex:i];
            [index insertObject:@"2" atIndex:i];
            [index replaceObjectAtIndex:i-1 withObject:@"3"];
            tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [tableView insertRowsAtIndexPaths:@[tempIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        i = 0;
    }
    else {
        //set background for cell is while, if cell is TranslationTableViewCell
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
//        cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }
//    [self resetColorInTableView];
}

#pragma mark DetailtCellDelegate

-(void)recordButton:(UIButton *)button {
    if (playerFinished) {
        playerFinished = NO;
        myTimerRecord = [NSTimer scheduledTimerWithTimeInterval:timeRecord
                                                         target:self
                                                       selector:@selector(stopRecord)
                                                       userInfo:nil
                                                        repeats:NO];
        recordButton = button;
        if (player.playing) {
            [player stop];
        }
        if (!recorder.recording) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            // Start recording
            [recorder record];
            //[button setTitle:@"Recording" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"RecordingIcon"] forState:UIControlStateNormal];
            strSoundPath1= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"recordStart"] ofType:@"wav"];
            soundRead = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath1] error:NULL];
            [soundRead play];
        }
        else {
            // Pause recording
            //never call this method dungtv
            [recorder pause];
        }
    }
}

-(void)stopRecord{
    checkRecord = YES;
    playerFinished = YES;
    //[recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"RecordIcon"] forState:UIControlStateNormal];
    strSoundPath1= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"recordEnd"] ofType:@"wav"];
    soundRead = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath1] error:NULL];
    [soundRead play];
    [myTimerRecord invalidate];
    myTimerRecord = nil;
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

-(void)playerButton:(UIButton *)button {
    if (playerFinished) {
        if (checkRecord) {
            [recorder stop];
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:NO error:nil];
            if (!recorder.recording) {
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
                [player setDelegate:self];
#pragma mark audioOutPut
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];
                [player play];
            }
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Record your voice first" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

-(void)playSlowButton:(UIButton *)button {
    if (playerFinished) {
        NSInteger i=0;
        for (NSString *str in index) {
            if ([str isEqualToString:@"2"]) {
                break;
            }
            i++;
        }
        DMObject *obj;
        obj =[arrayOfObject objectAtIndex:i];
        strSoundPath= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",obj.voice] ofType:@"m4a"];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath] error:&error];
        player.delegate = self;
        player.enableRate = YES;
        player.rate = 0.5f;
        //player.volume = 2.0;
#pragma mark audioOutPut
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];
        [player play];
    }
}

-(void)playDefaultButton:(UIButton *)button {
    if (playerFinished) {
        playerFinished = NO;
        NSInteger i=0;
        for (NSString *str in index) {
            if ([str isEqualToString:@"2"]) {
                break;
            }
            i++;
        }
        DMObject *obj;
        obj =[arrayOfObject objectAtIndex:i];
        strSoundPath= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",obj.voice] ofType:@"m4a"];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath] error:&error];
        player.delegate = self;
        //player.volume = 2.0;
#pragma mark audioOutPut
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];
        [player play];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(checkPlaybackTime:)
                                                 userInfo:nil
                                                  repeats:YES];
    }
}

#pragma mark Get time of video

- (void) checkPlaybackTime:(NSTimer *)theTimer
{
    timeRecord = player.currentTime*2;
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [myTimer invalidate];
    myTimer = nil;
    playerFinished = YES;
    
    indexClick++;
    
    if (checkAutoPlay && indexClick < [arrayOfObject count]) {
        myTimerAutoPlay = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(autorun) userInfo:nil repeats:NO];
    }
}

#pragma mark Custom

-(IBAction)clickBack{
  
    [player stop];
    [self.navigationController popViewControllerAnimated:!self.isFromHome];
}

-(IBAction)playAll:(id)sender{
   // UIButton *playBTN = (UIButton*)[self.myTableView viewWithTag:22];
    if (checkAutoPlay) {
        [self.playAllBTN setImage:[UIImage imageNamed:@"PlayAllIcon"] forState:UIControlStateNormal];
        
        [player stop];
        [myTimerAutoPlay invalidate];
        myTimerAutoPlay = nil;
        checkAutoPlay = NO;
    }
    else if (indexClick < [arrayOfObject count]){
        [self.playAllBTN setImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
        [self autorun];
    }
}

-(void)autorun {
    checkAutoPlay = YES;
    [myTimerRecord invalidate];
    myTimerRecord = nil;
    
    playerFinished = YES;
    [myTimer invalidate];
    myTimer = nil;
    NSInteger i = 0;
    NSIndexPath *tempIndexPath;
    if (![(index)[indexClick] isEqualToString:@"2"]) {
        DMObject *newInsertObj;
        newInsertObj =[arrayOfObject objectAtIndex:indexClick];
        
        strSoundPath= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",newInsertObj.voice] ofType:@"m4a"];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strSoundPath] error:&error];
        player.delegate = self;
        //player.volume = 2.0;
#pragma mark audioOutPut
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];
        [player play];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(checkPlaybackTime:)
                                                 userInfo:nil
                                                  repeats:YES];
        BOOL check = FALSE;
        
        [self checkDataInIndexArr:YES :0];
        
        if (![(index)[indexClick] isEqualToString:@"3"]) {
            checkRecord = NO;
            for (NSString *str in index) {
                if ([str isEqualToString:@"2"]) {
                    check = TRUE;
                    break;
                }
                i++;
            }
            if (check) {
                [index removeObjectAtIndex:i];
                [arrayOfObject removeObjectAtIndex:i];
                tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.myTableView deleteRowsAtIndexPaths:@[tempIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
            if (indexClick > i) i=indexClick;
            else i=indexClick + 1;
            [arrayOfObject insertObject:newInsertObj atIndex:i];
            [index insertObject:@"2" atIndex:i];
            [index replaceObjectAtIndex:i-1 withObject:@"3"];
            tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.myTableView insertRowsAtIndexPaths:@[tempIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        i = 0;
        [self.myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexClick inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    else {
        [self.myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexClick inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        indexClick = indexClick + 1;
        if (indexClick<[arrayOfObject count]) {
            myTimerAutoPlay = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(autorun) userInfo:nil repeats:NO];
        }
    }
//    [self resetColorInTableView];
}

//check array index, if have object value 3, replace it with value 1
-(void)checkDataInIndexArr:(BOOL)bl :(NSInteger)row{
    if (bl) {
        NSInteger numberObject = [index count];
        for (int k = 0; k < numberObject; k++) {
            NSString *str = [index objectAtIndex:k];
            if ([str isEqualToString:@"3"] && k != indexClick) {
                [index replaceObjectAtIndex:k withObject:@"1"];
            }
        }
    }
    else {
        NSInteger numberObject = [index count];
        for (int k = 0; k < numberObject; k++) {
            NSString *str = [index objectAtIndex:k];
            if ([str isEqualToString:@"3"] && k != row) {
                [index replaceObjectAtIndex:k withObject:@"1"];
            }
        }
    }
}

//-(void)resetColorInTableView{
//    NSIndexPath *tempIndexPath;
//    NSInteger i = 0;
//    for (NSString *str in index) {
//        tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        EnglishPhraseTableViewCell *cell = (EnglishPhraseTableViewCell*)[self.myTableView cellForRowAtIndexPath:tempIndexPath];
//
//        UILabel *label = (UILabel*)[cell viewWithTag:102];
//        if ([str isEqualToString:@"3"]) [label setBackgroundColor:[UIColor cyanColor]];
//        else [label setBackgroundColor:[UIColor whiteColor]];
//        i++;
//    }
//}

#pragma mark MainCellDelegate

-(void)cellClicked:(UITableViewCell*)cell{
    source = [NSString stringWithFormat:@"%ld", (long)cell.tag];
}

-(void)favoriteClicked:(UIButton*)sender{
    [self update:sender.tag :sender];
}

#pragma mark UPDateSQLite

-(void)update:(NSInteger)objectID :(UIButton*)sender{
    DMObject *object;
    object =[arrayOfObject objectAtIndex:objectID];
    NSString *querySql;
    if ([object.favorite isEqualToString:@"1"]) {
        querySql = [NSString stringWithFormat:@"UPDATE phrase SET favorite=0 WHERE _id=%@", object.idOB];
        object.favorite = @"0";
        [sender setImage:[UIImage imageNamed:@"unStarIcon"] forState:UIControlStateNormal];
    }
    else {
        querySql = [NSString stringWithFormat:@"UPDATE phrase SET favorite=1 WHERE _id=%@", object.idOB];
        object.favorite = @"1";
        [sender setImage:[UIImage imageNamed:@"StarIcon"] forState:UIControlStateNormal];
    }
    sqlite3_stmt *statement;
    if(sqlite3_open([dbPathString UTF8String], &catalogueDB) == SQLITE_OK){
        const char *query_sql = [querySql UTF8String];
        if(sqlite3_prepare(catalogueDB, query_sql, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_UPDATE){
                
            }
        }
    }
    sqlite3_close(catalogueDB);
}

#pragma mark Custom

-(IBAction)favotire:(id)sender{
    PhrasesViewController *view = [[PhrasesViewController alloc] init];
    view.favoriteScreen = YES;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark Search
-(IBAction)clickSearch:(id)sender{
    
#pragma mark Revmob
    
    indexClick = 0;
    if(!self.isFromHome){
    
        if(self.searchBTN.tag == 0){
            [self.playAllBTN setHidden:YES];
            self.mySearchBar.text = nil;
            [self.searchBTN setTag:1];
            [self.mySearchBar setHidden:NO];
            [self.myTableView setHidden:YES];
        }else{
           [self.playAllBTN setHidden:NO];
            [self.searchBTN setTag:0];
            [self.mySearchBar setHidden:YES];
            //[self moveUp];
            [self.mySearchBar resignFirstResponder];
            self.searchScreen = NO;
            [self makeArrayOfObject];
            
            [self.myTableView reloadData];
            [self.myTableView setHidden:NO];
        }
    }
    else{
        [self.navigationController popViewControllerAnimated:NO];
        
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if(searchText.length == 0){
        self.searchScreen = NO;
        [self.playAllBTN setHidden:YES];
        [self.myTableView setHidden:YES];
    }else{
        self.searchScreen = YES;
        searchString = searchText;
        //[self.myTableView setHidden:NO];
    }
    [self makeArrayOfObject];
    [self.myTableView reloadData];
    //[self.myTableView setHidden:NO];
    //[self.myTableView ]
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.mySearchBar resignFirstResponder];
    [self.myTableView setHidden:NO];
    if (arrayOfObject.count>0) [self.playAllBTN setHidden:NO];
    
   
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.mySearchBar resignFirstResponder];
}

@end
