# Q003 Answer: createDirectChannel Leaks Native Resources

## 問題根因
在 `SystemSensorManager.java` 的 `createDirectChannel()` 方法中，
當驗證失敗時直接返回 null，但忘記關閉已經打開的 native handle。

在某些錯誤路徑上，native 資源已被分配但未釋放。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（資源洩漏）
@Override
public SensorDirectChannel createDirectChannel(MemoryFile memoryFile) {
    int size = memoryFile.length();
    // 先打開 native handle
    long nativeHandle = nativeCreateDirectChannel(memoryFile.getFileDescriptor(), size);
    
    if (size < MIN_DIRECT_CHANNEL_SIZE) {
        return null;  // BUG: 沒有關閉 nativeHandle
    }
    
    if (nativeHandle == 0) {
        return null;  // 這裡 OK，native 創建失敗
    }
    
    return new SensorDirectChannel(this, nativeHandle, size);
}

// 正確的代碼
@Override
public SensorDirectChannel createDirectChannel(MemoryFile memoryFile) {
    int size = memoryFile.length();
    if (size < MIN_DIRECT_CHANNEL_SIZE) {
        return null;  // 驗證失敗，尚未分配 native 資源
    }
    
    long nativeHandle = nativeCreateDirectChannel(memoryFile.getFileDescriptor(), size);
    if (nativeHandle == 0) {
        return null;
    }
    
    return new SensorDirectChannel(this, nativeHandle, size);
}
```

## 相關知識
- Direct Channel 使用 shared memory 和 native file descriptors
- 資源洩漏會導致 OOM 和 fd exhaustion
- 正確的順序：先驗證，後分配

## 難度說明
**Hard** - 需要理解資源管理和錯誤處理路徑。
