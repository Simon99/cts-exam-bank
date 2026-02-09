# Answer: Geofence Proximity Alert Never Triggered

## Bug Location

**Two files are affected:**

### File 1: LocationManager.java (API Layer - Geofence Creation)
**Path:** `frameworks/base/location/java/android/location/LocationManager.java`
**Line:** ~1825

### File 2: GeofenceManager.java (Service Layer - State Check)
**Path:** `frameworks/base/services/core/java/com/android/server/location/geofence/GeofenceManager.java`
**Line:** ~288

## Root Cause Analysis

Geofence proximity alerts fail at both setup and state checking.

### Bug 1: LocationManager.addProximityAlert() radius handling
The radius is zeroed out and validation is removed:

```java
// BUGGY CODE
// Preconditions.checkArgument(radius > 0, "invalid radius");  // Validation removed!
mService.addGeofence(createCircularGeofence(latitude, longitude, Math.abs(radius) * 0),  // radius * 0 = 0!
        createRequest(GPS_PROVIDER, expiration), intent,
        mContext.getPackageName(), mContext.getAttributionTag());

// CORRECT CODE
Preconditions.checkArgument(radius > 0, "invalid radius");
mService.addGeofence(createCircularGeofence(latitude, longitude, radius),
        createRequest(GPS_PROVIDER, expiration), intent,
        mContext.getPackageName(), mContext.getAttributionTag());
```

### Bug 2: GeofenceManager.checkGeofenceState() comparison reversed
The inside/outside comparison is inverted:

```java
// BUGGY CODE
boolean inside = distance > radius;  // Wrong! This is OUTSIDE logic

// CORRECT CODE
boolean inside = distance <= radius;  // Correct - inside when distance <= radius
```

## Fix

**LocationManager.java:**
```java
Preconditions.checkArgument(radius > 0, "invalid radius");
mService.addGeofence(createCircularGeofence(latitude, longitude, radius),
        createRequest(GPS_PROVIDER, expiration), intent,
        mContext.getPackageName(), mContext.getAttributionTag());
```

**GeofenceManager.java:**
```java
boolean inside = distance <= radius;
```

## Debugging Path

1. CTS test `testAddProximityAlert` fails - proximity alert never triggers
2. Set up geofence with known location, move into range
3. Check LocationManager.addProximityAlert() - radius becomes 0!
4. **First bug found:** `Math.abs(radius) * 0` zeroes the radius
5. Fix radius, test still fails when moving in/out of geofence
6. Trace to GeofenceManager.checkGeofenceState()
7. **Second bug found:** `distance > radius` is inverted - thinks inside is outside!

## Geofence State Logic

```
                    radius
                      ↓
Center ●═══════════════●
       ←── distance ──→

inside  = distance <= radius  (within the circle)
outside = distance > radius   (outside the circle)

State transitions:
- OUTSIDE → INSIDE:  trigger ENTER alert
- INSIDE → OUTSIDE:  trigger EXIT alert
```

## Key Learning Points

- **Math expressions:** `Math.abs(x) * 0` is always 0 - subtle bug!
- **Comparison operators:** `<=` vs `>` have opposite meanings
  - `distance <= radius` = inside
  - `distance > radius` = outside
- **Validation importance:** Removing `radius > 0` check allows invalid geofences
- **State machine:** Geofence uses STATE_UNKNOWN/INSIDE/OUTSIDE with transitions
- **Parameter flow:** LocationManager → Geofence object → GeofenceManager → state checks
