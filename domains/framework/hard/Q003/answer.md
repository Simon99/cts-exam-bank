# Q003 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**行號**: `writeToParcel()` 方法中 mFlags 的寫入

## 問題代碼

```java
public void writeToParcel(Parcel out, int flags) {
    out.writeString8(mAction);
    Uri.writeToParcel(out, mData);
    out.writeString8(mType);
    out.writeString8(mIdentifier);
    out.writeString8(mPackage);
    ComponentName.writeToParcel(mComponent, out);
    
    if (mSourceBounds != null) {
        out.writeInt(1);
        mSourceBounds.writeToParcel(out, flags);
    } else {
        out.writeInt(0);
    }
    
    if (mCategories != null) {
        final int N = mCategories.size();
        out.writeInt(N);
        for (int i=0; i<N; i++) {
            out.writeString8(mCategories.valueAt(i));
        }
    } else {
        out.writeInt(0);
    }
    
    if (mSelector != null) {
        out.writeInt(1);
        mSelector.writeToParcel(out, flags);
    } else {
        out.writeInt(0);
    }
    
    if (mClipData != null) {
        out.writeInt(1);
        mClipData.writeToParcel(out, flags);
    } else {
        out.writeInt(0);
    }
    out.writeInt(mContentUserHint);
    
    out.writeBundle(mExtras);
    
    // BUG: 這裡應該是 out.writeInt(mFlags)
    // 但是錯誤地寫成了 out.writeInt(mFlags ^ 1)
    out.writeInt(mFlags ^ 1);  // ← 錯誤！XOR 操作改變了 flags 值
}
```

## 根本原因

`mFlags ^ 1` 對 flags 值做了 XOR 運算：
- 當 `mFlags = 0` 時，`0 ^ 1 = 1`
- 當 `mFlags = 1` 時，`1 ^ 1 = 0`

這導致：
1. 寫入 Parcel 的值是被修改過的
2. `readFromParcel()` 讀回的是錯誤值
3. 反序列化後 Intent 的行為與原始不一致

## 修復方案

```java
// 修正：移除 XOR 操作
public void writeToParcel(Parcel out, int flags) {
    // ... 其他字段保持不變 ...
    
    // 正確寫法：直接寫入原始值
    out.writeInt(mFlags);  // 不要 XOR
}
```

## 影響分析

這個 bug 會導致：
1. **跨進程 Intent 傳遞不一致** - 序列化後 flags 改變
2. **權限 flag 錯誤** - 如 FLAG_GRANT_READ_URI_PERMISSION 可能被錯誤添加或移除
3. **Activity 啟動行為異常** - 如 FLAG_ACTIVITY_NEW_TASK 狀態錯誤

## 難度分析

**Hard** 難度原因：
- 需要理解 Parcel 序列化機制
- XOR 操作隱藏，不容易發現
- 影響範圍廣（所有跨進程 Intent）

## 調試技巧

1. 比較寫入前和讀回後的值
2. 在 `writeToParcel` 和 `readFromParcel` 加 log
3. 使用 debugger 檢查 Parcel 內容
