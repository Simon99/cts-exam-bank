# CTS 題目：Display Access 存取權限判斷錯誤

## 背景

你正在除錯 Android 14 Display 子系統。CTS 測試報告以下失敗：

```
android.display.cts.DisplayTest#testGetDisplays FAILED
```

測試發現：呼叫 `DisplayManager.getDisplays()` 取得系統上所有 display 時，結果中缺少預期的 secondary display（overlay display）。測試預期至少能取得 default display 和 secondary display，但實際只取得 default display。

## 症狀

1. **Secondary display 無法被取得** — 應用程式無法看到系統上的 public overlay display
2. **getDisplays() 回傳不完整** — 只回傳 default display，缺少其他 public display
3. **應用無法使用多螢幕功能** — 需要存取多個螢幕的應用程式功能異常

## 測試環境

- 設備：Pixel 7 (panther)
- Android 版本：14 (API 34)
- 測試模組：CtsDisplayTestCases

## CTS 測試程式碼片段

```java
@Test
public void testGetDisplays() {
    Display[] displays = mDisplayManager.getDisplays();
    assertNotNull(displays);
    assertTrue(2 <= displays.length);  // 預期至少有 2 個 display
    
    boolean hasDefaultDisplay = false;
    boolean hasSecondaryDisplay = false;
    for (Display display : displays) {
        if (display.getDisplayId() == DEFAULT_DISPLAY) {
            hasDefaultDisplay = true;
        }
        if (isSecondaryDisplay(display)) {  // 檢查 overlay display
            hasSecondaryDisplay = true;
        }
    }
    assertTrue(hasDefaultDisplay);
    assertTrue(hasSecondaryDisplay);  // 這裡失敗！
}
```

## 可疑區域

`Display.hasAccess()` 方法負責判斷某個 UID 是否有權限存取特定 display。這個方法在 `DisplayManager.getDisplays()` 的內部實作中被呼叫，用來過濾出應用程式可以存取的 display。

## 你的任務

1. 分析 `Display.hasAccess()` 的存取權限判斷邏輯
2. 找出導致 public display 無法被正確存取的 bug
3. 提供正確的修復方案

## 提示

- 檢查 FLAG_PRIVATE 標誌的判斷邏輯
- 注意比較運算子的方向性
- 思考什麼情況下 public display 應該允許所有人存取
