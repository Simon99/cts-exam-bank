# Q003 解答：Credentials getPid 返回錯誤值

## 問題根因

在 `Credentials.java` 的 `getPid()` 方法中，返回了錯誤的字段值。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/Credentials.java`

**問題代碼**:

```java
public class Credentials {
    private final int pid;
    private final int uid;
    private final int gid;

    public Credentials (int pid, int uid, int gid) {
        this.pid = pid;
        this.uid = uid;
        this.gid = gid;
    }

    public int getPid() {
        return 0;  // Bug: 硬編碼返回 0，應該返回 pid
    }

    public int getUid() {
        return uid;
    }
    
    public int getGid() {
        return gid;
    }
}
```

## 修復方案

將 `return 0;` 改為 `return pid;`

```java
public int getPid() {
    return pid;  // ← 正確：返回 pid 字段
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

- Getter 方法應該返回對應的字段值
- 這類 bug 通常是複製貼上時忘記修改返回值
- 單元測試可以快速發現這類簡單錯誤
