# Q002 答案解析

## Bug 位置

**主要檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
private void writeValue(Parcel parcel, String key, Object v, int flags) {
    parcel.writeString(key);
    
    if (v == null) {
        parcel.writeInt(VAL_NULL);
    } else if (v instanceof String) {
        parcel.writeInt(VAL_STRING);
        parcel.writeString((String) v);
    } else if (v instanceof Bundle) {
        parcel.writeInt(VAL_BUNDLE);
        // BUG: 寫入嵌套 Bundle 時共享了 flags，但沒有正確設置邊界
        ((Bundle) v).writeToParcel(parcel, flags);
    }
    // ...
}
```

**相關問題** 在 `Parcel.java`:
```java
public void writeBundle(Bundle val) {
    if (val == null) {
        writeInt(-1);
        return;
    }
    // BUG: 沒有正確寫入 Bundle 的大小前綴
    val.writeToParcel(this, 0);
}
```

## 根本原因

嵌套 Bundle 序列化時：
1. 沒有正確寫入每個嵌套 Bundle 的大小前綴
2. 反序列化時無法正確定位嵌套 Bundle 的邊界
3. 導致數據讀取位置錯亂，內層數據被外層數據覆蓋

## 修復方案

```java
// BaseBundle.java
private void writeValue(Parcel parcel, String key, Object v, int flags) {
    parcel.writeString(key);
    
    if (v instanceof Bundle) {
        parcel.writeInt(VAL_BUNDLE);
        parcel.writeBundle((Bundle) v);  // 使用 writeBundle 確保正確邊界
    }
    // ...
}

// Parcel.java
public void writeBundle(Bundle val) {
    if (val == null) {
        writeInt(-1);
        return;
    }
    final int startPos = dataPosition();
    writeInt(-1);  // placeholder for length
    val.writeToParcel(this, 0);
    final int endPos = dataPosition();
    setDataPosition(startPos);
    writeInt(endPos - startPos - 4);  // write actual length
    setDataPosition(endPos);
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/os/BaseBundle.java` - Bundle 值寫入
2. `frameworks/base/core/java/android/os/Parcel.java` - Bundle 序列化邊界
3. `frameworks/base/core/java/android/os/Bundle.java` - writeToParcel 入口

## 調試過程

1. 打印每層 Bundle 序列化後的大小和位置
2. 比較寫入和讀取時的數據位置
3. 發現嵌套 Bundle 沒有長度前綴
4. 讀取時位置計算錯誤導致數據交叉

## 難度分析

**Hard** - 涉及複雜的嵌套序列化和邊界處理
