# Media-E-Q009 解答

## Root Cause
`MediaFormat.java` 中處理 `KEY_DURATION` 時，返回值從微秒被錯誤轉換為毫秒（除以 1000）。

原本：
```java
public long getLong(@NonNull String name) {
    return ((Long)mMap.get(name)).longValue();
}
```

被改成：
```java
public long getLong(@NonNull String name) {
    long value = ((Long)mMap.get(name)).longValue();
    if (KEY_DURATION.equals(name)) {
        return value / 1000;  // 錯誤地除以 1000
    }
    return value;
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern A（縱向單點）- 單位轉換錯誤

## 追蹤路徑
1. CTS log → `ExtractorTest.java:234` 的 `assertEquals` 失敗
2. 查看錯誤訊息 → duration 是預期值的 1/1000 (10000000 → 10000)
3. 追蹤 `MediaFormat.getLong(KEY_DURATION)` → 發現返回值被除以 1000
4. 檢查 `MediaFormat.java` 的 `getLong()` 方法

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaFormat.java |
| 正確定位 bug 位置 | 20% | getLong() 中 KEY_DURATION 處理 |
| 理解 root cause | 20% | 能解釋微秒被錯誤轉換為毫秒 |
| 修復方案正確 | 10% | 移除錯誤的除法運算 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 MediaExtractor 的 native 層找問題
- 檢查媒體檔案 metadata 解析
- 追蹤 track format 的設置流程
