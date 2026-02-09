# Display-E-Q008 解答

## Root Cause
在 `Display.java` 的 `getRefreshRate()` 方法中，返回值被錯誤地硬編碼為 0.0f。

原本：
```java
public float getRefreshRate() {
    synchronized (mLock) {
        updateDisplayInfoLocked();
        return mDisplayInfo.getRefreshRate();
    }
}
```

被改成：
```java
public float getRefreshRate() {
    synchronized (mLock) {
        updateDisplayInfoLocked();
        return 0.0f;
    }
}
```

## 涉及檔案
- `frameworks/base/core/java/android/view/Display.java`

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 `expected:<60.0> but was:<0.0>`
2. 理解是 getRefreshRate() 返回錯誤
3. 搜索 `getRefreshRate` 的實現
4. 在 Display.java 找到被修改的返回值

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 Display.java |
| 正確定位 bug 位置 | 20% | 找到 getRefreshRate() 方法 |
| 理解 root cause | 20% | 解釋返回值應來自 mDisplayInfo |
| 修復方案正確 | 10% | 恢復正確返回 mDisplayInfo.getRefreshRate() |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 在 DisplayInfo 或 DisplayMode 中找問題
- 沒有注意 CTS log 中的具體數值對比
- 試圖在 SurfaceFlinger 層找刷新率設定
