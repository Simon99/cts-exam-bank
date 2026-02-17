# Q008 Answer: Shader Blob Cache Corruption on Multifile Mode

## 問題根因
在 `egl_cache.cpp` 的 `updateMode()` 函數中存在競態條件。

當多個線程同時調用 `setBlob()` 或 `getBlob()` 時：
1. 兩個線程都進入 `updateMode()`
2. 第一個線程設置 `checked = true` 並開始切換到 multifile 模式
3. 第二個線程看到 `checked = true`，直接返回
4. 但此時 `mMultifileMode` 可能還沒被正確設置
5. 導致一個線程用 multifile 寫入，另一個用 monolithic 讀取

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_cache.cpp` - `updateMode()` 函數

## 關鍵代碼分析
```cpp
// 原始代碼 - 有 race condition
void egl_cache_t::updateMode() {
    static bool checked = false;  // 問題1: static 變量不受 mutex 保護
    if (checked) {
        return;
    }
    checked = true;  // 問題2: 在完成模式設置前就標記完成

    // Check the device config to decide whether multifile should be used
    if (base::GetBoolProperty("ro.egl.blobcache.multifile", false)) {
        mMultifileMode = true;  // 這行可能在 checked=true 之後才執行
        ALOGV("Using multifile EGL blobcache");
    }
    // ...
}
```

## 修復方式
```cpp
// 正確的代碼 - 使用 std::call_once 確保原子性
void egl_cache_t::updateMode() {
    static std::once_flag onceFlag;
    std::call_once(onceFlag, [this]() {
        // Check the device config to decide whether multifile should be used
        if (base::GetBoolProperty("ro.egl.blobcache.multifile", false)) {
            mMultifileMode = true;
            ALOGV("Using multifile EGL blobcache");
        }
        
        // Allow forcing the mode for debug purposes
        std::string mode = base::GetProperty("debug.egl.blobcache.multifile", "");
        if (mode == "true") {
            mMultifileMode = true;
        } else if (mode == "false") {
            mMultifileMode = false;
        }
        
        if (mMultifileMode) {
            mCacheByteLimit = static_cast<size_t>(
                    base::GetUintProperty<uint32_t>("ro.egl.blobcache.multifile_limit",
                                                    kMaxMultifileTotalSize));
        }
    });
}
```

## 調試步驟
1. 添加 log 在 `updateMode()` 開始和結束處，記錄線程 ID
2. 在 `setBlob()` 和 `getBlob()` 中記錄使用的模式
3. 使用多線程測試程序模擬並發訪問
4. 檢查 `/data/data/<app>/cache/` 下的 cache 文件格式

## 相關知識
- EGL blob cache 是 GPU shader 編譯優化的關鍵
- Monolithic 模式：所有 cache 存在一個文件
- Multifile 模式：每個 entry 一個文件，減少 I/O
- `std::call_once` 保證初始化只執行一次，且線程安全

## 難度說明
**Hard** - 需要理解 C++ 多線程同步機制，以及 Android 屬性系統。
Race condition 問題難以復現，需要仔細分析代碼流程。
