# Build & Deploy — 編譯和刷機注意事項

## 乾淨 Image 備份

**位置：** `~/aosp-images/clean-panther-14/`

**快速恢復：**
```bash
# 手機進 fastboot 後
~/aosp-images/flash-clean.sh [device_serial]

# 例如
~/aosp-images/flash-clean.sh 27161FDH20031X
```

不需要重新 build，直接刷回乾淨狀態。

---

## 增量編譯不可靠

### 現象
- `m services` + `make systemimage` 後 flash → bootloop
- 原因：只重編了 services.jar，但 AIDL 介面/依賴 class 沒跟著重編 → ABI 不匹配
- `vendor.img` / `boot.img` 可能跟 `system.img` 版本不同步

### 規則
**一律使用 full build：`make -j$(nproc)`**

不要用：
- ~~`m services`~~
- ~~`m framework-minus-apex`~~
- ~~`make systemimage`~~

### 未來改善
若要啟用增量編譯，**必須先建立 code review SOP**：
- 確認 patch 不涉及 AIDL 介面變更
- 確認無跨模組依賴變更
- 明確列出哪些檔案類型可以安全增量編譯

### 實測數據
- Full build（有 cache）：~1:30
- Full build（無 cache）：~16 分鐘
- ccache 設定：50G（已寫入 .bashrc）

## PRODUCT_DEFAULT_PROPERTY_OVERRIDES 可能不生效

### 現象
- 在 `device-panther.mk` 中加的 property 不出現在 `getprop`
- build output 的 `build.prop` 裡有，但裝置上沒有

### Workaround
```bash
adb root
adb remount
# 直接寫入 /vendor/build.prop
adb shell "echo 'ro.xxx.yyy=value' >> /vendor/build.prop"
adb reboot
```

### TODO
- 調查 `PRODUCT_VENDOR_PROPERTIES` 是否更可靠
- 確認 property 載入順序

## Flash 流程

### 標準流程
```bash
export PATH=~/aosp-panther/out/host/linux-x86/bin:$PATH
export ANDROID_PRODUCT_OUT=~/develop_claw/aosp-sandbox-2/out/target/product/panther

# 進 fastboot
adb reboot bootloader
sleep 5

# 確認通訊正常
fastboot devices
fastboot getvar product  # 必須秒回，不能 hang

# Flash（-w 清除 userdata）
fastboot flashall -w
```

### Flash 前必做
1. 確認 fastboot 通訊正常（`fastboot getvar product` 要秒回）
2. 如果 hang → USB 狀態異常，需要手動處理（見 usb_issues.md）
