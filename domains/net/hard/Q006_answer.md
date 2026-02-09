# Q006 解答：SntpClient 時間同步後 round trip time 計算錯誤

## 問題根因

往返時間計算公式中，服務器處理時間的計算順序搞反了。應該是 `(t3 - t2)` 但寫成了 `(t2 - t3)`。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/SntpClient.java`

**問題代碼**:

```java
// Bug: 服務器處理時間計算錯誤
mRoundTripTime = (responseTime - requestTime) - (receiveTime - transmitTime);
```

## 修復方案

```java
// 正確：(t4 - t1) - (t3 - t2)
mRoundTripTime = (responseTime - requestTime) - (transmitTime - receiveTime);
```

## NTP 時間戳說明

```
Client                          Server
  |                               |
  |-------- request ------------>| t1 = requestTime (發送時間)
  |                               | t2 = receiveTime (服務器收到)
  |                               | t3 = transmitTime (服務器發送)
  |<------- response ------------| t4 = responseTime (收到回應)
```

## 往返時間公式

- **Total elapsed time** = t4 - t1
- **Server processing time** = t3 - t2
- **Round trip time** = (t4 - t1) - (t3 - t2)

服務器處理時間是正數（先收到才發送），所以 `t3 > t2`，`(t3 - t2) > 0`。

Bug 代碼用 `(t2 - t3)` 得到負數，導致：
```
RTT = (t4-t1) - (t2-t3) = (t4-t1) + (t3-t2)
```
這會得到一個過大或錯誤的值。

## 呼叫鏈

```
requestTime()
    └── socket.send(request) → t1 = requestTime
    └── socket.receive(response) → t4 = responseTime
    └── readTimestamp(RECEIVE_TIME_OFFSET) → t2
    └── readTimestamp(TRANSMIT_TIME_OFFSET) → t3
    └── mRoundTripTime = (t4-t1) - (t2-t3)  // Bug！
```

## 驗證命令

```bash
atest android.net.cts.SntpClientTest#testRoundTripTime
```

## 學習要點

- 仔細核對數學公式的實現
- 變量命名要與協議定義一致
- 時間計算的順序很重要（減法不可交換）
