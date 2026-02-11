# Q004 Answer: getSensorList Returns Empty List

## 問題根因
在 `SensorManager.java` 的 `getSensorList()` 方法中，
當 type 為 `TYPE_ALL (-1)` 時，應該跳過類型過濾並返回所有感測器。

Bug 是條件判斷順序錯誤：先檢查類型匹配，再檢查是否為 TYPE_ALL。
由於沒有感測器的 type 是 -1，所以沒有任何感測器被加入列表。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public List<Sensor> getSensorList(int type) {
    List<Sensor> result = new ArrayList<>();
    for (Sensor sensor : mFullSensorList) {
        if (sensor.getType() == type) {  // 這裡 TYPE_ALL=-1 永遠不匹配
            result.add(sensor);
        } else if (type == Sensor.TYPE_ALL) {
            result.add(sensor);
        }
    }
    return result;
}

// 正確的代碼（先檢查 TYPE_ALL）
public List<Sensor> getSensorList(int type) {
    List<Sensor> result = new ArrayList<>();
    for (Sensor sensor : mFullSensorList) {
        if (type == Sensor.TYPE_ALL || sensor.getType() == type) {
            result.add(sensor);
        }
    }
    return result;
}
```

## 相關知識
- Sensor.TYPE_ALL = -1（代表所有感測器類型）
- 邏輯短路：|| 運算符會先評估 TYPE_ALL 條件

## 難度說明
**Easy** - 錯誤訊息說明列表為空，只需檢查 TYPE_ALL 的處理邏輯即可。
