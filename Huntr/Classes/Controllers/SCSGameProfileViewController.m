//
//  SCSGameProfileViewController.m
//  Huntr
//
//  Created by Justin Leger on 8/19/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSGameProfileViewController.h"
#import "PhotoAnswerViewController.h"
#import "LocationAnswerViewController.h"

#import "SCSPushNotificationManager.h"

#import "SCSLocationTypeClueViewController.h"
#import "SCSPictureTypeClueViewController.h"

#import <AFNetworking/UIKit+AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "NSDate+SCSHuntrHelpers.h"

#import "SCSGame.h"
#import "SCSTeam.h"
#import "SCSClue.h"
#import "SCSRegisteredPlayer.h"

#import "GameClueCell.h"
#import "LeaderboardCell.h"
#import "TeamCell.h"



@interface SCSGameProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSTimer * gameTimer;

@property (nonatomic, strong) NSArray * clues;
@property (nonatomic, strong) NSArray * teams;

@end

@implementation SCSGameProfileViewController



#pragma mark - View Lifecycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self resetUI];
}

- (void) dealloc {
    [self invalidateGameTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.alpha = 0;
//    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:refreshControl];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationGameStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationTeamStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationClueStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationAnswerStatusUpdate object:nil];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [SVProgressHUD showWithStatus:@"Loading Game"];
    [self refresh:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationGameStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationTeamStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationClueStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationAnswerStatusUpdate object:nil];
}

- (void)handlePushNotification:(NSNotification *)note
{
    [self refresh:nil];
}

#pragma mark - Property Setters and Getters

- (SCSGame *) selectedGame
{
    return [SCSHuntrEnviromentManager sharedManager].activeGame;
}

- (void) setSelectedGame:(SCSGame *)selectedGame
{
    [SCSHuntrEnviromentManager sharedManager].activeGame = selectedGame;
}

#pragma mark - IBAction Functions

- (void)refresh:(UIRefreshControl* )control
{
    [self refreshGameWithCompletion:^(NSString *errorString) {
        if (control) [control endRefreshing];
        if (!errorString) {
            
            [self refreshUI];
            [self.tableView reloadData];
            
        }
        else {
            NSLog(@"%@",errorString);
        }
        
        [SVProgressHUD dismiss];
    }];
}

-(IBAction)selectContentType:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.contentToDisplay = SCSProfileContentTypeTeams;
        self.tableView.allowsSelection = NO;
        [SVProgressHUD showWithStatus:@"Refreshing Teams"];
    }
    else {
        self.contentToDisplay = SCSProfileContentTypeClues;
        self.tableView.allowsSelection = (self.selectedGame.status == SCSGameStatusInProgress || self.selectedGame.status == SCSGameStatusCompleted );
        [SVProgressHUD showWithStatus:@"Refreshing Clues"];
    }
    
//    [self.tableView reloadData];
    [self refresh:nil];
}

#pragma mark - Private Methods

- (void) refreshUI
{
    // UI Update around Active Player
    SCSRegisteredPlayer * activePlayer = [SCSHuntrEnviromentManager sharedManager].registeredPlayer;
    if (activePlayer) {
        
        [self.avatarImage setImageWithURL:[NSURL URLWithString:activePlayer.pictureURL] placeholderImage:[UIImage imageNamed:@"mh"]];
        self.subSubtitleLabel.text = activePlayer.playerName;
        
        SCSTeam * activeTeam = activePlayer.activeTeam;
        if (activeTeam) {
            self.subtitleLabel.text = activeTeam.teamName;
            self.subtitleLabel.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f  blue:204.0f/255.0f alpha:1];
        }
        else {
            self.subtitleLabel.text = @"No Team Selected Currently";
            self.subtitleLabel.textColor = [UIColor redColor];
        }
    }
    
    // UI Update around Active Game
    if (self.selectedGame) {
        self.titleLabel.text = self.selectedGame.gameName;
        self.headerTitleLabel.text = self.selectedGame.gameName;
        
        if (self.selectedGame.status == SCSGameStatusNotStarted) {
            self.addTeamButton.hidden = NO;
            self.gameDateTimeLabel.hidden = YES;
            [self.contentTypeSegmentControl setEnabled:NO forSegmentAtIndex:1];
            [self invalidateGameTimer];
        }
        else if (self.selectedGame.status == SCSGameStatusInProgress) {
            self.addTeamButton.hidden = YES;
            self.gameDateTimeLabel.hidden = NO;
            [self.contentTypeSegmentControl setEnabled:[SCSHuntrEnviromentManager sharedManager].hasActiveTeam forSegmentAtIndex:1];
            [self startGameTimer];
        }
        else if (self.selectedGame.status == SCSGameStatusCompleted) {
            self.addTeamButton.hidden = YES;
            self.gameDateTimeLabel.hidden = NO;
            [self.contentTypeSegmentControl setEnabled:YES forSegmentAtIndex:1];
            [self invalidateGameTimer];
            self.gameDateTimeLabel.text = [self.selectedGame.startDate prettyStartDateAndDurationFromEndDate:self.selectedGame.endDate];
        }
        else {
            self.addTeamButton.hidden = YES;
            self.gameDateTimeLabel.hidden = NO;
            self.gameDateTimeLabel.text = @"Unknown Game State";
        }
    }
}

