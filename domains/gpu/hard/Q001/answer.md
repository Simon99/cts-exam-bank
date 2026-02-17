# Q001 Answer: EGL Layer Injection Causes Crash

## 問題根因
在 EGL layer 初始化過程中，存在複雜的依賴關係：
1. `Loader.cpp` 載入驅動並填充函數表
2. `egl_layers.cpp` 載入 layer 並嘗試 wrap 函數
3. `egl_platform_entries.cpp` 提供平台函數

問題出在 `egl_layers.cpp` 的 `initLayer()` 中，它假設 platform 函數表已經被填充，
但實際上在某些路徑下，函數表還是空的。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_layers.cpp` - layer init 順序
2. `frameworks/native/opengl/libs/EGL/Loader.cpp` - driver 載入
3. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - 函數表填充

## 修復方式
```cpp
// 錯誤的代碼 (egl_layers.cpp)
void LayerLoader::loadLayers() {
    // ...
    for (const auto& layer : layers) {
        layer->initLayer(gEGLImpl.platform);  // BUG: platform 可能還沒初始化
    }
}

// 正確的代碼
void LayerLoader::loadLayers() {
    // 確保驅動已載入
    if (!gEGLImpl.dso) {
        ALOGE("Cannot load layers before driver");
        return;
    }
    for (const auto& layer : layers) {
        layer->initLayer(gEGLImpl.platform);
    }
}
```

## 調試步驟
1. 在 Loader::open() 添加 log 記錄載入時間點
2. 在 LayerLoader::loadLayers() 追蹤調用順序
3. 檢查 gEGLImpl.platform 在各時間點的狀態
4. 使用 addr2line 分析 crash 的準確位置

## 相關知識
- EGL layer 是 Android 的 debugging 基礎設施
- Layer 可以 intercept 所有 EGL/GL 調用
- 初始化順序問題是複雜系統中常見的 bug

## 難度說明
**Hard** - 需要理解 3 個檔案的交互：Loader、LayerLoader、platform_entries。
需要追蹤複雜的初始化順序和依賴關係。
