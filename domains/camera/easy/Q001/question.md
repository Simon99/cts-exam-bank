# Camera2 連拍功能異常

## 情境

測試團隊報告 Camera2 API 的連拍功能出現異常行為。當開發者傳入空的 CaptureRequest 列表時，應該拋出 `IllegalArgumentException`，但現在程式繼續執行並在後續產生 `NullPointerException`。

## 問題程式碼

```java
// CameraDeviceImpl.java - captureBurst()
public int captureBurst(List<CaptureRequest> requests, CaptureCallback callback,
        Executor executor) throws CameraAccessException {
    if (requests == null && requests.isEmpty()) {
        throw new IllegalArgumentException("At least one request must be given");
    }
    return submitCaptureRequest(requests, callback, executor, /*streaming*/false);
}
```

## 問題

上述程式碼中的 bug 是什麼？

## 選項

A. `requests.isEmpty()` 應該改為 `requests.size() == 0`

B. 條件判斷的邏輯運算符錯誤，`&&` 應該改為 `||`

C. 應該先檢查 `requests.isEmpty()` 再檢查 `requests == null`

D. 缺少對 `executor` 參數的 null 檢查
