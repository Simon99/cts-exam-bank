# Q003: 答案解析

## 問題根源

在 `IntentService.java` 的 `onDestroy()` 方法中，沒有調用 `mServiceLooper.quit()` 來停止 HandlerThread。

## Bug 位置

`frameworks/base/core/java/android/app/IntentService.java`

```java
@Override
public void onDestroy() {
    // BUG: 缺少 mServiceLooper.quit();
    // 原本應該有：mServiceLooper.quit();
}
```

## 問題分析

IntentService 工作流程：
1. `onCreate()`: 創建 HandlerThread 並啟動 Looper
2. `onStart()`: 將 Intent 封裝為 Message 發送到 Handler
3. `onDestroy()`: 應該終止 Looper 釋放資源

Bug 移除了 `mServiceLooper.quit()` 調用，導致：
- HandlerThread 永遠不會退出
- 線程洩漏
- 如果後續有 Message，可能導致異常行為

## 正確代碼

```java
@Override
public void onDestroy() {
    mServiceLooper.quit();  // 必須退出 Looper
}
```

## 修復驗證

```bash
atest android.app.cts.IntentServiceTest#testIntentServiceLifeCycle
```

## 難度分類理由

**Easy** - 錯誤訊息明確指出 "Looper not quit"，直接查看 onDestroy() 方法即可發現問題，單一檔案一行修復。
