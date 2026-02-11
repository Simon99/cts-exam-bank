# Camera2 設備關閉時資源重複釋放

## 情境

在多執行緒環境下，Camera2 應用偶爾會崩潰。分析發現問題出在 `CameraDevice.close()` 被多次調用時，資源會被重複釋放，導致各種異常。

## 問題程式碼

```java
// CameraDeviceImpl.java - close()
public void close() {
    synchronized (mInterfaceLock) {
        mClosing.set(true);

        if (mOfflineSwitchService != null) {
            mOfflineSwitchService.shutdownNow();
            mOfflineSwitchService = null;
        }

        // ... 後續資源釋放 ...

        if (mRemoteDevice != null) {
            mRemoteDevice.disconnect();
            mRemoteDevice.unlinkToDeath(this, /*flags*/0);
        }

        // ... 更多清理 ...
    }
}
```

## 問題

這段程式碼在多執行緒環境下有什麼問題？如何修復？

## 選項

A. `synchronized` 鎖的範圍不對，應該用更細粒度的鎖

B. 應該使用 `mClosing.getAndSet(true)` 並檢查返回值，若已在關閉中則直接返回

C. `mRemoteDevice` 在 `disconnect()` 後應該立即設為 null，而不是在方法最後

D. 應該在 synchronized 區塊外先檢查 `mClosing`，減少鎖競爭
