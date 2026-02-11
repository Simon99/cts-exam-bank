# CTS Exam Bank - Dry Run 驗證報告

Generated: 2026-02-11 08:38
Tested against: aosp-sandbox-1

## 總覽

| 領域 | 題數 | 成功 | 失敗 |
|------|------|------|------|
| AlarmManager | 30 | 30 | 0 ✅ |
| app | 30 | 30 | 0 ✅ |
| camera | 30 | 30 | 0 ✅ |
| display | 30 | 30 | 0 ✅ |
| filesystem | 30 | 29 | 1 |
| framework | 30 | 29 | 1 |
| gpu | 30 | 29 | 1 |
| input | 30 | 25 | 5 |
| jobscheduler | 30 | 29 | 1 |
| location | 30 | 30 | 0 ✅ |
| media | 30 | 30 | 0 ✅ |
| net | 30 | 30 | 0 ✅ |
| security | 53 | 52 | 1 |
| sensor | 30 | 30 | 0 ✅ |
| vibrator | 30 | 30 | 0 ✅ |
| **總計** | **473** | **463** | **10** |

**成功率：97.9%**

---

## 失敗題目詳情

### filesystem/medium/Q005
- `StorageManager.java` Hunk #1 FAILED at 1580
- `VolumeInfo.java` Hunk #1 FAILED at 320

### jobscheduler/hard/Q002
- `DeviceIdleJobsController.java` Hunk #1 FAILED at 280

### gpu/hard/Q002
- malformed patch at line 21

### framework/hard/Q007
- `Intent.java` Hunk #1 FAILED at 7890

### input/medium/Q003
- `MotionEvent.java` Hunk #1 FAILED at 2134

### input/medium/Q008
- `KeyEvent.java` Hunk #1 FAILED at 2089

### input/hard/Q001
- malformed patch at line 19

### input/hard/Q006
- `VelocityTracker.java` Hunk #1 FAILED at 156

### input/hard/Q007
- `MotionPredictor.java` Hunk #1 FAILED at 142

### security/hard/Q006
- `SELinuxNeverallowRulesTest.java` malformed patch at line 20
