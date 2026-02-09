# Q010 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/IntentFilter.java`

**寫入順序 (writeToParcel)**:
```java
public final void writeToParcel(Parcel dest, int flags) {
    // ... 其他欄位 ...
    dest.writeInt(mPriority);          // 先寫 priority
    dest.writeInt(mHasStaticPartialTypes ? 1 : 0);
    dest.writeInt(mHasDynamicPartialTypes ? 1 : 0);
    dest.writeInt(getAutoVerify() ? 1 : 0);
    dest.writeInt(mInstantAppVisibility);
    dest.writeInt(mOrder);             // 後寫 order
    // ...
}
```

**讀取順序 (IntentFilter(Parcel source))** - BUG 版本:
```java
public IntentFilter(Parcel source) {
    // ... 其他欄位 ...
    mOrder = source.readInt();         // BUG: 先讀 order（應該先讀 priority）
    mHasStaticPartialTypes = source.readInt() > 0;
    mHasDynamicPartialTypes = source.readInt() > 0;
    setAutoVerify(source.readInt() > 0);
    setVisibilityToInstantApp(source.readInt());
    mPriority = source.readInt();      // BUG: 後讀 priority（應該後讀 order）
    // ...
}
```

## 根本原因

1. Parcel 是順序敏感的序列化格式
2. `writeToParcel()` 先寫 mPriority，後寫 mOrder
3. Bug 版本的構造函數將讀取順序顛倒了
4. 導致讀出的值互換

## 修復方案

```java
public IntentFilter(Parcel source) {
    // ... 其他欄位 ...
    mPriority = source.readInt();      // 先讀 priority（與寫入順序一致）
    mHasStaticPartialTypes = source.readInt() > 0;
    mHasDynamicPartialTypes = source.readInt() > 0;
    setAutoVerify(source.readInt() > 0);
    setVisibilityToInstantApp(source.readInt());
    mOrder = source.readInt();         // 後讀 order（與寫入順序一致）
    // ...
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/content/IntentFilter.java` - writeToParcel() 和構造函數

## 關鍵概念

### Parcel 序列化規則
- Parcel 是 Android 的 IPC 序列化機制
- 必須按照**完全相同的順序**讀寫
- 沒有欄位名，完全依賴順序

### IntentFilter 的 priority vs order
- **priority**: 用於 Intent 解析時的排序（較高優先）
- **order**: 用於同 priority 內的進一步排序

## 難度分析

**Hard** - 需要理解：
- Parcel 的順序敏感特性
- IntentFilter 的完整序列化流程
- 仔細比對大量欄位的讀寫順序

## CTS 測試意圖

驗證 Parcelable 實現的正確性，確保物件經過序列化/反序列化後保持完整性。
