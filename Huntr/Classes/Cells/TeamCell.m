//
//  TeamCell.m
//  Huntr
//
//  Created by Joy Tao on 4/22/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "TeamCell.h"


@implementation TeamCell

- (void) setTeam:(SCSTeam *)team
{
    if (_team != team) _team = team;
    [self configureView];
}

- (void)addTeamButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        if (self.selectedGame.status == SCSGameStatusInProgress) {
            [self gameInProgressAddTeamAlert];
        }
        else {
            if (self.teamButtonActionBlock) self.teamButtonActionBlock();
        }
    }
}

- (void) configureView
{
    if (self.team) {
        self.textLabel.text = self.team.teamName;
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        if ([[SCSHuntrEnviromentManager sharedManager] isPlayerMemberOfTeamID:self.team.teamID]) {
//          accessoryButton.enabled = NO;
//          accessoryButton.alpha = 0.5f;
            self.accessoryView = nil;
        }
        else {
            UIButton * accessoryButton = [UIButton setupNormalStyle];
            [accessoryButton addTarget:self action:@selector(addTeamButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
            self.accessoryView = accessoryButton;
        }
    }
    else {
        self.textLabel.text = nil;
        self.accessoryView = nil;
    }
}

- (IBAction) gameInProgressAddTeamAlert
{
    NSString * message = [NSString stringWithFormat:@"You're about to join Team %@ while the game is in progress. Once you select Ok you will be automatically ntered into the game. Are you ready?", self.team.teamName];
    UIAlertController * addTeamAlertController = [UIAlertController alertControllerWithTitle:@"Confirm Add Team" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [addTeamAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction * actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (self.teamButtonActionBlock) self.teamButtonActionBlock();
        [addTeamAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [addTeamAlertController addAction:actionCancel];
    [addTeamAlertController addAction:actionOk];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:addTeamAlertController animated:YES completion:nil];
}

@end
