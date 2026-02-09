# Q002 Answer: EGL Extension Missing from Required List

## 問題根因
在 `egl_platform_entries.cpp` 的 `gExtensionString` 定義中，
`EGL_KHR_wait_sync` extension 名稱被錯誤地拼寫為 `EGL_KHR_wait_sinc`（typo）。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp`

## 修復方式
```cpp
// 錯誤的代碼
"EGL_KHR_wait_sinc "                    // strongly recommended

// 正確的代碼
"EGL_KHR_wait_sync "                    // strongly recommended
```

## 相關知識
- EGL extension 字串匹配是精確匹配
- `gExtensionString` 定義了允許暴露給應用的 extensions
- 驅動支援的 extension 必須在此列表中才會被包含在最終的 extension 字串

## 難度說明
**Easy** - fail log 明確指出缺少哪個 extension，只需在源碼中搜尋該 extension 的定義即可發現 typo。
