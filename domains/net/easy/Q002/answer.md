# Q002 解答：LocalSocket isBound 狀態錯誤

## 問題根因

在 `LocalSocket.java` 的 `bind()` 方法中，`isBound` 標誌應該在成功綁定後設置為 `true`，
但 bug 導致該標誌沒有被正確設置。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocket.java`

**問題代碼**（第 155-168 行附近）:

```java
public void bind(LocalSocketAddress bindpoint) throws IOException {
    implCreateIfNeeded();

    synchronized (this) {
        if (isBound) {
            throw new IOException("already bound");
        }

        localAddress = bindpoint;
        impl.bind(localAddress);
        // Bug: isBound 沒有設為 true
        // isBound = true; ← 這行被註釋掉或刪除了
    }
}
```

## 修復方案

確保在 `bind()` 成功後設置 `isBound = true;`

```java
public void bind(LocalSocketAddress bindpoint) throws IOException {
    implCreateIfNeeded();

    synchronized (this) {
        if (isBound) {
            throw new IOException("already bound");
        }

        localAddress = bindpoint;
        impl.bind(localAddress);
        isBound = true;  // ← 添加這行
    }
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalSocketTest#testAccessors
   ```

## 學習要點

- 狀態標誌必須在操作成功後正確更新
- `bind` 和 `connect` 都需要更新相應的狀態
- 審查代碼時要注意是否有遺漏的狀態更新
