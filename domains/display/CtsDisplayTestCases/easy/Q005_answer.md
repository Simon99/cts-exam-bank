# Display-E-Q005 解答

## Root Cause
在設備配置中錯誤設定了 `ro.surface_flinger.max_graphics_width` 系統屬性。

根據 Android CDD 規範，非 TV 設備（不具有 FEATURE_LEANBACK）不允許限制 framebuffer 尺寸。CTS 測試會檢查 `ro.surface_flinger.max_graphics_width` 和 `ro.surface_flinger.max_graphics_height` 是否為空字串。

問題修改在 `device/google/panther/vendor.prop` 或類似的設備配置文件中，添加了：
```
ro.surface_flinger.max_graphics_width=1920
```

## 涉及檔案
- `device/google/panther/vendor.prop`（或 `device.mk`、`system.prop` 等設備配置文件）

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 `expected:<[]> but was:<[1920]>`
2. 理解測試邏輯 → 非 TV 設備不應設置 max_graphics_width
3. `adb shell getprop ro.surface_flinger.max_graphics_width` 確認返回 1920
4. 搜索設備配置 `grep -r "max_graphics_width" device/google/panther/`

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 位置 | 40% | 找到設備配置文件中的 prop 設定 |
| 理解 CDD 規範 | 20% | 了解非 TV 設備不能限制 framebuffer |
| 正確定位 root cause | 20% | 知道是 system property 導致 |
| 修復方案正確 | 10% | 移除或註釋掉該屬性 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 在 SurfaceFlinger 代碼中找問題（問題在設備配置）
- 不知道 getprop 可以直接檢查系統屬性值
- 沒有注意 CTS log 中的具體數值 "1920"
