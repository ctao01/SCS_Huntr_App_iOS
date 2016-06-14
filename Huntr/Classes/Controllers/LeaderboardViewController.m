//
//  LeaderboardViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "LeaderboardCell.h"
#import "SCSHuntrClient.h"
#import "GameViewController.h"

@interface LeaderboardViewController ()
@property (nonatomic , strong) NSArray * teams;
@end

@implementation LeaderboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    NSString * gameId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentGameId];
    [[SCSHuntrClient sharedClient] getScoreboardByGame:gameId successBlock:^(NSArray * arrayResult) {
        
        NSSortDescriptor * rankingSort = [NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES];
        NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"teamName" ascending:YES];
        arrayResult = [arrayResult sortedArrayUsingDescriptors:[NSArray arrayWithObjects:rankingSort,nameSort, nil]];
        self.teams = [NSArray arrayWithArray:arrayResult];
        [self.tableView reloadData];
        
    } failureBlock:^(NSString * errorString) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction) quitCurrentGame:(id)sender
{
    NSLog(@"%@",[self.navigationController.tabBarController class]);
    
    if(((GameViewController*)self.navigationController.tabBarController).selectedGame.status == GameStatusCompleted)
    {
        if ([self.navigationController.tabBarController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
        {
            [self.navigationController.tabBarController  dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        
    }
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardCellIdentifer"];
    [cell setTheTeam:[self.teams objectAtIndex:indexPath.row]];
    // Configure the cell...
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
