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
//#import "AnswerViewController.h"
#import "PhotoAnswerViewController.h"
#import "LocationAnswerViewController.h"


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
    [[SCSHuntrClient sharedClient]getCluesByTeamWithSuccessBlock:^(NSArray *arrayResult) {
        self.clues = arrayResult;
    } failureBlock:^(NSString *errorString) {
        
    }];
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    });*/

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
    
    SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
    cell.descriptionLabel.text = clue.clueDescription;
    cell.pointLabel.text = [NSString stringWithFormat:@"%i points",[clue.pointValue intValue]];
    cell.typeImageView.image = ([clue.type isEqualToString:@"Picture"]) ? [UIImage imageNamed:@"Camera"]:[UIImage imageNamed:@"location"];
    cell.checkImageView.hidden = !clue.submittedAnswer.isCorrect;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
    if ([clue.type isEqualToString:@"Location"])
    {
        [self performSegueWithIdentifier:kGoToLocAnswerSegueIdentifier sender:self];
    }
    else if ([clue.type isEqualToString:@"Picture"])
    {
        [self performSegueWithIdentifier:kGoToPicAnswerSegueIdentifier sender:self];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SCSClue * clue = [self.clues objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];

    if ([[segue identifier] isEqualToString:kGoToPicAnswerSegueIdentifier])
    {
        PhotoAnswerViewController * controller = segue.destinationViewController;
        controller.clueToAnswer = clue;
        controller.answerImageView.hidden = false;
    }
    else if ([[segue identifier] isEqualToString:kGoToLocAnswerSegueIdentifier])
    {
        LocationAnswerViewController * controller = segue.destinationViewController;
        controller.clueToAnswer = clue;
        controller.answerMapView.hidden = false;
    }
}


@end
