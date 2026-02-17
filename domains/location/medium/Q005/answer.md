# Answer: GnssMeasurementsEvent Callback Not Invoked

## Bug Location

**Two files are affected:**

### File 1: LocationManager.java (API Layer - Registration)
**Path:** `frameworks/base/location/java/android/location/LocationManager.java`
**Line:** ~2453

### File 2: GnssMeasurementsProvider.java (Service Layer - Delivery)
**Path:** `frameworks/base/services/core/java/com/android/server/location/gnss/GnssMeasurementsProvider.java`
**Line:** ~201

## Root Cause Analysis

GNSS measurements callbacks fail at both registration and delivery stages.

### Bug 1: LocationManager passes null transport
The transport is created but not stored, and null is passed to the service:

```java
// BUGGY CODE
GnssMeasurementCallbackTransport transport = new GnssMeasurementCallbackTransport(...);
// transport not stored in map!
return mService.registerGnssMeasurementsCallback(
    null,  // Passing null instead of transport!
    request, mContext.getPackageName(), mContext.getAttributionTag());

// CORRECT CODE
GnssMeasurementCallbackTransport transport = new GnssMeasurementCallbackTransport(...);
synchronized (mGnssMeasurementCallbackTransports) {
    mGnssMeasurementCallbackTransports.put(callback, transport);
}
return mService.registerGnssMeasurementsCallback(
    transport, request, mContext.getPackageName(), mContext.getAttributionTag());
```

### Bug 2: GnssMeasurementsProvider doesn't deliver
Even if registration worked, the delivery to listeners is missing:

```java
// BUGGY CODE
public void onReportMeasurements(GnssMeasurementsEvent event) {
    synchronized (mMultiplexerLock) {
        mLastGnssMeasurementsEvent = event;
    }
    // Missing delivery! Event is cached but never sent to listeners
}

// CORRECT CODE
public void onReportMeasurements(GnssMeasurementsEvent event) {
    synchronized (mMultiplexerLock) {
        mLastGnssMeasurementsEvent = event;
    }
    deliverToListeners(listener -> {
        listener.onGnssMeasurementsReceived(event);
    });
}
```

## Fix

**LocationManager.java:**
```java
GnssMeasurementCallbackTransport transport = new GnssMeasurementCallbackTransport(
        mContext, executor, callback);
synchronized (mGnssMeasurementCallbackTransports) {
    mGnssMeasurementCallbackTransports.put(callback, transport);
}
try {
    return mService.registerGnssMeasurementsCallback(
            transport, request, mContext.getPackageName(), mContext.getAttributionTag());
```

**GnssMeasurementsProvider.java:**
```java
deliverToListeners(listener -> {
    listener.onGnssMeasurementsReceived(event);
});
```

## Debugging Path

1. CTS test `testRegisterGnssMeasurementsCallback` fails - callback never fires
2. Check LocationManager.registerGnssMeasurementsCallback() - creates transport
3. **First bug found:** Transport created but null passed to service!
4. Fix null parameter, test still fails
5. Trace to GnssMeasurementsProvider.onReportMeasurements()
6. **Second bug found:** Event is cached but never delivered to listeners

## Callback Transport Pattern

```
App Callback ← Transport ← Service ← Provider ← HAL

1. App registers callback via LocationManager
2. LocationManager wraps callback in Transport (for thread handling)
3. Transport is registered with LocationManagerService
4. Service stores transport in GnssMeasurementsProvider's listener list
5. HAL reports measurements → Provider.onReportMeasurements()
6. Provider calls deliverToListeners() → Transport → App Callback
```

## Key Learning Points

- **Transport pattern:** Callbacks are wrapped in "transports" for thread safety and executor handling
- **Two-part registration:**
  1. Store transport in local map (for unregister lookup)
  2. Register transport with remote service
- **Delivery pattern:** `deliverToListeners(listener -> listener.onXxx(data))`
- **Cache vs delivery:** Caching data (mLastEvent) is separate from delivering to listeners
