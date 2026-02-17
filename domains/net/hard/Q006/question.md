# Q006: SntpClient 時間同步後 round trip time 計算錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.SntpClientTest#testRoundTripTime

junit.framework.AssertionFailedError: 
Round trip time should be positive
Expected: > 0
Actual: -12345678
    at android.net.cts.SntpClientTest.testRoundTripTime(SntpClientTest.java:89)
```

## 測試代碼片段

```java
@Test
public void testRoundTripTime() throws Exception {
    SntpClient client = new SntpClient();
    
    // 請求時間同步
    boolean success = client.requestTime("time.google.com", 5000);
    assertTrue("Time request should succeed", success);
    
    // 獲取結果
    long ntpTime = client.getNtpTime();
    long ntpTimeReference = client.getNtpTimeReference();
    long roundTripTime = client.getRoundTripTime();
    
    // 驗證
    assertTrue("NTP time should be positive", ntpTime > 0);  // ← 通過
    assertTrue("Reference should be positive", ntpTimeReference > 0);  // ← 通過
    assertTrue("Round trip should be positive", roundTripTime > 0);  // ← 失敗！負值
}
```

## 問題描述

SNTP 客戶端成功獲取網路時間，但計算出的往返時間（round trip time）是負數。

NTP 協議定義：
- `Round trip time = (t4 - t1) - (t3 - t2)`
- 其中 t1=發送時間, t2=服務器收到時間, t3=服務器發送時間, t4=收到回應時間

## 相關代碼結構

`SntpClient.java`:
```java
public boolean requestTime(InetAddress address, int port, int timeout, Network network) {
    // ...
    long requestTime = System.currentTimeMillis();
    socket.send(request);
    
    socket.receive(response);
    long responseTime = System.currentTimeMillis();
    
    // 解析 NTP 回應
    long originateTime = readTimestamp(buffer, ORIGINATE_TIME_OFFSET);
    long receiveTime = readTimestamp(buffer, RECEIVE_TIME_OFFSET);
    long transmitTime = readTimestamp(buffer, TRANSMIT_TIME_OFFSET);
    
    // 計算往返時間
    mRoundTripTime = (responseTime - requestTime) - (transmitTime - receiveTime);
    // ...
}
```

涉及 `Timestamp64.java` 和 `Duration64.java` 進行時間轉換。

## 任務

1. 分析 NTP 時間計算公式
2. 追蹤時間戳的讀取和轉換
3. 找出計算錯誤的原因
4. 修復問題

## 提示

- 涉及文件數：3（SntpClient.java, sntp/Timestamp64.java, sntp/Duration64.java）
- 難度：Hard
- 關鍵字：round trip、timestamp、ORIGINATE_TIME、RECEIVE_TIME、TRANSMIT_TIME
- 呼叫鏈：requestTime() → readTimestamp() → Timestamp64 → 計算
