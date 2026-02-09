# Q001 Answer: OpenGL ES Version Mismatch

## 問題根因
在 `egl_display.cpp` 的 `initialize()` 函數中，版本字串的設定邏輯有錯誤。
當驅動回報 EGL 1.5（對應 OpenGL ES 3.2）時，版本字串應該設為 1.5，
但 bug 將判斷條件寫錯，導致版本降級為 1.4。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_display.cpp`

## 修復方式
```cpp
// 錯誤的代碼
if ((cnx->major == 1) && (cnx->minor == 4)) {  // BUG: 應該是 minor == 5
    mVersionString = sVersionString15;
    cnx->driverVersion = EGL_MAKE_VERSION(1, 5, 0);
}

// 正確的代碼
if ((cnx->major == 1) && (cnx->minor == 5)) {
    mVersionString = sVersionString15;
    cnx->driverVersion = EGL_MAKE_VERSION(1, 5, 0);
}
```

## 相關知識
- EGL 版本與 OpenGL ES 版本的對應關係
- Android 如何回報 GPU 能力
- CDD 7.1.4.1/C-0-1 要求版本一致性

## 難度說明
**Easy** - 從 fail log 可以直接看出是版本不匹配，只需要在源碼中搜尋版本字串設定邏輯即可定位。
