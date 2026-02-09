# Q006 Answer: EGL Object Reference Not Tracked

## 問題根因
在 `egl_display.cpp` 的 `removeObject()` 函數中，
從 objects set 移除 object 的操作被註解掉了，
導致已銷毀的 object 仍然被認為是有效的。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - object tracking
2. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - object 生命週期

## 修復方式
```cpp
// 錯誤的代碼
void egl_display_t::removeObject(egl_object_t* object) {
    std::lock_guard<std::mutex> _l(lock);
    // objects.erase(object);  // BUG: 被註解掉了
}

// 正確的代碼
void egl_display_t::removeObject(egl_object_t* object) {
    std::lock_guard<std::mutex> _l(lock);
    objects.erase(object);
}
```

## 調試步驟
1. 在 addObject/removeObject 添加 log
2. 追蹤 context 的生命週期
3. 檢查 objects set 在 destroy 前後的大小

## 相關知識
- EGL object 使用 set 追蹤所有活動 objects
- getObject() 通過檢查 set 來驗證有效性
- 不從 set 移除會導致 use-after-free 無法被檢測

## 難度說明
**Medium** - 需要理解 object tracking 機制並追蹤 add/remove 操作。
