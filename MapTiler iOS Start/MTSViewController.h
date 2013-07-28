//
//  MTSViewController.h
//  MapTiler iOS Start
//
//  Created by Jiří Ondruška on 15.06.13.
//  Copyright (c) 2013 KlokanTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MapBox.h"

@interface MTSViewController : UIViewController<RMMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet RMMapView *mapView;

@end
