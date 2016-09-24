//
//  SCSClueViewController.h
//  Huntr
//
//  Created by Joy Tao on 8/24/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSClueViewController : UIViewController

@property (nonatomic, weak) SCSGame * selectedGame;
@property (nonatomic, assign) SCSClue * selectedClue;

@property (nonatomic, weak) IBOutlet UIVisualEffectView * blurView;
//@property (nonatomic, weak) IBOutlet UILabel * clueDescLabel;
@property (nonatomic, weak) IBOutlet UITextView * clueDescTextView;
@property (nonatomic, weak) IBOutlet UIButton * roundButton;

@end
