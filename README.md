# KOParallaxView
视差滚动+无限循环滚动，仿格瓦拉首页效果

***


## Features

- 视差滚动（parallax effect）
- 图片无限循环滚动（infinite） 
- 可支持本地图片与异步加载图片（local image and async image support）

## Installation

Grab the files in `KOParallaxView/` and put it in your project. 

## Usage

first,  import `KOParallaxHeader.h` and `KOParallaxView.h`

attach a UIScrollView subclass to show
```objectivec
_parallaxHeader = [[KOParallaxHeader alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 300)
                                       forScorllContainer:self.tableView
                                openContentParallaxEffect:YES];
```

and you can add images 
```objectivec
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:[UIImage imageNamed:@"1.jpg"]];
        [images addObject:[UIImage imageNamed:@"2.jpg"]];
        [images addObject:[UIImage imageNamed:@"3.jpg"]];
        [images addObject:[UIImage imageNamed:@"4.jpg"]];
        _parallaxHeader.imageListView.displayImages = images;
```

then add view to show
```
self.tableView.tableHeaderView = _parallaxHeader;
```


### License

`KOParallaxView` is released under the MIT license.

### Author

Kino

`Email: 992276678@qq.com/ kinoandworld@gmail.com`

`Weibo: http://weibo.com/u/1878504510`

contact me if had any quetion .
