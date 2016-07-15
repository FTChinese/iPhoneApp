//
//  NBSGCDOverrider.m
//  test_configLocal
//
//  Created by yang kai on 14-3-27.
//  Copyright (c) 2014年 NBS. All rights reserved.
//


#ifdef __BLOCKS__
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef NBSGCDOverride_H
#define NBSGCDOverride_H
    #define dispatch_async(...) NBSDispatch_async(__VA_ARGS__)
    #define dispatch_sync(...) NBSDispatch_sync(__VA_ARGS__)
    #define dispatch_after(...) NBSDispatch_after(__VA_ARGS__)
    #define dispatch_apply(...) NBSDispatch_apply(__VA_ARGS__)
    
void NBSDispatch_async(dispatch_queue_t queue, dispatch_block_t block);
void NBSDispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
void NBSDispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block);
void NBSDispatch_apply(size_t iterations, dispatch_queue_t queue, void(^block)(size_t));
    
#endif
    
#ifdef __cplusplus
}
#endif

#endif
