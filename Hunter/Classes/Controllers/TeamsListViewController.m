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
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions 

- (IBAction)createNewTeam:(id)sender
{
    [self performSegueWithIdentifier:@"CreateNewTeamSegue" sender: self];

}

#pragma mark - NewEntityControllerDelegate
- (void) didCreateNewTeam {
    
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
    NSLog(@"%li",(long)indexPath.row);
}

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


@end
