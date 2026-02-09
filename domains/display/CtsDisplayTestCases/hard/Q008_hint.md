# Q008 提示

## 提示 1（方向性）
問題出在 VirtualDisplayAdapter 中。觀察 `VirtualDisplayDevice` 類別有哪些與 display state 相關的成員變量。

<details>
<summary>點擊展開提示 2</summary>

## 提示 2（關鍵變量）
注意 `VirtualDisplayDevice` 中有兩個 state 相關的變量：
- `mDisplayState` (int)
- `mIsDisplayOn` (boolean)

這兩個變量分別在哪些方法中被更新？

</details>

<details>
<summary>點擊展開提示 3</summary>

## 提示 3（方法分析）
比較兩個方法：
1. `requestDisplayStateLocked(int state, ...)` - 由系統電源管理調用
2. `setDisplayState(boolean isOn)` - 由應用控制調用

`requestDisplayStateLocked` 更新了哪個變量？它有沒有同時更新另一個變量？

</details>

<details>
<summary>點擊展開提示 4</summary>

## 提示 4（DisplayDeviceInfo）
在 `getDisplayDeviceInfoLocked()` 方法中（約第 560 行），找到這一行：
```java
mInfo.state = mIsDisplayOn ? Display.STATE_ON : Display.STATE_OFF;
```

`DisplayDeviceInfo.state` 是根據哪個變量決定的？如果 `requestDisplayStateLocked` 只更新 `mDisplayState` 而不更新 `mIsDisplayOn`，會發生什麼？

</details>

<details>
<summary>點擊展開提示 5（解答方向）</summary>

## 提示 5（修復方向）
在 `requestDisplayStateLocked` 中，需要同步更新 `mIsDisplayOn`：

```java
if (state != mDisplayState) {
    mDisplayState = state;
    
    // 需要新增：同步 mIsDisplayOn
    boolean isOn = (state != Display.STATE_OFF);
    if (mIsDisplayOn != isOn) {
        mIsDisplayOn = isOn;
        mInfo = null;  // 失效緩存
        sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
    }
    
    // ... callback 邏輯
}
```

</details>
