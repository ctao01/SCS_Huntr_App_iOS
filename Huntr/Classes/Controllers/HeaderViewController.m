//
//  HeaderViewController.m
//  Twitter User Interface
//
//  Created by Justin Leger on 7/29/16.
//  Copyright © 2016 Dean Brindley. All rights reserved.
//

#import "HeaderViewController.h"
#import "FXBlurView.h"

#define offset_HeaderStop 40.0
#define distance_W_LabelHeader 31.0

#define kPullToRefreshDistance 64.0

@interface HeaderViewController () <UIScrollViewDelegate>

@end

@implementation HeaderViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0);
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews
{
//    NSLog(@"%@", NSStringFromCGRect(self.headerView.bounds));
    
    if (!self.headerImageView) {
        // Header - Normal Image
        self.headerImageView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerImageView.image = [UIImage imageNamed:@"header_2_bg"];
        [self.headerView addSubview:self.headerImageView];
    }
    
    if (!self.headerBlurImageView) {
        // Header - Blurred Image
        self.headerBlurImageView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
        self.headerBlurImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerBlurImageView.image = [[UIImage imageNamed:@"header_2_bg"] blurredImageWithRadius:10 iterations:20 tintColor:[UIColor clearColor]];
        self.headerBlurImageView.alpha = 0.0;
        [self.headerView addSubview:self.headerBlurImageView];
    }
    
    if (!self.headerView.clipsToBounds) self.headerView.clipsToBounds = YES;
}

#pragma mark - ScrollView Delegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pullToRefreshOffset = -(scrollView.contentOffset.y + kPullToRefreshDistance);
    
    CGFloat offset = scrollView.contentOffset.y + self.headerView.bounds.size.height;
    NSLog(@"%f :: %f", pullToRefreshOffset, offset);
    
    CATransform3D headerTransform = CATransform3DIdentity;
    
    // PULL DOWN -----------------
    
    if (offset < 0) {
        CGFloat headerScaleFactor = -(offset) / self.headerView.bounds.size.height;
        CGFloat headerSizevariation = ((self.headerView.bounds.size.height * (1.0 + headerScaleFactor)) - self.headerView.bounds.size.height)/2;
        headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0);
        headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0);
        
        self.headerView.layer.zPosition = 0;
    }
    
    // SCROLL UP/DOWN ------------
    
    else {
        
        // Header -----------
        
        headerTransform = CATransform3DTranslate(headerTransform, 0, MAX(-offset_HeaderStop, -offset), 0);
        
        //  ------------ Blur
        
        self.headerBlurImageView.alpha = MIN(1.0, (offset)/distance_W_LabelHeader);
    }
    
    // Apply Transformations
    self.headerView.layer.transform = headerTransform;
}

@end
