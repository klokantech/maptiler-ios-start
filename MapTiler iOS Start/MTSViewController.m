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
}

@end

@implementation MTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"MapTiler iOS Start";
    
    // Setup map source
    RMMBTilesSource *offlineSource = [[RMMBTilesSource alloc] initWithTileSetResource:@"map" ofType:@"mbtiles"];
    
    // Setup RMMapView
    self.mapView.tileSource = offlineSource;
    self.mapView.delegate = self;
    
    self.mapView.showLogoBug = NO;
    self.mapView.hideAttribution = YES;
    self.mapView.adjustTilesForRetinaDisplay = YES;
    self.mapView.showsUserLocation = YES;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.mapView.zoom = (offlineSource.minZoom + offlineSource.maxZoom) / 2;
    
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
            self.mapView.userTrackingMode = RMUserTrackingModeFollow;
            [locationButton setImage:[UIImage imageNamed:@"location_follow"]];
            break;
        case RMUserTrackingModeFollow:
            self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
            [locationButton setImage:[UIImage imageNamed:@"location_heading"]];
            break;
        default:
            self.mapView.userTrackingMode = RMUserTrackingModeNone;
            [locationButton setImage:[UIImage imageNamed:@"location_none"]];
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


@end
