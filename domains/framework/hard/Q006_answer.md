# Q006 答案解析

## Bug 位置

**檔案 1**: `frameworks/base/core/java/android/os/Parcel.java`
```java
public void writeSparseArray(@Nullable SparseArray<Object> val) {
    if (val == null) {
        writeInt(-1);
        return;
    }
    int N = val.size();
    writeInt(N);
    // BUG: 寫入時用 i 作為 key，而非 val.keyAt(i)
    for (int i = 0; i < N; i++) {
        writeInt(i);  // 錯誤：應該是 val.keyAt(i)
        writeValue(val.valueAt(i));
    }
}
```

**檔案 2**: `frameworks/base/core/java/android/os/Parcel.java`
```java
public SparseArray readSparseArray(@Nullable ClassLoader loader) {
    int N = readInt();
    if (N < 0) {
        return null;
    }
    SparseArray sa = new SparseArray(N);
    for (int i = 0; i < N; i++) {
        int key = readInt();
        Object value = readValue(loader);
        sa.put(key, value);  // key 是錯誤的（是索引而非原始 key）
    }
    return sa;
}
```

**檔案 3**: `frameworks/base/core/java/android/os/BaseBundle.java`
```java
private void writeValue(Parcel parcel, String key, Object v, int flags) {
    // ...
    if (v instanceof SparseArray) {
        parcel.writeInt(VAL_SPARSEARRAY);
        parcel.writeSparseArray((SparseArray) v);  // 調用有問題的方法
    }
}
```

## 根本原因

`Parcel.writeSparseArray()` 在序列化 SparseArray 時，錯誤地寫入了索引 `i` 而不是實際的 key `val.keyAt(i)`。這導致稀疏的 key（如 100, Integer.MAX_VALUE）被替換為連續的 0, 1, 2...

## 修復方案

```java
// Parcel.java
public void writeSparseArray(@Nullable SparseArray<Object> val) {
    if (val == null) {
        writeInt(-1);
        return;
    }
    int N = val.size();
    writeInt(N);
    for (int i = 0; i < N; i++) {
        writeInt(val.keyAt(i));  // 正確：寫入實際 key
        writeValue(val.valueAt(i));
    }
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/os/Parcel.java` - 序列化/反序列化
2. `frameworks/base/core/java/android/os/BaseBundle.java` - 值寫入
3. `frameworks/base/core/java/android/util/SparseArray.java` - 數據結構

## 難度分析

**Hard** - 需要理解 SparseArray 的稀疏結構和序列化協議
