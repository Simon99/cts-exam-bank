# Q006: FileUtil BUFFER_SIZE 設置過小導致測試超時

## CTS 測試失敗信息

```
Test: android.filesystem.cts.SequentialRWTest#testSingleSequentialWrite
FAILURE: Test timed out after 600000 milliseconds
    at android.filesystem.cts.SequentialRWTest.testSingleSequentialWrite
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
順序寫入測試因超時而失敗。
測試需要寫入大量數據，但執行時間遠超預期。

## 相關日誌
```
I SequentialRWTest: Starting sequential write test
I SequentialRWTest: File size target: 2147483648 bytes
I FileUtil: Writing with buffer size: 1024 bytes
I SequentialRWTest: Progress: 1% after 60 seconds
W SequentialRWTest: Test running too slow...
E SequentialRWTest: Test timeout after 600 seconds
```

## 提示
- 檢查 `FileUtil.java` 中的 `BUFFER_SIZE` 常量
- 緩衝區大小直接影響 I/O 效率
