//  Copyright (c) 2014 650 Industries, Inc. All rights reserved.

#import "BKBackgroundController.h"

#import <mach/mach.h>

float reportCPUUsage();
int countCores();

@implementation BKBackgroundController {
    NSThread *_runLoopThread;
    CADisplayLink *_backgroundDisplayLink;
}

- (instancetype)init
{
    if (self = [super init]) {
        _runLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(_runLoop) object:nil];
        _runLoopThread.threadPriority = 1.0;

        _backgroundDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayLinkTick:)];

        [_runLoopThread start];
    }
    return self;
}

- (void)dealloc
{
    [_runLoopThread cancel];
    [_runLoopThread release];
    _runLoopThread = nil;

    [_backgroundDisplayLink invalidate];
    [_backgroundDisplayLink release];
    _backgroundDisplayLink = nil;

    [super dealloc];
}

- (void)_runLoop
{
    @autoreleasepool {
        BOOL done = NO;

        [_backgroundDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        do {
            SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
            if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
                done = YES;
            }

        } while (!done);
    }
}

- (void)_displayLinkTick:(CADisplayLink *)sender
{
    reportCPUUsage();
}

@end

float reportCPUUsage() {
    kern_return_t result;

    // Get thread list
    thread_array_t threadList;
    mach_msg_type_number_t threadCount;
    result = task_threads(mach_task_self(), &threadList, &threadCount);
    if (result != KERN_SUCCESS) {
        return -1;
    }

    float totalCPU = 0;
    for (int threadIndex = 0; threadIndex < threadCount; threadIndex++) {
        // Get thread info
        thread_basic_info_data_t threadBasicInfo;
        mach_msg_type_number_t threadBasicInfoCount = THREAD_BASIC_INFO_COUNT;
        result = thread_info(threadList[threadIndex],
                             THREAD_BASIC_INFO,
                             (thread_info_t)&threadBasicInfo,
                             &threadBasicInfoCount);
        if (result != KERN_SUCCESS) {
            return -1;
        }

        // Get thread identifier info
        thread_identifier_info_data_t threadIdentifierInfo;
        mach_msg_type_number_t threadIdentifierInfoCount = THREAD_IDENTIFIER_INFO_COUNT;
        result = thread_info(threadList[threadIndex],
                             THREAD_IDENTIFIER_INFO,
                             (thread_info_t)&threadIdentifierInfo,
                             &threadIdentifierInfoCount);
        if (result != KERN_SUCCESS) {
            return -1;
        }

        // Calculate time percentages
        float threadPercent = 0;
        if (!(threadBasicInfo.flags & TH_FLAGS_IDLE)) {
            threadPercent = threadBasicInfo.cpu_usage / (float)TH_USAGE_SCALE * 100.0;
            totalCPU = totalCPU + threadPercent;
        }

        // Get queue name
        if (threadIdentifierInfo.thread_handle) {
            const char *queueName;

            dispatch_queue_t *queue = (dispatch_queue_t *)threadIdentifierInfo.dispatch_qaddr;
            // Don't want to dereference a null pinter; don't want to trigger fetching the default label
            if (queue && *queue) {
                queueName = dispatch_queue_get_label(*queue);
            } else {
                queueName = "";
            }

            NSLog(@"totalCPU: %f threadPercent: %f queueName: %s", totalCPU, threadPercent, queueName);
        }
    } // for each thread

    result = vm_deallocate(mach_task_self(), (vm_offset_t)threadList, threadCount * sizeof(thread_t));
    assert(result == KERN_SUCCESS);
    return totalCPU;
}

int countCores() {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t hostInfoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &hostInfoCount);
    return hostInfo.max_cpus;
}

