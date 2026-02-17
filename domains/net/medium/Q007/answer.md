# Q007 解答：Credentials.getPid() 返回錯誤的值

## 問題根因

`Credentials` 構造函數中，參數賦值的順序被錯誤地寫反了。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/Credentials.java`

**問題代碼**:

```java
public Credentials(int pid, int uid, int gid) {
    this.gid = gid;   // Bug: 順序錯亂
    this.uid = uid;
    this.pid = pid;
}
```

雖然賦值語句是對的，但如果被改成：

```java
public Credentials(int pid, int uid, int gid) {
    this.pid = gid;   // Bug: 賦錯值
    this.uid = uid;
    this.gid = pid;
}
```

## 正確代碼

```java
public Credentials(int pid, int uid, int gid) {
    this.pid = pid;
    this.uid = uid;
    this.gid = gid;
}
```

## 問題分析

Unix `struct ucred` 的字段順序是 `pid, uid, gid`。

Native 代碼正確地按這個順序傳入：
```c
jclass credClass = (*env)->FindClass(env, "android/net/Credentials");
jmethodID ctor = (*env)->GetMethodID(env, credClass, "<init>", "(III)V");
return (*env)->NewObject(env, credClass, ctor, ucred.pid, ucred.uid, ucred.gid);
```

但 Java 側的賦值順序錯誤，導致值被交換。

## 驗證命令

```bash
atest android.net.cts.LocalSocketTest#testPeerCredentials
```

## 學習要點

- 構造函數參數賦值要與字段聲明對應
- JNI 和 Java 之間的參數傳遞需要一致
- 類似名稱的參數容易發生順序錯誤
