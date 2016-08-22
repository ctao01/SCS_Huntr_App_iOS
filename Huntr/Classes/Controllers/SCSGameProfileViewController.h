//
//  SCSGameProfileViewController.h
//  Huntr
//
//  Created by Justin Leger on 8/19/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "ProfileViewController.h"

typedef NS_ENUM(NSInteger, SCSProfileContentType) {
    SCSProfileContentTypeTeams,
    SCSProfileContentTypeClues
};

@interface SCSGameProfileViewController : ProfileViewController

@property (nonatomic, assign) SCSProfileContentType contentToDisplay;

@property (nonatomic , strong) SCSGame * selectedGame;

@property (weak, nonatomic) IBOutlet UISegmentedControl *contentTypeSegmentControl;
@property (weak, nonatomic) IBOutlet TWTButton * addTeamButton;
@property (weak, nonatomic) IBOutlet UILabel * gameDateTimeLabel;

@end
