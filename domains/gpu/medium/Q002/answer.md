# Q002 Answer: MSAA Config Not Available When Forced

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglChooseConfigImpl()` 中，
當構建 MSAA attrib list 時，將 MSAA 屬性放在了原始 attrib_list 的**後面**，
但 EGL attrib list 以 EGL_NONE 結尾，導致 MSAA 屬性在 EGL_NONE 之後被忽略。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - attrib 組裝邏輯
2. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - force_msaa flag 讀取

## 修復方式
```cpp
// 錯誤的代碼
EGLint aaAttribs[attribCount + 4];
memcpy(aaAttribs, attrib_list, attribCount * sizeof(EGLint));  // 包含 EGL_NONE
aaAttribs[attribCount] = EGL_SAMPLE_BUFFERS;     // 在 EGL_NONE 後面！
aaAttribs[attribCount + 1] = 1;
aaAttribs[attribCount + 2] = EGL_SAMPLES;
aaAttribs[attribCount + 3] = 4;

// 正確的代碼
EGLint aaAttribs[attribCount + 4];
aaAttribs[0] = EGL_SAMPLE_BUFFERS;
aaAttribs[1] = 1;
aaAttribs[2] = EGL_SAMPLES;
aaAttribs[3] = 4;
memcpy(&aaAttribs[4], attrib_list, attribCount * sizeof(EGLint));
```

## 調試步驟
1. Log 出組裝後的 aaAttribs 內容
2. 確認 EGL_NONE 的位置
3. 追蹤驅動實際收到的 attrib list

## 難度說明
**Medium** - 需要理解 attrib list 格式並加 log 追蹤組裝過程。
