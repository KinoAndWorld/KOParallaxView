//
//  KOParallaxView.m
//  KOParallaxView
//
//  Created by kino on 15/9/2.
//
//

#import "KOParallaxView.h"

#import "KOParallaxContentView.h"

NS_ENUM(NSUInteger, KOParallaxViewPosition){
    KOParallaxViewPositionLeft = 0,
    KOParallaxViewPositionCenter,
    KOParallaxViewPositionRight
};


@interface KOParallaxView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *containerView;
@property (strong, nonatomic) NSMutableArray *itemViewList;
@property (assign, nonatomic) enum KOParallaxViewPosition currentItemIndex;
@property (assign, nonatomic) NSInteger currentItemPage;

@property (assign, nonatomic) KOParallaxState state;
@property (assign, nonatomic) CGSize baseSize;

@property (strong, nonatomic) GCDTimer *timer;

@end

@implementation KOParallaxView

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame isOpenParallaxEffect:NO];
}

- (instancetype)initWithFrame:(CGRect)frame
         isOpenParallaxEffect:(BOOL)openParallaxEffect{
    if (self = [super initWithFrame:frame]) {
        _baseSize = frame.size;
        _openParallaxEffect = openParallaxEffect;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    _scrollEnabled = YES;
    _pagingEnabled = YES;
    _currentItemPage = 0;
    _autoScrollDuration = 5;
    
    [self addSubview:self.containerView];
    
    self.itemViewList = [NSMutableArray array];
}

- (void)reloadContentView{
    //clean up
    [self.itemViewList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *contentV = obj;
        [contentV removeFromSuperview];
    }];
    [self.itemViewList removeAllObjects];
    
    _currentItemPage = 0;
    
    //display 1张图的时候需要额外处理
    if (self.displayImages.count <= 1) {
        [self constructSinplePage];
    }else{
        [self constructContentView];
    }
    
    [self checkViewAutoScroll];
}

- (void)constructSinplePage{
    KOParallaxContentView *centerContentView = [self nextItemViewAtIndex:KOParallaxViewPositionLeft
                                                                  atPage:0];
    [self.itemViewList addObject:centerContentView];
    [self.containerView addSubview:centerContentView];
    
    self.containerView.contentSize = CGSizeMake(_itemViewList.count * self.itemWidth , self.itemHeight);
}

- (void)constructContentView{
    KOParallaxContentView *preContentView = [self nextItemViewAtIndex:KOParallaxViewPositionLeft
                                                               atPage:_displayImages.count-1];
    [self.itemViewList addObject:preContentView];
    [self.containerView addSubview:preContentView];
    
    KOParallaxContentView *centerContentView = [self nextItemViewAtIndex:KOParallaxViewPositionCenter
                                                                  atPage:0];
    [self.itemViewList addObject:centerContentView];
    [self.containerView addSubview:centerContentView];
    
    KOParallaxContentView *nextContentView = [self nextItemViewAtIndex:KOParallaxViewPositionRight
                                                                atPage:1];
    [self.itemViewList addObject:nextContentView];
    [self.containerView addSubview:nextContentView];
    
    self.containerView.contentSize = CGSizeMake(_itemViewList.count * self.itemWidth , self.itemHeight);
    self.currentItemIndex = KOParallaxViewPositionCenter;
    self.containerView.contentOffset = CGPointMake(_currentItemIndex * self.itemWidth, 0);
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    if (_openParallaxEffect) {
        [self handleParallaxWhenOffsetChanged:scrollView.contentOffset.x];
    }
    
    CGFloat imageWidth = CGRectGetWidth(self.frame);
    NSUInteger indexChanged = ceilf((scrollView.contentOffset.x - imageWidth/2.f) / imageWidth);
    if (indexChanged != _currentItemIndex) {
        if (indexChanged > _currentItemIndex) {
            _currentItemPage = [self nextItemPage];
        }else{
            _currentItemPage = [self preItemPage];
        }
        _currentItemIndex = indexChanged;
        [self cycleItemViewsWhenItemIndexChanged];
    }
    
//    NSLog(@"_currentItemIndex : %ld \n _currentItemPage : %ld",(long)_currentItemIndex,(long)_currentItemPage);
}

