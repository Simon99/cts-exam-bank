# Q010 [Hard]: NetworkPolicy 備份還原後 cycleRule 丟失

## CTS 測試失敗現象

```
FAIL: android.net.cts.NetworkPolicyTest#testBackupRestore
java.lang.AssertionError: 
Expected cycleRule to be preserved after backup/restore
Expected: RecurrenceRule[cycleDay=15, timezone=Asia/Taipei]
Actual: RecurrenceRule[NEVER]

    at android.net.cts.NetworkPolicyTest.testBackupRestore(NetworkPolicyTest.java:156)
```

## 失敗的測試代碼片段

```java
@Test
public void testBackupRestore() throws Exception {
    // 建立一個有週期規則的 NetworkPolicy
    NetworkTemplate template = new NetworkTemplate.Builder(NetworkTemplate.MATCH_MOBILE)
            .setSubscriberIds(Set.of("310260"))
            .setMeteredness(NetworkStats.METERED_YES)
            .build();
    
    RecurrenceRule cycleRule = RecurrenceRule.buildRecurringMonthly(15, 
            ZoneId.of("Asia/Taipei"));
    
    NetworkPolicy original = new NetworkPolicy(
            template,
            cycleRule,
            1024 * 1024 * 100,  // 100MB warning
            1024 * 1024 * 500,  // 500MB limit
            NetworkPolicy.SNOOZE_NEVER,
            NetworkPolicy.SNOOZE_NEVER,
            NetworkPolicy.SNOOZE_NEVER,
            true,   // metered
            false); // inferred
    
    // 備份
    byte[] backup = original.getBytesForBackup();
    
    // 還原
    DataInputStream in = new DataInputStream(new ByteArrayInputStream(backup));
    NetworkPolicy restored = NetworkPolicy.getNetworkPolicyFromBackup(in);
    
    // 驗證 cycleRule 保持一致
    assertTrue("cycleRule should have cycle", restored.hasCycle());  // ← 失敗！
    assertEquals(original.cycleRule, restored.cycleRule);
}
```

## 問題描述

`NetworkPolicy` 的備份/還原功能在處理 `RecurrenceRule` 時出錯。備份時 `cycleRule` 被正確寫入，但還原時沒有正確讀取，導致還原後的 `cycleRule` 變成 `NEVER`（無週期）。

## 相關源碼位置

```
frameworks/base/core/java/android/net/NetworkPolicy.java
```

關鍵方法：
1. `getBytesForBackup()` - 序列化到 byte[]
2. `getNetworkPolicyFromBackup(DataInputStream)` - 從備份還原
3. `RecurrenceRule.writeToStream(DataOutputStream)` - 週期規則序列化
4. `new RecurrenceRule(DataInputStream)` - 週期規則反序列化

## 備份格式

```
VERSION (int)
TEMPLATE_DATA (bytes)
CYCLE_RULE (RecurrenceRule format)
WARNING_BYTES (long)
LIMIT_BYTES (long)
LAST_WARNING_SNOOZE (long)
LAST_LIMIT_SNOOZE (long)
LAST_RAPID_SNOOZE (long) [VERSION >= 3]
METERED (int: 0 or 1)
INFERRED (int: 0 or 1)
```

## 調試提示

1. 檢查 `getBytesForBackup()` 中 cycleRule 的寫入位置
2. 檢查 `getNetworkPolicyFromBackup()` 中 cycleRule 的讀取位置
3. 確認版本號處理邏輯是否正確
4. 注意讀取順序必須與寫入順序一致

## 任務

找出備份/還原過程中 `cycleRule` 丟失的原因。