- (void) resetUI
{
    self.avatarImage.image = [UIImage imageNamed:@"mh.png"];
    self.subSubtitleLabel.text = @"---";

    self.subtitleLabel.text = @"---";
    self.subtitleLabel.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f  blue:204.0f/255.0f alpha:1];
    
    self.titleLabel.text = @"---";
    self.headerTitleLabel.text = @"---";

    self.addTeamButton.hidden = YES;
    self.gameDateTimeLabel.hidden = NO;
    [self.contentTypeSegmentControl setEnabled:[SCSHuntrEnviromentManager sharedManager].hasActiveTeam forSegmentAtIndex:1];
    self.gameDateTimeLabel.text = @"---";
}

- (void) refreshTeamsListWithCompletion:(void (^)(NSString *errorString))completion
{
    [[SCSHuntrClient sharedClient] getAllTeamsWithSuccessBlock:^(NSArray * arrayResult) {
        
        NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"teamName" ascending:YES];
        self.teams = [[[NSArray alloc] initWithArray:arrayResult] sortedArrayUsingDescriptors:[NSArray arrayWithObjects: nameSortDescriptor, nil]];
        
        [arrayResult enumerateObjectsUsingBlock:^(SCSTeam * obj, NSUInteger idx, BOOL * stop) {
            
//            BOOL joined = [[SCSHuntrEnviromentManager sharedManager] isPlayerMemberOfTeamID:obj.teamID];
//            if (joined == YES) self.joinedTeamIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
        }];
        
        if(completion) completion(nil);
        
    }failureBlock:^(NSString *errorString) {
        // TODO: error message
        if(completion) completion(errorString);
    }];
}

- (void) refreshClueListWithCompletion:(void (^)(NSString *errorString))completion
{
    [[SCSHuntrClient sharedClient] getCluesWithSuccessBlock:^(NSArray *arrayResult) {
        
        self.clues = arrayResult;
        
        if(completion) completion(nil);
        
    } failureBlock:^(NSString *errorString) {
        // TODO: error message
        if(completion) completion(errorString);
    }];
}

- (void) refreshGameWithCompletion:(void (^)(NSString *errorString))completion
{
    [[SCSHuntrClient sharedClient] getGameById:self.selectedGame.gameID successBlock:^(id response) {
        
//        SCSGame * oldGame = self.selectedGame;
        self.selectedGame = (SCSGame*)response;
        
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES];
        self.teams = [self.selectedGame.teamList sortedArrayUsingDescriptors:@[sortDescriptor]];            

        self.clues = self.selectedGame.clueList;
        
        
        if(completion) completion(nil);
        
    } failureBlock:^(NSString *errorString) {
        // TODO: error message
        NSLog(@"%@",errorString);
        if(completion) completion(errorString);
    }];
}


#pragma mark - Game Time Functions

- (void) invalidateGameTimer
{
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
    }
}

- (void) updateGameTimer
{
    //Get the time left until the specified date
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gameDateTimeLabel.text = [self.selectedGame.endDate prettyTimeRemaining];
    });
}

- (void) startGameTimer
{
    [self updateGameTimer];
    
    [self invalidateGameTimer];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateGameTimer)
                                                    userInfo:nil
                                                     repeats:YES];
}

#pragma mark - Add Team Actions

- (IBAction) addTeamActions:(id)sender
{
    UIAlertController * addTeamAlertController = [UIAlertController alertControllerWithTitle:@"Add Team" message:@"Please enter the new team name." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [addTeamAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction * actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UITextField * teamNameTextField = [addTeamAlertController.textFields firstObject];
        [self addTeamWithName:teamNameTextField.text];
        [addTeamAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    actionOk.enabled = NO;
    
    [addTeamAlertController addAction:actionCancel];
    [addTeamAlertController addAction:actionOk];
    
    [addTeamAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"< New Team Name Here >";
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            actionOk.enabled = ![textField.text isEqualToString:@""];
        }];
    }];
    
    [self presentViewController:addTeamAlertController animated:YES completion:nil];
}

