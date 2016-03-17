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

@interface TeamsListViewController () <NewEntityControllerDelegate>
@property (nonatomic , strong) NSArray * teams;
@end

@implementation TeamsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [[SCSHuntrClient sharedClient]getAllTeamsByGame:self.selectedGame.gameID successBlock:^(NSArray * arrayResult){
        
        NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"teamName" ascending:true];
        self.teams = [[[NSArray alloc]initWithArray:arrayResult] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSortDescriptor, nil]];
        [self.tableView reloadData];
        
    } failureBlock:^(NSString * errorString){
        
    }];
    
    if ([self.selectedGame.gameStatus isEqualToString:@"In Progress"]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions 

- (IBAction)createNewTeam:(id)sender
{
    [self performSegueWithIdentifier:@"CreateNewTeamSegue" sender:sender];

}

#pragma mark - NewEntityControllerDelegate
- (void) didCreateNewTeam:(NSString*)teamName {
    
    NSDictionary * parameter = [NSDictionary dictionaryWithObject: teamName forKey: @"teamName"];
    [[SCSHuntrClient sharedClient]addTeamToGame:parameter successBlock:^(id object){} failureBlock:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:teamCellIdentifer];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:teamCellIdentifer];
    
    cell.textLabel.text = [(SCSTeam*)[self.teams objectAtIndex:indexPath.row] teamName];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCSTeam * selectedTeam = [self.teams objectAtIndex:indexPath.row];
    [self checkIfUserExistInTheTeam:selectedTeam completion:^(BOOL isExisting){
        if (isExisting)
        {
            [self performSegueWithIdentifier:@"EnterGameSceneSegue" sender:indexPath];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[SCSHuntrClient sharedClient]addPlayerToTeam:selectedTeam.teamID successBlock:^(id response) {
                    if(response)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"EnterGameSceneSegue" sender:indexPath];

                        });
                    }
                } failureBlock:nil];
            });
        }
    }];
}


#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender
{
    if ([self.selectedGame.gameStatus isEqualToString:@"In Progress"]) return YES;
    else return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CreateNewTeamSegue"])
    {
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeTeam;
    }
    else if ([[segue identifier] isEqualToString:@"EnterGameSceneSegue"])
    {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        SCSTeam * selectedTeam = [self.teams objectAtIndex:selectedIndexPath.row];
       
        [[NSUserDefaults standardUserDefaults]setObject:selectedTeam.teamID forKey:@"current_team"];
    }
}

#pragma private methods 

- (void) checkIfUserExistInTheTeam:(SCSTeam*)selectedTeam completion:(void (^)(BOOL))completion
{
    [[SCSHuntrClient sharedClient] getPlayersByTeam:selectedTeam.teamID successBlock:^(NSArray *arrayResult) {
        
        [arrayResult enumerateObjectsUsingBlock:^(SCSPlayer * player, NSUInteger idx, BOOL * stop) {
            
            if ([player.playerName isEqualToString:[[SCSEnvironment sharedInstance]currentPlayer]])
            {
                *stop = YES;
                completion(YES);
                return;
            }
            if (idx == arrayResult.count - 1)
            {
                completion(NO);
            }
        }];
        
    } failureBlock:nil];
}

@end
