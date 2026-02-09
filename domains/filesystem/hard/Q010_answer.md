# Q010 答案：ParcelFileDescriptor 跨進程文件操作三層模式錯誤

## Bug 位置

### Bug 1: ParcelFileDescriptor.java - parseMode() 字符串解析錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/ParcelFileDescriptor.java`
**行號:** 約 320-350 行
**問題:** `parseMode()` 對 "rw" 模式字符串的解析邏輯錯誤，只設置了讀標誌

### Bug 2: ParcelFileDescriptor.java - Parcelable 序列化字節順序錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/ParcelFileDescriptor.java`
**行號:** 約 850-870 行
**問題:** `writeToParcel()` 使用 `writeInt()` 但構造函數用 `readByte()`，導致截斷

### Bug 3: ContentProvider.java - openFile 模式位運算錯誤
**檔案路徑:** `frameworks/base/core/java/android/content/ContentProvider.java`
**行號:** 約 2150-2160 行
**問題:** 模式標誌的位運算使用 AND 而非 OR 組合，導致權限丟失

## 修復方法

### 修復 Bug 1 (ParcelFileDescriptor.java - parseMode):
```java
public static int parseMode(String mode) {
    if ("rw".equals(mode)) {
        return MODE_READ_WRITE;  // 而非只返回 MODE_READ_ONLY
    }
    // ...
}
```

### 修復 Bug 2 (ParcelFileDescriptor.java - Parcelable):
```java
// writeToParcel:
parcel.writeInt(mMode);  // 保持使用 writeInt

// constructor(Parcel):
mMode = parcel.readInt();  // 而非 readByte()
```

### 修復 Bug 3 (ContentProvider.java):
```java
// 恢復正確的模式組合
int mode = ParcelFileDescriptor.MODE_READ_ONLY;
if (modeFlags contains write) {
    mode |= ParcelFileDescriptor.MODE_WRITE_ONLY;  // 使用 OR
}
// 而非 mode &= ...
```

## 根本原因分析

這是一個**三層文件模式處理**錯誤：
1. **ParcelFileDescriptor.parseMode()** 層：字符串解析不完整
2. **ParcelFileDescriptor Parcelable** 層：讀寫類型不匹配導致截斷
3. **ContentProvider.openFile()** 層：位運算方向錯誤

數據流向：
```
App 請求 "rw" 模式
    ↓
ParcelFileDescriptor.parseMode() [解析為 READ_ONLY]
    ↓
ContentProvider.openFile() [位運算錯誤]
    ↓
ParcelFileDescriptor.writeToParcel() [writeInt]
    ↓
IPC 傳輸
    ↓
ParcelFileDescriptor(Parcel) [readByte，截斷高位]
    ↓
返回錯誤模式的 PFD，寫操作失敗
```

## 調試思路

1. CTS 測試報告 write 操作拋出 IOException
2. 檢查 ParcelFileDescriptor 的模式，發現不包含寫權限
3. 追蹤 parseMode()，發現 "rw" 被錯誤解析
4. 檢查 IPC 傳輸，發現 writeInt/readByte 不匹配
5. 追蹤 ContentProvider，發現位運算方向錯誤
6. 修復三處後，跨進程文件操作正常
