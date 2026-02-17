# Q008: Get Vibrator Info Returns Null

## CTS Test
`android.os.cts.VibratorTest#testGetInfo`

## Failure Log
```
java.lang.NullPointerException: Attempt to invoke virtual method 
'int android.os.VibratorInfo.getId()' on a null object reference
    at android.os.cts.VibratorTest.testGetInfo(VibratorTest.java:275)
```

## 現象描述
呼叫 `vibrator.getInfo()` 後嘗試存取回傳的 VibratorInfo 物件時發生 NPE。
文件說明 getInfo() 不應回傳 null。

## 提示
- 檢查 `getInfo()` 方法的實作
- 注意是否有條件會導致回傳 null
- 方法應該保證非空回傳值
