# Q007 解答：VpnService.Builder.establish() 返回 null 但無錯誤日誌

## 問題根因

`VpnService.Builder.establish()` 中，`mConfig.validate()` 返回 false 時靜默返回 null，而不是讓 validate 方法拋出異常告知調用者問題所在。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/VpnService.java`

**問題代碼** (Builder.establish 方法):

```java
public ParcelFileDescriptor establish() {
    mConfig.updateAllowedFamilies();
    
    // Bug: 靜默失敗，不告知原因
    if (!mConfig.validate()) {
        return null;
    }
    
    try {
        return getService().establishVpn(mConfig);
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}
```

## 修復方案

讓 validate() 在驗證失敗時拋出描述性異常：

```java
public ParcelFileDescriptor establish() {
    mConfig.updateAllowedFamilies();
    
    // validate() 內部會拋 IllegalArgumentException 並說明問題
    mConfig.validate();
    
    try {
        return getService().establishVpn(mConfig);
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}
```

## VpnConfig.validate() 應該的行為

```java
public void validate() {
    if (addresses.isEmpty()) {
        throw new IllegalArgumentException("At least one address must be set");
    }
    if (mtu < 0) {
        throw new IllegalArgumentException("MTU must be non-negative");
    }
    // ... 其他驗證
}
```

## 呼叫鏈分析

```
Builder.establish()
    └── mConfig.validate()
            └── 返回 false（缺少必要配置）
    └── if (!validate()) return null;  // Bug: 靜默失敗
    └── getService().establishVpn()  // 從未執行到

正確行為應該是：
Builder.establish()
    └── mConfig.validate()
            └── throw IllegalArgumentException("Missing required config")
    └── 異常向上傳播，告知調用者問題
```

## 驗證命令

```bash
atest android.net.cts.VpnServiceTest#testEstablishVpn
```

## 學習要點

- 避免靜默失敗（silent failure）
- 驗證失敗應該拋出描述性異常
- null 返回值應該有文檔說明其含義
- 開發者友好的錯誤信息有助於調試
