//
//  TeamsListTableViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/6/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "TeamsListViewController.h"
#import "NewEntityViewController.h"
#import "GameViewController.h"
#import "SCSHuntrClient.h"
#import "SCSEnvironment.h"
#import "EnvironmentManger.h"


@interface TeamsListViewController () <NewEntityControllerDelegate>
@property (nonatomic , strong) NSArray * teams;
@property (nonatomic , assign) NSIndexPath * joinedTeamIndexPath;
@end

@implementation TeamsListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.joinedTeamIndexPath = nil;
    [self refreshUI];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshTeamsListWithCompletion:^{
        [self.tableView reloadData];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectedGame.status != Completed)
    {
        if ([[EnvironmentManger sharedManager] hasJoinedGame:self.selectedGame.gameID] == NO)
        {
            [self performSegueWithIdentifier:kRegisterUserSegueIdentifier sender:self];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods 

- (void) refreshUI {
    
    if (self.selectedGame.status == InProgress) {
        self.navigationItem.rightBarButtonItem.enabled = true;
        self.addTeamBtn.enabled = false;
        self.updateNameBtn.enabled = true;
    }
    else {
        // Not Started
        self.navigationItem.rightBarButtonItem.enabled = false;
        self.addTeamBtn.enabled = true;
        self.updateNameBtn.enabled = true;
    }
    self.infoLabel.text = ([[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerName]) ? [NSString stringWithFormat:@"Welcome %@",[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerName]]:@"Welcome";
}

- (void) refreshTeamsListWithCompletion:(void (^)(void))completion
{
    [[SCSHuntrClient sharedClient]getAllTeamsByGame:self.selectedGame.gameID successBlock:^(NSArray * arrayResult){
        
        [arrayResult enumerateObjectsUsingBlock:^(SCSTeam * obj, NSUInteger idx, BOOL * stop) {
            BOOL joined = [[EnvironmentManger sharedManager]hasJoinedTeam:obj.teamID inGame:self.selectedGame.gameID];
            if (joined == true) {
                self.joinedTeamIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            }
        }];
        
        NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"teamName" ascending:true];
        self.teams = [[[NSArray alloc]initWithArray:arrayResult] sortedArrayUsingDescriptors:[NSArray arrayWithObjects: nameSortDescriptor, nil]];
        if(completion) completion();
        
    } failureBlock:^(NSString * errorString){
        
    }];
}

- (void) checkIfUserNameHasBeenTakenInTheTeam:(SCSTeam*)selectedTeam completion:(void (^)(BOOL))completion
{
    NSString * playerName = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentPlayerName];
    [[SCSHuntrClient sharedClient] getPlayersByTeam:selectedTeam.teamID successBlock:^(NSArray *arrayResult) {
        
        if (arrayResult.count > 0){
            [arrayResult enumerateObjectsUsingBlock:^(SCSPlayer * player, NSUInteger idx, BOOL * stop) {
                
                if ([player.playerName isEqualToString:playerName])
                {
                    *stop = YES;
                    completion(YES);
                }
                if (idx == arrayResult.count - 1)
                {
                    completion(NO);
                }
            }];
        }
        else{
            completion(NO);
        }
        
        
    } failureBlock:^(NSString *errorString) {
        
    }];
}

#pragma mark - Actions 

- (void) accessoryButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (IBAction)refrsh:(UIRefreshControl* )control
{
    [[SCSHuntrClient sharedClient]getGameById:self.selectedGame.gameID successBlock:^(id response)
     {
         SCSGame * currentGame = self.selectedGame;
         self.selectedGame = (SCSGame*)response;
         if (self.selectedGame.status != currentGame.status) {
             // Game Status Changed
             [self refreshUI];
         }
         // Refresh Teams For the Game
         [self refreshTeamsListWithCompletion:^{
             [self.tableView reloadData];
             [control endRefreshing];
         }];
         
         
     } failureBlock:^(NSString *errorString) {
        //TODO: getGameById Error;
     }];
}

- (IBAction)createNewTeam:(id)sender
{
    [self performSegueWithIdentifier:@"CreateNewTeamSegue" sender:sender];
    
}

#pragma mark - NewEntityControllerDelegate

- (void) registerUserDidSave :(NewEntityViewController *)controller {
    
    /* Binding Game Id with Player Name */
    [[EnvironmentManger sharedManager]joinGame:self.selectedGame.gameID];
    [[EnvironmentManger sharedManager] registerGame:self.selectedGame.gameID withPlayerName:controller.nameField.text];
    
    /* Set Current Player Name */
    [[NSUserDefaults standardUserDefaults]setObject:controller.nameField.text forKey:kCurrentPlayerName];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) registerUserDidCancel:(NewEntityViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];

}

