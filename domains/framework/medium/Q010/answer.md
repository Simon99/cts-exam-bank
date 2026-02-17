# Q010 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
void readFromParcelInner(Parcel parcel, int length) {
    if (length < 0) {
        throw new RuntimeException("Bad length in parcel: " + length);
    } else if (length == 0) {
        mParcelledData = NoImagePreloadHolder.EMPTY_PARCEL;
        mParcelledByNative = false;
        return;
    }
    
    // BUG: 沒有保存 parcel 數據的副本
    mParcelledData = parcel;  // 直接引用，而非副本
    mParcelledByNative = false;
    // 沒有 skip 到正確位置
}
```

## 根本原因

`readFromParcelInner()` 直接引用原始 Parcel 對象而不是創建數據副本。當外部代碼繼續使用 Parcel 時，會改變數據位置，導致後續 unparcel 失敗。

## 修復方案

```java
void readFromParcelInner(Parcel parcel, int length) {
    if (length < 0) {
        throw new RuntimeException("Bad length in parcel: " + length);
    } else if (length == 0) {
        mParcelledData = NoImagePreloadHolder.EMPTY_PARCEL;
        mParcelledByNative = false;
        return;
    }
    
    // 創建數據副本
    Parcel p = Parcel.obtain();
    p.appendFrom(parcel, parcel.dataPosition(), length);
    p.setDataPosition(0);
    mParcelledData = p;
    mParcelledByNative = false;
    parcel.setDataPosition(parcel.dataPosition() + length);  // 跳過已讀數據
}
```

## 調試過程

1. Parcel 位置異常說明 lazy data 被外部操作影響
2. 追蹤 readFromParcelInner 和 unparcel
3. 發現 mParcelledData 是原始 Parcel 的直接引用

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java`
- `frameworks/base/core/java/android/os/Parcel.java`

## 難度分析

**Medium** - 需要理解 lazy unparceling 和 Parcel 數據位置管理
