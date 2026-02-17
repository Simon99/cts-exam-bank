# Q001 答案：CameraManager 返回空的相機列表

## 問題根因

在 `CameraManager.java` 的 `getCameraIdList()` 方法中，有一個條件判斷錯誤導致始終返回空列表。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/CameraManager.java`

```java
// Bug: 條件判斷反了，應該是 mDeviceIdList == null 才需要查詢
public String[] getCameraIdList() throws CameraAccessException {
    synchronized (mLock) {
        // BUG: 這裡的條件被改成了 != null，導致已有列表時重新查詢，沒有時返回空
        if (mDeviceIdList != null) {
            // 錯誤地在這裡清空並重新查詢
            mDeviceIdList.clear();
        }
        return mDeviceIdList != null ? mDeviceIdList.toArray(new String[0]) : new String[0];
    }
}
```

## 修復方法

```java
public String[] getCameraIdList() throws CameraAccessException {
    synchronized (mLock) {
        // 正確：只在列表為空時才查詢
        if (mDeviceIdList == null) {
            mDeviceIdList = new ArrayList<String>();
            // ... 正常的相機發現邏輯
        }
        return mDeviceIdList.toArray(new String[0]);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraManagerTest#testCameraManagerGetDeviceIdList`
4. 測試應該通過

## 學習重點
- CTS 測試會驗證 API 返回值的正確性
- 條件判斷的邏輯錯誤是常見的 bug 類型
- 單一方法的邏輯錯誤通常只需要修改一個檔案
