// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AmazonInterstitialCustomEvent.h"
#import <AmazonAd/AmazonAdInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import "MPLogging.h"

/**
 * AmazonInterstitialCustomEvent extends MoPub's MPInterstitialCustomEvent class 
 * to allow developers to easily display Amazon Interstitial Ads through the MoPub SDK.
 */
@interface AmazonInterstitialCustomEvent() <AmazonAdInterstitialDelegate>

/**
 * Amazon Interstitial Ad View
 */
@property (nonatomic) AmazonAdInterstitial *adView;

@end

@implementation AmazonInterstitialCustomEvent

static NSString * const kAMAVersion = @"iOSMoPubAdapter-1.0";
static NSString * const kAMADomain = @"com.amazon.mobileAds";
static NSString * const kAMATestingEnabled = @"testingEnabled";
static NSString * const kAMALoggingEnabled = @"loggingEnabled";
static NSString * const kAMAGeolocationEnabled = @"geolocationEnabled";
static NSString * const kAMAAppKey = @"appKey";
static NSString * const kAMAPublisherKey = @"pk";
static NSString * const kAMASlotKey = @"slot";
static NSString * const kAMASlotName = @"MoPubAMZN";
static NSString * const kAMAAdvancedOptionsKey = @"advOptions";

// MPInterstitialCustomEventDelegate
@dynamic delegate;

- (instancetype)init
{
    if (self = [super init]) {
        // Initialize Interstitial Ad
        _adView = [AmazonAdInterstitial amazonAdInterstitial];
        _adView.delegate = self;
    }
    return self;
}

#pragma mark - MPInterstitialCustomEvent
/**
 * Called by MoPub to load an interstitial ad
 */
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSData *pkData = [NSJSONSerialization dataWithJSONObject:@[kAMAVersion]
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
    NSString *pkString = [[NSString alloc] initWithData:pkData encoding:NSUTF8StringEncoding];
    AmazonAdOptions *options = [AmazonAdOptions options];
    [options setAdvancedOption:pkString forKey:kAMAPublisherKey];
    [options setAdvancedOption:kAMASlotName forKey:kAMASlotKey];
    [self processCustomEvent:info forOptions:options];
    [self.adView load:options];
}

/**
 * Presents the interstitial ad from the given root View Controller
 */
- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.adView presentFromViewController:rootViewController];
}

#pragma mark - AmazonAdInterstitialDelegate
- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial Ad Loaded");
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitial];
}

- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    MPLogInfo(@"Amazon Interstitial Ad Failed to Load: %@", error.errorDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[self convertAmazonErrorToError:error]];
}

- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial Ad Did Appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial Ad Did Disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial Ad Will Disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial Ad Will Present");
    [self.delegate interstitialCustomEventWillAppear:self];
}

#pragma mark - private
/**
 * Converts AmazonError to NSError for MoPub error handling callback
 */
- (NSError *)convertAmazonErrorToError:(AmazonAdError *)error
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(error.errorDescription, nil)};
    return [NSError errorWithDomain:kAMADomain code:error.errorCode userInfo:userInfo];
}

/**
 * Sets the appropriate advanced options from the Custom Event Data info dictionary
 */
- (void)processCustomEvent:(NSDictionary *)info forOptions:(AmazonAdOptions *)options
{
    if ([info objectForKey:kAMAAppKey]) {
        NSString *appKey = [info objectForKey:kAMAAppKey];
        [[AmazonAdRegistration sharedRegistration] setAppKey:appKey];
    }
    if ([info objectForKey:kAMALoggingEnabled]) {
        BOOL loggingEnabled = [[info objectForKey:kAMALoggingEnabled] boolValue];
        [[AmazonAdRegistration sharedRegistration] setLogging:loggingEnabled];
    }
    if ([info objectForKey:kAMATestingEnabled]) {
        options.isTestRequest = [[info objectForKey:kAMATestingEnabled] boolValue];
    }
    if ([info objectForKey:kAMAGeolocationEnabled]) {
        bool geolocationEnabled = [[info objectForKey:kAMAGeolocationEnabled] boolValue];
        [options setUsesGeoLocation:geolocationEnabled];
    }
    if ([info objectForKey:kAMAAdvancedOptionsKey]) {
        NSDictionary *advancedOptions = [info objectForKey:kAMAAdvancedOptionsKey];
        for (id optionKey in advancedOptions) {
            [options setAdvancedOption:[advancedOptions objectForKey:optionKey] forKey:optionKey];
        }
    }
}

@end
