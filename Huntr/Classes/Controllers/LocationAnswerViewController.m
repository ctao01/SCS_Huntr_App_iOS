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
    self.descriptionTextView.text = self.clueToAnswer.clueDescription;
    self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.clueToAnswer.pointValue intValue]];
    self.pointLabel.textColor =  (self.clueToAnswer.submittedAnswer.isCorrect) ? [UIColor colorWithRed:76.0f/255.0f green:217.0f/255.0f blue:171.0f/255.0f alpha:1.0] : [UIColor darkGrayColor];
    self.clueTypeImageView.image = [UIImage imageNamed:@"Location"];
    

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.clueToAnswer.didSubmit == false){
        self.answerMapView.showsUserLocation  = true;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization]; // For background access
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    else
    {
        SCSAnnotation * annotation = [[SCSAnnotation alloc] initWithCoordinate:self.clueToAnswer.submittedAnswer.answerLocation.coordinate];
        [self.answerMapView addAnnotation:annotation];
    }
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
    
    CLLocationDistance distance = [userLocation distanceFromLocation:self.clueToAnswer.clueLocation];
    
    NSString *distanceReturned = [NSString stringWithFormat:@"%f",distance];
    
    if([distanceReturned doubleValue] <= 500 && [distanceReturned doubleValue]>0){
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
            [[SCSHuntrClient sharedClient] postAnswer:answerInfo withClue:self.clueToAnswer.clueID type:@"Location" successBlock:nil failureBlock:nil];
        }
        else
        {
            
        }

    }
    else
    {
        
    }
    
}


@end
