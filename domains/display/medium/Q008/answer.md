# 解答：Display Override Info 更新異常

## Bug 位置

`frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

方法：`setDisplayInfoOverrideFromWindowManagerLocked()` 第 307 行

## Bug 描述

條件判斷邏輯被反轉：

```java
// 錯誤的程式碼
} else if (mOverrideDisplayInfo.equals(info)) {
    mOverrideDisplayInfo.copyFrom(info);
    mInfo.set(null);
    return true;
}
```

應該是：

```java
// 正確的程式碼
} else if (!mOverrideDisplayInfo.equals(info)) {
    mOverrideDisplayInfo.copyFrom(info);
    mInfo.set(null);
    return true;
}
```

## Bug 分析

### 原因

條件判斷中的 `!`（NOT）被移除，導致邏輯完全反轉：

| 情況 | 原本行為 | Bug 行為 |
|------|---------|---------|
| info 與現有 override 不同 | 更新 override，返回 true | 不更新，返回 false |
| info 與現有 override 相同 | 不更新，返回 false | 更新 override，返回 true |

### 為什麼會導致 testGetMetrics 失敗

1. **正常流程**：Window Manager 改變 display 的 rotation 或 insets 時，會調用此方法傳入新的 DisplayInfo
2. **Bug 影響**：由於新的 info 與舊的不同，條件 `mOverrideDisplayInfo.equals(info)` 為 false，不會進入更新分支
3. **結果**：`mOverrideDisplayInfo` 不會被更新，`mInfo` 也不會被清除重新計算
4. **CTS 失敗**：`Display.getMetrics()` 返回的是過時的值，與預期的新值不符

### 方法邏輯說明

```java
public boolean setDisplayInfoOverrideFromWindowManagerLocked(DisplayInfo info) {
    if (info != null) {
        if (mOverrideDisplayInfo == null) {
            // 首次設置 override：創建新物件
            mOverrideDisplayInfo = new DisplayInfo(info);
            mInfo.set(null);  // 清除緩存，強制重新計算
            return true;
        } else if (!mOverrideDisplayInfo.equals(info)) {  // ← Bug 在這裡
            // override 已存在且有變化：更新
            mOverrideDisplayInfo.copyFrom(info);
            mInfo.set(null);  // 清除緩存
            return true;
        }
        // override 已存在且無變化：不做事
    } else if (mOverrideDisplayInfo != null) {
        // 清除 override
        mOverrideDisplayInfo = null;
        mInfo.set(null);
        return true;
    }
    return false;  // 沒有變化
}
```

## 修復方案

```diff
-            } else if (mOverrideDisplayInfo.equals(info)) {
+            } else if (!mOverrideDisplayInfo.equals(info)) {
```

## 關鍵知識點

1. **State Management**：Display 系統需要正確追蹤 override 狀態的變化
2. **條件判斷**：equals() 比較的結果需要正確處理，注意 `!` 運算符
3. **Cache Invalidation**：`mInfo.set(null)` 是清除緩存的關鍵，確保下次獲取時重新計算
4. **返回值語義**：返回 true 表示有變更，系統需要通知監聽者
