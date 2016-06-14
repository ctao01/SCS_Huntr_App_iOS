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
#import "PhotoAnswerViewController.h"
#import "LocationAnswerViewController.h"
#import "GameViewController.h"

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
    
    [self refresh:nil];
}

#pragma mark - Actions 

- (IBAction) quitCurrentGame:(id)sender
{
    /*if(((GameViewController*)self.navigationController.tabBarController).selectedGame.status == GameStatusCompleted)
    {
        
    }
    else
    {
        
        
    }*/
    
    if ([self.navigationController.tabBarController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self.navigationController.tabBarController  dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)refresh:(UIRefreshControl* )control
{
    [[SCSHuntrClient sharedClient] getCluesWithSuccessBlock:^(NSArray *arrayResult) {
        
        self.clues = arrayResult;
        [self.tableView reloadData];
        if (control) [control endRefreshing];
        
    } failureBlock:^(NSString *errorString) {
        
        // TODO: error message
        NSLog(@"%@",errorString);
        
        if (control) [control endRefreshing];
    }];
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
        cell = [[GameClueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:clueCellIdentifer];
    
    SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
    cell.descriptionLabel.text = clue.clueDescription;
    cell.pointLabel.text = [NSString stringWithFormat:@"%i points",[clue.pointValue intValue]];
    cell.typeImageView.image = ([clue.type isEqualToString:@"Picture"]) ? [UIImage imageNamed:@"Camera"]:[UIImage imageNamed:@"location"];
    
    cell.statusImageView.hidden = (!clue.didSubmit) || (clue.submittedAnswer.isPending) || (clue.didSubmit == true && clue.submittedAnswer.isCorrect == false);
    cell.statusImageView.image = [UIImage imageNamed:@"approval.png"];
    
    cell.pendingStatusLabel.hidden = ((clue.didSubmit) && (clue.submittedAnswer.isPending)) ? false : true;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCSClue * clue = [self.clues objectAtIndex:indexPath.row];
    if (clue.clueType  == ClueTypeLocation)
    {
        [self performSegueWithIdentifier:kGoToLocAnswerSegueIdentifier sender:self];
    }
    else if (clue.clueType == ClueTypePicture)
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
        controller.selectedClue = clue;
        controller.selectedGame = self.selectedGame;
        controller.answerImageView.hidden = false;
    }
    else if ([[segue identifier] isEqualToString:kGoToLocAnswerSegueIdentifier])
    {
        LocationAnswerViewController * controller = segue.destinationViewController;
        controller.selectedClue = clue;
        controller.selectedGame = self.selectedGame;
        controller.answerMapView.hidden = false;
    }
}


@end
