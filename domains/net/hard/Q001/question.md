# Q001: VPN 連接成功但 NetworkCapabilities 顯示錯誤的 transport type

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.VpnTest#testVpnNetworkCapabilities

junit.framework.AssertionFailedError: VPN should have TRANSPORT_VPN capability
Expected: true
Actual: false
    at android.net.cts.VpnTest.testVpnNetworkCapabilities(VpnTest.java:245)
```

## 測試代碼片段

```java
@Test
public void testVpnNetworkCapabilities() throws Exception {
    // 啟動 VPN
    startVpnService();
    waitForVpnConnected();
    
    // 獲取 VPN 網路的 NetworkCapabilities
    Network vpnNetwork = mConnectivityManager.getActiveNetwork();
    NetworkCapabilities caps = mConnectivityManager.getNetworkCapabilities(vpnNetwork);
    
    // 驗證 transport type
    assertTrue("Should have TRANSPORT_VPN", 
               caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN));  // ← 失敗
    
    // 驗證 VpnTransportInfo
    TransportInfo info = caps.getTransportInfo();
    assertTrue("Should be VpnTransportInfo", info instanceof VpnTransportInfo);  // ← 也失敗
}
```

## 問題描述

VPN 連接成功（可以正常通信），但 `NetworkCapabilities` 沒有正確設置：
1. 沒有 `TRANSPORT_VPN` capability
2. `getTransportInfo()` 沒有返回 `VpnTransportInfo`

這涉及到多個文件的呼叫鏈：
- `Vpn.java` - VPN 服務主邏輯
- `VpnTransportInfo.java` - VPN transport 信息
- `NetworkCapabilities.java` - 網路能力描述

## 相關代碼結構

```java
// Vpn.java - agentConnect() 方法中創建 NetworkCapabilities
private void agentConnect() {
    NetworkCapabilities.Builder ncBuilder = new NetworkCapabilities.Builder()
        .addTransportType(NetworkCapabilities.TRANSPORT_VPN)
        .setTransportInfo(new VpnTransportInfo(mVpnType, mSessionId, ...));
    // ...
    mNetworkAgent = new NetworkAgent(..., ncBuilder.build(), ...);
}

// VpnTransportInfo.java
public VpnTransportInfo(int type, String sessionId, boolean bypassable, ...) {
    this.mType = type;
    // ...
}
```

## 任務

1. 追蹤 VPN 連接時 NetworkCapabilities 的創建流程
2. 檢查 `Vpn.java` 中如何構建 capabilities
3. 檢查 `VpnTransportInfo` 的創建
4. 找出為什麼 transport 信息沒有正確設置
5. 修復問題（可能涉及多處修改）

## 提示

- 涉及文件數：3（Vpn.java, VpnTransportInfo.java, NetworkCapabilities 相關）
- 難度：Hard
- 關鍵字：agentConnect、NetworkCapabilities、TRANSPORT_VPN、VpnTransportInfo
- 呼叫鏈：Vpn.agentConnect() → NetworkCapabilities.Builder → VpnTransportInfo
