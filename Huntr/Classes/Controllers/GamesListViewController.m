//
//  GamesListViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/3/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GamesListViewController.h"

#import "SCSPushNotificationManager.h"
#import "SCSHuntrClient.h"
//#import "SCSEnvironment.h"
#import "GameCell.h"

#import "SCSGameProfileViewController.h"

#import "TeamsListViewController.h"
#import "GameViewController.h"
#import "NewEntityViewController.h"

@interface GamesListViewController () <NewEntityControllerDelegate>
@property (nonatomic , strong) NSArray * games;
@property (nonatomic , strong) SCSGame * selectedGame;
@end
//
@implementation GamesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationGameStatusUpdate object:nil];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [self refresh:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationGameStatusUpdate object:nil];
}

- (void)handlePushNotification:(NSNotification *)note
{
    [self refresh:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)refresh:(UIRefreshControl* )control
{
    [[SCSHuntrClient sharedClient] getAllGames:^(NSArray * arrayResult) {
        
        self.games = [NSArray arrayWithArray:arrayResult];
        [self.tableView reloadData];
        if (control) [control endRefreshing];
        
    } failureBlock:^(NSString * errorString) {
        
        // TODO: error message
        NSLog(@"%@",errorString);
        if (control) [control endRefreshing];
    }];
}

#pragma mark - NewEntityControllerDelegate

- (void) registerUserDidSave :(NewEntityViewController *)controller {
    
    /* Binding Game Id with Player Name */
//    [[EnvironmentManger sharedManager] registerGame:self.selectedGame.gameID];
//    [[EnvironmentManger sharedManager] registerPlayerName:controller.nameField.text];
    
    [controller dismissViewControllerAnimated:YES completion:^{
         [self performSegueWithIdentifier:kGetTeamsSegueIdentifier sender:self];
    }];
    
}

- (void) registerUserDidCancel:(NewEntityViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.games count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * gameCellIdentifier = @"gameCellIdentifier";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:gameCellIdentifier];
    
    cell.selectedGame = [self.games objectAtIndex:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGame = [self.games objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:kGameProfileSegueIdentifier sender:self];
    
//    [[NSUserDefaults standardUserDefaults] setObject:self.selectedGame.gameID forKey:kCurrentGameId];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    if (self.selectedGame.status == SCSGameStatusCompleted)
//    {
//        [self performSegueWithIdentifier:kGetGameSegueIdentifier sender:self];
//    }
//    else
//    {
////        if ([[EnvironmentManger sharedManager] hasJoinedGame:self.selectedGame.gameID] == NO)
////        {
////            [self performSegueWithIdentifier:kRegisterUserSegueIdentifier sender:self];
////        }
////        else {
////            [[NSUserDefaults standardUserDefaults] setObject: [[EnvironmentManger sharedManager] playerNameInGame:self.selectedGame.gameID ] forKey:kCurrentPlayerName];
//            [self performSegueWithIdentifier:kGetTeamsSegueIdentifier sender:self];
////        }
//
//    }

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kRegisterUserSegueIdentifier]) {
        
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeNewUser;
    }
    else if ([[segue identifier] isEqualToString:kGetGameSegueIdentifier])
    {
        GameViewController * gameViewController = segue.destinationViewController;
        gameViewController.selectedGame = self.selectedGame;
        
    }
    else if ([[segue identifier] isEqualToString:kGetTeamsSegueIdentifier])
    {
        TeamsListViewController * vcTeams = segue.destinationViewController;
        vcTeams.selectedGame = self.selectedGame;
    }
    else if ([[segue identifier] isEqualToString:kGameProfileSegueIdentifier])
    {
        SCSGameProfileViewController * gameProfile = segue.destinationViewController;
        gameProfile.selectedGame = self.selectedGame;
    }
}



@end