- (void)handleParallaxWhenOffsetChanged:(CGFloat)offsetX{
    
    [self.itemViewList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KOParallaxContentView *view = obj;
        CGFloat final = self.itemWidth * idx;
        CGFloat missing = final - offsetX;
        CGFloat parallaxProgress = missing / self.frame.size.width;
        /*if (idx == 1) {
            NSLog(@"The NO.%d View's ParallaxProgress %f",idx,parallaxProgress);
        }*/
        view.parallaxProgress = parallaxProgress;
    }];
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.state = KOParallaxStateScrolling;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.state = KOParallaxStateNormal;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.state = KOParallaxStateScrolling;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.state = KOParallaxStateNormal;
}


#pragma mark - Internal Method

- (void)cycleItemViewsWhenItemIndexChanged{
    if (_currentItemIndex == KOParallaxViewPositionRight) {
        /**
         * 滑动到尾页，向左调整位移 并动态加载下一页
         */
        KOParallaxContentView *leftImageV = self.itemViewList[0];
        [leftImageV removeFromSuperview];
        [self.itemViewList removeObjectAtIndex:0];
        
        KOParallaxContentView *createdView = [self nextItemViewAtIndex:KOParallaxViewPositionRight
                                                                atPage:[self nextItemPage]];
        [self.itemViewList addObject:createdView];
        [self.containerView addSubview:createdView];
        
        [self settleItemViewOrder];
        
        self.currentItemIndex = KOParallaxViewPositionCenter;
        self.containerView.contentOffset = CGPointMake(_containerView.contentOffset.x - self.itemWidth, 0);
    }else if (_currentItemIndex == KOParallaxViewPositionLeft){
        /**
         * 滑动到首页，向右调整位移 并动态加载前一页
         */
        KOParallaxContentView *rightImageV = [self.itemViewList lastObject];
        [rightImageV removeFromSuperview];
        [self.itemViewList removeObject:rightImageV];
        
        KOParallaxContentView *createdView = [self nextItemViewAtIndex:KOParallaxViewPositionLeft
                                                                atPage:[self preItemPage]];
        [self.itemViewList insertObject:createdView atIndex:0];
        [self.containerView addSubview:createdView];
        
        [self settleItemViewOrder];
        
        self.currentItemIndex = KOParallaxViewPositionCenter;
        self.containerView.contentOffset = CGPointMake(_containerView.contentOffset.x + self.itemWidth, 0);
    }
}

- (void)settleItemViewOrder{
    [self.itemViewList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *itemView = obj;
        itemView.frame = CGRectMake(idx * self.itemWidth, 0, self.itemWidth, self.itemHeight);
    }];
}

- (KOParallaxContentView *)nextItemViewAtIndex:(NSUInteger)index atPage:(NSUInteger)page{
    CGRect contentFrame = CGRectMake(index * self.itemWidth, 0, self.itemWidth, self.itemHeight);
    
    KOParallaxContentView *contentView =[[KOParallaxContentView alloc] initWithFrame:contentFrame];
    contentView.openParallaxEffect = _openParallaxEffect;
    contentView.displayImage = _displayImages[page];
    contentView.pageIndex = page;
    
    return contentView;
}

- (KOParallaxContentView *)nextItemViewAtIndex:(NSUInteger)index{
    return [self nextItemViewAtIndex:index atPage:_currentItemPage];
}

- (void)shiftCenterContentViewByDeltaValue:(CGFloat)delta{
    if (!self.itemViewList || self.itemViewList.count == 0) return;
    
    if (self.itemViewList.count == 1) {
        KOParallaxContentView *itemView = [_itemViewList firstObject];
        [itemView shiftImageViewFrameByDelta:delta];
    }else{
        [self.itemViewList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KOParallaxContentView *itemView = obj;
            if (itemView && itemView.frame.origin.x == self.itemWidth) {
                [itemView shiftImageViewFrameByDelta:delta];
            }
        }];
    }
}

- (void)updateImageAtPage:(NSUInteger)page newImage:(UIImage *)image{
    
    if (page >= _displayImages.count) return;
    if (!image || ![image isKindOfClass:[UIImage class]]) return;
    
    _displayImages[page] = image;
    
    [self.itemViewList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KOParallaxContentView *itemView = obj;
        if (itemView.pageIndex == page) {
            itemView.displayImage = image;
        }
    }];
}

