//
//  DetailWedstrijdViewController.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 23/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "DetailWedstrijdViewController.h"

@interface DetailWedstrijdViewController ()

@property (strong, nonatomic) IBOutlet UILabel *thuisPloegLabel;
@property (strong, nonatomic) IBOutlet UILabel *bezoekersPloegLabel;
@property (strong, nonatomic) IBOutlet UILabel *momentLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultaatLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *meldingSwitch;

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIBarButtonItem *directionBtn;
@property (strong, nonatomic) MKMapItem *sporthalItem;

@end

@implementation DetailWedstrijdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sporthalItem = nil;
    if ([self.wedstrijd.sporthal length] > 0) {
        [self addMapToView];
        [self zoekSporthal];
    }
    [self setLabels];
}

-(void) setPloeg:(Ploeg *) ploeg EnWedstrijd:(Wedstrijd *) wedstrijd
{
    _ploeg = ploeg;
    _wedstrijd = wedstrijd;
}

- (void) setLabels
{
    NSString * ploeg1 = [[NSString alloc] init];
    NSString * ploeg2 = [[NSString alloc] init];
    
    if ([self.wedstrijd.ishome boolValue]) {
        ploeg1 = self.ploeg.naam;
        ploeg2 = self.wedstrijd.tegenstander;
    } else {
        ploeg1 = self.wedstrijd.tegenstander;
        ploeg2 = self.ploeg.naam;
    }
    
    self.thuisPloegLabel.text = ploeg1;
    self.bezoekersPloegLabel.text = ploeg2;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.momentLabel.text = [formatter stringFromDate:self.wedstrijd.moment];
    
    
    if ([self.wedstrijd.resultaat length] > 0) {
        self.resultaatLabel.text = self.wedstrijd.resultaat;
    
        NSArray*score = [self.wedstrijd.resultaat componentsSeparatedByString:@"-"];
    
        if ([score count] == 2) {
            if (([self.wedstrijd.ishome boolValue] && [score[0] isEqualToString:@"3"]) || (![self.wedstrijd.ishome boolValue] && [score[1] isEqualToString:@"3"])) {
                self.resultaatLabel.textColor = [UIColor colorWithRed:(99/255.f) green:(150/255.f) blue:(38/255.f) alpha:1];
            } else {
                self.resultaatLabel.textColor = [UIColor redColor];
            }
        }
    } else {
        self.resultaatLabel.text = @"/";
    }
    
    if ([self.wedstrijd.type length] > 0) {
        self.typeLabel.text = self.wedstrijd.type;
    } else {
        self.typeLabel.text = @"/";
    }
    
    if ([self findNotificationWithWedstrijdId:self.wedstrijd.uniek] == nil) {
        self.meldingSwitch.on = NO;
    } else {
        self.meldingSwitch.on = YES;
    }
    
    if ([self.wedstrijd.moment compare:[NSDate date]] == NSOrderedDescending) {
        self.meldingSwitch.enabled = YES;
    } else {
        self.meldingSwitch.enabled = NO;
    }
}

#define kMapHeaderHeight 150

- (void) addMapToView
{
    CGRect frame = self.view.frame;
    UIView *tableHeader = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, CGRectGetWidth(frame), kMapHeaderHeight)];
    tableHeader.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeader;
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), kMapHeaderHeight)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    self.directionBtn = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleBordered target:self action:@selector(getRoute)];
    self.navigationItem.rightBarButtonItem = self.directionBtn;
    
}

- (void) zoekSporthal
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:self.wedstrijd.sporthal
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                     if (error) {
                         
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fout bij laden"
                                                                         message:@"Het adres kan niet worden geladen."
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                         [alert show];
                         [self.directionBtn setEnabled:NO];
                         
                         return;
                     }
                     
                     if(placemarks && placemarks.count > 0)
                     {
                         CLPlacemark *placemark = placemarks[0];
                         self.sporthalItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]];

                         MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                         annotation.coordinate = self.sporthalItem.placemark.coordinate;
                         annotation.title = self.wedstrijd.sporthal;
                         [self.mapView addAnnotation:annotation];
                         [self.mapView selectAnnotation:annotation animated:YES];
                         
                         CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(self.sporthalItem.placemark.coordinate.latitude + 0.005, self.sporthalItem.placemark.coordinate.longitude);
                         self.mapView.centerCoordinate = coords;
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coords, 2000, 2000);
                         [self.mapView setRegion:region animated:YES];
                     }
                 }
     ];
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"SporthalAdres";
    MKAnnotationView *view = [sender dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
    }
        view.annotation = annotation;
    
    return view;
}

- (void) getRoute
{
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
    [self.sporthalItem openInMapsWithLaunchOptions:options];
}

- (IBAction)toggleMelding {
    if (self.meldingSwitch.on) {
        [self addNotificatie];
    } else {
        [self deleteNotificatie];
    }
}

#define intervalMin 30

- (void) addNotificatie
{
    NSDate *date = [NSDate dateWithTimeInterval:-(intervalMin * 60) sinceDate:self.wedstrijd.moment];
    
    NSString * ploeg1 = [[NSString alloc] init];
    NSString * ploeg2 = [[NSString alloc] init];
    
    if ([self.wedstrijd.ishome boolValue]) {
        ploeg1 = self.ploeg.naam;
        ploeg2 = self.wedstrijd.tegenstander;
    } else {
        ploeg1 = self.wedstrijd.tegenstander;
        ploeg2 = self.ploeg.naam;
    }
    NSString *body = [ploeg1 stringByAppendingString:[NSString stringWithFormat:@" - %@ begint over %i minuten", ploeg2, intervalMin]];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.alertBody = body;
    localNotification.alertAction = @"Bekijken";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = @{@"wid": self.wedstrijd.uniek, @"pid": self.ploeg.uniek };
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void) deleteNotificatie
{
    UILocalNotification *not = [self findNotificationWithWedstrijdId:self.wedstrijd.uniek];
    if (not != nil) {
        [[UIApplication sharedApplication] cancelLocalNotification: not];
    }
}

- (UILocalNotification *) findNotificationWithWedstrijdId:(NSNumber *) uniek {
    UILocalNotification *notification = nil;
    
    for (UILocalNotification *event in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSDictionary *userInfoCurrent = event.userInfo;
        
        if ([[userInfoCurrent valueForKey:@"wid"] intValue] == [uniek intValue]) {
            notification = event;
            break;
        }
    }
    
    return notification;
}

@end
