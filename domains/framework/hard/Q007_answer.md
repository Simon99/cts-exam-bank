# Q007 答案解析

## Bug 位置

**檔案 1**: `frameworks/base/core/java/android/content/Intent.java`
```java
public void writeToParcel(Parcel out, int flags) {
    // ...
    // BUG: 沒有對 mCategories 進行同步
    final int N = mCategories != null ? mCategories.size() : 0;
    out.writeInt(N);
    for (int i = 0; i < N; i++) {
        out.writeString8(mCategories.valueAt(i));  // 可能拋出 CME
    }
    // ...
}
```

**檔案 2**: `frameworks/base/core/java/android/content/Intent.java`
```java
public @NonNull Intent addCategory(String category) {
    // BUG: 添加時沒有同步
    if (mCategories == null) {
        mCategories = new ArraySet<String>();
    }
    mCategories.add(category);
    return this;
}
```

**檔案 3**: `frameworks/base/core/java/android/util/ArraySet.java`
```java
// ArraySet 本身不是線程安全的
public boolean add(E element) {
    // 修改內部數組，可能導致迭代時 CME
}
```

## 根本原因

1. Intent 的 mCategories 是非同步的 ArraySet
2. addCategory 和 writeToParcel 沒有進行同步
3. 多線程同時讀寫會導致 ConcurrentModificationException

## 修復方案

```java
// Intent.java
private final Object mLock = new Object();

public @NonNull Intent addCategory(String category) {
    synchronized (mLock) {
        if (mCategories == null) {
            mCategories = new ArraySet<String>();
        }
        mCategories.add(category);
    }
    return this;
}

public void writeToParcel(Parcel out, int flags) {
    // ...
    synchronized (mLock) {
        final int N = mCategories != null ? mCategories.size() : 0;
        out.writeInt(N);
        for (int i = 0; i < N; i++) {
            out.writeString8(mCategories.valueAt(i));
        }
    }
    // ...
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/content/Intent.java` - 主要修改
2. `frameworks/base/core/java/android/util/ArraySet.java` - 理解數據結構
3. `frameworks/base/core/java/android/os/Parcel.java` - 序列化入口

## 難度分析

**Hard** - 涉及多線程同步、集合迭代安全
