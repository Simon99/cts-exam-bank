# Q002 Answer: UnregisterListener Throws NullPointerException

## 問題根因
在 `SensorManager.java` 的 `unregisterListener()` 方法中，
應該在方法開頭就檢查 listener 是否為 null，如果是 null 就直接返回。

Bug 是 null 檢查被放在了錯誤的位置（在存取 listener 之後），
導致在檢查之前就已經對 null 進行操作而崩潰。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼（null 檢查太晚）
public void unregisterListener(SensorEventListener listener) {
    // 先做了一些操作...
    mListenerMap.remove(listener);  // 這裡已經使用了 listener
    if (listener == null) {
        return;
    }
    unregisterListenerImpl(listener);
}

// 正確的代碼（null 檢查在開頭）
public void unregisterListener(SensorEventListener listener) {
    if (listener == null) {
        return;
    }
    mListenerMap.remove(listener);
    unregisterListenerImpl(listener);
}
```

## 相關知識
- Android API 設計原則：對無效輸入要容錯
- null 檢查應該在方法開頭執行
- unregisterListener(null) 是常見的錯誤使用情況

## 難度說明
**Easy** - NullPointerException 指向確切的行號，直接看 null 檢查的順序就能發現問題。
