# Q004 答案解析

## Bug 位置

**涉及多個檔案的交互問題**

**檔案 1**: `frameworks/base/core/java/android/os/BaseBundle.java`
```java
private void unparcel() {
    synchronized (this) {
        final Parcel source = mParcelledData;
        if (source != null) {
            // ...
            readFromParcelInner(source);
            // BUG: 沒有在讀取後清理 Binder 引用
            // source 中的 Binder 引用仍然存在
        }
    }
}
```

**檔案 2**: `frameworks/base/core/java/android/os/Parcel.java`
```java
public final IBinder readStrongBinder() {
    // BUG: 讀取 Binder 時增加了引用計數
    // 但如果 Bundle 被重複 unparcel，會多次增加計數
    return nativeReadStrongBinder(mNativePtr);
}
```

**檔案 3**: `frameworks/base/core/java/android/os/Bundle.java`
```java
public void clear() {
    super.clear();
    // BUG: clear 時沒有減少 Binder 引用計數
}
```

## 根本原因

1. Bundle 的 lazy unparceling 機制在多次訪問時可能重複創建 Binder 引用
2. Bundle clear 或被 GC 時沒有正確減少 Binder 引用計數
3. mParcelledData 中保持著 Binder 的強引用

## 修復方案

```java
// BaseBundle.java
private void unparcel() {
    synchronized (this) {
        final Parcel source = mParcelledData;
        if (source != null) {
            if (mMap == null) {
                mMap = new ArrayMap<>();
            }
            readFromParcelInner(source);
            mParcelledData = null;  // 清除引用
            source.recycle();  // 正確回收 Parcel
        }
    }
}

// Bundle.java
public void clear() {
    // 清理 Binder 引用
    if (mMap != null) {
        for (Object value : mMap.values()) {
            if (value instanceof IBinder) {
                // 通知 Binder 減少引用
            }
        }
    }
    super.clear();
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/os/BaseBundle.java`
2. `frameworks/base/core/java/android/os/Parcel.java`
3. `frameworks/base/core/java/android/os/Bundle.java`

## 調試過程

1. 使用 Debug.getBinderLocalObjectCount() 監控 Binder 數量
2. 在 Bundle 各生命週期節點添加 log
3. 發現 unparcel 後 mParcelledData 沒有被清理
4. Parcel 沒有被 recycle 導致 Binder 引用保留

## 難度分析

**Hard** - 涉及資源管理、引用計數、多個類的生命週期交互
