# Q008: PendingIntent 跨包傳遞時 FLAG 丟失

## CTS 測試失敗信息

```
Test: android.app.cts.PendingIntentTest#testGetFlagsAfterCrossPackageParcel
FAILURE: PendingIntent flags not preserved after cross-package transfer

Original PendingIntent:
- Flags: FLAG_IMMUTABLE | FLAG_UPDATE_CURRENT (0x44000000)
- Creator package: com.test.sender
- Target component: com.test.receiver/.ReceiverActivity

After receiving via Binder:
- Flags: 0x00000000 (all flags lost!)
- Creator package: com.test.sender (preserved)
- Target component: com.test.receiver/.ReceiverActivity (preserved)

Flag comparison:
- FLAG_IMMUTABLE: Expected YES, Actual NO
- FLAG_UPDATE_CURRENT: Expected YES, Actual NO

    at android.app.cts.PendingIntentTest.testGetFlagsAfterCrossPackageParcel
```

## 測試環境
- 跨應用傳遞 PendingIntent
- 使用 Binder IPC

## 問題描述
PendingIntent 跨應用傳遞後，所有 flags 都丟失了，
但其他屬性（creator package、target component）保留正常。

## 相關日誌
```
D PendingIntent: Creating with flags=0x44000000
D PendingIntent: writeToParcel flags=0x44000000
D Binder: Transferring PendingIntent across packages
D PendingIntent: createFromParcel
W PendingIntent: Flags field not read from parcel!
D PendingIntentTest: Received flags=0x0
```

## 提示
- PendingIntent 是 Parcelable
- 檢查 writeToParcel 和 CREATOR
- 跨包傳遞涉及 ActivityManagerService
