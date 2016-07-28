//
//  GameClueCell.h
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameClueCell.h"

@implementation GameClueCell

- (void) setTheClue:(SCSClue *)theClue
{
    if (_theClue != theClue) {
        _theClue = theClue;
        [self configureView];
    }
}

- (void) configureView
{
    self.statusImageView.image = [UIImage imageNamed:@"approval.png"];
    
    if (self.theClue) {
        self.descriptionLabel.text = self.theClue.clueDescription;
        self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.theClue.pointValue intValue]];
        self.typeImageView.image = ([self.theClue.type isEqualToString:@"Picture"]) ? [UIImage imageNamed:@"Camera"]:[UIImage imageNamed:@"location"];
        
        self.statusImageView.hidden = (!self.theClue.didSubmit) || self.theClue.submittedAnswer.isPending || (self.theClue.didSubmit == YES && self.theClue.submittedAnswer.isCorrect == NO);
        self.pendingStatusLabel.hidden = ((self.theClue.didSubmit) && self.theClue.submittedAnswer.isCorrect) ? NO : YES;
    }
    else {
        self.descriptionLabel.text = nil;
        self.pointLabel.text = nil;
        self.typeImageView.image = nil;
        
        self.statusImageView.hidden = YES;
        self.pendingStatusLabel.hidden = YES;
    }
}

@end
