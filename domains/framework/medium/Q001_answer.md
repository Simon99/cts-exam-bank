# Q001 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
void writeToParcelInner(Parcel parcel, int flags) {
    final ArrayMap<String, Object> map;
    synchronized (this) {
        unparcel();
        map = mMap;
    }
    final int N = map.size();
    // parcel.writeInt(N);  // BUG: 沒有寫入元素數量
    for (int i = 0; i < N; i++) {
        writeValue(parcel, map.keyAt(i), map.valueAt(i), flags);
    }
}
```

## 根本原因

`writeToParcelInner()` 方法在寫入 Bundle 內容前，沒有先寫入元素數量 N。這導致 `readFromParcelInner()` 無法知道要讀取多少元素，從而無法正確恢復數據。

## 修復方案

```java
void writeToParcelInner(Parcel parcel, int flags) {
    final ArrayMap<String, Object> map;
    synchronized (this) {
        unparcel();
        map = mMap;
    }
    final int N = map.size();
    parcel.writeInt(N);  // 正確：先寫入元素數量
    for (int i = 0; i < N; i++) {
        writeValue(parcel, map.keyAt(i), map.valueAt(i), flags);
    }
}
```

## 調試過程

1. 加 log 追蹤 writeToParcel 流程
2. 確認數據確實被寫入 Parcel
3. 加 log 追蹤 readFromParcel 流程
4. 發現 readFromParcel 讀不到正確的元素數量

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java`（主要修改）
- `frameworks/base/core/java/android/os/Bundle.java`（理解調用關係）

## 難度分析

**Medium** - 需要理解 Parcel 序列化協議，追蹤寫入和讀取的對應關係
