# Q005 解答：NetworkPolicy 序列化後 warningBytes 變成 limitBytes

## 問題根因

`writeToParcel()` 和構造函數 `NetworkPolicy(Parcel)` 中，`warningBytes` 和 `limitBytes` 的讀寫順序不一致。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/NetworkPolicy.java`

**問題代碼** (writeToParcel):

```java
public void writeToParcel(Parcel dest, int flags) {
    dest.writeParcelable(template, flags);
    dest.writeParcelable(cycleRule, flags);
    dest.writeLong(limitBytes);      // Bug: 先寫 limit
    dest.writeLong(warningBytes);    // 後寫 warning
    // ...
}
```

**構造函數** (正確順序):

```java
private NetworkPolicy(Parcel source) {
    template = source.readParcelable(null);
    cycleRule = source.readParcelable(null);
    warningBytes = source.readLong();  // 先讀 warning
    limitBytes = source.readLong();    // 後讀 limit
    // ...
}
```

## 修復方案

讓 writeToParcel 的順序與構造函數一致：

```java
public void writeToParcel(Parcel dest, int flags) {
    dest.writeParcelable(template, flags);
    dest.writeParcelable(cycleRule, flags);
    dest.writeLong(warningBytes);    // 先寫 warning
    dest.writeLong(limitBytes);      // 後寫 limit
    // ...
}
```

## 問題分析

Parcel 是順序讀寫的：

| 操作 | write 順序 (Bug) | read 順序 | 結果 |
|------|------------------|-----------|------|
| 第一個 long | limitBytes (2GB) | warningBytes | warning = 2GB ❌ |
| 第二個 long | warningBytes (1GB) | limitBytes | limit = 1GB ❌ |

## 呼叫鏈

```
original.writeToParcel(parcel, 0)
    └── writeLong(limitBytes=2GB)    // 位置 0-7
    └── writeLong(warningBytes=1GB)  // 位置 8-15

NetworkPolicy.CREATOR.createFromParcel(parcel)
    └── readLong() → warningBytes    // 讀位置 0-7 得到 2GB
    └── readLong() → limitBytes      // 讀位置 8-15 得到 1GB
```

## 驗證命令

```bash
atest android.net.cts.NetworkPolicyTest#testParcelable
```

## 學習要點

- Parcelable 的 write 和 read 順序必須完全對應
- 這是 FIFO（先進先出）的數據結構
- 代碼審查時對照 writeToParcel 和構造函數