- (void) updateUserDidSave:(NewEntityViewController *)controller
{
    //TODO: UPDATE USER NAME
    
    
    /* Binding Game Id with Player Name */
    
    [[EnvironmentManger sharedManager] registerGame:self.selectedGame.gameID withPlayerName:controller.nameField.text];
    
    /* Set Current Player Name */
    [[NSUserDefaults standardUserDefaults]setObject:controller.nameField.text forKey:kCurrentPlayerName];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateUserDidCancel:(NewEntityViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];

}

- (void) newTeamWillAdd:(NewEntityViewController *)controller completion:(void (^)(void))completion

{
    __block BOOL isExsitingTeam = false;
    [self.teams enumerateObjectsUsingBlock:^(SCSTeam* team, NSUInteger idx, BOOL *  stop) {
        if ([team.teamName isEqualToString:controller.nameField.text]){
            isExsitingTeam = true;
            *stop = true;
        }
    }];
    
    if (isExsitingTeam == true) {
        if (completion) completion();
    }
}

- (void) newTeamDidAdd:(NewEntityViewController *)controller
{
    NSDictionary * parameter = [NSDictionary dictionaryWithObject: controller.nameField.text forKey: @"teamName"];
    [[SCSHuntrClient sharedClient] addTeamToGame:parameter successBlock:^(id object){
        
        /* Binding Game Id with Team Name */
        [[EnvironmentManger sharedManager] joinGame:self.selectedGame.gameID withTeamId:((SCSTeam*)object).teamID];
        
        /* Set Current Player Name */
        [[NSUserDefaults standardUserDefaults ]setObject:((SCSTeam*)object).teamID forKey:kCurrentTeamId];
        
        [controller dismissViewControllerAnimated:YES completion:^{
            [self.tableView reloadData];
        }];

        
    }failureBlock:^(NSString *errorString) {
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [ac dismissViewControllerAnimated:YES completion:nil];
        }];
        [ac addAction:actionOk];
        
    }];
    
}

- (void) willValidateNewTeam:(NSString*)teamName completion:(void (^)(bool isExisting))completion
{
//    __block BOOL isTeamNameExsiting = false;
//    [self.teams enumerateObjectsUsingBlock:^(SCSTeam* team, NSUInteger idx, BOOL *  stop) {
//        if ([team.teamName isEqualToString:teamName]) {
//            isTeamNameExsiting = true;
//            * stop = true;
//        }
//
//    }];
//    completion(isTeamNameExsiting);

}


