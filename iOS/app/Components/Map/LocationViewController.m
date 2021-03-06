//
//  LocationViewController.m
//  app
//
//  Created by Joel Oliveira on 19/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "LocationViewController.h"
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "Configuration.h"
#import "RegionsMarker.h"
#import "NotificarePushLib.h"

#define MAP_PADDING 20

@interface LocationViewController ()

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray * circles;
@property (nonatomic, strong) NSMutableArray * markers;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, assign, getter=shouldShowCircles) BOOL showCircles;

@end


@implementation LocationViewController

+ (NSString *)configurationKey {
    return @"location";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    if ([self.notificarePushLib checkLocationUpdates]) {
        
        [[self mapView] setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        [[self mapView] setShowsUserLocation:YES];
    }

    [[self mapView] setMapType:MKMapTypeStandard];

    [[self mapView] setShowsPointsOfInterest:YES];
    [[self mapView] setShowsBuildings:NO];

}

-(void)changeBadge{
    
    [self setupNavigationBar];
    
}

-(void)populateMap {
    
    [[self mapView] removeOverlays:[self circles]];
    [[self mapView] removeAnnotations:[self markers]];
    
    NSMutableArray * markers = [NSMutableArray array];
    NSMutableArray * regions = [NSMutableArray array];
    
    NSLog(@"Regions %li regions", (unsigned long)self.notificarePushLib.locationManager.monitoredRegions.count);
    
    for (CLRegion * region in self.notificarePushLib.locationManager.monitoredRegions) {

        RegionsMarker *annotation = [[RegionsMarker alloc] initWithName:[region identifier] address:@"" coordinate:[region center]] ;
        [markers addObject:annotation];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:[region center] radius:[region radius]];
        [regions addObject:circle];
    }
    
#warning NEEDS TO BE REPLACED BY API REQUEST (CAN BE DONE ON APPDELEGATE)
    // API Request here, currently only mocked data
    NSError * error=nil;
    NSString *pathString=[[NSBundle mainBundle] pathForResource:@"regionsMock" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:pathString];
    NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    //
    
    NSDictionary *regionsJson = [jsonObject objectForKey:@"regions"];
    
    if(regionsJson && [regionsJson count] > 0){
        
        for (NSDictionary * region in regionsJson) {
            
            // Parsing coordinates, if not available, skip to next region
            CLLocationCoordinate2D location;
            
            NSDictionary *coordinates = [[region objectForKey:@"geometry"] objectForKey:@"coordinates"];
            
            if (coordinates && [coordinates count] > 1) {
                
                NSMutableArray *coordinatesArray = [[NSMutableArray alloc] initWithCapacity:2];
                
                for (id coord in coordinates) {
                    
                    [coordinatesArray addObject:coord];
                }
                
                location = CLLocationCoordinate2DMake([[coordinatesArray objectAtIndex:1] doubleValue],
                                                      [[coordinatesArray objectAtIndex:0] doubleValue]);
            } else {
                
                continue;
            }
            
            // Parsing region radius, if not available, skip to next region
            CLLocationDistance radius;
            
            if ([region objectForKey:@"distance"]) {
                
                radius = [[region objectForKey:@"distance"] doubleValue];
                
            } else {
                
                continue;
            }
        
            // Parsing the name
            NSString *name = @"Unknown name";
            
            if ([region objectForKey:@"name"]) {
                
                name = [region objectForKey:@"name"];
            }
            
            RegionsMarker *annotation = [[RegionsMarker alloc] initWithName:name address:@"" coordinate:location] ;
            [markers addObject:annotation];
            
            if ([self shouldShowCircles]) {
                
                MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:radius];
                [regions addObject:circle];
            }
        }
    }
    
    [self setCircles:regions];
    [self setMarkers:markers];
    [[self mapView] addOverlays:regions];
    [[self mapView] addAnnotations:markers];
    //[self setRegion:[self mapView]];
    
#warning TESTING PURPOSES ONLY, SHOULD BE REMOVED
    // Testing purposes only
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(51.9328507, 4.454954499999985);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    
    [[self mapView] setRegion:region animated:YES];
    [[self mapView] regionThatFits:region];
    //
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {

    
    static NSString *identifier = @"RegionsMarker";
    
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
    
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    [annotationView setImage:(annotation == [mapView userLocation]) ? [UIImage imageNamed:@"MapUserMarker"] : nil];

    [annotationView setAnnotation:annotation];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    [circleView setFillColor:[self circleColor]];
    [circleView setStrokeColor:[UIColor clearColor]];
    [circleView setAlpha:0.5f];
    
    return circleView;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

}



- (void)setRegion:(MKMapView *)mapView{
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate([annotation coordinate]);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(MAP_PADDING, MAP_PADDING, MAP_PADDING, MAP_PADDING) animated:YES];
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if([view annotation] != [mapView userLocation]){
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude);
        
        //create MKMapItem out of coordinates
        MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        
        if (destination && [destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]){
            
            //iOS 6
            [destination setName:[[view annotation] title]];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, destination, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                     forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
            
            
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeDriving:MKLaunchOptionsDirectionsModeKey}];
            
        } else{
            
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
                
                NSString* url = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=transit",[[mapView userLocation] coordinate].latitude,[[mapView userLocation] coordinate].longitude,[[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
                
            }else{
                //using iOS 5 which has the Google Maps application
                NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",[[mapView userLocation] coordinate].latitude,[[mapView userLocation] coordinate].longitude,[[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
            
        }
    }
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self populateMap];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateMap) name:@"gotRegions" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNavigationBar) name:@"rangingBeacons" object:nil];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"gotRegions"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"incomingNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"rangingBeacons"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
