# Q006 答案解析

## 問題根因
`FileUtil.BUFFER_SIZE` 被錯誤地設置為 1KB（1024 bytes），
而原始值應該是 10MB（10 * 1024 * 1024 bytes）。
過小的緩衝區導致大量的 I/O 操作，嚴重降低寫入效率。

## 修復位置
`cts/tests/filesystem/src/android/filesystem/cts/FileUtil.java`

## 修復方法
將 `BUFFER_SIZE` 恢復為 10MB。

## 原始代碼
```java
public static final int BUFFER_SIZE = 1024;  // Bug: 1KB 太小
```

## 修復後代碼
```java
public static final int BUFFER_SIZE = 10 * 1024 * 1024;  // 10MB
```

## 知識點
1. 緩衝區大小對 I/O 性能有顯著影響
2. 較大的緩衝區減少系統調用次數
3. CTS 測試有時間限制，性能問題會導致超時

## 調試技巧
1. 注意到超時錯誤，首先檢查可能影響性能的參數
2. 對比日誌中的緩衝區大小與預期值
3. 緩衝區大小通常在 KB 到 MB 級別
