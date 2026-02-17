# Q010: Intent.getAction() 返回錯誤 action

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testGetAction FAILED

java.lang.AssertionError: expected:<android.intent.action.VIEW> but was:<null>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.content.cts.IntentTest.testGetAction(IntentTest.java:156)
```

## 測試代碼片段

```java
@Test
public void testGetAction() {
    assertNull(mIntent.getAction());
    mIntent.setAction(Intent.ACTION_VIEW);
    assertEquals(Intent.ACTION_VIEW, mIntent.getAction());  // 這裡失敗
}
```

## 背景信息

- `setAction()` 設置 Intent 的 action
- `getAction()` 應該返回之前設置的 action
- Action 是 Intent 最重要的屬性之一

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
