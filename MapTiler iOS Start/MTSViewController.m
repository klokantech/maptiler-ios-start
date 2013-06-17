//
//  MTSViewController.m
//  MapTiler iOS Start
//
//  Created by Jiří Ondruška on 15.06.13.
//  Copyright (c) 2013 KlokanTech. All rights reserved.
//

#import "MTSViewController.h"

@interface MTSViewController ()

@end

@implementation MTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"MapTiler iOS Start";
    
    // Setup map source
    RMMBTilesSource *offlineSource = [[RMMBTilesSource alloc] initWithTileSetResource:@"grandcanyon" ofType:@"mbtiles"];
    
    // Setup RMMapView
    self.mapView.tileSource = offlineSource;
    
    self.mapView.showLogoBug = NO;
    self.mapView.hideAttribution = YES;
    self.mapView.adjustTilesForRetinaDisplay = YES;
    self.mapView.showsUserLocation = YES;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.mapView.zoom = (offlineSource.minZoom + offlineSource.maxZoom) / 2;
    
    // Setup location button
    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
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


@end
