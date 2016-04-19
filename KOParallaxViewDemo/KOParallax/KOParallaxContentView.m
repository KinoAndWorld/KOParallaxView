//
//  KOParallaxContentView.m
//  KOParallaxView
//
//  Created by kino on 15/9/3.
//
//

#import "KOParallaxContentView.h"

@interface KOParallaxContentView()

@property (strong, nonatomic) UIImageView *displayImageView;

@property (assign, nonatomic) CGRect baseFrame;

@end

@implementation KOParallaxContentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.baseFrame = frame;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _maxParallaxOffset = 120.f;
    
    self.clipsToBounds = YES;
    
    [self addSubview:self.displayImageView];
}

#pragma mark - Layout

- (void)layoutSubviews{
    [super layoutSubviews];
//    if (_openParallaxEffect) {
//        self.displayImageView.frame = CGRectInset(self.bounds, -_maxParallaxOffset, 0);
//    }else{
//        self.displayImageView.frame = self.bounds;
//    }
}

- (void)shiftImageViewFrameByDelta:(CGFloat)delta{
    CGRect oriFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                 self.baseFrame.size.width, self.baseFrame.size.height);
    oriFrame.size.height += delta;
    self.frame = oriFrame;
    
    if (_openParallaxEffect) {
        self.displayImageView.frame = CGRectInset(self.bounds, -_maxParallaxOffset - delta, 0);
    }else{
        self.displayImageView.frame = self.bounds;
    }
}

#pragma mark - Setter

- (void)setDisplayImage:(UIImage *)displayImage{
    if (displayImage) {
        _displayImage = displayImage;
        self.displayImageView.image = displayImage;
    }
}

- (void)setOpenParallaxEffect:(BOOL)openParallaxEffect{
    _openParallaxEffect = openParallaxEffect;
    if (_openParallaxEffect) {
        self.displayImageView.frame = CGRectInset(self.bounds, -_maxParallaxOffset, 0);
    }else{
        self.displayImageView.frame = self.bounds;
    }
}

- (void)setParallaxProgress:(CGFloat)parallaxProgress{
//    if (!_openParallaxEffect) return;
    _parallaxProgress = parallaxProgress;
    CGRect frame = self.displayImageView.frame;
    
    frame.origin.x = -_maxParallaxOffset + parallaxProgress * _maxParallaxOffset;
    self.displayImageView.frame = frame;
}

#pragma mark - Getter

- (UIImageView *)displayImageView{
    if (!_displayImageView) {
        _displayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _displayImageView.contentMode = UIViewContentModeScaleAspectFill;
        _displayImageView.clipsToBounds = YES;
    }
    return _displayImageView;
}

@end
