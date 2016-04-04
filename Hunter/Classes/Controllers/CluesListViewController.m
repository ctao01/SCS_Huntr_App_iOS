//
//  CluesListViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "CluesListViewController.h"
#import "SCSHuntrClient.h"
#import "GameClueCell.h"
#import "AnswerViewController.h"

@interface CluesListViewController ()
@property (nonatomic, strong) NSArray * clues;
@end

@implementation CluesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshClues];
    
}

#pragma mark - Private Methods
- (void) refreshClues
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * currentGameId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_game"];
        NSString * currentTeamId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_team"];
        
        [[SCSHuntrClient sharedClient]getCluesByGame:currentGameId successBlock:^(NSArray * cluesResult){
            [[SCSHuntrClient sharedClient]getAnswersByTeam:currentTeamId andGame:currentGameId successBlock:^(NSArray *answersResult) {
                
                [cluesResult enumerateObjectsUsingBlock:^(SCSClue* clueObj, NSUInteger clueIdx, BOOL * clueStop) {
                    [answersResult enumerateObjectsUsingBlock:^(NSString* ansObj, NSUInteger ansIdx, BOOL * ansStop) {
                        if([clueObj.clueID isEqualToString:ansObj])
                        {
                            clueObj.isCorrect = YES;
                            *ansStop = YES;
                        }
                    }];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.clues = [NSArray arrayWithArray:cluesResult];
                    [self.tableView reloadData];
                });
                
            } failureBlock:^(NSString *errorString) {
                
            }];
            
        }failureBlock:^(NSString *errorString) {
            
        }];
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.clues count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * clueCellIdentifer = @"clueCellIdentifer";
    GameClueCell *cell = [tableView dequeueReusableCellWithIdentifier:clueCellIdentifer];
    if (cell == nil)
        cell = [[GameClueCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:clueCellIdentifer];
    [cell setTheClue:[self.clues objectAtIndex:indexPath.row]];
    
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


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    SCSClue * selectedClue = [self.clues objectAtIndex:selectedIndexPath.row];
    
    return !selectedClue.isCorrect;
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"GetAnswerSegue"])
    {
        AnswerViewController * controller = segue.destinationViewController;
        SCSClue * selectedClue = [self.clues objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        controller.theClue = selectedClue;

    }
}


@end
