//
//  MapViewController.h
//  app
//
//  Created by Joel Oliveira on 19/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <MapKit/MapKit.h>
#import "BadgeLabel.h"

@interface LocationViewController : NotificareComponentViewController <MKMapViewDelegate>


@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, strong) IBOutlet UIView * badge;
@property (nonatomic, strong) IBOutlet BadgeLabel * badgeNr;
@property (nonatomic, strong) IBOutlet UIButton * badgeButton;
@property (nonatomic, strong) IBOutlet UIImageView * buttonIcon;
@property (nonatomic, strong) NSMutableArray * circles;
@property (nonatomic, strong) NSMutableArray * markers;
@property (nonatomic, strong) NSString * viewTitle;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, assign, getter=shouldShowCircles) BOOL showCircles;

@end
