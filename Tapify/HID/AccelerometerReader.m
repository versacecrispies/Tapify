#import "AccelerometerReader.h"
#import <IOKit/hid/IOHIDManager.h>
#import <IOKit/hid/IOHIDDevice.h>
#import <mach/mach_time.h>
#import <string.h>

// HID report constants for AppleSPUHIDDevice accelerometer
static const int    kReportLength       = 22;
static const int    kXOffset            = 6;
static const int    kYOffset            = 10;
static const int    kZOffset            = 14;
static const double kRawToG             = 1.0 / 65536.0;

// Per-device context passed into IOHIDDevice callbacks
typedef struct {
    uint8_t             reportBuf[22];
    __unsafe_unretained AccelerometerReader *reader;
} DeviceContext;

// ---------------------------------------------------------------------------
// Private class extension — declares methods called from C callbacks
// ---------------------------------------------------------------------------
@interface AccelerometerReader ()
@property (nonatomic, readwrite) BOOL isRunning;
- (void)_deviceMatched:(IOHIDDeviceRef)device;
@end

// ---------------------------------------------------------------------------
// C-level HID callbacks (must be plain C functions, not blocks)
// ---------------------------------------------------------------------------

static void HIDReportCallback(void         *context,
                               IOReturn      result,
                               void         *sender,
                               IOHIDReportType type,
                               uint32_t      reportID,
                               uint8_t      *report,
                               CFIndex       reportLength)
{
    (void)sender; (void)type; (void)reportID;
    if (result != kIOReturnSuccess || reportLength < kReportLength) return;

    int32_t rawX = 0, rawY = 0, rawZ = 0;
    memcpy(&rawX, report + kXOffset, sizeof(int32_t));
    memcpy(&rawY, report + kYOffset, sizeof(int32_t));
    memcpy(&rawZ, report + kZOffset, sizeof(int32_t));

    AccelSample sample;
    sample.x         = (double)rawX * kRawToG;
    sample.y         = (double)rawY * kRawToG;
    sample.z         = (double)rawZ * kRawToG;
    sample.timestamp = mach_absolute_time();

    // Print first 30 raw reports to stderr for byte layout analysis.
    // Run the binary directly to see output: /Applications/Tapify.app/Contents/MacOS/Tapify
    static int sDumpCount = 0;
    if (sDumpCount < 30) {
        sDumpCount++;
        fprintf(stderr, "[TapifyHex] report %02d (%ld bytes): ", sDumpCount, (long)reportLength);
        for (CFIndex i = 0; i < reportLength; i++) {
            fprintf(stderr, "%02X ", report[i]);
        }
        fprintf(stderr, " | x=%.4f y=%.4f z=%.4f\n",
                (double)rawX * kRawToG,
                (double)rawY * kRawToG,
                (double)rawZ * kRawToG);
    }

    DeviceContext *ctx = (DeviceContext *)context;
    AccelSampleHandler handler = ctx->reader.sampleHandler;
    if (handler) {
        handler(sample);
    }
}

static void DeviceMatchedCallback(void            *context,
                                   IOReturn         result,
                                   void            *sender,
                                   IOHIDDeviceRef   device)
{
    (void)result; (void)sender;
    AccelerometerReader *reader = (__bridge AccelerometerReader *)context;
    [reader _deviceMatched:device];
}

static void DeviceRemovedCallback(void            *context,
                                   IOReturn         result,
                                   void            *sender,
                                   IOHIDDeviceRef   device)
{
    (void)result; (void)sender; (void)device;
    AccelerometerReader *reader = (__bridge AccelerometerReader *)context;
    NSLog(@"[Tapify] Accelerometer device removed.");
    reader.isRunning = NO;
}

// ---------------------------------------------------------------------------
@implementation AccelerometerReader {
    IOHIDManagerRef  _hidManager;
    NSThread        *_hidThread;
    NSMutableArray  *_deviceContexts; // heap-allocated DeviceContext wrappers
}

- (void)start {
    if (_isRunning) return;
    NSLog(@"[Tapify] AccelerometerReader starting.");
    _deviceContexts = [NSMutableArray array];
    _hidThread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(_runHIDLoop)
                                           object:nil];
    _hidThread.name = @"com.tapify.hid";
    _hidThread.qualityOfService = NSQualityOfServiceUserInteractive;
    [_hidThread start];
}

- (void)stop {
    if (_hidManager) {
        IOHIDManagerUnscheduleFromRunLoop(_hidManager,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopDefaultMode);
        IOHIDManagerClose(_hidManager, kIOHIDOptionsTypeNone);
        CFRelease(_hidManager);
        _hidManager = NULL;
    }
    [_hidThread cancel];
    _hidThread = nil;
    _isRunning = NO;
}

