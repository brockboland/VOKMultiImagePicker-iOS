//
//  VOKMultiImagePicker.m
//  VOKMultiImagePicker
//
//  Created by Luke Quigley on 12/8/14.
//  Copyright (c) 2014 VOKAL LLC. All rights reserved.
//

#import "VOKMultiImagePicker.h"

#import "NSBundle+VOK.h"
#import "NSString+VOK.h"
#import "PHFetchResult+VOK.h"
#import "UIImage+VOK.h"
#import "VOKAssetCollectionsViewController.h"
#import "VOKAssetCollectionViewCell.h"
#import "VOKAssetsViewController.h"
#import "VOKMultiImagePickerConstants.h"
#import "VOKSelectedAssetManager.h"

@interface VOKMultiImagePicker ()

@property (nonatomic) UIView *containerView;

@end

@implementation VOKMultiImagePicker

static CGFloat const VOKMultiImagePickerAddItemsButtonHeight = 60.0f;

- (instancetype)init
{
    if (self = [super init]) {
        [[VOKSelectedAssetManager sharedManager] resetManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:VOKMultiImagePickerNotifications.assetsChanged
                                               object:nil];
}

- (void)setupView
{
    //Setup container view.
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  CGRectGetWidth(self.view.frame),
                                                                  CGRectGetHeight(self.view.frame) - VOKMultiImagePickerAddItemsButtonHeight)];
    [self.view addSubview:self.containerView];
    
    //Setup add items button.
    self.addItemsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addItemsButton addTarget:self action:@selector(doneSelectingAssets) forControlEvents:UIControlEventTouchUpInside];
    self.addItemsButton.frame = CGRectMake(0.0f,
                                           CGRectGetMaxY(self.containerView.frame),
                                           CGRectGetWidth(self.view.frame),
                                           VOKMultiImagePickerAddItemsButtonHeight);
    
    CGSize imageSize = CGSizeMake(CGRectGetWidth(self.addItemsButton.frame), VOKMultiImagePickerAddItemsButtonHeight);
    UIImage *enabledImage = [UIImage vok_imageOfColor:[UIColor greenColor] size:imageSize];
    UIImage *disabledImage = [UIImage vok_imageOfColor:[UIColor lightGrayColor] size:imageSize];
    
    [self.addItemsButton setBackgroundImage:enabledImage forState:UIControlStateNormal];
    [self.addItemsButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    [self.addItemsButton setTitle:[NSString vok_addItems] forState:UIControlStateNormal];
    [self.view addSubview:self.addItemsButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.addItemsButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addItemsButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addItemsButton
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addItemsButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:VOKMultiImagePickerAddItemsButtonHeight]];
    
    UINavigationController *containerNavigationController = [[UINavigationController alloc] init];
    containerNavigationController.view.frame = self.containerView.bounds;
    
    [self addChildViewController:containerNavigationController];
    [self.containerView addSubview:containerNavigationController.view];
    [containerNavigationController didMoveToParentViewController:self];
    
    VOKAssetCollectionsViewController *albumViewController = [[VOKAssetCollectionsViewController alloc] init];
    
    switch (self.startPosition) {
        case VOKMultiImagePickerStartPositionAlbums:
            containerNavigationController.viewControllers = @[albumViewController];
            break;
        case VOKMultiImagePickerStartPositionCameraRoll: {
            PHFetchResult *fetchResult = [PHFetchResult vok_fetchResultWithAssetsOfType:self.mediaType];
            VOKAssetsViewController *cameraRollViewController = [[VOKAssetsViewController alloc] initWithFetchResult:fetchResult];
            cameraRollViewController.title = [NSString vok_cameraRoll];
            containerNavigationController.viewControllers = @[albumViewController, cameraRollViewController];
            break;
        }
    }
    
    [self updateAddItemsButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationReceived:(NSNotification *)notification
{
    [self updateAddItemsButton];
}

- (void)updateAddItemsButton
{
    NSArray *selectedAssetsArray = [[VOKSelectedAssetManager sharedManager] selectedAssets];
    NSInteger assetCount = selectedAssetsArray.count;
    if (assetCount) {
        self.addItemsButton.enabled = YES;
        
        NSString *titleString;
        if (assetCount == 1) {
            titleString = [NSString vok_addOneItem];
        } else {
            titleString = [NSString stringWithFormat:[NSString vok_addXItemsFormat], @(assetCount)];
        }
        [self.addItemsButton setTitle:titleString forState:UIControlStateNormal];
    } else {
        self.addItemsButton.enabled = NO;
        [self.addItemsButton setTitle:[NSString vok_addItems] forState:UIControlStateNormal];
    }
}

#pragma mark - Values passed to the manager.

- (void)setMediaType:(PHAssetMediaType)mediaType
{
    _mediaType = mediaType;
    
    [VOKSelectedAssetManager sharedManager].mediaType = mediaType;
}

- (void)setAssetCollectionViewCellClass:(Class)assetCollectionViewCellClass
{
    if ([assetCollectionViewCellClass isSubclassOfClass:[VOKAssetCollectionViewCell class]]) {
        _assetCollectionViewCellClass = assetCollectionViewCellClass;
        
        [VOKSelectedAssetManager sharedManager].assetCollectionViewCellClass = assetCollectionViewCellClass;
    } else {
        NSAssert(NO, @"You must use a subclass of VOKAssetCollectionViewCell.");
    }
}

- (void)setAssetCollectionViewColumnCount:(NSInteger)assetCollectionViewColumnCount
{
    _assetCollectionViewColumnCount = assetCollectionViewColumnCount;
    
    [VOKSelectedAssetManager sharedManager].assetCollectionViewColumnCount = assetCollectionViewColumnCount;
}

#pragma mark - Actions

- (IBAction)doneSelectingAssets
{
    [self.imageDelegate multiImagePicker:self selectedAssets:[[VOKSelectedAssetManager sharedManager] selectedAssets]];
    [self dismissViewControllerAnimated:YES completion:^{
        [[VOKSelectedAssetManager sharedManager] resetManager];
    }];
}

@end
