//
//  DemoViewController.h
//  KOParallaxViewDemo
//
//  Created by kino on 15/9/5.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    DisplayTypeSingleImage = 0,
    DisplayTypeMultiImage,
    DisplayTypeAsyncLoadImage
}DisplayType;

@interface DemoViewController : UIViewController

@property (assign, nonatomic) DisplayType displayType;

@end
