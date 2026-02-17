# Q010 Answer: SensorDirectChannel.isOpen() Always Returns True

## 問題根因
在 `SensorDirectChannel.java` 的 `close()` 方法中，
忘記將 `mIsOpen` 狀態設為 false。導致即使 channel 已關閉，
`isOpen()` 仍返回 true。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorDirectChannel.java`

## 修復方式
```java
// 錯誤的代碼（缺少狀態更新）
@Override
public void close() {
    if (mIsOpen) {
        mNativeHandle.close();
        // mIsOpen = false;  // 這行被遺漏
    }
}

// 正確的代碼
@Override
public void close() {
    if (mIsOpen) {
        mNativeHandle.close();
        mIsOpen = false;
    }
}
```

## 相關知識
- SensorDirectChannel 用於高效能感測器資料傳輸
- close() 釋放 native 資源並更新狀態
- isOpen() 用於檢查 channel 是否可用

## 難度說明
**Easy** - 狀態不一致問題，檢查 close() 中的狀態更新即可。
