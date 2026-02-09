# Q008: GnssNavigationMessage.getType() Returns Invalid Value

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testRegisterGnssNavigationMessageCallback
java.lang.AssertionError: 
Expected message type in range [0x0101, 0x0104] for GPS L1 C/A
Actual: 0
    at android.location.cts.fine.LocationManagerFineTest.testRegisterGnssNavigationMessageCallback(LocationManagerFineTest.java:945)
```

## 失敗的測試代碼片段

```java
@Test
public void testRegisterGnssNavigationMessageCallback() throws Exception {
    GnssNavigationMessageCapture capture = new GnssNavigationMessageCapture(mContext);
    
    mManager.registerGnssNavigationMessageCallback(DIRECT_EXECUTOR, capture);
    
    try {
        GnssNavigationMessage message = capture.getNextNavigationMessage(30000);
        assertThat(message).isNotNull();
        
        int type = message.getType();
        // GPS L1 C/A 訊息類型應該在 0x0101 - 0x0104 範圍內
        assertThat(type).isIn(Range.closed(0x0101, 0x0104));  // ← 失敗：type = 0
    } finally {
        mManager.unregisterGnssNavigationMessageCallback(capture);
    }
}
```

## 問題描述

GNSS 導航訊息的類型 (`getType()`) 應該返回有效的訊息類型碼，但實際返回 0（無效值）。

## 相關源碼位置

- `frameworks/base/location/java/android/location/GnssNavigationMessage.java` — 訊息數據類
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssNavigationMessageProvider.java` — 訊息 Provider

## 調試提示

1. 訊息類型是如何從 HAL 傳遞到 Framework 的？
2. Provider 在轉發訊息時是否正確設定了所有欄位？

## 任務

找出訊息類型丟失的 bug 並修復。
