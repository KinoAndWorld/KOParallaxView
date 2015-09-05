//
//  KOParallaxContentView.h
//  KOParallaxView
//
//  Created by kino on 15/9/3.
//
//

#import <UIKit/UIKit.h>

@interface KOParallaxContentView : UIView

@property (assign ,nonatomic) BOOL openParallaxEffect;

@property (assign, nonatomic) CGFloat maxParallaxOffset;    //default is 100.f

@property (strong, nonatomic) UIImage *displayImage;

@property (assign, nonatomic) CGFloat parallaxProgress;     //value in -1.0 ~ 1.0

@property (assign, nonatomic) NSUInteger pageIndex;

- (void)shiftImageViewFrameByDelta:(CGFloat)delta;

@end
