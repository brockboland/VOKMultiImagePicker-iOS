//
//  VOKMultiImagePickerExampleDataSource.h
//  VOKMultiImagePicker-iOS
//
//  Created by Luke Quigley on 12/10/14.
//  Copyright (c) 2014 VOKAL LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOKMultiImagePickerExampleDataSource;

NS_ENUM(NSInteger, VOKMultiImagePickerExampleDataSourceRow) {
    VOKMultiImagePickerExampleDataSourceRowPhotos,
    VOKMultiImagePickerExampleDataSourceRowVideos,
    VOKMultiImagePickerExampleDataSourceRowBoth,
    VOKMultiImagePickerExampleDataSourceRowPhotosInCameraRoll,
    VOKMultiImagePickerExampleDataSourceRowVideosInCameraRoll,
    
    VOKMultiImagePickerExampleDataSourceRowCount
};

@protocol VOKMultiImagePickerExampleDataSourceDelegate <NSObject>

- (void)dataSource:(VOKMultiImagePickerExampleDataSource *)dataSource selectedRow:(NSInteger)row;

@end

@interface VOKMultiImagePickerExampleDataSource : NSObject

@property (nonatomic, weak) id<VOKMultiImagePickerExampleDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
