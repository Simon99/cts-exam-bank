# Q007: VpnService.Builder.establish() 返回 null 但無錯誤日誌

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.VpnServiceTest#testEstablishVpn

junit.framework.AssertionFailedError: 
VPN tunnel establishment failed
Expected: non-null ParcelFileDescriptor
Actual: null
    at android.net.cts.VpnServiceTest.testEstablishVpn(VpnServiceTest.java:156)
```

## 測試代碼片段

```java
@Test
public void testEstablishVpn() throws Exception {
    // 準備 VPN
    Intent intent = VpnService.prepare(mContext);
    assertNull("VPN should be prepared", intent);
    
    // 創建 VPN Service
    TestVpnService service = new TestVpnService();
    service.onCreate();
    
    // 配置並建立隧道
    VpnService.Builder builder = service.new Builder();
    builder.addAddress("10.0.0.2", 24);
    builder.addRoute("0.0.0.0", 0);
    builder.setMtu(1500);
    builder.setSession("TestVPN");
    
    ParcelFileDescriptor tunnel = builder.establish();  // ← 返回 null
    
    assertNotNull("Tunnel should be established", tunnel);
}
```

## 問題描述

VPN 已經 prepare，Builder 配置完整，但 `establish()` 返回 null。沒有異常，沒有錯誤日誌。

這涉及到：
- `VpnService.Builder` 驗證配置
- 調用系統服務建立隧道
- `Vpn.java` 處理請求

## 相關代碼結構

`VpnService.java`:
```java
public class Builder {
    private final VpnConfig mConfig = new VpnConfig();
    
    public ParcelFileDescriptor establish() {
        // 驗證配置
        mConfig.validate();
        
        // 調用 VPN 管理服務
        try {
            return getService().establishVpn(mConfig);
        } catch (RemoteException e) {
            throw e.rethrowFromSystemServer();
        }
    }
}
```

`VpnConfig.java`:
```java
public void validate() {
    // 驗證必要的配置項
}
```

`Vpn.java`:
```java
public synchronized ParcelFileDescriptor establishVpn(VpnConfig config) {
    // 驗證調用者
    // 創建隧道
    // 返回 FileDescriptor
}
```

## 任務

1. 追蹤 `establish()` 的完整流程
2. 檢查 `VpnConfig.validate()` 的驗證邏輯
3. 檢查 `Vpn.establishVpn()` 返回 null 的條件
4. 找出問題所在

## 提示

- 涉及文件數：3（VpnService.java, VpnConfig.java, Vpn.java）
- 難度：Hard
- 關鍵字：establish、VpnConfig、validate、establishVpn
- 呼叫鏈：Builder.establish() → VpnConfig.validate() → Vpn.establishVpn()
