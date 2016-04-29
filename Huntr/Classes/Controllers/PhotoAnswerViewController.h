//
//  PhotoAnswerViewController.h
//  Huntr
//
//  Created by Joy Tao on 4/27/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAnswerViewController : UIViewController

@property (nonatomic , strong) SCSClue * clueToAnswer;

@property (nonatomic , strong) IBOutlet UIImageView * clueTypeImageView;
@property (nonatomic , strong) IBOutlet UILabel * pointLabel;
@property (nonatomic , strong) IBOutlet UITextView * descriptionTextView;
@property (nonatomic , strong) IBOutlet UIButton * takePhotoButton;

@property (nonatomic , strong) IBOutlet UIImageView * answerImageView;


@end
