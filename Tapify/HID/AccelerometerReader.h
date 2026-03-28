#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A single accelerometer reading from the Apple Silicon SPU sensor.
typedef struct {
    double x;           ///< X-axis acceleration in g-force
    double y;           ///< Y-axis acceleration in g-force
    double z;           ///< Z-axis acceleration in g-force (at rest ~1.0 due to gravity)
    uint64_t timestamp; ///< mach_absolute_time of the sample
} AccelSample;

/// Block type called with each new accelerometer sample (~100 Hz).
typedef void (^AccelSampleHandler)(AccelSample sample);

/**
 * AccelerometerReader
 *
 * Accesses the Apple Silicon MEMS accelerometer via IOKit HID.
 * Matches the AppleSPUHIDDevice (vendor usage page 0xFF00, usage 3).
 * Runs IOHIDManager on a dedicated background thread.
 * Thread-safe: sampleHandler is called from the internal HID thread.
 */
@interface AccelerometerReader : NSObject

/// Called on every incoming HID report (~100Hz). Set before calling -start.
@property (nonatomic, copy, nullable) AccelSampleHandler sampleHandler;

/// Whether the accelerometer device was found and opened successfully.
@property (nonatomic, readonly) BOOL isRunning;

/// Start reading accelerometer data. No-op if already running.
- (void)start;

/// Stop reading and release IOKit resources.
- (void)stop;

@end

NS_ASSUME_NONNULL_END
