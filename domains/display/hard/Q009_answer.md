# CTS 失敗分析題 - DIS-H009 答案

## Bug 識別（20 分）

### 問題概述

這個 bug 包含**兩個相互關聯的錯誤**，造成跨函數的狀態不一致：

#### Bug 1: setRefreshRateSwitchingTypeInternal() 邊界檢查錯誤
```java
void setRefreshRateSwitchingTypeInternal(@DisplayManager.SwitchingType int newValue) {
    // BUG: 錯誤的上界檢查 - 排除了 SWITCHING_TYPE_RENDER_FRAME_RATE_ONLY (3)
    if (newValue < DisplayManager.SWITCHING_TYPE_NONE
            || newValue > DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
        newValue = DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
    }
    mDisplayModeDirector.setModeSwitchingType(newValue);
}
```

**問題**：邊界檢查使用 `> SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS (2)` 作為上界，但合法值包括 `SWITCHING_TYPE_RENDER_FRAME_RATE_ONLY (3)`，導致值 3 被錯誤地替換為 1。

#### Bug 2: getRefreshRateSwitchingTypeInternal() 狀態轉換錯誤
```java
int getRefreshRateSwitchingTypeInternal() {
    int type = mDisplayModeDirector.getModeSwitchingType();
    // BUG: 錯誤的兼容性映射
    if (type == DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
        return DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
    }
    return type;
}
```

**問題**：即使成功設置了 `SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS (2)`，讀取時也會被錯誤地轉換為 `SWITCHING_TYPE_WITHIN_GROUPS (1)`。

### Bug 類型
- **狀態不一致 (STATE)**：set/get 返回不匹配的值
- **邊界錯誤 (BOUND)**：對合法值範圍的錯誤判斷

---

## 根因分析（30 分）

### 狀態追蹤

```
CTS 測試執行流程：

1. 測試調用 setRefreshRateSwitchingType(2)  // SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS
        ↓
2. setRefreshRateSwitchingTypeInternal(2) 執行
   - 邊界檢查: 2 > 2 → false, 通過檢查
   - mDisplayModeDirector.setModeSwitchingType(2) 成功執行
   - 內部狀態: mModeSwitchingType = 2 ✓
        ↓
3. 測試調用 getRefreshRateSwitchingType() 驗證
        ↓
4. getRefreshRateSwitchingTypeInternal() 執行
   - type = mDisplayModeDirector.getModeSwitchingType() → 2
   - if (type == 2) → true
   - return 1  // 錯誤！返回 SWITCHING_TYPE_WITHIN_GROUPS
        ↓
5. CTS 斷言失敗: Expected 2, Actual 1
```

### 受影響的值分析

| Switching Type | 值 | set 行為 | get 行為 | 狀態一致？ |
|----------------|-----|----------|----------|-----------|
| NONE | 0 | 正常存儲 | 正常返回 | ✓ |
| WITHIN_GROUPS | 1 | 正常存儲 | 正常返回 | ✓ |
| ACROSS_AND_WITHIN_GROUPS | 2 | 正常存儲 | **錯誤返回 1** | ✗ |
| RENDER_FRAME_RATE_ONLY | 3 | **錯誤替換為 1** | 正常返回 | ✗ |

### 為什麼 CTS 測試失敗

`testModeSwitchOnPrimaryDisplay` 測試：
1. 設置 `SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS (2)` - 成功
2. 讀取並驗證 - 返回 `1` 而非 `2`
3. 斷言失敗

---

## 修復方案（30 分）

### 正確的程式碼

```java
void setRefreshRateSwitchingTypeInternal(@DisplayManager.SwitchingType int newValue) {
    // 移除錯誤的邊界檢查，讓 DisplayModeDirector 處理驗證
    mDisplayModeDirector.setModeSwitchingType(newValue);
}

@DisplayManager.SwitchingType
int getRefreshRateSwitchingTypeInternal() {
    // 直接返回，不做任何轉換
    return mDisplayModeDirector.getModeSwitchingType();
}
```

### 修復 Patch

```diff
 void setRefreshRateSwitchingTypeInternal(@DisplayManager.SwitchingType int newValue) {
-    // Validate switching type bounds
-    if (newValue < DisplayManager.SWITCHING_TYPE_NONE
-            || newValue > DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
-        newValue = DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
-    }
     mDisplayModeDirector.setModeSwitchingType(newValue);
 }

 @DisplayManager.SwitchingType
 int getRefreshRateSwitchingTypeInternal() {
-    int type = mDisplayModeDirector.getModeSwitchingType();
-    // Map cross-group switching to within-groups for compatibility
-    if (type == DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
-        return DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
-    }
-    return type;
+    return mDisplayModeDirector.getModeSwitchingType();
 }
```

### 修復原理

1. **移除錯誤的邊界檢查**：原始代碼已經通過 `@DisplayManager.SwitchingType` 註解和 `DisplayModeDirector` 內部驗證來確保值的有效性
2. **移除錯誤的值映射**：不應在讀取時修改已存儲的值，這違反了 get/set 的基本契約
3. **保持透明傳遞**：讓底層 `DisplayModeDirector` 負責所有狀態管理

---

## 深入分析（20 分）

### 用戶體驗影響

1. **設置界面不一致**：用戶選擇 "跨組刷新率切換" 後，系統顯示可能仍為 "組內切換"
2. **實際行為受限**：因為內部狀態正確，實際刷新率切換行為可能正常，但這會造成 UI 和實際行為不一致
3. **RENDER_FRAME_RATE_ONLY 完全失效**：設置值 3 會被替換為 1，用戶無法使用此模式

### SWITCHING_TYPE_RENDER_FRAME_RATE_ONLY (3) 行為

```
設置流程：
setRefreshRateSwitchingType(3)
→ setRefreshRateSwitchingTypeInternal(3)
→ 邊界檢查: 3 > 2 → true (被視為無效)
→ newValue = 1 (替換為 WITHIN_GROUPS)
→ mDisplayModeDirector.setModeSwitchingType(1)

結果：
- 用戶設置 RENDER_FRAME_RATE_ONLY (3)
- 系統實際存儲 WITHIN_GROUPS (1)
- 完全不同的刷新率切換行為
```

### 預防措施

1. **單元測試**：
   ```java
   @Test
   public void testSetGetConsistency_AllTypes() {
       for (int type = 0; type <= 3; type++) {
           service.setRefreshRateSwitchingType(type);
           assertEquals("Type " + type + " inconsistent", 
                       type, service.getRefreshRateSwitchingType());
       }
   }
   ```

2. **整合測試**：驗證 set 後立即 get 返回相同值

3. **Code Review 檢查項**：
   - get/set 對稱性
   - 邊界值使用常量而非硬編碼
   - 避免在 getter 中修改/轉換值

4. **設計原則**：
   - 驗證邏輯應集中在一處（如 DisplayModeDirector）
   - getter 不應包含業務邏輯
   - 使用 @SwitchingType 註解讓編譯器輔助檢查

---

## 總結

這是一個典型的**跨函數狀態不一致** bug：
- `set` 中的錯誤邊界檢查會破壞部分輸入值
- `get` 中的錯誤映射會破壞返回值
- 兩個錯誤互相獨立但組合後造成嚴重的一致性問題
- 需要同時理解 setter 和 getter 的行為才能完整分析問題