#pragma mark - Setter

- (void)setDisplayImages:(NSMutableArray *)displayImages{
    if (displayImages && displayImages.count > 0) {
        _displayImages = [NSMutableArray arrayWithArray:displayImages];
        [self reloadContentView];
    }
}

- (void)setState:(KOParallaxState)state{
    if (state != _state) {
        [self willChangeValueForKey:@"state"];
        _state = state;
        [self didChangeValueForKey:@"state"];
    }
}

- (void)setCurrentItemIndex:(enum KOParallaxViewPosition)currentItemIndex{
    if (currentItemIndex != _currentItemIndex) {
        _currentItemIndex = currentItemIndex;
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    if (_scrollEnabled != scrollEnabled){
        _scrollEnabled = scrollEnabled;
        _containerView.scrollEnabled = _scrollEnabled;
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled{
    if (_pagingEnabled != pagingEnabled){
        _pagingEnabled = pagingEnabled;
        _containerView.pagingEnabled = pagingEnabled;
        [self setNeedsLayout];
    }
}

- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    
    [self checkViewAutoScroll];
}

- (void)checkViewAutoScroll{
    if (self.displayImages && self.displayImages.count > 1) {
        
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
        if (_autoScroll) {
            //timer
            _timer = [GCDTimer repeatingTimer:_autoScrollDuration block:^{
                if (_state != KOParallaxStateScrolling && CGSizeEqualToSize(_baseSize, self.frame.size)) {
                    //暂时先这样  虽然有点蠢
                    for (int i = 0; i <= [self itemWidth]; i++) {
                        [self.containerView setContentOffset:CGPointMake(self.containerView.contentOffset.x + i, 0)
                                                    animated:YES];
                    }
                    if (self.containerView.contentOffset.x != [self itemWidth]) {
                        self.containerView.contentOffset = CGPointMake([self itemWidth], 0);
                    }
                }
            }];
        }else{
            if (_timer) {
                [_timer invalidate];
            }
        }
    }
}

- (void)invalidateTimer{
	[_timer invalidate];
	_timer = nil;
}

#pragma mark - Getter

- (UIScrollView *)containerView{
    if (!_containerView) {
        _containerView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _containerView.delegate = self;
        _containerView.pagingEnabled = _pagingEnabled;
        _containerView.scrollEnabled = _scrollEnabled;
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.scrollsToTop = NO;
        _containerView.clipsToBounds = NO;
    }
    return _containerView;
}

- (CGFloat)itemWidth{
    CGFloat imageWidth = CGRectGetWidth(self.frame);
    return imageWidth;
}

- (CGFloat)itemHeight{
    CGFloat imageHeight = self.baseSize.height;//CGRectGetHeight(self.frame);
    return imageHeight;
}

- (NSInteger)nextItemPage{
    NSInteger willComePage = _currentItemPage + 1;
    NSInteger maxPage = _displayImages.count - 1;
    if (willComePage > maxPage ) {
        willComePage = 0;
    }
    return willComePage;
}

- (NSInteger)preItemPage{
    NSInteger willComePage = _currentItemPage - 1;
    NSInteger maxPage = _displayImages.count - 1;
    if (willComePage < 0) {
        willComePage = maxPage;
    }
    return willComePage;
}

@end


@interface GCDTimer()

@property (copy, nonatomic) void(^excuteBlock)(void);

@property (strong, nonatomic) dispatch_source_t source;

@end

@implementation GCDTimer

+ (GCDTimer *)repeatingTimer:(NSTimeInterval)seconds
                       block:(void (^)(void))block {
    NSParameterAssert(seconds);
    NSParameterAssert(block);
    
    GCDTimer *timer = [[self alloc] init];
    timer.excuteBlock = block;
    timer.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                          0, 0,
                                          dispatch_get_main_queue());
    uint64_t nsec = (uint64_t)(seconds * NSEC_PER_SEC);
    dispatch_source_set_timer(timer.source,
                              dispatch_time(DISPATCH_TIME_NOW, nsec),
                              nsec, 0);
    dispatch_source_set_event_handler(timer.source, block);
    dispatch_resume(timer.source);
    return timer;
}

- (void)invalidate {
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
    self.excuteBlock = nil;
}

@end