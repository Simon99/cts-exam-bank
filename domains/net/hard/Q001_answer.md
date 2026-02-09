# Q001 解答：VPN 連接成功但 NetworkCapabilities 顯示錯誤的 transport type

## 問題根因

`Vpn.java` 的 `agentConnect()` 方法中構建 `NetworkCapabilities` 時：
1. 沒有調用 `addTransportType(TRANSPORT_VPN)`
2. 沒有調用 `setTransportInfo(createVpnTransportInfo())`

## Bug 位置

**文件**: `frameworks/base/services/core/java/com/android/server/connectivity/Vpn.java`

**問題代碼** (agentConnect 方法):

```java
private void agentConnect() {
    NetworkCapabilities.Builder ncBuilder = new NetworkCapabilities.Builder()
        // Bug: 缺少這兩行
        // .addTransportType(NetworkCapabilities.TRANSPORT_VPN)
        .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_SUSPENDED)
        .removeCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN);
    // Bug: 缺少設置 TransportInfo
    // ncBuilder.setTransportInfo(createVpnTransportInfo());
    
    mNetworkAgent = new NetworkAgent(..., ncBuilder.build(), ...);
}
```

## 修復方案

```java
private void agentConnect() {
    NetworkCapabilities.Builder ncBuilder = new NetworkCapabilities.Builder()
        .addTransportType(NetworkCapabilities.TRANSPORT_VPN)  // 添加 transport type
        .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_SUSPENDED)
        .removeCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        .setTransportInfo(createVpnTransportInfo());  // 設置 transport info
    
    mNetworkAgent = new NetworkAgent(..., ncBuilder.build(), ...);
}
```

## 呼叫鏈分析

```
Vpn.agentConnect()
    ├── NetworkCapabilities.Builder
    │       ├── addTransportType(TRANSPORT_VPN)  ← 缺失
    │       └── setTransportInfo(VpnTransportInfo)  ← 缺失
    └── new VpnTransportInfo(type, sessionId, bypassable, ...)
            └── 存儲 VPN 類型、session ID 等信息
```

## VpnTransportInfo 的作用

`VpnTransportInfo` 包含：
- `mType`: VPN 類型（VpnManager.TYPE_*）
- `mSessionId`: VPN session 識別碼
- `mBypassable`: 是否可繞過
- `mLongLivedTcpConnectionsExpensive`: TCP 長連接是否昂貴

這些信息對於系統判斷網路行為很重要。

## 驗證命令

```bash
atest android.net.cts.VpnTest#testVpnNetworkCapabilities
```

## 學習要點

- VPN 需要正確設置 TRANSPORT_VPN capability
- TransportInfo 提供傳輸層的詳細信息
- 檢查 Builder 模式是否設置了所有必要的屬性
