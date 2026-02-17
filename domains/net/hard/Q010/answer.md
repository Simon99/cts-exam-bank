# Q010 答案 [Hard]：NetworkPolicy 備份還原後 cycleRule 丟失

## 問題根因

問題涉及三個檔案的交互：
1. `NetworkPolicy.java` 備份時寫入順序錯誤
2. `NetworkPolicyManager.java` 還原邏輯不完整
3. `RecurrenceRule.java` 序列化順序錯誤

## Bug 位置

1. **NetworkPolicy.java** - getBytesForBackup()
2. **NetworkPolicyManager.java** - restorePoliciesFromBackup()
3. **RecurrenceRule.java** - writeToStream()

## 錯誤代碼 - NetworkPolicy.java

```java
public byte[] getBytesForBackup() throws IOException {
    out.writeInt(VERSION_RAPID);
    out.write(getNetworkTemplateBytesForBackup());
    
    // BUG: 先寫了 warningBytes，再寫 cycleRule
    out.writeLong(warningBytes);  // ← 順序錯誤！
    cycleRule.writeToStream(out);  // ← 應該在 warningBytes 之前
}
```

## 錯誤代碼 - NetworkPolicyManager.java

```java
public NetworkPolicy[] restorePoliciesFromBackup(byte[] data) {
    // BUG: 沒有正確讀取策略計數
    // 缺少反序列化邏輯
    if (data == null || data.length == 0) {
        return new NetworkPolicy[0];
    }
    // 不完整的還原
    return policies.toArray(new NetworkPolicy[0]);
}
```

## 錯誤代碼 - RecurrenceRule.java

```java
public void writeToStream(DataOutputStream out) throws IOException {
    // BUG: 先寫 period 而非 start time
    out.writeUTF(period.toString());  // 順序錯誤！
    if (start != null) {
        out.writeLong(start.toEpochSecond());
    }
    // 缺少：zone ID、end time 處理
}
```

## 修復方案

### NetworkPolicy.java
```java
public byte[] getBytesForBackup() throws IOException {
    out.writeInt(VERSION_RAPID);
    out.write(getNetworkTemplateBytesForBackup());
    cycleRule.writeToStream(out);    // 1. cycleRule
    out.writeLong(warningBytes);      // 2. warningBytes
    out.writeLong(limitBytes);        // 3. limitBytes
    // ...
}
```

### NetworkPolicyManager.java
```java
public NetworkPolicy[] restorePoliciesFromBackup(byte[] data) {
    List<NetworkPolicy> policies = new ArrayList<>();
    DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
    int count = in.readInt();
    for (int i = 0; i < count; i++) {
        policies.add(NetworkPolicy.getNetworkPolicyFromBackup(in));
    }
    return policies.toArray(new NetworkPolicy[0]);
}
```

### RecurrenceRule.java
```java
public void writeToStream(DataOutputStream out) throws IOException {
    out.writeLong(start.toEpochSecond());
    out.writeUTF(start.getZone().getId());
    out.writeBoolean(end != null);
    if (end != null) {
        out.writeLong(end.toEpochSecond());
        out.writeUTF(end.getZone().getId());
    }
    out.writeUTF(period.toString());
}
```

## 序列化黃金法則

1. **順序必須一致**：寫入順序 = 讀取順序
2. **版本控制**：新增欄位時要處理舊版本相容
3. **多檔案協調**：相關類的序列化邏輯要一致

## 驗證命令

```bash
atest android.net.cts.NetworkPolicyTest#testBackupRestore
```

## 學習要點

- 二進位序列化沒有欄位名，完全依賴順序
- 多個類之間的序列化需要協調一致
- Round-trip 測試是驗證序列化正確性的關鍵
