# DIS-M005 解答

## Bug 位置

**文件**: `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**方法**: `createVirtualDisplayLocked()`

**問題程式碼**（約第 127-132 行）:

```java
boolean isPublic = (flags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0;

// Validate that non-public displays have proper authorization
if (!isPublic && projection == null) {
    Slog.w(TAG, "Private virtual display requires media projection authorization");
    return null;
}
```

## 問題分析

### 錯誤的安全假設

開發者錯誤地認為 private virtual display 需要 MediaProjection 授權才能創建。這是對 virtual display 權限模型的誤解。

### Public vs Private Virtual Display 的區別

| 特性 | Private Display | Public Display |
|------|-----------------|----------------|
| 可見性 | 只對創建者可見 | 其他應用也可見 |
| 權限需求 | 較低（自己的內容） | 較高（跨應用共享） |
| MediaProjection | 不需要 | 可能需要（取決於用途） |
| 安全風險 | 低 | 較高 |

### 為什麼 Private Display 不需要 Projection

1. **自我隔離**: Private display 只對創建它的應用可見，不存在跨應用的資訊洩漏風險
2. **常見用途**: 離屏渲染、圖像處理、VR 應用的渲染目標
3. **設計原則**: Android 的權限模型是基於「最小權限原則」——只在必要時才要求額外權限

### MediaProjection 的正確用途

MediaProjection 主要用於：
- 屏幕錄製
- 屏幕截圖
- 屏幕共享

這些操作涉及捕獲其他應用的內容，因此需要用戶明確授權。

## 修復方案

### 方案 1：直接移除錯誤檢查（推薦）

```java
// 刪除以下程式碼：
// boolean isPublic = (flags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0;
// if (!isPublic && projection == null) {
//     Slog.w(TAG, "Private virtual display requires media projection authorization");
//     return null;
// }
```

### 方案 2：修正條件邏輯（如果確實需要某種檢查）

如果是為了某種特定場景添加檢查，應該更精確地定義條件：

```java
// 只有在需要捕獲其他應用內容時才需要 projection
boolean needsProjection = (flags & VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR) != 0;
if (needsProjection && projection == null) {
    Slog.w(TAG, "Auto-mirror display requires media projection authorization");
    return null;
}
```

## 修復後的 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java
@@ -124,14 +124,6 @@ final class VirtualDisplayAdapter extends DisplayAdapter {
 
         String name = virtualDisplayConfig.getName();
         boolean secure = (flags & VIRTUAL_DISPLAY_FLAG_SECURE) != 0;
-        boolean isPublic = (flags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0;
-
-        // Validate that non-public displays have proper authorization
-        if (!isPublic && projection == null) {
-            Slog.w(TAG, "Private virtual display requires media projection authorization");
-            return null;
-        }
 
         IBinder displayToken = mSurfaceControlDisplayFactory.createDisplay(name, secure,
                 virtualDisplayConfig.getRequestedRefreshRate());
```

## 學習重點

1. **理解 Android 的 Virtual Display 權限模型**: Private display 是低風險操作，不需要額外授權
2. **避免過度設計安全檢查**: 錯誤的安全檢查可能破壞合法功能
3. **閱讀 CTS 測試以理解預期行為**: `testPrivateVirtualDisplay` 明確測試了不需要 projection 就能創建 private display

## 相關文件

- `frameworks/base/core/java/android/hardware/display/VirtualDisplay.java`
- `cts/tests/tests/display/src/android/hardware/display/cts/VirtualDisplayTest.java`
- Android Developer Documentation: Virtual displays
