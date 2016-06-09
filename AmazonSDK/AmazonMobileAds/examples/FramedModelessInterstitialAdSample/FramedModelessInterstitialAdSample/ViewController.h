// Copyright 2012-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *adContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UILabel *loadStatusLabel;

- (IBAction)loadModelessInterstitial:(id)sender;
- (IBAction)showModelessInterstitial:(id)sender;
- (IBAction)closeModelessInterstitial:(id)sender;

@end

