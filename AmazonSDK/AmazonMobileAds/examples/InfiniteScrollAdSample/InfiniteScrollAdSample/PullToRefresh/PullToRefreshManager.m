// Copyright 2012-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PullToRefreshManager.h"
#import "PullToRefreshView.h"

CGFloat const kAnimationDuration = 0.2f;

@interface PullToRefreshManager()

@property (nonatomic, strong) PullToRefreshView *pullToRefreshView;
@property (nonatomic, weak) UITableView *table;
@property (nonatomic, weak) id<PullToRefreshManagerClient> client;

@end

@implementation PullToRefreshManager

- (id)initWithPullToRefreshViewHeight:(CGFloat)height tableView:(UITableView *)table withClient:(id<PullToRefreshManagerClient>)client {

    if (self = [super init]) {
        self.client = client;
        self.table = table;        
        self.pullToRefreshView = [[PullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([self.table frame]), height)];
    }
    
    return self;
}

- (CGFloat)tableScrollOffset {
    
    CGFloat offset = self.table.contentSize.height - self.table.contentOffset.y - self.table.frame.size.height;
    
    return offset;
}

- (void)relocatePullToRefreshView {
    
    CGFloat yOrigin = self.table.contentSize.height;
    
    CGRect frame = [self.pullToRefreshView frame];
    frame.origin.y = yOrigin;
    [self.pullToRefreshView setFrame:frame];
    
    [self.table addSubview:self.pullToRefreshView];
}

- (void)setPullToRefreshViewVisible:(BOOL)visible {
    
    [self.pullToRefreshView setHidden:!visible];
}

- (void)tableViewScrolled {
    
    if (![self.pullToRefreshView isHidden] && ![self.pullToRefreshView isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];

        if (offset >= 0.0f) {
            
            [self.pullToRefreshView changeStateOfControl:PullToRefreshStateIdle offset:offset];
            
        } else if (offset <= 0.0f && offset >= -[self.pullToRefreshView fixedHeight]) {
                
            [self.pullToRefreshView changeStateOfControl:PullToRefreshStatePull offset:offset];
            
        } else {
            
            [self.pullToRefreshView changeStateOfControl:PullToRefreshStateRelease offset:offset];
        }
    }
}

- (void)tableViewReleased {
    
    if (![self.pullToRefreshView isHidden] && ![self.pullToRefreshView isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];
        CGFloat height = -[self.pullToRefreshView fixedHeight];
        
        if (offset <= 0.0f && offset < height) {
            
            [self.client bottomPullToRefreshTriggered:self];
            
            [self.pullToRefreshView changeStateOfControl:PullToRefreshStateLoading offset:offset];
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                if (self.table.contentSize.height >= self.table.frame.size.height)
                    [self.table setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f)];
            }];
        }
    }
}

- (void)tableViewReloadFinished {
    
    [self.table setContentInset:UIEdgeInsetsZero];

    [self relocatePullToRefreshView];

    [self.pullToRefreshView changeStateOfControl:PullToRefreshStateIdle offset:CGFLOAT_MAX];
}

@end