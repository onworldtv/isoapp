//
//  YTGirdItemCell.m
//  OnWorld
//
//  Created by yestech1 on 6/26/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTGirdItemCell.h"

@implementation YTGirdItemCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"YTGirdItemCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor blueColor].CGColor;
        
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}
@end
