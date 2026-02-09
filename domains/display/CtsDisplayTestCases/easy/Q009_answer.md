# Display-E-Q009 解答

## Root Cause
在 `OverlayDisplayAdapter.java` 創建 overlay display 時，缺少了 `FLAG_PRESENTATION` 標誌。

原本：
```java
mInfo.flags = DisplayDeviceInfo.FLAG_PRESENTATION | DisplayDeviceInfo.FLAG_TRUSTED;
```

被改成：
```java
mInfo.flags = DisplayDeviceInfo.FLAG_TRUSTED;
```

這導致 overlay display 的 flags 只有 `FLAG_TRUSTED`（0x2）而缺少 `FLAG_PRESENTATION`（0x4）。

## 涉及檔案
- `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 `expected:<6> but was:<2>`
2. 理解 6 = FLAG_PRESENTATION(4) | FLAG_TRUSTED(2)，2 = FLAG_TRUSTED
3. 搜索 overlay display 的創建邏輯
4. 找到 OverlayDisplayAdapter 中設置 flags 的位置

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 OverlayDisplayAdapter.java |
| 正確定位 bug 位置 | 20% | 找到 flags 賦值處 |
| 理解 root cause | 20% | 解釋 FLAG_PRESENTATION 被移除 |
| 修復方案正確 | 10% | 恢復 FLAG_PRESENTATION |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 不理解 Display.FLAG_* 的位元運算
- 在 Display.java 或 DisplayInfo.java 找問題
- 沒有追蹤到 DisplayDeviceInfo 的創建處
