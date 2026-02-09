# Q002: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: Activity.java
在 `dispatchActivityCreated()` 中，Activity 自己的 callback 先於 Application callback 被調用。

### Bug 2: Application.java
在 `dispatchActivityCreated()` 中，回調使用反向迭代，導致後註冊的 callback 先執行。

## Bug 1 位置

`frameworks/base/core/java/android/app/Activity.java`

```java
private void dispatchActivityCreated(@Nullable Bundle savedInstanceState) {
    // BUG: Activity callback 先於 Application callback
    if (mActivityCallback != null) {
        mActivityCallback.onActivityCreated(this, savedInstanceState);
    }
    getApplication().dispatchActivityCreated(this, savedInstanceState);
    // 應該是先 Application，再 Activity
}
```

## Bug 2 位置

`frameworks/base/core/java/android/app/Application.java`

```java
/* package */ void dispatchActivityCreated(@NonNull Activity activity,
        @Nullable Bundle savedInstanceState) {
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        // BUG: 反向迭代
        for (int i = callbacks.length - 1; i >= 0; i--) {
            ((ActivityLifecycleCallbacks)callbacks[i]).onActivityCreated(activity,
                    savedInstanceState);
        }
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 Activity.dispatchActivityCreated 中
Log.d("Activity", "dispatchActivityCreated - before app dispatch");
Log.d("Activity", "dispatchActivityCreated - after app dispatch");

// 在 Application.dispatchActivityCreated 中  
Log.d("Application", "dispatchActivityCreated callback index: " + i);
```

2. **觀察 log**:
```
D Activity: dispatchActivityCreated - calling activity callback
D Activity: dispatchActivityCreated - before app dispatch
D Application: dispatchActivityCreated callback index: 2  // 反向！
D Application: dispatchActivityCreated callback index: 1
D Application: dispatchActivityCreated callback index: 0
```

3. **定位問題**: 
   - Activity 的 callback 在 Application 之前被調用
   - Application 的 callbacks 以反向順序執行

## 問題分析

### Bug 1 分析
Activity.java 中 `dispatchActivityCreated` 調用順序錯誤，應該先讓 Application dispatch，再調用 Activity 自己的 callback。

### Bug 2 分析
Application.java 中使用反向迭代，破壞了註冊順序的語義。

## 正確代碼

### 修復 Bug 1 (Activity.java)
```java
private void dispatchActivityCreated(@Nullable Bundle savedInstanceState) {
    getApplication().dispatchActivityCreated(this, savedInstanceState);
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        for (int i = 0; i < callbacks.length; i++) {
            ((Application.ActivityLifecycleCallbacks) callbacks[i]).onActivityCreated(this,
                    savedInstanceState);
        }
    }
}
```

### 修復 Bug 2 (Application.java)
```java
/* package */ void dispatchActivityCreated(@NonNull Activity activity,
        @Nullable Bundle savedInstanceState) {
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        for (int i = 0; i < callbacks.length; i++) {  // 正向迭代
            ((ActivityLifecycleCallbacks)callbacks[i]).onActivityCreated(activity,
                    savedInstanceState);
        }
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ActivityCallbacksTest#testActivityCallbackOrder
```

## 難度分類理由

**Medium** - 需要理解 Activity 生命周期的完整回調機制，追蹤跨 Activity 和 Application 兩個類別的調用流程，涉及兩個檔案的協作問題。
