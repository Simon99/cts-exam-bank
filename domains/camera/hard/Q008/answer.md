# Q008 答案：RAW Capture DNG Metadata 不完整

## 問題根因

DngCreator 在寫入 DNG 時，某些從 CameraCharacteristics 獲取的 calibration 資料沒有正確寫入。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/DngCreator.java`

```java
public DngCreator(CameraCharacteristics characteristics, CaptureResult result) {
    // BUG: 條件判斷錯誤，跳過了 color calibration
    if (characteristics.get(CameraCharacteristics.SENSOR_CALIBRATION_TRANSFORM1) != null) {
        // 這裡應該是 COLOR_CORRECTION_TRANSFORM，不是 SENSOR_CALIBRATION_TRANSFORM1
        // 因為 key 錯誤，條件永遠為 null
    }
    
    // BUG: illuminant 資訊沒有傳給 native
    // mNativeContext.setCalibrationIlluminant(...); // 被註解掉了
}
```

**文件 2：** `frameworks/base/core/jni/android_hardware_camera2_DngCreator.cpp`

```cpp
static void DngCreator_init(JNIEnv* env, jobject thiz, ...) {
    // BUG: ColorMatrix 寫入條件錯誤
    if (colorMatrix1.size() > 0) {
        // 條件應該是 == 9，不是 > 0
        if (colorMatrix1.size() == 6) {  // 永遠為 false
            writer->addEntry(TAG_COLORMATRIX1, colorMatrix1);
        }
    }
}

static void DngCreator_writeInputStream(JNIEnv* env, ...) {
    // BUG: AsShotNeutral 沒有寫入
    // addAsShotNeutral(writer, asShotNeutral); // 被註解
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/CameraCharacteristics.java`

```java
// 常量定義問題
public static final Key<ColorSpaceTransform> SENSOR_COLOR_TRANSFORM1 = 
    new Key<>("android.sensor.colorTransform1", ColorSpaceTransform.class);
    // BUG: 應該在 legacy 設備上也提供 fallback
```

## 修復方法

```java
// DngCreator.java
public DngCreator(CameraCharacteristics characteristics, CaptureResult result) {
    // 使用正確的 key
    ColorSpaceTransform transform = characteristics.get(
        CameraCharacteristics.SENSOR_COLOR_TRANSFORM1);
    if (transform != null) {
        setColorMatrix(transform);
    }
    
    // 設置 illuminant
    Integer illuminant = characteristics.get(
        CameraCharacteristics.SENSOR_REFERENCE_ILLUMINANT1);
    if (illuminant != null) {
        nativeSetCalibrationIlluminant(illuminant);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest StillCaptureTest#testRawCapture`
4. 測試應該通過

## 學習重點
- DNG 是標準化的 RAW 格式，有嚴格的 metadata 要求
- CameraCharacteristics 包含相機校準資訊
- Native 和 Java 層需要正確傳遞所有必要資訊