- (void) addTeamWithName:(NSString *)teamName
{
    NSDictionary * parameter = [NSDictionary dictionaryWithObject:teamName forKey: @"teamName"];
    [[SCSHuntrClient sharedClient] addTeamToGame:parameter successBlock:^(id object) {
        
        [SVProgressHUD showWithStatus:@"Refreshing Teams"];
        [self refresh:nil];
        
    } failureBlock:^(NSString *errorString) {
        
        if ([errorString rangeOfString:@"status code: 409" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            errorString = [NSString stringWithFormat:@"A team with a name similar to %@ already exits. Please pick a different name.", teamName];
        }
        
        UIAlertController * errorAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [errorAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [errorAlertController addAction:actionOk];
        [self presentViewController:errorAlertController animated:YES completion:nil];
    }];
}


#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contentToDisplay == SCSProfileContentTypeClues) return 80.0;
    
    return 45.0;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.contentToDisplay == SCSProfileContentTypeTeams) return 1;
    
    if (self.contentToDisplay == SCSProfileContentTypeClues) return 1;
    
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.contentToDisplay == SCSProfileContentTypeTeams) return self.teams.count;
    
    if (self.contentToDisplay == SCSProfileContentTypeClues) return self.clues.count;
    
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contentToDisplay == SCSProfileContentTypeTeams) {
        
        SCSTeam * team = [self.teams objectAtIndex:indexPath.row];
        
        if (self.selectedGame.status == SCSGameStatusNotStarted || ([SCSHuntrEnviromentManager sharedManager].hasActiveTeam == NO && self.selectedGame.status == SCSGameStatusInProgress)) {
            
            static NSString * teamCellIdentifer = @"teamCellIdentifer";
            TeamCell * cell = [tableView dequeueReusableCellWithIdentifier:teamCellIdentifer];
            
            cell.tableView = self.tableView;
            cell.selectedGame = self.selectedGame;
            cell.team = team;
            
            cell.teamButtonActionBlock = ^{
                [SVProgressHUD showWithStatus:@"Adding Player"];
                
                [[SCSHuntrClient sharedClient] addPlayerToTeam:team.teamID successBlock:^(id response) {
                    [[SCSHuntrEnviromentManager sharedManager] joinGameID:self.selectedGame.gameID withTeamID:team.teamID];
                    [self refresh:nil];
                } failureBlock:^(NSString *errorString) {
                    if ([errorString rangeOfString:@"status code: 409" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [[SCSHuntrEnviromentManager sharedManager] joinGameID:self.selectedGame.gameID withTeamID:team.teamID];
                    }
                    [self refresh:nil];
                }];
            };
            
            return cell;
        }
        else if (self.selectedGame.status == SCSGameStatusInProgress || self.selectedGame.status == SCSGameStatusCompleted) {
            
            static NSString * leaderboardCellIdentifer = @"leaderboardCellIdentifer";
            LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:leaderboardCellIdentifer];
            
            cell.theTeam = [self.teams objectAtIndex:indexPath.row];
            return cell;
        }
    }
    else {
        static NSString * clueCellIdentifer = @"clueCellIdentifer";
        GameClueCell *cell = [tableView dequeueReusableCellWithIdentifier:clueCellIdentifer];
        
        cell.selectedGame = self.selectedGame;
        cell.theClue = [self.clues objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contentToDisplay == SCSProfileContentTypeTeams) {
        
    
    }
    else if (self.contentToDisplay == SCSProfileContentTypeClues) {
        
        SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
        
        if (self.selectedGame.status == SCSGameStatusInProgress || (self.selectedGame.status == SCSGameStatusCompleted && clue.clueState != SCSClueStateUnawswered )) {
            
            if (clue.clueType  == SCSClueTypeLocation)
            {
                [self performSegueWithIdentifier:kGoToLocAnswerSegueIdentifier sender:self];
            }
            else if (clue.clueType == SCSClueTypePicture)
            {
                [self performSegueWithIdentifier:kGoToPicAnswerSegueIdentifier sender:self];
            }
        }
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.contentToDisplay == SCSProfileContentTypeTeams) {
        return NO;
    }
    else if (self.contentToDisplay == SCSProfileContentTypeClues) {
        
        SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
        
        if (self.selectedGame.status == SCSGameStatusInProgress || (self.selectedGame.status == SCSGameStatusCompleted && clue.clueState != SCSClueStateUnawswered )) {
            
            return YES;
        }
    }

    return YES;
}

//
//- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Add your Colour.
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [self setCellColor:[UIColor colorWithWhite:0.0 alpha:1.000] ForCell:cell];  //highlight colour
//}
//
//- (void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Reset Colour.
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [self setCellColor:[UIColor clearColor] ForCell:cell]; //normal color
//    
//}
//
//- (void) setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
//    cell.contentView.backgroundColor = color;
//    cell.backgroundColor = color;
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SCSClue * clue = [self.clues objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    
    if ([[segue identifier] isEqualToString:kGoToPicAnswerSegueIdentifier])
    {
        SCSPictureTypeClueViewController * controller = segue.destinationViewController;
        controller.selectedGame = self.selectedGame;
        controller.selectedClue = clue;
//        controller.selectedGame = self.selectedGame;
    }
    else if ([[segue identifier] isEqualToString:kGoToLocAnswerSegueIdentifier])
    {
        SCSLocationTypeClueViewController * controller = segue.destinationViewController;
        controller.selectedGame = self.selectedGame;
        controller.selectedClue = clue;
//        controller.selectedGame = self.selectedGame;
    }
}

@end
