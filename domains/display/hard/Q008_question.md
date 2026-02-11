# CTS 題目：DIS-H008

## 考試資訊
- **難度**: Hard
- **預估時間**: 35 分鐘
- **領域**: Display / Virtual Display Security

---

## 情境描述

你是 Android Framework 團隊的資深工程師。安全團隊報告了一個嚴重的安全漏洞：

**安全報告摘要**：
> 在我們的滲透測試中，發現第三方應用程式能夠成功創建帶有 `VIRTUAL_DISPLAY_FLAG_TRUSTED` 標誌的虛擬顯示器，即使該應用程式沒有聲明 `ADD_TRUSTED_DISPLAY` 權限。這違反了 Android 的安全模型，可能讓惡意應用獲得系統級顯示能力。

**Bug ID**: CVE-2024-XXXX (模擬)
**嚴重程度**: Critical

---

## 失敗的 CTS 測試

```
android.hardware.display.cts.VirtualDisplayTest#testTrustedVirtualDisplay
```

### 測試日誌

```
INSTRUMENTATION_STATUS: class=android.hardware.display.cts.VirtualDisplayTest
INSTRUMENTATION_STATUS: current=12
INSTRUMENTATION_STATUS: test=testTrustedVirtualDisplay

junit.framework.AssertionFailedError: Expected SecurityException to be thrown 
when creating trusted virtual display without ADD_TRUSTED_DISPLAY permission
    at android.hardware.display.cts.VirtualDisplayTest.testTrustedVirtualDisplay(VirtualDisplayTest.java:487)
    at java.lang.reflect.Method.invoke(Native Method)
    at junit.framework.TestCase.runTest(TestCase.java:168)
    at junit.framework.TestCase.runBare(TestCase.java:134)

Test was expecting permission denial but the virtual display was created successfully.
Display ID returned: 42
Display flags: VIRTUAL_DISPLAY_FLAG_TRUSTED | VIRTUAL_DISPLAY_FLAG_PUBLIC

INSTRUMENTATION_STATUS: numtests=25
INSTRUMENTATION_STATUS: stack=...
INSTRUMENTATION_STATUS_CODE: -1
```

---

## 問題

1. **定位問題 (10分)**
   - 指出哪個檔案、哪個方法包含此安全漏洞
   - 說明這個權限檢查應該保護什麼

2. **根因分析 (15分)**
   - 分析條件判斷邏輯的錯誤
   - 說明 De Morgan's Law 在這個 bug 中的作用
   - 解釋為什麼原本應該被拒絕的呼叫現在被允許了

3. **安全影響評估 (5分)**
   - 列出至少 3 個可能的安全風險
   - 解釋為什麼 trusted display 需要特殊權限保護

4. **修復方案 (5分)**
   - 提供正確的條件邏輯
   - 確保系統 UID 不受影響，且非系統呼叫者必須有正確權限

---

## 相關檔案

```
frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
```

重點方法: `createVirtualDisplayInternal()`

---

## 提示

<details>
<summary>提示 1 (扣 2 分)</summary>

觀察權限檢查的條件判斷：
- 什麼情況下應該進行權限檢查？
- 什麼情況下應該跳過權限檢查？

</details>

<details>
<summary>提示 2 (扣 3 分)</summary>

比較以下兩個條件表達式的邏輯等價性：
- `!(A && B)` 等價於 `!A || !B`
- 原始條件和現有條件的真值表是什麼？

</details>

<details>
<summary>提示 3 (扣 5 分)</summary>

問題在約 1557 行的 if 條件。正確邏輯應該是：
「如果呼叫者不是系統 UID **並且**請求了 trusted flag，則檢查權限」

現在的條件是什麼意思？

</details>
