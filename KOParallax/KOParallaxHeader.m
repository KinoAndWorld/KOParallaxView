//
//  KOParallaxHeader.m
//  KOParallaxView
//
//  Created by kino on 15/9/4.
//
//

#import "KOParallaxHeader.h"

#import "KOParallaxView.h"

@interface KOParallaxHeader()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (unsafe_unretained, nonatomic) UIScrollView *outsideContainerView;

@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGPoint currentOffset;

@property (strong, nonatomic) UITapGestureRecognizer *tapContentViewGesture;


@end

@implementation KOParallaxHeader

- (instancetype)initWithFrame:(CGRect)frame
           forScorllContainer:(UIScrollView *)container{
    return [self initWithFrame:frame forScorllContainer:container openContentParallaxEffect:NO];
}

- (instancetype)initWithFrame:(CGRect)frame
           forScorllContainer:(UIScrollView *)container
    openContentParallaxEffect:(BOOL)parallaxEffect{
    if (self = [super initWithFrame:frame]) {
        _outsideContainerView = container;
        _contentView = [[KOParallaxView alloc] initWithFrame:self.bounds
                                        isOpenParallaxEffect:parallaxEffect];
        [self commonInit];
        
        [self addObserverForScrollElement];
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView{
    if (self = [super initWithFrame:contentView.bounds]) {
        _contentView = contentView;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _parallaxDeltaFactor = 0.5f;
    
    [self addSubview:self.contentScrollView];
    
    if (_contentView) {
        [self.contentScrollView addSubview:_contentView];
    }
}

#pragma mark - Observer

- (void)addObserverForScrollElement{
    [self.outsideContainerView addObserver:self forKeyPath:@"contentOffset"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    if ([self.contentView isKindOfClass:[KOParallaxView class]]) {
        [self.contentView addObserver:self forKeyPath:@"state"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
        
        self.tapContentViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(touchContentView:)];
        [self.contentView addGestureRecognizer:_tapContentViewGesture];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGPoint newOffset = [newValue CGPointValue];
        CGFloat delta = [self shiftViewWhenOffsetChanged:newOffset];
        if ([_contentView isKindOfClass:[KOParallaxView class]]) {
            [((KOParallaxView *)_contentView) shiftCenterContentViewByDeltaValue:delta];
        }
    }else if ([keyPath isEqualToString:@"state"]) {
        if ([_contentView isKindOfClass:[KOParallaxView class]]) {
            NSNumber *newValue = change[NSKeyValueChangeNewKey];
            self.outsideContainerView.scrollEnabled = ([newValue unsignedIntegerValue] == KOParallaxStateNormal);
        }
    }
}

- (void)dealloc{
    [self.outsideContainerView removeObserver:self forKeyPath:@"contentOffset"];
    if ([self.contentView isKindOfClass:[KOParallaxView class]]) {
        [self.contentView removeObserver:self forKeyPath:@"state"];
        [self removeGestureRecognizer:_tapContentViewGesture];
    }
}

- (void)touchContentView:(UIGestureRecognizer *)gesture{
    if (gesture.view == _contentView) {
        if (((KOParallaxView *)_contentView).state == KOParallaxStateNormal) {
            if (self.didSelectItemPage && [_contentView isKindOfClass:[KOParallaxView class]]) {
                self.didSelectItemPage(((KOParallaxView *)_contentView).currentItemPage);
            }
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self shiftViewWhenOffsetChanged:_currentOffset];
}

- (CGFloat)shiftViewWhenOffsetChanged:(CGPoint)offset{
    CGRect frame = self.contentScrollView.frame;
    CGFloat delta = 0.0f;
    if (offset.y > 0){
        frame.origin.y = MAX(offset.y * _parallaxDeltaFactor, 0);
        self.contentScrollView.frame = frame;
        self.clipsToBounds = YES;
        self.contentView.frame = self.contentScrollView.bounds;
    }else{
        CGRect rect = self.bounds;
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        
//        NSLog(@"原本Frame :%@",NSStringFromCGRect(self.contentScrollView.frame));
        self.contentScrollView.frame = rect;
//        NSLog(@"变成Frame :%@",NSStringFromCGRect(self.contentScrollView.frame));
        self.clipsToBounds = NO;
        self.contentView.frame = self.contentScrollView.bounds;
    }
    if (self.whenScrollViewFrameChanged) {
        self.whenScrollViewFrameChanged(_contentScrollView.frame, delta);
    }
    self.currentOffset = offset;
    return delta;
}

#pragma mark - Getter

- (KOParallaxView *)imageListView{
    if ([self.contentView isKindOfClass:[KOParallaxView class]]) {
        return (KOParallaxView *)_contentView;
    }
    return nil;
}

- (UIScrollView *)contentScrollView{
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _contentScrollView;
}

@end
