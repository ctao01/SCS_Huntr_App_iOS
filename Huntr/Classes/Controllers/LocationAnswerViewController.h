//
//  LocationAnswerViewController.h
//  Huntr
//
//  Created by Joy Tao on 4/27/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationAnswerViewController : UIViewController

@property (nonatomic , strong) SCSGame * selectedGame;
@property (nonatomic , strong) SCSClue * selectedClue;

@property (nonatomic , strong) IBOutlet UIImageView * clueTypeImageView;
@property (nonatomic , strong) IBOutlet UILabel * pointLabel;
@property (nonatomic , strong) IBOutlet UITextView * descriptionTextView;
@property (nonatomic , strong) IBOutlet UIButton * checkInButton;

@property (nonatomic , strong) IBOutlet MKMapView * answerMapView;

@end
