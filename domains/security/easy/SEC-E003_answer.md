# SEC-E003 Answer: Algorithm 驗證缺少 EC 算法

## 正確答案
**B) 解析算法時的 switch 語句中缺少 `case KM_ALGORITHM_EC` 分支**

## 問題根因
在 `AuthorizationList.java` 的算法解析邏輯中，
switch 語句只處理了 RSA、AES、HMAC，但漏掉了 EC 算法的 case。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
switch (algorithmValue) {
    case KM_ALGORITHM_RSA:
        return Algorithm.RSA;
    case KM_ALGORITHM_AES:
        return Algorithm.AES;
    case KM_ALGORITHM_HMAC:
        return Algorithm.HMAC;
    // BUG: 缺少 EC case
    default:
        return null;
}

// 正確的代碼
switch (algorithmValue) {
    case KM_ALGORITHM_RSA:
        return Algorithm.RSA;
    case KM_ALGORITHM_EC:
        return Algorithm.EC;
    case KM_ALGORITHM_AES:
        return Algorithm.AES;
    case KM_ALGORITHM_HMAC:
        return Algorithm.HMAC;
    default:
        return null;
}
```

## 為什麼其他選項不對

**A)** 如果常數值錯誤，會在編譯時或其他測試中發現，不會只影響這一個測試。

**C)** TAG 值錯誤會影響整個欄位的解析，不只是 EC 算法。

**D)** 如果 getAlgorithm() 直接返回 null，所有算法測試都會失敗，不只是 EC。

## 相關知識
- EC (Elliptic Curve) 是現代推薦的非對稱加密算法
- KeyMaster 支援多種算法類型
- switch 語句漏掉 case 是常見的遺漏錯誤

## 難度說明
**Easy** - 缺少 case 分支是明顯的遺漏，錯誤訊息直接指向 EC。
