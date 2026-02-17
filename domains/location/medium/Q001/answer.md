# Answer: requestLocationUpdates Ignores minUpdateDistanceMeters

## Bug Location

**Two files are affected:**

### File 1: LocationRequest.java (API Layer)
**Path:** `frameworks/base/location/java/android/location/LocationRequest.java`
**Line:** ~594

### File 2: LocationProviderManager.java (Service Layer)  
**Path:** `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
**Line:** ~1150

## Root Cause Analysis

This bug spans two layers of the Location stack:

### Bug 1: LocationRequest.getMinUpdateDistanceMeters()
The getter method always returns 0 instead of the actual configured distance value:

```java
// BUGGY CODE
public float getMinUpdateDistanceMeters() {
    return 0;  // Always returns 0!
}

// CORRECT CODE  
public float getMinUpdateDistanceMeters() {
    return mMinUpdateDistanceMeters;
}
```

### Bug 2: LocationProviderManager distance check removed
Even if the getter worked, the service-side distance filtering logic was removed:

```java
// BUGGY CODE - check completely removed
return true;

// CORRECT CODE
float minDistance = mRequest.getMinUpdateDistanceMeters();
if (minDistance > 0 && mLastLocation != null) {
    if (location.distanceTo(mLastLocation) < minDistance) {
        return false;
    }
}
return true;
```

## Fix

**LocationRequest.java:**
```java
public float getMinUpdateDistanceMeters() {
    return mMinUpdateDistanceMeters;
}
```

**LocationProviderManager.java:**
```java
// check min distance
float minDistance = mRequest.getMinUpdateDistanceMeters();
if (minDistance > 0 && mLastLocation != null) {
    if (location.distanceTo(mLastLocation) < minDistance) {
        return false;
    }
}
return true;
```

## Debugging Path

1. CTS test `testRequestLocationUpdates_minUpdateDistanceMeters` fails
2. The test registers for updates with minUpdateDistanceMeters > 0
3. Check LocationManager.requestLocationUpdates() - parameters look correct
4. **First clue:** Add logging to LocationRequest.getMinUpdateDistanceMeters() - returns 0!
5. **Second clue:** Even after fixing getter, still fails - trace to service side
6. Locate distance check logic in LocationProviderManager - code is missing

## Key Learning Points

- **Cross-layer bugs:** API layer bugs can mask service layer bugs (and vice versa)
- **Both getter and consumer:** When a value isn't being used, check:
  1. Is the getter returning the correct value?
  2. Is the consumer actually using the value?
- **Request parameters flow:** LocationRequest → Binder IPC → LocationProviderManager
