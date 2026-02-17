# Q001 Answer: EGL Context Creation Fails Intermittently

## 問題根因
在 `egl_display.cpp` 的 `initialize()` 函數中，設置 `eglIsInitialized = true` 
和發送 `refCond.notify_all()` 的順序錯誤。這導致等待的線程可能在初始化完成前被喚醒。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - 初始化順序
2. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - 使用初始化狀態

## 修復方式
```cpp
// 錯誤的代碼
{ // scope for refLock
    std::unique_lock<std::mutex> _l(refLock);
    refCond.notify_all();  // BUG: 先 notify
    eglIsInitialized = true;  // 後設置狀態
}

// 正確的代碼
{ // scope for refLock
    std::unique_lock<std::mutex> _l(refLock);
    eglIsInitialized = true;  // 先設置狀態
    refCond.notify_all();     // 後 notify
}
```

## 調試步驟
1. 在 `egl_display.cpp` 的 `initialize()` 添加 log
2. 在 context 創建前檢查 `eglIsInitialized` 狀態
3. 觀察多線程場景下的時序

## 相關知識
- 條件變量需要先設置狀態再 notify
- race condition 導致的 bug 需要理解同步機制

## 難度說明
**Medium** - 間歇性失敗需要加 log 追蹤時序，涉及 2 個檔案。
