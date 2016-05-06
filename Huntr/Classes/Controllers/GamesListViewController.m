//
//  GamesListViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/3/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GamesListViewController.h"
#import "SCSHuntrClient.h"
#import "SCSEnvironment.h"
#import "GameCell.h"
#import "TeamsListViewController.h"
#import "GameViewController.h"
#import "NewEntityViewController.h"

@interface GamesListViewController () <NewEntityControllerDelegate>
@property (nonatomic , strong) NSArray * games;
@property (nonatomic , strong) SCSGame * selectedGame;
@end

@implementation GamesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SCSHuntrClient sharedClient]getAllGames:^(NSArray * arrayResult){
       
        self.games = [NSArray arrayWithArray:arrayResult];
        [self.tableView reloadData];
        
    } failureBlock:^(NSString * errorString){
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NewEntityControllerDelegate

- (void) registerUserDidSave :(NewEntityViewController *)controller {
    
    /* Binding Game Id with Player Name */
//    [[EnvironmentManger sharedManager]joinGame:self.selectedGame.gameID];
//    [[EnvironmentManger sharedManager] registerGame:self.selectedGame.gameID withPlayerName:controller.nameField.text];
    
    /* Set Current Player Name */
    [[NSUserDefaults standardUserDefaults]setObject:controller.nameField.text forKey:kCurrentPlayerName];
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameCellIdentifier"];
    if (cell == nil)
        cell = [[GameCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameCellIdentifier"];
    cell.theGame = [self.games objectAtIndex:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGame = [self.games objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults]setObject:self.selectedGame.gameID forKey:kCurrentGameId];
    
    if (self.selectedGame.status == GameStatusCompleted)
    {
        [self performSegueWithIdentifier:kGetGameSegueIdentifier sender:self];
    }
    else
    {
        if ([[EnvironmentManger sharedManager] hasJoinedGame:self.selectedGame.gameID] == NO)
        {
            [self performSegueWithIdentifier:kRegisterUserSegueIdentifier sender:self];
        }
        else {
            [self performSegueWithIdentifier:kGetTeamsSegueIdentifier sender:self];
        }

    }

}

//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}
//
//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 62.0f;
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@",segue.identifier);
   
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    SCSGame * selectedGame = [self.games objectAtIndex:selectedIndexPath.row];

    if ([[segue identifier] isEqualToString:kGetTeamsSegueIdentifier])
    {
        // Not Start or In Progress
        
        TeamsListViewController * viewController = segue.destinationViewController;
        [viewController setSelectedGame:selectedGame];
    }
    else if ([[segue identifier] isEqualToString:kRegisterUserSegueIdentifier]) {
        
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeNewUser;
    }
    else if ([[segue identifier] isEqualToString:kGetGameSegueIdentifier])
    {
        GameViewController * gameViewController = segue.destinationViewController;
        gameViewController.selectedGame = self.selectedGame;
        
        NSLog(@"%u",self.selectedGame.status);
    }
    
}



@end
