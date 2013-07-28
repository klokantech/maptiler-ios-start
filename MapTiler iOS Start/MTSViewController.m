//
//  MTSViewController.m
//  MapTiler iOS Start
//
//  Created by Jiří Ondruška on 15.06.13.
//  Copyright (c) 2013 KlokanTech. All rights reserved.
//

#import "MTSViewController.h"

@interface MTSViewController ()
{
    UIBarButtonItem *locationButton;
    RMMBTilesSource *source;
    CLLocation *userLocation;
    CLLocationManager *locationManager;
}

@end

@implementation MTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"MapTiler iOS Start";
    
    // Setup coarse location service, so we know user lcoation before we try to locate it with MapBox tracking
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 1000.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if ([CLLocationManager locationServicesEnabled])
    {
        [locationManager startUpdatingLocation];
        userLocation = locationManager.location;
    }
    
    // Setup map source
    source = [[RMMBTilesSource alloc] initWithTileSetResource:@"map" ofType:@"mbtiles"];
    
    // Setup RMMapView
    self.mapView.tileSource = source;
    self.mapView.delegate = self;
    
    self.mapView.showLogoBug = NO;
    self.mapView.hideAttribution = YES;
    self.mapView.adjustTilesForRetinaDisplay = YES;
    self.mapView.showsUserLocation = YES;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.mapView.zoom = (source.minZoom + source.maxZoom) / 2;
    
    // Setup location button
    locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_none"] style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = locationButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Button Actions

- (void)locationButtonPressed
{
    switch (self.mapView.userTrackingMode) {
        case RMUserTrackingModeNone:
            {
                CLLocationCoordinate2D southWest = source.latitudeLongitudeBoundingBox.southWest;
                CLLocationCoordinate2D northEast = source.latitudeLongitudeBoundingBox.northEast;
                
                if (userLocation.coordinate.latitude >= southWest.latitude
                    && userLocation.coordinate.latitude <= northEast.latitude
                    && userLocation.coordinate.longitude >= southWest.longitude
                    && userLocation.coordinate.longitude <= northEast.longitude) {
                    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"User not on map"
                                                message:@"Current user location is outside this map"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }
            break;
        case RMUserTrackingModeFollow:
            self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
            break;
        default:
            self.mapView.userTrackingMode = RMUserTrackingModeNone;
            break;
    }
}

#pragma mark - RMMapView Delegate

- (void)mapView:(RMMapView *)mapView didChangeUserTrackingMode:(RMUserTrackingMode)mode animated:(BOOL)animated
{
    switch (self.mapView.userTrackingMode) {
        case RMUserTrackingModeFollow:
            [locationButton setImage:[UIImage imageNamed:@"location_follow"]];
            break;
        case RMUserTrackingModeFollowWithHeading:
            [locationButton setImage:[UIImage imageNamed:@"location_heading"]];
            break;
        default:
            [locationButton setImage:[UIImage imageNamed:@"location_none"]];
            break;
    }
}

- (void)mapViewRegionDidChange:(RMMapView *)rmMapView
{
    CLLocationCoordinate2D center = rmMapView.centerCoordinate;
    
    CLLocationCoordinate2D southWest = source.latitudeLongitudeBoundingBox.southWest;
    CLLocationCoordinate2D northEast = source.latitudeLongitudeBoundingBox.northEast;
    
    BOOL changed = NO;
    
    if (center.latitude < southWest.latitude) {
        center.latitude = southWest.latitude;
        changed = YES;
    }
    if (center.longitude < southWest.longitude) {
        center.longitude = southWest.longitude;
        changed = YES;
    }
    if (center.latitude > northEast.latitude) {
        center.latitude = northEast.latitude;
        changed = YES;
    }
    if (center.longitude > northEast.longitude) {
        center.longitude = northEast.longitude;
        changed = YES;
    }
    
    if (changed) {
        [rmMapView setCenterCoordinate:center animated:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    userLocation = [locations objectAtIndex:0];
}



@end
