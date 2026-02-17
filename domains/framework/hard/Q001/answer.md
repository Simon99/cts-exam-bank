# Q001 答案解析

## Bug 位置

**主要檔案**: `frameworks/base/core/java/android/os/Parcel.java`

**問題代碼**:
```java
private <T extends Parcelable> T readParcelableInternal(
        @Nullable ClassLoader loader, @Nullable Class<T> clazz, int flags) {
    String name = readString();
    if (name == null) {
        return null;
    }
    
    Parcelable.Creator<?> creator = null;
    synchronized (sCreators) {
        HashMap<String, Parcelable.Creator<?>> map = sCreators.get(loader);
        if (map != null) {
            creator = map.get(name);
        }
    }
    
    if (creator == null) {
        // BUG: 沒有正確處理 ClassLoader 查找 CREATOR
        Class<?> c = Class.forName(name);  // 應該使用 loader
        // ...
    }
    // ...
}
```

## 根本原因

`readParcelableInternal()` 在查找 CREATOR 時沒有使用傳入的 ClassLoader。使用默認的 `Class.forName(name)` 會使用系統 ClassLoader，無法找到應用自定義的 Parcelable 類。

## 完整分析

**涉及的調用鏈**：
1. `Intent.getParcelableExtra()` → 
2. `Bundle.getParcelable()` →
3. `BaseBundle.getValue()` → 
4. `Parcel.readValue()` →
5. `Parcel.readParcelableInternal()` ← **問題在這裡**

## 修復方案

```java
private <T extends Parcelable> T readParcelableInternal(
        @Nullable ClassLoader loader, @Nullable Class<T> clazz, int flags) {
    String name = readString();
    if (name == null) {
        return null;
    }
    
    // ... creator cache lookup
    
    if (creator == null) {
        // 正確：使用傳入的 ClassLoader
        Class<?> c = Class.forName(name, true, loader);
        // ...
    }
    // ...
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/os/Parcel.java` - 主要修改
2. `frameworks/base/core/java/android/os/BaseBundle.java` - 理解調用鏈
3. `frameworks/base/core/java/android/content/Intent.java` - 理解入口

## 調試過程

1. 分析堆棧：從 Intent → Bundle → Parcel
2. 在每層添加 log 確認 ClassLoader 傳遞
3. 發現 Parcel.readParcelableInternal 丟失了 ClassLoader
4. 追蹤 CREATOR 查找邏輯

## 難度分析

**Hard** - 需要理解完整的序列化鏈路，涉及 3 個核心檔案的交互
