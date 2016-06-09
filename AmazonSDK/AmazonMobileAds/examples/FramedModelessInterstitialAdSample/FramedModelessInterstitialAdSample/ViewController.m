// Copyright 2012-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"
#import <AmazonAd/AmazonAdModelessInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>

@interface ViewController () <UIContentContainer, AmazonAdModelessInterstitialDelegate>

@property (nonatomic) AmazonAdModelessInterstitial *modelessInterstitial;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (IBAction)loadModelessInterstitial:(id)sender
{
    // Create the modeless interstitial object
    if (!self.modelessInterstitial) {
        self.modelessInterstitial = [AmazonAdModelessInterstitial modelessInterstitialWithContainerView:self.adContainerView];
        self.modelessInterstitial.delegate = self;
    }
    
    // Load a modeless interstitial ad
    AmazonAdOptions *options = [AmazonAdOptions options];
    options.isTestRequest = YES;
    [self.modelessInterstitial load:options];
}

- (IBAction)showModelessInterstitial:(id)sender
{
    if (self.modelessInterstitial.isReady) {
        self.adContainerView.hidden = NO;
        self.closeButton.hidden = NO;
        self.dimView.hidden = NO;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.adContainerView.alpha = 1.0;
                             self.closeButton.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [self.modelessInterstitial onPresented];
                         }];
    }
}

- (IBAction)closeModelessInterstitial:(id)sender
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.adContainerView.alpha = 0.0;
                         self.closeButton.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.adContainerView.hidden = YES;
                         self.closeButton.hidden = YES;
                         self.dimView.hidden = YES;
                         [self.modelessInterstitial onHidden];
                     }];
}

#pragma mark - UIContentContainer
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.width > size.height) {
        self.adContainerViewWidthConstraint.constant = 0;
        self.adContainerViewHeightConstraint.constant = 10;
    } else {
        self.adContainerViewWidthConstraint.constant = 10;
        self.adContainerViewHeightConstraint.constant = 0;
    }
}

#pragma mark - AmazonAdModelessInterstitialDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)modelessInterstitialDidLoad:(AmazonAdModelessInterstitial *)modelessInterstitial
{
    self.loadStatusLabel.text = @"Modeless Interstitial Loaded";
}

- (void)modelessInterstitialDidFailToLoad:(AmazonAdModelessInterstitial *)modelessInterstitial withError:(AmazonAdError *)error
{
    self.loadStatusLabel.text = @"No Modeless Interstitial Loaded";
    NSLog(@"Modeless interstitial failed to load: %@", error.errorDescription);
}

- (void)modelessInterstitialDidExpire:(AmazonAdModelessInterstitial *)interstitial
{
    self.loadStatusLabel.text = @"Modeless Interstitial Expired";
    NSLog(@"Modeless interstitial has expired");
}

@end
