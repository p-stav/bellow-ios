//
//  ImageCropping.h
//  Ripple
//
//  Created by Paul Stavropoulos on 1/31/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCropping : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize withColor: (UIColor *)color;

@end
