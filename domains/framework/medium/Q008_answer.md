# Q008 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/Parcel.java`

**問題代碼**:
```java
public final Bundle readBundle(@Nullable ClassLoader loader) {
    int length = readInt();
    if (length < 0) {
        return null;
    }
    final Bundle bundle = new Bundle(this, length);
    // bundle.setClassLoader(loader);  // BUG: 沒有設置 ClassLoader
    return bundle;
}
```

## 根本原因

`Parcel.readBundle(ClassLoader)` 方法沒有將傳入的 ClassLoader 設置給新創建的 Bundle。導致 Bundle 使用默認的 ClassLoader，無法找到應用自定義的 Parcelable 類。

## 修復方案

```java
public final Bundle readBundle(@Nullable ClassLoader loader) {
    int length = readInt();
    if (length < 0) {
        return null;
    }
    final Bundle bundle = new Bundle(this, length);
    bundle.setClassLoader(loader);  // 正確：設置 ClassLoader
    return bundle;
}
```

## 調試過程

1. ClassNotFoundException 說明 ClassLoader 不對
2. 追蹤 readBundle(ClassLoader) 方法
3. 發現 loader 參數沒有被使用
4. Bundle 的 setClassLoader 沒有被調用

## 涉及檔案

- `frameworks/base/core/java/android/os/Parcel.java`
- `frameworks/base/core/java/android/os/Bundle.java`（理解 ClassLoader）

## 難度分析

**Medium** - 需要理解 ClassLoader 在序列化中的作用
