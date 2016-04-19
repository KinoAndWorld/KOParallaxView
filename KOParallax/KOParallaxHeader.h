//
//  KOParallaxHeader.h
//  KOParallaxView
//
//  Created by kino on 15/9/4.
//
//

#import <UIKit/UIKit.h>

@class KOParallaxView;

@interface KOParallaxHeader : UIView

@property (assign, nonatomic) CGFloat parallaxDeltaFactor;              //default is 0.5
@property (strong, nonatomic, readonly) KOParallaxView *imageListView;
@property (copy, nonatomic) void(^whenScrollViewFrameChanged)(CGRect scrollNewFrame, CGFloat delta);
@property (copy, nonatomic) UIView *(^parallaxContentViewLoadBlock)(NSUInteger index);

@property (copy, nonatomic) void(^didSelectItemPage)(NSUInteger page);

- (instancetype)initWithFrame:(CGRect)frame
           forScorllContainer:(UIScrollView *)container;

- (instancetype)initWithFrame:(CGRect)frame
           forScorllContainer:(UIScrollView *)container
    openContentParallaxEffect:(BOOL)parallaxEffect;

- (instancetype)initWithContentView:(UIView *)contentView;

@end
