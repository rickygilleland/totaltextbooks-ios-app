// Copyright 2012-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CardViewController.h"
#import "adCell.h"
#import "newsFeedCell.h"
#import <AmazonAd/AmazonAdView.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>

#define adTag 1234
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface CardViewController ()

@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) NSMutableArray *infScroll;
@property (strong, nonatomic) NSMutableArray *adArray;
@property (strong, nonatomic) AmazonAdView *amazonAdView;
@property (strong, nonatomic) AmazonAdOptions *option;
@property (nonatomic) CGSize adSize;

@end

@implementation CardViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor clearColor];
    self.pullToRefreshManager = [[PullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    
    self.infScroll = [[NSMutableArray alloc] init];
    self.photoArray = [[NSMutableArray alloc] init];
    
    // Photo array
    for (int i = 1; i <= 13; i++)
        [self.photoArray insertObject:[NSString stringWithFormat:@"%d", i] atIndex:i-1];
    
    if (IDIOM == IPAD) {
        self.adSize = AmazonAdSize_728x90;
    } else {
        self.adSize = AmazonAdSize_320x50;
    }
    
    // Ad options
    self.option = [AmazonAdOptions options];
    self.option.isTestRequest = YES;
    
    // Initialize adArray of size 3
    self.adArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++) {
        self.amazonAdView = [AmazonAdView amazonAdViewWithAdSize:self.adSize];

        self.amazonAdView.tag = adTag;
        self.amazonAdView.delegate = self;
        [self.amazonAdView loadAd:self.option];
        [self.adArray insertObject:self.amazonAdView atIndex:i];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(void)loadData
{
    for (int j = 0; j < 2; j ++) {
        for (int i = 0; i < 2; i++) {
            [self.infScroll insertObject:@"custom" atIndex:self.infScroll.count];
        }
        [self.infScroll insertObject:@"ad" atIndex:self.infScroll.count];
        for (int i = 0; i < 2; i++) {
            [self.infScroll insertObject:@"custom" atIndex:self.infScroll.count];
        }
    }
    
    [self.tableView reloadData];

    [self.pullToRefreshManager tableViewReloadFinished];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.infScroll[indexPath.row] isEqualToString:@"ad"]) {
        if (IDIOM == IPAD) {
            return 120;
        }
        return 85;
    }
    return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infScroll.count;
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do Nothing
}

// The adArray of size will hold 3 ads
// Table will display adArray[1]
// Ads in adArray will be shifted accordingly when user scroll up or down
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[AdCell class]]) {
        AdCell *currCell = (AdCell *)cell;
        [[currCell viewWithTag:adTag] removeFromSuperview];
        
        NSArray *visibleCells = [self.tableView visibleCells];
        
        UITableViewCell *topCell = visibleCells[0];
        NSIndexPath *pathOfTheCell = [tableView indexPathForCell:topCell];
        NSInteger topRow = [pathOfTheCell row];
        
        UITableViewCell *bottomCell = visibleCells[visibleCells.count - 1];
        pathOfTheCell = [tableView indexPathForCell:bottomCell];
        NSInteger bottomRow = [pathOfTheCell row];
        
        if (indexPath.row <= topRow) {
            // Scroll down
            self.adArray[0] = self.adArray[1];
            self.adArray[1] = self.adArray[2];
            // Request new ad
            self.amazonAdView = [AmazonAdView amazonAdViewWithAdSize:self.adSize];
            self.amazonAdView.tag = adTag;
            self.amazonAdView.delegate = self;
            [self.amazonAdView loadAd:self.option];
            self.adArray[2] = self.amazonAdView;
        } else if (indexPath.row >= bottomRow) {
            // Scroll up
            self.adArray[2] = self.adArray[1];
            self.adArray[1] = self.adArray[0];
            // Request new ad
            self.amazonAdView = [AmazonAdView amazonAdViewWithAdSize:self.adSize];
            self.amazonAdView.tag = adTag;
            self.amazonAdView.delegate = self;
            [self.amazonAdView loadAd:self.option];
            self.adArray[0] = self.amazonAdView;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.infScroll[indexPath.row] isEqualToString:@"ad"]) {
        // Ad cell
        NSString *reuseIdentifier = @"adIPhone";
        if (IDIOM == IPAD) {
            reuseIdentifier = @"adIPad";
        }
        
        AdCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if (IDIOM == IPAD)
            ((AmazonAdView *)self.adArray[1]).frame = CGRectMake((self.view.bounds.size.width - self.adSize.width)/2.0, (120-self.adSize.height)/2, self.adSize.width, self.adSize.height);
        else
            ((AmazonAdView *)self.adArray[1]).frame = CGRectMake((self.view.bounds.size.width - self.adSize.width)/2.0, (85-self.adSize.height)/2, self.adSize.width, self.adSize.height);
        
        [cell addSubview:self.adArray[1]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else {
        // Custom cell
        NewsFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"newsFeedCell"];
        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Random text
        cell.cardContent.text = @"Examine she brother prudent add day ham. Far stairs now coming bed oppose hunted become his. You zealously departure had procuring suspicion. Books whose front would purse if be do decay.";
        cell.cardTitle.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];;
        cell.pic.image = [UIImage imageNamed:[self.photoArray objectAtIndex:[self getRandomNumberBetween:0 to:12]]];
        return cell;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.pullToRefreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.pullToRefreshManager tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(PullToRefreshManager *)manager {
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0f];
}

#pragma mark AmazonAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoad:(AmazonAdView *)view
{
    NSLog(@"Ad loaded");
}

- (void)adViewDidFailToLoad:(AmazonAdView *)view withError:(AmazonAdError *)error
{
//    [self.amazonAdView loadAd:self.option];
    NSLog(@"Ad Failed to load. Error code %d: %@", error.errorCode, error.errorDescription);
}

- (void)adViewWillExpand:(AmazonAdView *)view
{
    NSLog(@"Ad will expand");
}

- (void)adViewDidCollapse:(AmazonAdView *)view
{
    NSLog(@"Ad has collapsed");
}

@end
