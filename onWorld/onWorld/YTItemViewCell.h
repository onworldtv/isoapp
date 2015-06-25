//
//  YTItemViewCell.h
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTItemViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgItem;
@property (weak, nonatomic) IBOutlet UITextView *txtitemName;
@property (weak, nonatomic) IBOutlet UILabel *txtCategory;

@end
