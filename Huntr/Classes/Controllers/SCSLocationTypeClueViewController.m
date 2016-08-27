//
//  SCSLocationTypeClueViewController.m
//  Huntr
//
//  Created by Joy Tao on 8/23/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSLocationTypeClueViewController.h"
#import <MapKit/MapKit.h>

#import "SCSPushNotificationManager.h"
#import "SCSPushNotification.h"

@interface SCSHutrAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@implementation SCSHutrAnnotation

@synthesize coordinate = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self != nil)
    {
        _coordinate = coordinate;
    }
    
    return self;
}

@end

@interface SCSHutrAnswerAnnotation : SCSHutrAnnotation
@end

@implementation SCSHutrAnswerAnnotation
@end

@interface SCSLocationTypeClueViewController () < MKMapViewDelegate , CLLocationManagerDelegate >
@property (nonatomic, weak) IBOutlet MKMapView * mapView;

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLLocation * currentLocation;
//@property (nonatomic, strong) CLLocation * oldLocation;

@end

@implementation SCSLocationTypeClueViewController

static float MilesToMeters(float miles) {
    // 1 mile is 1609.344 meters
    // source: http://www.google.com/search?q=1+mile+in+meters
    return 1609.344f * miles;
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTransparentStyle];
    
    self.currentLocation = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;

    
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = false;
    
    [self updateByGameAndClue];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationClueStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:SCSPushNotificationAnswerStatusUpdate object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationGameStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSPushNotificationTeamStatusUpdate object:nil];
}

- (void)handlePushNotification:(NSNotification *)note
{
    SCSPushNotification * pn = note.userInfo[@"pn"];
    NSString * gameID = pn.aps[@"gameID"];
    NSString * teamID = pn.aps[@"teamID"];
    NSString * clueID = pn.aps[@"clueID"];
    
    if ([clueID isEqualToString:self.selectedClue.clueID]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateByGameAndClue
{
    if (self.selectedClue.clueState == SCSClueStateUnawswered)
    {
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        /* Game is in Progress: SCSClueStateAnswerPendingReview, SCSClueStateAnswerAccepted, SCSClueStateAnswerRejected 
           OR
           Game is Completed
         */
        
        self.roundButton.alpha = 0;
        
        self.mapView.showsUserLocation = true;
        self.mapView.userInteractionEnabled = true;
        SCSHutrAnswerAnnotation * annotation = [[SCSHutrAnswerAnnotation alloc] initWithCoordinate:self.selectedClue.submittedAnswer.answerLocation.coordinate];
        [self.mapView addAnnotation:annotation];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.selectedClue.submittedAnswer.answerLocation.coordinate, MilesToMeters(5), MilesToMeters(5));
        [self zoomMapToFitRegion:region animateWithDuration:0.4f completion:nil];
        
        
    }
}

#pragma mark - Button Actions

- (IBAction) checkin:(id)sender
{
    [UIAlertController showAlertInViewController:self withTitle:@"Huntr Notification" message:@"Are you sure to submit the answer?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex){
        if (buttonIndex == controller.firstOtherButtonIndex) {
            BOOL correctLocation = [self isUserInTheLocation:self.currentLocation];
            if (correctLocation == false){
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"You are not here" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
            }
            else
            {
                NSDictionary * answerInfo = @{@"latitude": [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude], @"longitude": [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude]};
                
                [[SCSHuntrClient sharedClient] postAnswer:answerInfo withClue:self.selectedClue successBlock:^(id response) {
                    [self.navigationController popViewControllerAnimated:YES];
                } failureBlock:^(NSString *errorString) {
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Oops! Something wrong" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
                }];

            }
        }
        
    }];
    
    
//    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Huntr Notification" message:@"Are you sure to submit the answer?" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//        
//    }];
//    
//    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action ) {
//        [self.navigationController popViewControllerAnimated:true];
//        
//    }];
//    
//    [alertVC addAction:cancelAction];
//    [alertVC addAction:yesAction];
//    
//    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - MKMapView Delegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if ([annotation isKindOfClass:[SCSHutrAnswerAnnotation class]])
    {
        MKAnnotationView * answerAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"clueLocation"];
        if (answerAnnotationView == nil) {
            answerAnnotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"clueLocation"];
            answerAnnotationView.image = [ UIImage imageNamed:@"map-marker"];
        }
        return answerAnnotationView;
    }
    else
    {
        MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"currentLocation"];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"currentLocation"];
            annotationView.image = [ UIImage imageNamed:@"map-car"];
        }
        return annotationView;
    }
    
}

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    for (MKAnnotationView * view in views) {
        [UIView animateWithDuration:0.8f animations:^{
            view.alpha = 1;
            
        } completion:^(BOOL finished) {
            [view addBounceAnimation];
//            [self.locationManager startUpdatingLocation];
        }];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to get user location" );
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (self.currentLocation == nil)
    {
        self.currentLocation = locations.lastObject;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, MilesToMeters(0.5), MilesToMeters(0.5));
        
        [self zoomMapToFitRegion:region animateWithDuration:0.8f completion:^{
            SCSHutrAnnotation * annotation = [[SCSHutrAnnotation alloc] initWithCoordinate:self.currentLocation.coordinate];
            [self.mapView addAnnotation:annotation];
        }];
        
        
    }
    else
    {
        CLLocation * oldLocation = self.currentLocation;
        self.currentLocation = locations.lastObject;
        
        CLLocationDistance distance = [oldLocation distanceFromLocation:self.currentLocation];
        if (distance >= MilesToMeters(2))
        {
            SCSHutrAnnotation * annotation = [self.mapView.annotations firstObject];
            MKAnnotationView * annotationView = [self.mapView viewForAnnotation: annotation];
            
            CGPoint fromPos = [self.mapView convertCoordinate:oldLocation.coordinate toPointToView:self.mapView];
            CGPoint toPos = [self.mapView convertCoordinate:self.currentLocation.coordinate toPointToView:self.mapView];
            [annotationView addMovingAnimationOnMapFrom:fromPos to:toPos];
        }
    }
    
}

#pragma mark - Private Methods

- (void) zoomMapToFitRegion:(MKCoordinateRegion)region animateWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [UIView animateWithDuration:duration animations:^{
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    } completion:^(BOOL finished) {
        if (completion != nil) completion();
    }];
    
}

- (BOOL) isUserInTheLocation:(CLLocation *) location {
    
    CLLocationDistance distance = [location distanceFromLocation:self.selectedClue.clueLocation];
    
    NSString * distanceReturned = [NSString stringWithFormat:@"%f",distance];
    
    if([distanceReturned doubleValue] < 50 && [distanceReturned doubleValue] >= 0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
