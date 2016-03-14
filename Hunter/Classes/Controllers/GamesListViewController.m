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

@interface GamesListViewController ()
@property (nonatomic , strong) NSArray * games;
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
//    [self performSegueWithIdentifier:@"GetTeamsSegue" sender:self];
//    SCSGame * selectedGame = [self.games objectAtIndex:indexPath.row];
//    [[NSUserDefaults standardUserDefaults]setObject:selectedGame.gameID forKey:@"current_game"];
//    TeamsListViewController * teamsListViewController = [[TeamsListViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    teamsListViewController.selectedGame = selectedGame;
//    [self.navigationController pushViewController:teamsListViewController animated:YES];
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    SCSGame * selectedGame = [self.games objectAtIndex:selectedIndexPath.row];
    if ([selectedGame.gameStatus isEqualToString:@"Completed"]) return NO;
    else return YES;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GetTeamsSegue"]){        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        SCSGame * selectedGame = [self.games objectAtIndex:selectedIndexPath.row];
        
        [[NSUserDefaults standardUserDefaults]setObject:selectedGame.gameID forKey:@"current_game"];
        
        TeamsListViewController * viewController = segue.destinationViewController;
        [viewController setSelectedGame:selectedGame];
    }

}



@end
