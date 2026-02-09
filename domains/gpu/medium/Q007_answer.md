# Q007 Answer: Shader Cache Not Working

## 問題根因
在 `egl_cache.cpp` 的 `getBlob()` 函數中，
查詢成功後沒有將結果複製到輸出 buffer，導致 cache hit 但資料沒有返回。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_cache.cpp` - cache get 邏輯
2. `frameworks/native/opengl/libs/EGL/BlobCache.cpp` - 底層 cache 實現

## 修復方式
```cpp
// 錯誤的代碼
EGLsizeiANDROID egl_cache_t::getBlob(const void* key, EGLsizeiANDROID keySize,
        void* value, EGLsizeiANDROID valueSize) {
    // ...
    size_t size = mBlobCache->get(key, keySize, value, valueSize);
    // BUG: 沒有 memcpy，只返回了 size
    return size;
}

// 正確的代碼應該確保 mBlobCache->get() 正確填充 value buffer
// 或者在這裡補上 memcpy
```

## 調試步驟
1. 在 `getBlob()` 添加 log 記錄 key 和 size
2. 驗證 cache 是否被正確填充
3. 檢查返回的 value buffer 內容

## 相關知識
- Android 使用 BlobCache 存儲編譯後的 shader
- Cache key 通常是 shader source 的 hash
- Cache miss 會導致每次都重新編譯

## 難度說明
**Medium** - 需要理解 cache 機制並追蹤 get/set 操作的資料流。
