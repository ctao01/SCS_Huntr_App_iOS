//
//  GameProfileViewController.m
//  Twitter User Interface
//
//  Created by Justin Leger on 7/29/16.
//  Copyright © 2016 Dean Brindley. All rights reserved.
//

#import "ProfileViewController.h"
#import "FXBlurView.h"

#define offset_HeaderStop 40.0
#define distance_W_LabelHeader 30.0

#define kPullToRefreshDistance 64.0
#define kPullToRefreshDistance 64.0

@interface ProfileViewController () <UIScrollViewDelegate>

@end

@implementation ProfileViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0);
}

- (void)viewDidLayoutSubviews
{
//    NSLog(@"%@", NSStringFromCGRect(self.headerView.bounds));
    
    if (!self.headerImageView) {
        // Header - Normal Image
        self.headerImageView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerImageView.image = [UIImage imageNamed:@"header_bg"];
        [self.headerView insertSubview:self.headerImageView belowSubview:self.headerTitleLabel];
    }
    
    if (!self.headerBlurImageView) {
        // Header - Blurred Image
        self.headerBlurImageView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
        self.headerBlurImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerBlurImageView.image = [[UIImage imageNamed:@"header_bg"] blurredImageWithRadius:10 iterations:20 tintColor:[UIColor clearColor]];
        self.headerBlurImageView.alpha = 0.0;
        [self.headerView insertSubview:self.headerBlurImageView belowSubview:self.headerTitleLabel];
    }
    
    if (!self.headerView.clipsToBounds) self.headerView.clipsToBounds = YES;
}

#pragma mark - ScrollView Delegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pullToRefreshOffset = -(scrollView.contentOffset.y + kPullToRefreshDistance);
//
//    if (pullToRefreshOffset >=  0) {
//        let translationOffset = min(scrollviewOffset, stepOffset)
//        let alpha =  min (scrollviewOffset / stepOffset, 1.0)
//        
//        self.refreshLabel?.layer.transform = CATransform3DMakeTranslation(0, translationOffset , 0)
//        self.titleLabel?.layer.transform = CATransform3DMakeTranslation(0, translationOffset , 0)
//        self.refreshLabel?.alpha = alpha
//    }else{
//        self.titleLabel?.layer.transform = CATransform3DIdentity
//        self.refreshLabel?.layer.transform = CATransform3DIdentity
//        self.refreshLabel?.alpha = 0.0
//    }
    
    CGFloat offset = scrollView.contentOffset.y + self.headerView.bounds.size.height;
    NSLog(@"%f :: %f", pullToRefreshOffset, offset);
    
    CATransform3D avatarTransform = CATransform3DIdentity;
    CATransform3D headerTransform = CATransform3DIdentity;
    
    // PULL DOWN -----------------
    
    if (offset < 0) {
        CGFloat headerScaleFactor = -(offset) / self.headerView.bounds.size.height;
        CGFloat headerSizevariation = ((self.headerView.bounds.size.height * (1.0 + headerScaleFactor)) - self.headerView.bounds.size.height)/2;
        headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0);
        headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0);
        
        self.headerView.layer.zPosition = 0;
        self.headerTitleLabel.hidden = YES;
    }
    
    // SCROLL UP/DOWN ------------
    
    else {
        
        // Header -----------
        
        headerTransform = CATransform3DTranslate(headerTransform, 0, MAX(-offset_HeaderStop, -offset), 0);
        
        //  ------------ Label
        
        self.headerTitleLabel.hidden = NO;
        CGFloat alignToNameLabel = -offset + self.titleLabel.frame.origin.y + self.headerView.frame.size.height + offset_HeaderStop;
        
        CGRect headerTitleLabelFrame = self.headerTitleLabel.frame;
        headerTitleLabelFrame.origin = CGPointMake(self.headerTitleLabel.frame.origin.x, MAX(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop));
        self.headerTitleLabel.frame = headerTitleLabelFrame;
        
        
        //  ------------ Blur
        
        self.headerBlurImageView.alpha = MIN(1.0, (offset - alignToNameLabel)/distance_W_LabelHeader);
        
        // Avatar -----------
        
        CGFloat avatarScaleFactor = (MIN(offset_HeaderStop, offset)) / self.avatarImage.bounds.size.height / 1.4; // Slow down the animation
        CGFloat avatarSizeVariation = ((self.avatarImage.bounds.size.height * (1.0 + avatarScaleFactor)) - self.avatarImage.bounds.size.height) / 2.0;
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
        
        if (offset <= offset_HeaderStop) {
            
            if (self.avatarImage.layer.zPosition < self.headerView.layer.zPosition) {
                self.headerView.layer.zPosition = 0;
            }
        }
        else {
            
            if (self.avatarImage.layer.zPosition >= self.headerView.layer.zPosition) {
                self.headerView.layer.zPosition = 2;
            }
        }
    }
    
    // Apply Transformations
    self.headerView.layer.transform = headerTransform;
    self.avatarImage.layer.transform = avatarTransform;
    
    // Segment control
    
    CGFloat segmentViewOffset = self.profileView.frame.size.height - self.segmentedView.frame.size.height - offset;
    
    CATransform3D segmentTransform = CATransform3DIdentity;
    
    // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
    segmentTransform = CATransform3DTranslate(segmentTransform, 0, MAX(segmentViewOffset, -offset_HeaderStop), 0);
    
    self.segmentedView.layer.transform = segmentTransform;
    
    // Set scroll view insets just underneath the segment control
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.segmentedView.frame), 0, 0, 0);
}

@end
