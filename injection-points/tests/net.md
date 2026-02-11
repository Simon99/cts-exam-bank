# net 模組注入點分布列表

**CTS 路徑**: `cts/tests/net/`
**更新時間**: 2026-02-10

---

## 概覽

- **總注入點數**: 28
- **按難度分布**: Easy(10) / Medium(12) / Hard(6)
- **涵蓋測試類別**: LocalSocketTest

## 對應 AOSP 源碼路徑

- `frameworks/base/core/java/android/net/LocalSocket.java`
- `frameworks/base/core/java/android/net/LocalServerSocket.java`
- `frameworks/base/core/java/android/net/LocalSocketImpl.java`
- `frameworks/base/core/java/android/net/LocalSocketAddress.java`
- `frameworks/base/core/java/android/net/Credentials.java`

---

## CTS 測試分析

### LocalSocketTest.java 測試重點

| 測試方法 | 驗證功能 | 重點 API |
|---------|---------|---------|
| testLocalConnections | socket 連線、資料傳輸、shutdown | connect(), accept(), getInputStream(), shutdownInput() |
| testAccessors | socket 屬性設置與取得 | bind(), setReceiveBufferSize(), setSoTimeout() |
| testSetSoTimeout_readTimeout | 讀取超時機制 | setSoTimeout(), read() |
| testSetSoTimeout_writeTimeout | 寫入超時機制 | setSoTimeout(), write() |
| testAvailable | 可讀資料量 | available() |
| testLocalSocketCreatedFromFileDescriptor | 從 FD 建立 socket | LocalSocket(FileDescriptor) |
| testFlush | 輸出流刷新 | flush() |
| testCreateFromFd | FD 建立與資源洩漏檢測 | Os.socket(), 資源管理 |
| testCreateFromFd_notConnected | 未連線 FD 建立 socket 失敗 | checkConnected() |
| testCreateFromFd_notSocket | 非 socket FD 建立失敗 | IllegalArgumentException |

---

## 注入點清單

### 1. LocalSocket 連線與狀態管理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| NET-001 | LocalSocket.java | connect() | 140-152 | COND, STATE | Easy | testLocalConnections |
| NET-002 | LocalSocket.java | connect() - isConnected check | 141-143 | COND | Easy | testLocalConnections |
| NET-003 | LocalSocket.java | bind() | 162-175 | COND, STATE | Easy | testAccessors |
| NET-004 | LocalSocket.java | bind() - isBound check | 165-167 | COND | Easy | testAccessors |
| NET-005 | LocalSocket.java | checkConnected() | 76-82 | ERR, STATE | Medium | testCreateFromFd_notConnected |
| NET-006 | LocalSocket.java | implCreateIfNeeded() | 115-126 | SYNC, STATE | Medium | testLocalConnections |

### 2. LocalServerSocket 伺服器操作

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| NET-007 | LocalServerSocket.java | constructor - LISTEN_BACKLOG | 28 | CALC | Easy | testLocalConnections |
| NET-008 | LocalServerSocket.java | LocalServerSocket(String) | 37-46 | RES, ERR | Medium | testLocalConnections |
| NET-009 | LocalServerSocket.java | LocalServerSocket(FileDescriptor) | 56-61 | RES | Medium | testCreateFromFd |
| NET-010 | LocalServerSocket.java | accept() | 78-83 | RES, ERR | Medium | testLocalConnections |

### 3. LocalSocketImpl 核心實作

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| NET-011 | LocalSocketImpl.java | SocketInputStream.available() | 60-68 | BOUND, ERR | Easy | testAvailable |
| NET-012 | LocalSocketImpl.java | SocketInputStream.read(byte[], int, int) | 86-97 | BOUND | Easy | testLocalConnections |
| NET-013 | LocalSocketImpl.java | SocketInputStream.read(byte[], int, int) - bounds check | 91-93 | BOUND | Easy | testLocalConnections |
| NET-014 | LocalSocketImpl.java | SocketOutputStream.write(byte[], int, int) | 114-123 | BOUND | Easy | testLocalConnections |
| NET-015 | LocalSocketImpl.java | SocketOutputStream.write(byte[], int, int) - bounds check | 118-120 | BOUND | Easy | testLocalConnections |
| NET-016 | LocalSocketImpl.java | create() - sockType switch | 176-192 | COND, ERR | Medium | testLocalConnections |
| NET-017 | LocalSocketImpl.java | close() | 202-217 | RES, SYNC | Medium | testLocalConnections |
| NET-018 | LocalSocketImpl.java | close() - mFdCreatedInternally check | 205-207 | COND, RES | Medium | testLocalSocketCreatedFromFileDescriptor |
| NET-019 | LocalSocketImpl.java | connect() - fd null check | 221-223 | BOUND, ERR | Easy | testLocalConnections |
| NET-020 | LocalSocketImpl.java | bind() - fd null check | 234-236 | BOUND, ERR | Easy | testAccessors |
| NET-021 | LocalSocketImpl.java | listen() | 241-251 | ERR | Medium | testLocalConnections |
| NET-022 | LocalSocketImpl.java | accept() | 261-273 | RES, ERR | Hard | testLocalConnections |
| NET-023 | LocalSocketImpl.java | shutdownInput() | 306-316 | STATE, ERR | Medium | testLocalConnections |
| NET-024 | LocalSocketImpl.java | shutdownOutput() | 323-333 | STATE, ERR | Medium | testLocalConnections |
| NET-025 | LocalSocketImpl.java | getOption() - SO_TIMEOUT | 345-369 | COND, CALC | Hard | testSetSoTimeout_readTimeout |
| NET-026 | LocalSocketImpl.java | setOption() - SO_TIMEOUT | 393-425 | COND, CALC | Hard | testSetSoTimeout_writeTimeout |
| NET-027 | LocalSocketImpl.java | setFileDescriptorsForSend() | 438-442 | SYNC | Hard | testLocalConnections |
| NET-028 | LocalSocketImpl.java | getAncillaryFileDescriptors() | 453-460 | SYNC | Hard | testLocalConnections |

