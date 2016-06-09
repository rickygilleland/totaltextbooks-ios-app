// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AmazonBannerCustomEvent.h"
#import <AmazonAd/AmazonAdView.h>
#import <AmazonAd/AmazonAdError.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import "MPLogging.h"

/**
 * AmazonBannerCustomEvent extends MoPub's MPBannerCustomEvent class
 * to allow developers to easily display Amazon Banner Ads through the MoPub SDK.
 */
@interface AmazonBannerCustomEvent () <AmazonAdViewDelegate>

/**
 * Amazon Banner Ad
 */
@property (nonatomic) AmazonAdView *adView;

@end

@implementation AmazonBannerCustomEvent

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

// MPBannerCustomEventDelegate
@dynamic delegate;

# pragma mark - MPBannerCustomEvent
/**
 * Called by MoPub to load a banner ad
 */
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    NSData *pkData = [NSJSONSerialization dataWithJSONObject:@[kAMAVersion]
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
    NSString *pkString = [[NSString alloc] initWithData:pkData encoding:NSUTF8StringEncoding];
    AmazonAdOptions *options = [AmazonAdOptions options];
    [options setAdvancedOption:pkString forKey:kAMAPublisherKey];
    [options setAdvancedOption:kAMASlotName forKey:kAMASlotKey];
    [self processCustomEvent:info forOptions:options];
   
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    if ([self isAmazonAdSize:size]) {
        self.adView = [AmazonAdView amazonAdViewWithAdSize:size];
    } else {
        self.adView = [[AmazonAdView alloc] initWithFrame:rect];
    }
    self.adView.delegate = self;
    [self.adView setVerticalAlignment:AmazonAdVerticalAlignmentCenter];
    [self.adView setHorizontalAlignment:AmazonAdHorizontalAlignmentCenter];
    [self.adView loadAd:options];
}

#pragma mark - AmazonAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adViewDidLoad:(AmazonAdView *)view
{
    MPLogInfo(@"Amazon Banner Ad Loaded");
    [self.delegate bannerCustomEvent:self didLoadAd:view];
}

- (void)adViewDidFailToLoad:(AmazonAdView *)view withError:(AmazonAdError *)error
{
    MPLogInfo(@"Amazon Banner Ad Failed to Load: %@", error.errorDescription);
    [self.delegate bannerCustomEvent:self
            didFailToLoadAdWithError:[self convertAmazonErrorToError:error]];
}

- (void)adViewDidCollapse:(AmazonAdView *)view
{
    MPLogInfo(@"Amazon Banner Ad view did collapse");
}

- (void)adViewWillExpand:(AmazonAdView *)view
{
    MPLogInfo(@"Amazon Banner Ad view will expand");
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
 * Returns YES if the given size is a standard Amazon Ad size
 */
- (BOOL)isAmazonAdSize:(CGSize)size
{
    return ( CGSizeEqualToSize(size, AmazonAdSize_320x50)
          || CGSizeEqualToSize(size, AmazonAdSize_300x250)
          || CGSizeEqualToSize(size, AmazonAdSize_728x90)
          || CGSizeEqualToSize(size, AmazonAdSize_1024x50));
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
