// Copyright 2012-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <AmazonAd/AmazonAdInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>

#import "ViewController.h"

@interface ViewController () <AmazonAdInterstitialDelegate>

@property (strong, nonatomic) AmazonAdInterstitial *interstitial;
@property (strong, nonatomic) IBOutlet UIButton *loadAdButton;
@property (strong, nonatomic) IBOutlet UIButton *showAdButton;
@property (strong, nonatomic) IBOutlet UILabel *loadStatusLabel;

- (IBAction)loadAmazonInterstitial:(UIButton *)sender;
- (IBAction)showAmazonInterstitial:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.interstitial = [AmazonAdInterstitial amazonAdInterstitial];
    self.interstitial.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - IBAction

- (IBAction)loadAmazonInterstitial:(UIButton *)sender
{
    self.loadStatusLabel.text = @"Loading interstitial...";
    AmazonAdOptions *options = [AmazonAdOptions options];
    options.isTestRequest = YES;
    [self.interstitial load:options];
}

- (IBAction)showAmazonInterstitial:(UIButton *)sender
{
    [self.interstitial presentFromViewController:self];
}

#pragma mark - AmazonAdInterstitialDelegate

- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstial loaded.");
    self.loadStatusLabel.text = @"Interstitial loaded.";
}

- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    NSLog(@"Interstitial failed to load.");
    self.loadStatusLabel.text = @"Interstitial failed to load.";
}

- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial will be presented.");
}

- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial has been presented.");
}

- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial will be dismissed.");
}

- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial has been dismissed.");
    self.loadStatusLabel.text = @"No interstitial loaded.";
}

@end
