//
//  YTContentDetailViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTContentDetailViewController : UIViewController<YTSelectedItemProtocol>
@property (nonatomic,assign)int contentID;
@property (weak,nonatomic)IBOutlet UIScrollView *scrollView;

@end