- (void) willCreateNewTeam:(NSString*)teamName {
    
//    NSDictionary * parameter = [NSDictionary dictionaryWithObject: teamName forKey: @"teamName"];
//    [[SCSHuntrClient sharedClient]addTeamToGame:parameter successBlock:^(id object){
//        [self refreshTeamList];
//    } failureBlock:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * teamCellIdentifer = @"teamCellIdentifer";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:teamCellIdentifer];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:teamCellIdentifer];
    cell.textLabel.text = [(SCSTeam*)[self.teams objectAtIndex:indexPath.row] teamName];
    
    UIButton * accessoryButton = nil;
    if (self.joinedTeamIndexPath == nil) {
        accessoryButton = [UIButton setupNormalStyle];
    }
    else
    {
        accessoryButton = (indexPath.row == self.joinedTeamIndexPath.row) ? [UIButton setupJoinedStyle] : [UIButton setupNormalStyle];
    }
    
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;

    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%li",(long)indexPath.row);
    NSLog(@"%li",(long)self.joinedTeamIndexPath.row);
    // check user name exist in team
    // join team
    
    SCSTeam * team = [self.teams objectAtIndex:indexPath.row];

    
    if (self.joinedTeamIndexPath != nil)
    {
        if (self.joinedTeamIndexPath.row == indexPath.row) return;
        [self checkIfUserNameHasBeenTakenInTheTeam:team completion:^(BOOL taken){
            if(taken == false)
            {
                [[SCSHuntrClient sharedClient]addPlayerToTeam:team.teamID successBlock:^(id response) {
                    
                    [[NSUserDefaults standardUserDefaults]setObject:team.teamID forKey:kCurrentTeamId];
                    [[EnvironmentManger sharedManager] joinGame:self.selectedGame.gameID withTeamId:team.teamID];
                    
                    UITableViewCell * cell_old = [tableView cellForRowAtIndexPath:self.joinedTeamIndexPath];
                    UIButton * normalButton = [UIButton setupNormalStyle];
                    [normalButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpOutside];
                    cell_old.accessoryView = normalButton;
                    
                    UITableViewCell * cell_new = [tableView cellForRowAtIndexPath:indexPath];
                    UIButton * joinedButton = [UIButton setupJoinedStyle];
                    [joinedButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpOutside];
                    cell_new.accessoryView = joinedButton;
                    
                    self.joinedTeamIndexPath  = indexPath;


                } failureBlock:^(NSString *errorString) {
                    // TODO: Add Player To Team Error
                }];
                // switch
                
            }
            else
            {
                // Name has been taken ?
            }
        }];
        
    }
    else
    {
        [self checkIfUserNameHasBeenTakenInTheTeam:team completion:^(BOOL taken){
            if(taken == false)
            {
                [[SCSHuntrClient sharedClient]addPlayerToTeam:team.teamID successBlock:^(id response) {
                    
                    [[NSUserDefaults standardUserDefaults]setObject:team.teamID forKey:kCurrentTeamId];
                    [[EnvironmentManger sharedManager] joinGame:self.selectedGame.gameID withTeamId:team.teamID];
                    
                    UITableViewCell * cell_new = [tableView cellForRowAtIndexPath:indexPath];
                    UIButton * joinedButton = [UIButton setupJoinedStyle];
                    [joinedButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpOutside];
                    cell_new.accessoryView = joinedButton;
                    
                    self.joinedTeamIndexPath  = indexPath;

                    
                } failureBlock:^(NSString *errorString) {
                    // TODO: Add Player To Team Error
                }];
                
            }
            else
            {
                // Name has been taken ?
            }
        }];
        
    }
    
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.selectedGame.status == NotStarted)
    {
        if ([identifier isEqualToString:kAddTeamSegueIdentifier])
        {
            return YES;
        }
        else if ([identifier isEqualToString:kGetGameSegueIdentifier])
        {
            return NO;
        }
        else
        {
            // Register User, Update User
            return YES;
        }
    }
    else if (self.selectedGame.status == InProgress)
    {
        if ([identifier isEqualToString:kAddTeamSegueIdentifier])
        {
            return NO;
        }
        else if ([identifier isEqualToString:kGetGameSegueIdentifier])
        {
            return [[EnvironmentManger sharedManager]isReadyForGame];
        }
        else
        {
            // Register User, Update User
            return YES;
        }
        
    }
    else
        return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kRegisterUserSegueIdentifier]) {
        
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeNewUser;
    }
    else if ([[segue identifier] isEqualToString:kAddTeamSegueIdentifier]) {
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeNewTeam;
    }
    
    else if ([[segue identifier] isEqualToString:kUpdateUserSegueIdentifier])  {
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeUpdateUser;
    }
}



@end
