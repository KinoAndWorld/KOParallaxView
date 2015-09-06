//
//  DemoViewController.m
//  KOParallaxViewDemo
//
//  Created by kino on 15/9/5.
//
//

#import "DemoViewController.h"
#import "KOParallaxHeader.h"
#import "KOParallaxView.h"

#import <SDWebImage/SDWebImageManager.h>

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) KOParallaxHeader *parallaxHeader;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1.jpg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.alpha = 0.0;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"Cell"];
    
    _parallaxHeader = [[KOParallaxHeader alloc] initWithFrame:
                       CGRectMake(0, 0, self.view.bounds.size.width, 300)
                                           forScorllContainer:self.tableView
                                    openContentParallaxEffect:YES];
    if (_displayType == DisplayTypeSingleImage) {
        _parallaxHeader.imageListView.displayImages = [@[[UIImage imageNamed:@"1.jpg"]] mutableCopy];
        
    }else if (_displayType == DisplayTypeMultiImage){
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:[UIImage imageNamed:@"1.jpg"]];
        [images addObject:[UIImage imageNamed:@"2.jpg"]];
        [images addObject:[UIImage imageNamed:@"3.jpg"]];
        [images addObject:[UIImage imageNamed:@"4.jpg"]];
        [images addObject:[UIImage imageNamed:@"5.jpg"]];
        _parallaxHeader.imageListView.displayImages = images;
    }else if (_displayType == DisplayTypeAsyncLoadImage){
        
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 0; i < 5 ;i++) {
            //first add 5 holder image to show
            [images addObject:[UIImage imageNamed:@"placeHolder"]];
        }
        _parallaxHeader.imageListView.displayImages = images;
        
        //download queueurlString
        NSArray *urlStrings = @[@"http://imglf0.ph.126.net/I3zHRLTUyuGMiNRxDG9IRg==/1820861624441588616.jpg",
                                @"http://imglf1.ph.126.net/u3tngqcq_BLRplgof1Rwww==/6631400917722090442.jpg",
                                @"http://imglf1.ph.126.net/vTFTDtzInxX81OaIZYjPTw==/1953436338472180810.jpg",
                                @"http://imglf1.ph.126.net/T8h3JCh-6ZebvPAbzF1nGQ==/6608625633864352762.jpg",
                                @"http://imglf2.ph.126.net/k-amVP9oOgWmZCK4Do9K1Q==/164944336452609458.jpg"];
        for (NSString *urlString in urlStrings) {
            __weak DemoViewController *weakSelf = self;
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:urlString]
                                                            options:SDWebImageCacheMemoryOnly
                                                           progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               NSUInteger index = [urlStrings indexOfObject:imageURL.absoluteString];
                                                               if (index != NSNotFound) {
                                                                   [weakSelf.parallaxHeader.imageListView updateImageAtPage:index newImage:image];
                                                               }
                                                           }];
        }
    }
    
    self.tableView.tableHeaderView = _parallaxHeader;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Good Cell By Index %d",(int)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
