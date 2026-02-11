# CTS 面試題：Display - Easy - Q001

## 題目資訊
- **難度**: Easy
- **預估時間**: 15 分鐘
- **CTS 測試**: `android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking`
- **CTS 模組**: `CtsDisplayTestCases`

## 情境描述

你正在審查 Android Display 子系統的程式碼變更。一個開發者提交了一個「效能優化」的 patch，聲稱改善了亮度事件的遍歷效率。

在 code review 過程中，你需要找出這個 patch 中的問題。

## 失敗的 CTS 測試日誌

```
Test: android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking
Result: FAIL
Failure: java.lang.ArrayIndexOutOfBoundsException
    at com.android.server.display.BrightnessTracker.getEvents(BrightnessTracker.java:303)
    at android.hardware.display.DisplayManager.getBrightnessEvents(DisplayManager.java:892)
    at android.hardware.display.cts.BrightnessTest.testBrightnessSliderTracking(BrightnessTest.java:156)
```

## 有問題的程式碼區段

請審查以下 `BrightnessTracker.java` 的 `getEvents()` 方法：

```java
public ParceledListSlice<BrightnessChangeEvent> getEvents(int userId, boolean includePackage) {
    BrightnessChangeEvent[] events;
    synchronized (mEventsLock) {
        events = mEvents.toArray();
    }
    int[] profiles = mInjector.getProfileIds(mUserManager, userId);
    Map<Integer, Boolean> toRedact = new HashMap<>();
    for (int i = 0; i < profiles.length; ++i) {
        int profileId = profiles[i];
        boolean redact = (!includePackage) || profileId != userId;
        toRedact.put(profiles[i], redact);
    }
    ArrayList<BrightnessChangeEvent> out = new ArrayList<>(events.length);
    for (int i = 0; i <= events.length; ++i) {  // <-- 審查這行
        Boolean redact = toRedact.get(events[i].userId);
        if (redact != null) {
            if (!redact) {
                out.add(events[i]);
            } else {
                BrightnessChangeEvent event = new BrightnessChangeEvent((events[i]),
                        /* redactPackage */ true);
                out.add(event);
            }
        }
    }
    return new ParceledListSlice<>(out);
}
```

## 問題

1. **找出 Bug**: 這段程式碼中的錯誤是什麼？
2. **解釋原因**: 為什麼這個錯誤會導致 `ArrayIndexOutOfBoundsException`？
3. **提出修復**: 如何正確修復這個問題？
4. **影響分析**: 這個 bug 會在什麼情況下觸發？

## 提示

- 仔細檢查迴圈的邊界條件
- 考慮陣列索引的有效範圍
- 這是一個常見的 off-by-one 錯誤類型
