//
//  LocationAnswerViewController.m
//  Huntr
//
//  Created by Joy Tao on 4/27/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "LocationAnswerViewController.h"

@interface SCSAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@implementation SCSAnnotation

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

@interface LocationAnswerViewController()< MKMapViewDelegate , CLLocationManagerDelegate >
@property (nonatomic , strong) CLLocationManager * locationManager;
@end

@implementation LocationAnswerViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.text = self.selectedClue.clueDescription;
    self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.selectedClue.pointValue intValue]];
    self.pointLabel.textColor =  (self.selectedClue.submittedAnswer.isCorrect) ? [UIColor colorWithRed:76.0f/255.0f green:217.0f/255.0f blue:171.0f/255.0f alpha:1.0] : [UIColor darkGrayColor];
    self.clueTypeImageView.image = [UIImage imageNamed:@"Location"];
    if(self.selectedGame.status == GameStatusInProgress)
    {
        if (self.selectedClue.didSubmit == true && self.selectedClue.submittedAnswer.isCorrect == true)
        {
            self.pointLabel.textColor = [UIColor colorWithRed:76.0/255.0f green:217.0/255.0f blue:100.0/255.0 alpha:1];
            
            SCSAnnotation * annotation = [[SCSAnnotation alloc] initWithCoordinate:self.selectedClue.submittedAnswer.answerLocation.coordinate];
            [self.answerMapView addAnnotation:annotation];
            self.checkInButton.hidden = true;
            
        }
        else
        {
            self.pointLabel.textColor = [UIColor darkGrayColor];
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [self.locationManager requestWhenInUseAuthorization];
            }
            self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            self.locationManager.pausesLocationUpdatesAutomatically = NO;
            self.checkInButton.hidden = false;
            [self.checkInButton setTitle:@"Check In" forState:UIControlStateNormal];
            self.answerMapView.showsUserLocation  = true;

            
        }
    }
    else if (self.selectedGame.status == GameStatusCompleted)
    {
        self.checkInButton.hidden = true;
        
        if (self.selectedClue.submittedAnswer.isCorrect) {
            self.pointLabel.textColor = [UIColor colorWithRed:76.0/255.0f green:217.0/255.0f blue:100.0/255.0 alpha:1];
            
            SCSAnnotation * annotation = [[SCSAnnotation alloc] initWithCoordinate:self.selectedClue.submittedAnswer.answerLocation.coordinate];
            [self.answerMapView addAnnotation:annotation];
        }
        else
        {
            self.pointLabel.textColor = [UIColor lightGrayColor];
            self.answerMapView.showsUserLocation  = false;
        }
    }

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction) checkIn:(id)sender
{
    [self.locationManager startUpdatingLocation];

}

#pragma mark - Private Methods

- (BOOL) isUserInTheLocation:(CLLocation*)userLocation{
    
    CLLocationDistance distance = [userLocation distanceFromLocation:self.selectedClue.clueLocation];
    
    NSString *distanceReturned = [NSString stringWithFormat:@"%f",distance];
    
    if([distanceReturned doubleValue] <= 500 && [distanceReturned doubleValue] >= 0){
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.answerMapView setRegion:[self.answerMapView regionThatFits:region] animated:YES];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to get user location" );
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = locations.lastObject;
    
    if (currentLocation != nil)
    {
        [manager stopUpdatingLocation];
        BOOL isCorrect = [self isUserInTheLocation: currentLocation];
        if (isCorrect) {
            NSDictionary * answerInfo = @{@"latitude": [NSNumber numberWithDouble:currentLocation.coordinate.latitude], @"longitude": [NSNumber numberWithDouble:currentLocation.coordinate.longitude]};
            [[SCSHuntrClient sharedClient] postAnswer:answerInfo withClue:self.selectedClue.clueID type:@"Location" successBlock:^(id response) {
                
                [self.navigationController popViewControllerAnimated:true];

            }failureBlock:^(NSString * errorString){
                //TODO: ERROR
            }];
        }
        else
        {
            //TODO: ERROR
        }

    }
    else
    {
        //TODO: ERROR
        
    }
    
}


@end