### 4. LocalSocketAddress 位址處理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| NET-029 | LocalSocketAddress.java | Namespace.getId() | 48-50 | COND | Hard | testLocalConnections |
| NET-030 | LocalSocketAddress.java | constructor | 60-63 | STR | Medium | testLocalConnections |

### 5. Credentials 憑證處理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| NET-031 | Credentials.java | getPid() | 32-34 | CALC | Easy | testLocalConnections |
| NET-032 | Credentials.java | getUid() | 36-38 | CALC | Easy | testLocalConnections |
| NET-033 | Credentials.java | getGid() | 40-42 | CALC | Easy | testLocalConnections |

---

## 注入點詳細說明

### 重點注入點分析

#### NET-005: checkConnected() 狀態驗證
```java
// LocalSocket.java:76-82
private void checkConnected() {
    try {
        Os.getpeername(impl.getFileDescriptor());
    } catch (ErrnoException e) {
        throw new IllegalArgumentException("Not a connected socket", e);
    }
    isConnected = true;  // <-- 可注入：狀態設置錯誤
    isBound = true;
    implCreated = true;
}
```
**注入建議**: 將 `isConnected = true` 改為 `isConnected = false`，導致 `isConnected()` 回傳錯誤狀態

#### NET-017/018: close() 資源管理
```java
// LocalSocketImpl.java:202-217
public void close() throws IOException {
    synchronized (LocalSocketImpl.this) {
        if ((fd == null) || (mFdCreatedInternally == false)) {  // <-- 可注入：條件反轉
            fd = null;
            return;
        }
        try {
            Os.close(fd);
        } catch (ErrnoException e) {
            e.rethrowAsIOException();
        }
        fd = null;
    }
}
```
**注入建議**: 
- 將 `mFdCreatedInternally == false` 改為 `mFdCreatedInternally == true`，導致外部傳入的 FD 被錯誤關閉
- 移除 `fd = null`，導致 FD 狀態不一致

#### NET-013/015: 邊界檢查
```java
// LocalSocketImpl.java:91-93
if (off < 0 || len < 0 || (off + len) > b.length ) {  // <-- 可注入：邊界條件
    throw new ArrayIndexOutOfBoundsException();
}
```
**注入建議**: 將 `>` 改為 `>=`，導致邊界情況處理錯誤

#### NET-025/026: Socket Option 處理
```java
// LocalSocketImpl.java - getOption()
case SocketOptions.SO_TIMEOUT:
    StructTimeval timeval = Os.getsockoptTimeval(fd, OsConstants.SOL_SOCKET,
            OsConstants.SO_SNDTIMEO);  // <-- 可注入：使用錯誤的 option
    toReturn = (int) timeval.toMillis();
    break;
```
**注入建議**: 將 `SO_SNDTIMEO` 改為 `SO_RCVTIMEO`，導致取得錯誤的 timeout 值

---

## 難度分布統計

| 難度 | 數量 | 佔比 | 主要類型 |
|------|------|------|----------|
| Easy | 13 | 39% | BOUND, COND, CALC |
| Medium | 12 | 36% | STATE, RES, ERR |
| Hard | 8 | 24% | SYNC, 跨函數邏輯 |

## 注入類型統計

| 類型 | 數量 | 說明 |
|------|------|------|
| COND | 10 | 條件判斷錯誤 |
| BOUND | 8 | 邊界檢查問題 |
| ERR | 8 | 錯誤處理不當 |
| STATE | 6 | 狀態轉換錯誤 |
| RES | 6 | 資源管理問題 |
| SYNC | 5 | 同步問題 |
| CALC | 5 | 數值計算錯誤 |
| STR | 1 | 字串處理問題 |

---

## 備註

1. **cts/tests/net 模組較小**：只有一個 LocalSocketTest.java 測試檔案，主要測試 Unix Domain Socket 相關功能
2. **更多 net 相關測試**：在 `packages/modules/Connectivity/` 模組下有更完整的 Connectivity 測試
3. **建議補充**：可考慮分析 `cts/tests/netlegacy22.api/` 和 `cts/tests/netsecpolicy/` 獲取更多注入點
4. **實機驗證優先級**：建議優先驗證 NET-017/018（資源管理）和 NET-025/026（timeout 處理），這些是最可能產生明確 CTS fail 的點

---

**版本**: v1.0.0
**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/net.md`
