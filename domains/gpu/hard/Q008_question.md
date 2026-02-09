# Q008: Shader Blob Cache Corruption on Multifile Mode

## CTS Test
`android.opengl.cts.EglBlobCacheTest#testShaderCacheMultifile`

## Failure Log
```
FAILED: android.opengl.cts.EglBlobCacheTest#testShaderCacheMultifile

java.lang.AssertionError: Shader cache retrieval failed after app restart
Expected cached shader compilation to succeed, but got:
  - Cache hit: false
  - Shader recompilation required: true
  - Error: EGL_BAD_ACCESS (0x3002)

E/BlobCache: getBlob: key validation failed - corrupted entry detected
E/BlobCache: get: keySize mismatch: expected 4096, got 0
E/egl_cache: getBlob failed for shader key, returning 0

Stack trace:
  at android.opengl.cts.EglBlobCacheTest.verifyShaderCacheHit(EglBlobCacheTest.java:156)
  at android.opengl.cts.EglBlobCacheTest.testShaderCacheMultifile(EglBlobCacheTest.java:89)
```

## 現象描述
在啟用 multifile blob cache 模式 (`ro.egl.blobcache.multifile=true`) 後，
shader cache 在應用重啟後無法正確讀取，導致每次都需要重新編譯 shader。
問題僅在 multifile 模式出現，monolithic 模式正常。

## 提示
- EGL blob cache 用於存儲編譯過的 shader，避免重複編譯
- Android 14 引入了 multifile cache 模式，將每個 entry 存為獨立文件
- 需要理解 `egl_cache.cpp` 中 monolithic 和 multifile 模式的切換邏輯
- 關注 `updateMode()` 和 cache 初始化順序
- 問題可能涉及 cache mode 狀態的 race condition
