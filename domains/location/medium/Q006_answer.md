# Answer: LocationListener.onProviderEnabled Not Called

## Bug Location

**Two files are affected:**

### File 1: LocationListener.java (API Layer - Interface)
**Path:** `frameworks/base/location/java/android/location/LocationListener.java`
**Line:** ~81

### File 2: LocationProviderManager.java (Service Layer - Notification)
**Path:** `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
**Line:** ~894

## Root Cause Analysis

Provider enabled/disabled notifications fail at both the interface and service levels.

### Bug 1: LocationListener.onProviderEnabled() default method
The default implementation incorrectly calls onProviderDisabled:

```java
// BUGGY CODE - calls wrong method!
default void onProviderEnabled(@NonNull String provider) { 
    onProviderDisabled(provider);  // Calls disabled when enabled!
}

// CORRECT CODE - empty default (apps override if they care)
default void onProviderEnabled(@NonNull String provider) {}
```

### Bug 2: LocationProviderManager state change notification removed
The service-side notification logic is completely missing:

```java
// BUGGY CODE - notification removed
// notify listeners of enabled state change
// (nothing here!)

// CORRECT CODE
if (oldEnabled != enabled) {
    deliverToListeners(registration -> {
        if (registration.getTransport() instanceof ProviderTransport) {
            ((ProviderTransport) registration.getTransport())
                .deliverOnProviderEnabledChanged(mName, enabled);
        }
    });
}
```

## Fix

**LocationListener.java:**
```java
default void onProviderEnabled(@NonNull String provider) {}
```

**LocationProviderManager.java:**
```java
// notify listeners of enabled state change
if (oldEnabled != enabled) {
    deliverToListeners(registration -> {
        if (registration.getTransport() instanceof ProviderTransport) {
            ((ProviderTransport) registration.getTransport())
                .deliverOnProviderEnabledChanged(mName, enabled);
        }
    });
}
```

## Debugging Path

1. CTS test `testProviderEnabledCallback` fails
2. Test enables/disables provider and expects callbacks
3. Check LocationListener interface - **First bug:** onProviderEnabled calls onProviderDisabled!
4. Fix interface, test still fails
5. Trace to LocationProviderManager.onProviderEnabledChanged()
6. **Second bug found:** deliverToListeners() call is missing

## Provider State Callback Flow

```
Provider enabled/disabled
    ↓
LocationProviderManager.setAllowed() or similar
    ↓
if (oldEnabled != enabled)
    ↓
deliverToListeners() → ProviderTransport.deliverOnProviderEnabledChanged()
    ↓
LocationListener.onProviderEnabled() or onProviderDisabled()
```

## Key Learning Points

- **Default methods:** Java 8 default methods in interfaces can have bugs too!
- **State change notifications:** Always check:
  1. Is the state change detected? (`oldEnabled != enabled`)
  2. Is the notification sent? (`deliverToListeners()`)
- **Transport pattern:** `ProviderTransport.deliverOnProviderEnabledChanged()` wraps the actual listener call
- **Testing callbacks:** State callbacks need explicit enable/disable actions to test properly
