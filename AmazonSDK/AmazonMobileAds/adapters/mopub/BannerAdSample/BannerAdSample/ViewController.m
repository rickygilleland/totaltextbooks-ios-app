// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize MoPub Ad View
    self.adView = [[MPAdView alloc] initWithAdUnitId:@"{AD_UNIT_ID}" size:MOPUB_BANNER_SIZE];
    self.adView.delegate = self;
    [self.view addSubview:self.adView];
    [self repositionAd];
   
    // Request Geolocation Permissions
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIContentContainer protocol
/**
 * Detects device rotation to re-center the banner ad
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context){
        [self repositionAd];
    }];
}

#pragma mark - MPAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"Banner ad did load");
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"Failed to load banner ad");
}

#pragma mark - IBAction
- (IBAction)loadAd:(id)sender
{
    [self.adView loadAd];
}

#pragma mark - private
/**
 * Re-centers the banner ad on the screen. Call this method on device rotation.
 */
- (void)repositionAd
{
    CGFloat deviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat adHeight = CGRectGetHeight(self.adView.frame);
    self.adView.center = CGPointMake(deviceWidth/2, adHeight/2 + 20);
}

@end
