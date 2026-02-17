# Q001 解答：LocalSocket isConnected 狀態錯誤

## 問題根因

在 `LocalSocket.java` 的 `connect()` 方法中，`isConnected` 標誌應該在成功連接後設置為 `true`，
但 bug 導致該標誌沒有被正確設置。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocket.java`

**問題代碼**（第 134-145 行附近）:

```java
public void connect(LocalSocketAddress endpoint) throws IOException {
    synchronized (this) {
        if (isConnected) {
            throw new IOException("already connected");
        }

        implCreateIfNeeded();
        impl.connect(endpoint, 0);
        // Bug: isConnected = false; （錯誤地設為 false）
        isConnected = false;  // ← 應該是 true
        isBound = true;
    }
}
```

## 修復方案

將 `isConnected = false;` 改為 `isConnected = true;`

```java
public void connect(LocalSocketAddress endpoint) throws IOException {
    synchronized (this) {
        if (isConnected) {
            throw new IOException("already connected");
        }

        implCreateIfNeeded();
        impl.connect(endpoint, 0);
        isConnected = true;  // ← 正確：連接成功後設為 true
        isBound = true;
    }
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalSocketTest#testLocalConnections
   ```

## 學習要點

- 狀態標誌的正確管理是網絡編程的基礎
- 連接狀態應該在操作成功後立即更新
- 這類 bug 通常是複製貼上或手誤造成的
