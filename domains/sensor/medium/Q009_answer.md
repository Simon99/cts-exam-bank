# Q009 Answer: isDirectChannelTypeSupported Always Returns False

## 問題根因
在 `Sensor.java` 的 `isDirectChannelTypeSupported()` 方法中，
位元檢查的邏輯錯誤。應該檢查 flag 是否非零（表示支援），
但 bug 檢查是否為零（表示不支援）。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// Flag 定義
private static final int DIRECT_CHANNEL_FLAG_SHIFT = 10;
private static final int DIRECT_CHANNEL_MEMORY_FILE = 1 << DIRECT_CHANNEL_FLAG_SHIFT;
private static final int DIRECT_CHANNEL_HARDWARE_BUFFER = 2 << DIRECT_CHANNEL_FLAG_SHIFT;

// 錯誤的代碼
public boolean isDirectChannelTypeSupported(int sharedMemType) {
    switch (sharedMemType) {
        case SensorDirectChannel.TYPE_MEMORY_FILE:
            return (mFlags & DIRECT_CHANNEL_MEMORY_FILE) == 0;  // BUG: 應該是 != 0
        case SensorDirectChannel.TYPE_HARDWARE_BUFFER:
            return (mFlags & DIRECT_CHANNEL_HARDWARE_BUFFER) == 0;  // BUG
        default:
            return false;
    }
}

// 正確的代碼
public boolean isDirectChannelTypeSupported(int sharedMemType) {
    switch (sharedMemType) {
        case SensorDirectChannel.TYPE_MEMORY_FILE:
            return (mFlags & DIRECT_CHANNEL_MEMORY_FILE) != 0;
        case SensorDirectChannel.TYPE_HARDWARE_BUFFER:
            return (mFlags & DIRECT_CHANNEL_HARDWARE_BUFFER) != 0;
        default:
            return false;
    }
}
```

## 相關知識
- Direct channel 繞過 framework 直接將資料寫入共享記憶體
- TYPE_MEMORY_FILE：使用 MemoryFile (ashmem)
- TYPE_HARDWARE_BUFFER：使用 HardwareBuffer

## 難度說明
**Medium** - 需要理解 direct channel 機制和 flag 位元結構。
