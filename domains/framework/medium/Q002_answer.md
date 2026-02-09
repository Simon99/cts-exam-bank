# Q002 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public void writeToParcel(Parcel out, int flags) {
    out.writeString8(mAction);
    Uri.writeToParcel(out, mData);
    out.writeString8(mType);
    out.writeString8(mIdentifier);
    out.writeInt(mFlags);
    out.writeString8(mPackage);
    ComponentName.writeToParcel(mComponent, out);
    // out.writeBundle(mExtras);  // BUG: extras 沒有被寫入
    // ... 其他字段
}
```

## 根本原因

`Intent.writeToParcel()` 方法中，`mExtras` Bundle 沒有被寫入到 Parcel。這導致 `readFromParcel()` 讀取時 extras 為空。

## 修復方案

```java
public void writeToParcel(Parcel out, int flags) {
    out.writeString8(mAction);
    Uri.writeToParcel(out, mData);
    out.writeString8(mType);
    out.writeString8(mIdentifier);
    out.writeInt(mFlags);
    out.writeString8(mPackage);
    ComponentName.writeToParcel(mComponent, out);
    out.writeBundle(mExtras);  // 正確：寫入 extras
    // ... 其他字段
}
```

## 調試過程

1. 確認 putExtra 確實將數據存入 mExtras
2. 追蹤 writeToParcel，發現 mExtras 沒有被寫入
3. 對比 readFromParcel，確認讀取順序

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java`（主要）
- `frameworks/base/core/java/android/os/Bundle.java`（理解 Bundle 序列化）

## 難度分析

**Medium** - 需要追蹤 Intent 和 Bundle 的序列化流程
