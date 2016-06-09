// Copyright 2012-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PullToRefreshView.h"

@interface PullToRefreshView()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;
@property (nonatomic, readwrite, strong) UILabel *messageLabel;
@property (nonatomic, readwrite, assign) PullToRefreshState state;
@property (nonatomic, readwrite, assign) BOOL rotateIconWhileBecomingVisible;

@end

@implementation PullToRefreshView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.containerView.backgroundColor = [UIColor clearColor];

        [self addSubview:self.containerView];
        
        UIImage *iconImage = [UIImage imageNamed:@"PullToRefreshArrow.png"];
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, frame.size.height/2.0 - iconImage.size.height/2.0, iconImage.size.width, iconImage.size.height)];
        
        self.iconImageView.contentMode = UIViewContentModeCenter;
        self.iconImageView.image = iconImage;
        
        [self.containerView addSubview:self.iconImageView];
        
        self.loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.loadingActivityIndicator.center = self.iconImageView.center;
        self.loadingActivityIndicator.hidesWhenStopped = YES;
        
        [self.containerView addSubview:self.loadingActivityIndicator];
        
        CGFloat topMargin = 10.0f;
        CGFloat gap = 20.0f;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + gap, topMargin, frame.size.width - CGRectGetMaxX(self.iconImageView.frame) - gap * 2.0f, frame.size.height - topMargin * 2.0f)];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        [self.containerView addSubview:self.messageLabel];
        
        self.fixedHeight = frame.size.height;
        self.rotateIconWhileBecomingVisible = YES;
        
        [self changeStateOfControl:PullToRefreshStateIdle offset:CGFLOAT_MAX];
    }
    
    return self;
}

- (void)layoutSubviews {    
    [super layoutSubviews];
}

- (void)changeStateOfControl:(PullToRefreshState)state offset:(CGFloat)offset {
    
    self.state = state;
    
    CGFloat height = self.fixedHeight;
    
    switch (self.state) {
        
        case PullToRefreshStateIdle: {
            self.iconImageView.transform = CGAffineTransformIdentity;
            self.iconImageView.hidden = NO;
            
            [self.loadingActivityIndicator stopAnimating];

            self.messageLabel.text = @"Pull for more";
            
            break;
            
        } case PullToRefreshStatePull: {
            
            if (self.rotateIconWhileBecomingVisible) {
                CGFloat angle = (-offset * M_PI) / CGRectGetHeight([self frame]);
                self.iconImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
            } else {
                self.iconImageView.transform = CGAffineTransformIdentity;
            }
            
            self.messageLabel.text = @"Pull for more";
            
            break;
            
        } case PullToRefreshStateRelease: {
            self.iconImageView.transform=CGAffineTransformMakeRotation(M_PI);
            
            self.messageLabel.text = @"Release";
            
            height = self.fixedHeight + fabs(offset);
            
            break;
            
        } case PullToRefreshStateLoading: {
            
            self.iconImageView.hidden = YES;
            
            [self.loadingActivityIndicator startAnimating];
            
            self.messageLabel.text = @"Loading";
            
            height = self.fixedHeight + fabs(offset);
            
            break;
            
        } default:
            break;
    }
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (BOOL)isLoading {
    return [self.loadingActivityIndicator isAnimating];
}

@end
