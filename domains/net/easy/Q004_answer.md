# Q004 解答：LocalSocketAddress getNamespace 返回錯誤命名空間

## 問題根因

在 `LocalSocketAddress.java` 的單參數構造函數中，
默認命名空間被錯誤地設置為 `RESERVED` 而不是 `ABSTRACT`。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketAddress.java`

**問題代碼**:

```java
/**
 * Creates an instance with a given name in the {@link Namespace#ABSTRACT}
 * namespace
 *
 * @param name non-null name
 */
public LocalSocketAddress(String name) {
    this(name, Namespace.RESERVED);  // Bug: 應該是 ABSTRACT
}
```

## 修復方案

將 `Namespace.RESERVED` 改為 `Namespace.ABSTRACT`：

```java
public LocalSocketAddress(String name) {
    this(name, Namespace.ABSTRACT);  // ← 正確：默認使用 ABSTRACT
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalSocketAddressTest#testNamespace
   ```

## 學習要點

- 構造函數的默認值必須與文檔一致
- `ABSTRACT` 是 Linux abstract namespace，適合進程間通訊
- `RESERVED` 是 Android 保留的 /dev/socket 目錄，需要特殊權限
- 文檔和實現不一致是常見的 bug 來源
