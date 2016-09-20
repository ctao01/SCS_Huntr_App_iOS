//
//  GameClueCell.h
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameClueCell.h"

@implementation GameClueCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void) setTheClue:(SCSClue *)theClue
{
    if (_theClue != theClue) {
        _theClue = theClue;
        [self configureView];
    }
}

- (void) configureView
{
    if (self.theClue) {
        
        if (self.selectedGame.status == SCSGameStatusCompleted ) {
            if (self.theClue.clueState == SCSClueStateUnawswered) {
                self.selectionStyle  = UITableViewCellSelectionStyleNone;
            }
            self.accessoryType = UITableViewCellAccessoryNone;
        }
        
        self.descriptionLabel.text = self.theClue.clueDescription;
        self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.theClue.pointValue intValue]];
        self.typeImageView.image = (self.theClue.clueType == SCSClueTypePicture) ? [UIImage imageNamed:@"photoClue"]:[UIImage imageNamed:@"locationClue"];
        
//        self.statusImageView.hidden = (!self.theClue.didSubmit) || self.theClue.submittedAnswer.isPending || (self.theClue.didSubmit == YES && self.theClue.submittedAnswer.isCorrect == NO);
//        self.pendingStatusLabel.hidden = ((self.theClue.didSubmit) && self.theClue.submittedAnswer.isCorrect) ? NO : YES;
        
        if (self.theClue.clueState == SCSClueStateAnswerPendingReview)
        {
            self.statusImageView.image = [UIImage imageNamed:@"clueIndicatorPending"];
        }
        else if (self.theClue.clueState == SCSClueStateAnswerAccepted)
        {
            self.statusImageView.image = [UIImage imageNamed:@"clueIndicatorAccepted"];

        }
        else if (self.theClue.clueState == SCSClueStateAnswerRejected)
        {
            self.statusImageView.image = [UIImage imageNamed:@"clueIndicatorRejected"];
        }
        else
        {
            self.statusImageView.image = [UIImage imageNamed:@"clueIndicatorUnanswered"];
        }
    }
    else {
        
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        self.descriptionLabel.text = nil;
        self.pointLabel.text = nil;
        self.typeImageView.image = nil;
        
        self.statusImageView.hidden = YES;
    }
}

@end
