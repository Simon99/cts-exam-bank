# Q009: 答案解析

## 問題根源

本題有三個 Bug，分布在 AccountManager 認證流程的不同階段：

### Bug 1: AccountManager.java
`AmsTask.done()` 方法直接調用 callback，而不是通過 `postToHandler()` 轉發到指定的 Handler 線程。

### Bug 2: AccountManagerService.java
返回認證結果時使用了錯誤的 Bundle key，導致客戶端無法正確解析 account type。

### Bug 3: TokenCache.java
token 有效期檢查邏輯反轉，導致有效 token 被丟棄，過期 token 反而被緩存。

## Bug 1 位置

**檔案**: `frameworks/base/core/java/android/accounts/AccountManager.java`

```java
private abstract class AmsTask extends FutureTask<Bundle> 
        implements AccountManagerFuture<Bundle> {
    
    final Handler mHandler;  // 用戶指定的回調線程
    final AccountManagerCallback<Bundle> mCallback;
    
    @Override
    protected void done() {
        if (mCallback != null) {
            // BUG: 直接調用，不使用 Handler
            mCallback.run(this);
            
            // 應該是：
            // postToHandler(mHandler, mCallback, this);
        }
    }
}
```

## Bug 2 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/accounts/AccountManagerService.java`

```java
private Bundle createAuthTokenResult(Account account, String token) {
    Bundle result = new Bundle();
    result.putString(AccountManager.KEY_AUTHTOKEN, token);
    result.putString(AccountManager.KEY_ACCOUNT_NAME, account.name);
    
    // BUG: 使用錯誤的 key
    result.putString("account_type_info", account.type);
    
    // 應該是：
    // result.putString(AccountManager.KEY_ACCOUNT_TYPE, account.type);
    
    return result;
}
```

## Bug 3 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/accounts/TokenCache.java`

```java
public void put(
        Account account,
        String token,
        String tokenType,
        String packageName,
        byte[] sigDigest,
        long expiryMillis) {
    Objects.requireNonNull(account);
    
    // BUG: 比較符號反轉
    if (token == null || System.currentTimeMillis() < expiryMillis) {
        return;  // 這會丟棄所有未過期的 token！
    }
    
    // 正確應該是：
    // if (token == null || System.currentTimeMillis() > expiryMillis) {
    //     return;  // 丟棄過期的 token
    // }
}
```

## 診斷步驟

1. **添加 log 追蹤線程**:
```java
// AccountManager.java AmsTask.done()
Log.d("AccountManager", "done() called on thread: " + Thread.currentThread().getName());
if (mHandler != null) {
    Log.d("AccountManager", "Expected thread: " + mHandler.getLooper().getThread().getName());
}

// AccountManagerService.java
Log.d("AccountManagerService", "createAuthTokenResult: keys=" + result.keySet());

// TokenCache.java
Log.d("TokenCache", "put: currentTime=" + System.currentTimeMillis() 
    + " expiryMillis=" + expiryMillis 
    + " willCache=" + !(token == null || System.currentTimeMillis() < expiryMillis));
```

2. **觀察 log**:
```
# Token 緩存問題
D TokenCache: put: currentTime=1700000000 expiryMillis=1700100000 willCache=false
# Bug 3! 未過期的 token (expiry > current) 被丟棄

# 回調線程問題
D AccountManager: done() called on thread: Binder:1234_5  # Binder 線程！
D AccountManager: Expected thread: main
D AccountManager: Executing callback on: Binder:1234_5  # Bug 1!

# Bundle key 問題
D AccountManagerService: createAuthTokenResult: keys=[authtoken, accountName, account_type_info]
# Bug 2! 應該有 accountType 而不是 account_type_info
```

3. **問題定位**: 
   - Bug 1: Callback 在 Binder 線程執行
   - Bug 2: 客戶端用 KEY_ACCOUNT_TYPE 找不到值
   - Bug 3: 有效 token 不被緩存，每次都要重新獲取

## 問題分析

### Bug 1 分析（線程錯誤）
AccountManager 的異步 API 設計：
1. 用戶可以指定 Handler 來控制 callback 執行的線程
2. 典型用例：指定主線程 Handler，在 callback 中更新 UI
3. 服務通過 Binder IPC 返回結果，回調發生在 Binder 線程池

Bug 的影響：
- callback 總是在 Binder 線程執行
- 在 callback 中更新 UI 會導致 CalledFromWrongThreadException

### Bug 2 分析（Key 錯誤）
使用錯誤的 key 會導致：
- 客戶端使用 `AccountManager.KEY_ACCOUNT_TYPE` 取值時得到 null
- 依賴 account type 的邏輯會失敗

### Bug 3 分析（條件反轉）
`currentTime < expiryMillis` 等價於「token 未過期」：
- 未過期的 token 會被丟棄（return）
- 過期的 token 反而會被緩存
- 完全反轉了緩存邏輯

## 正確代碼

### 修復 Bug 1 (AccountManager.java)
```java
@Override
protected void done() {
    if (mCallback != null) {
        // 正確：通過 Handler 轉發到指定線程
        postToHandler(mHandler, mCallback, this);
    }
}
```

### 修復 Bug 2 (AccountManagerService.java)
```java
Bundle result = new Bundle();
result.putString(AccountManager.KEY_AUTHTOKEN, token);
result.putString(AccountManager.KEY_ACCOUNT_NAME, account.name);
// 正確：使用標準 key
result.putString(AccountManager.KEY_ACCOUNT_TYPE, account.type);
```

### 修復 Bug 3 (TokenCache.java)
```java
// 正確：丟棄過期的 token
if (token == null || System.currentTimeMillis() > expiryMillis) {
    return;
}
```

## 修復驗證

```bash
atest android.accounts.cts.AccountManagerTest#testAuthTokenCallbackThread
atest android.accounts.cts.AccountManagerTest#testGetAuthTokenWithCallback
atest com.android.server.accounts.AccountManagerServiceTest
```

## 難度分類理由

**Hard** - 需要理解：
1. Binder IPC 的線程模型
2. Handler 機制和線程調度
3. FutureTask 的 done() callback 語義
4. AccountManager 異步 API 的設計約定
5. Token 緩存機制

Bug 分布在客戶端（AccountManager）、服務端（AccountManagerService）、和緩存層（TokenCache）三個不同組件。
