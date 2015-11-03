//
//  TwitterService.m
//  Bellow
//
//  Created by Paul Stavropoulos on 2/3/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "TwitterService.h"
#import <Parse/Parse.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>

@implementation TwitterService

+ (void)sendTweet:(NSString *)tweetText withImage:(UIImage *)tweetImage
{
    // set up tweet
    NSURL *submitTweet;
    NSMutableURLRequest *request;
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSString *mediaId = nil;
    
    // Submit image if necessary
    if (tweetImage)
    {
        NSURL *submitImage = [NSURL URLWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:submitImage];
        
        [request setHTTPMethod:@"POST"];
        
        // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
        NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'
        NSString *FileParamConstant = @"media";
        
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // post body
        NSMutableData *body = [NSMutableData data];
        
        
        // add image data
        NSData *imageData = UIImageJPEGRepresentation(tweetImage, 0.45);
        if (imageData) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            // [body appendData:[@"media=" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        
        
        [[PFTwitterUtils twitter] signRequest:request];
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:kNilOptions
                                                                             error:&error];
        mediaId = [responseDictionary objectForKey:@"media_id_string"];
        
        
    }
    
    submitTweet = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    request = [NSMutableURLRequest requestWithURL:submitTweet];
    
    // escape all necessary characters
    NSString *tweet = [self percentEncodeString:tweetText];
    NSString *postString = [NSString stringWithFormat:@"status=%@", tweet];
    
    if (mediaId != nil)
    {
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"&media_ids=%@", mediaId]];
    }
    
    NSData *parameters = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parameters];
    [request setHTTPMethod:@"POST"];
    
    /*
     NSString *stringBoundary = @"cce6735153bf14e47e999e68bb183e70a1fa7fc89722fc1efdf03a917340";
     NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
     [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
     */
    [[PFTwitterUtils twitter] signRequest:request];
    
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error)
        NSLog(@"%@", error);
    else
    {
        // NSLog(@"Response: %@", response);
        NSLog(@"posted to twitter");
    }
}
                       

+ (NSString *)percentEncodeString:(NSString *)string
{
    NSMutableString * output = [[NSMutableString alloc] init];
    
    int sourceLen = (int) [string length];
    for (int i = 0; i < sourceLen; i++)
    {
        const unsigned char thisChar = [string characterAtIndex:i];
        if (thisChar == ' ')
            [output appendString:@"%20"];
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                 (thisChar >= 'a' && thisChar <= 'z')||
                 (thisChar >= 'A' && thisChar <= 'Z')||
                 (thisChar >= '0' && thisChar <= '9') )
            [output appendFormat:@"%c", thisChar];
        else
            [output appendFormat:@"%%%02X", thisChar];
    }
    
    return output;
}


@end
