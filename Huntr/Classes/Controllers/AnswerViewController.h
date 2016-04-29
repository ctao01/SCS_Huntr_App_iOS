//
//  AnswerViewController.h
//  Hunter
//
//  Created by Joy Tao on 3/8/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SCSClue.h"

@interface AnswerViewController : UIViewController 

@property (nonatomic , strong) SCSClue * theClue;

@property (nonatomic , strong) IBOutlet UIImageView * clueTypeImageView;
@property (nonatomic , strong) IBOutlet UILabel * pointLabel;
@property (nonatomic , strong) IBOutlet UITextView * descriptionTextView;
@property (nonatomic , strong) IBOutlet UIButton * answerButton;

@property (nonatomic , strong) IBOutlet MKMapView * answerMapView;
@property (nonatomic , strong) IBOutlet UIImageView * answerImageView;

@end