// ---------------------------------------------------------------------------
#pragma mark - Private

- (void)_runHIDLoop {
    @autoreleasepool {
        NSLog(@"[Tapify] HID thread started.");

        // Build the device matching dictionary for the SPU accelerometer.
        // On M1–M4 the device advertised PrimaryUsage=3; on M5 it does not,
        // so we match on the vendor usage page alone and filter by report size
        // in the matched callback.
        NSDictionary *matching = @{
            @(kIOHIDPrimaryUsagePageKey): @(0xFF00),
        };

        _hidManager = IOHIDManagerCreate(kCFAllocatorDefault,
                                         kIOHIDManagerOptionNone);
        if (!_hidManager) {
            NSLog(@"[Tapify] Failed to create IOHIDManager.");
            return;
        }

        IOHIDManagerSetDeviceMatching(_hidManager,
                                      (__bridge CFDictionaryRef)matching);

        IOHIDManagerRegisterDeviceMatchingCallback(_hidManager,
                                                   DeviceMatchedCallback,
                                                   (__bridge void *)self);
        IOHIDManagerRegisterDeviceRemovalCallback(_hidManager,
                                                  DeviceRemovedCallback,
                                                  (__bridge void *)self);

        IOHIDManagerScheduleWithRunLoop(_hidManager,
                                        CFRunLoopGetCurrent(),
                                        kCFRunLoopDefaultMode);

        IOReturn openResult = IOHIDManagerOpen(_hidManager,
                                               kIOHIDOptionsTypeNone);
        if (openResult != kIOReturnSuccess) {
            NSLog(@"[Tapify] IOHIDManagerOpen failed: 0x%x. "
                  @"Try running with elevated privileges.", openResult);
        } else {
            NSLog(@"[Tapify] IOHIDManagerOpen succeeded. Waiting for devices...");
        }

        // Block on this thread's run loop forever (until -stop cancels the thread)
        while (![NSThread currentThread].isCancelled) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, NO);
        }

        // Cleanup on exit
        IOHIDManagerUnscheduleFromRunLoop(_hidManager,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopDefaultMode);
        IOHIDManagerClose(_hidManager, kIOHIDOptionsTypeNone);
        CFRelease(_hidManager);
        _hidManager = NULL;
    }
}

- (void)_deviceMatched:(IOHIDDeviceRef)device {
    NSString *product = (__bridge_transfer NSString *)
        IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey));
    NSNumber *reportSize = (__bridge_transfer NSNumber *)
        IOHIDDeviceGetProperty(device, CFSTR(kIOHIDMaxInputReportSizeKey));
    NSNumber *usage = (__bridge_transfer NSNumber *)
        IOHIDDeviceGetProperty(device, CFSTR(kIOHIDPrimaryUsageKey));
    NSNumber *usagePage = (__bridge_transfer NSNumber *)
        IOHIDDeviceGetProperty(device, CFSTR(kIOHIDPrimaryUsagePageKey));

    NSLog(@"[Tapify] HID device found — product: %@, usagePage: 0x%X, usage: %@, reportSize: %d",
          product ?: @"(unknown)",
          usagePage.unsignedIntValue,
          usage ?: @"(none)",
          reportSize.intValue);

    if (reportSize.intValue != kReportLength) {
        NSLog(@"[Tapify] Skipping — report size %d != expected %d",
              reportSize.intValue, kReportLength);
        return;
    }

    NSLog(@"[Tapify] Opening as accelerometer: %@", product ?: @"(unknown)");

    // Allocate a per-device context on the heap — must outlive the callback lifetime
    DeviceContext *ctx = (DeviceContext *)calloc(1, sizeof(DeviceContext));
    ctx->reader = self;

    // Wrap in NSData so ARC-managed _deviceContexts array can free it
    NSData *ctxData = [NSData dataWithBytesNoCopy:ctx
                                           length:sizeof(DeviceContext)
                                     freeWhenDone:YES];
    [_deviceContexts addObject:ctxData];

    IOHIDDeviceRegisterInputReportCallback(device,
                                           ctx->reportBuf,
                                           kReportLength,
                                           HIDReportCallback,
                                           ctx);

    IOHIDDeviceScheduleWithRunLoop(device,
                                   CFRunLoopGetCurrent(),
                                   kCFRunLoopDefaultMode);

    IOReturn openResult = IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
    if (openResult != kIOReturnSuccess) {
        NSLog(@"[Tapify] IOHIDDeviceOpen failed: 0x%x", openResult);
    } else {
        _isRunning = YES;
        NSLog(@"[Tapify] Accelerometer online.");
    }
}

@end
