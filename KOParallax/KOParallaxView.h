//
//  KOParallaxView.h
//  KOParallaxView
//
//  Created by kino on 15/9/2.
//
//

#import <UIKit/UIKit.h>
#import "KOParallaxConst.h"

@interface KOParallaxView : UIView

@property (strong, nonatomic, readonly) UIScrollView *containerView;

@property (strong, nonatomic) NSMutableArray *displayImages;
@property (assign, nonatomic, readonly) NSInteger currentItemPage;

@property (assign, nonatomic) BOOL openParallaxEffect;

@property (assign, nonatomic, getter = isPagingEnabled) BOOL pagingEnabled;
@property (assign, nonatomic, getter = isScrollEnabled) BOOL scrollEnabled;
@property (assign, nonatomic, readonly) KOParallaxState state;

- (instancetype)initWithFrame:(CGRect)frame
         isOpenParallaxEffect:(BOOL)openParallaxEffect;

- (void)shiftCenterContentViewByDeltaValue:(CGFloat)delta;

- (void)updateImageAtPage:(NSUInteger)page newImage:(UIImage *)image;

@end
