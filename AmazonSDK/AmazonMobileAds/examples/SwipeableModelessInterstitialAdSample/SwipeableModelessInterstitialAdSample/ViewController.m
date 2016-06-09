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

@interface ViewController () <UIScrollViewDelegate, UIContentContainer, AmazonAdModelessInterstitialDelegate>

@property (nonatomic) AmazonAdModelessInterstitial *modelessInterstitial;
@property (nonatomic) UIView *interstitialPageView;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSInteger interstitialIndex;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger swipes;
@property (nonatomic) BOOL isPageViewsLoaded;

@end

@implementation ViewController

// A new modeless interstitial is loaded approximately every 5 swipes
const NSInteger kInterstitialReloadFrequency = 5;

const CGFloat kDesiredNavBarHeight = 54.0;
const CGFloat kDesiredToolBarHeight = 44.0;

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load all the images
    self.pages = [NSMutableArray array];
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    for (NSString *filePath in paths) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.opaque = YES;
        [self.pages addObject:imageView];
    }
    
    self.interstitialIndex = -1;
    self.pageIndex = 0;
    self.swipes = 0;
    
    // Load the modeless interstitial
    [self loadModelessInterstitial];
}

- (void)viewDidLayoutSubviews
{
    [self layout];
}

#pragma mark - Public

- (IBAction)previousImage:(id)sender
{
    if (self.pageIndex > 0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * (self.pageIndex - 1), 0.0);
                         }
                         completion:^(BOOL finished) {
                             [self updateScrollView];
                         }];
    }
}

- (IBAction)nextImage:(id)sender
{
    if (self.pageIndex < self.pages.count - 1) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * (self.pageIndex + 1), 0.0);
                         }
                         completion:^(BOOL finished) {
                             [self updateScrollView];
                         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)layout
{
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    CGFloat pageHeight = self.scrollView.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(pageWidth * self.pages.count, pageHeight);
    self.scrollView.contentOffset = CGPointMake(pageWidth * self.pageIndex, 0.0);
    
    [self.pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *pageView = self.pages[idx];
        pageView.frame = CGRectMake(pageWidth * idx, 0.0, pageWidth, pageHeight);
        [self.scrollView addSubview:pageView];
    }];
    
    if (self.pageIndex == self.interstitialIndex) {
        [self.modelessInterstitial onPresented];
    }
    
    [self updateToolBarItems];
}

- (void)updateToolBarItems
{
    if (self.pageIndex == 0) {
        self.previous.enabled = NO;
    } else if (self.pageIndex == self.pages.count - 1) {
        self.next.enabled = NO;
    } else {
        self.previous.enabled = YES;
        self.next.enabled = YES;
    }
}

- (void)updateScrollView
{
    // Infer the desired page from the new contentOffset.
    NSInteger tmpIndex = trunc(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
    BOOL refreshInterstitial = false;
    
    if (tmpIndex != self.pageIndex) {
        
        // If we are moving the modeless interstitial off the screen, call onHidden
        if (self.pageIndex == self.interstitialIndex) {
            [self.modelessInterstitial onHidden];
        }

        // If we are moving the modeless interstitial onto the screen, call onPresented
        if (tmpIndex == self.interstitialIndex) {
            if (![self.modelessInterstitial onPresented]) {
                NSLog(@"Modeless interstitial failed to present");
            }
        } else if (self.swipes > 0 && self.swipes % kInterstitialReloadFrequency == 0) {
            refreshInterstitial = YES;
        }
    }

    self.pageIndex = tmpIndex;
    [self updateToolBarItems];

    if (refreshInterstitial) {
        [self removeInterstitial];
        [self loadModelessInterstitial];
    }

    self.swipes++;
}

- (void)loadModelessInterstitial
{
    // Create the interstitial page view
    if (!self.interstitialPageView) {
        self.interstitialPageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    }
    
    // Create the modeless interstitial object
    if (!self.modelessInterstitial) {
        self.modelessInterstitial = [AmazonAdModelessInterstitial modelessInterstitialWithContainerView:self.interstitialPageView];
        self.modelessInterstitial.delegate = self;
    }
    
    // Load a modeless interstitial ad
    AmazonAdOptions *options = [AmazonAdOptions options];
    options.isTestRequest = YES;
    [self.modelessInterstitial load:options];
}

- (void)insertInterstitialAtIndex:(NSInteger)index
{
    // When we insert the interstitial page, we also need to relayout
    
    self.interstitialIndex = index;
    [self.pages insertObject:self.interstitialPageView atIndex:self.interstitialIndex];
    if (self.interstitialIndex < self.pageIndex) {
        self.pageIndex++;
    }
    [self layout];
}

- (void)removeInterstitial
{
    // When we remove the interstitial page, we also need to relayout
    
    [self.pages removeObject:self.interstitialPageView];
    if ((self.interstitialIndex != -1) && (self.interstitialIndex < self.pageIndex)) {
        self.pageIndex--;
    }
    self.interstitialIndex = -1;
    [self layout];
}

#pragma mark - AmazonAdModelessInterstitialDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)modelessInterstitialDidLoad:(AmazonAdModelessInterstitial *)interstitial
{
    // The modeless interstitial has been loaded
    // Insert it a couple of pages apart from the page currently on screen
    
    if (self.interstitialIndex == -1) {
        NSInteger index = self.pageIndex + 2;
        if (index > self.pages.count - 1) {
            index = index - (self.pages.count - 1);
        }
        
        [self insertInterstitialAtIndex:index];
    }
}

- (void)modelessInterstitialDidFailToLoad:(AmazonAdModelessInterstitial *)interstitial withError:(AmazonAdError *)error
{
    NSLog(@"Modeless interstitial failed to load: %@", error.errorDescription);
}

- (void)modelessInterstitialDidExpire:(AmazonAdModelessInterstitial *)interstitial
{
    NSLog(@"Modeless interstitial has expired");
}

#pragma mark - UIContentContainer
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.navBarHeightConstraint.constant = kDesiredNavBarHeight;
    self.toolbarHeightConstraint.constant = kDesiredToolBarHeight;
    self.navBar.hidden = NO;
    self.toolbar.hidden = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenAspectRatio = screenWidth < screenHeight ? (screenWidth / screenHeight) : (screenHeight / screenWidth);
    
    // If placing the navigation bar and the tool bar on the scree after a device orientation change
    // causes the scroll view to be less than the screen aspect ratio, hide them
    
    CGFloat height =  size.height - kDesiredNavBarHeight - kDesiredToolBarHeight;
    if ((height < size.width) && (height / size.width < screenAspectRatio)) {
        self.navBarHeightConstraint.constant = 0.0;
        self.navBar.hidden = YES;
        self.toolbarHeightConstraint.constant = 0.0;
        self.toolbar.hidden = YES;
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateScrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    [self updateScrollView];
}

@end
