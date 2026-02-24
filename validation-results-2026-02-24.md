# CTS 測試方法驗證結果
**日期**: 2026-02-24
**版本**: CTS 14_r7

## 統計
- 總題數: 40
- 有效: 11 (27.5%)
- 無效: 29 (72.5%)

## 有效題目 ✅

| 領域 | 難度 | 題號 | 模組 | 測試方法 |
|------|------|------|------|----------|
| Framework | Medium | Q001 | CtsOsTestCases | BundleTest#testWriteToParcel |
| Framework | Medium | Q004 | CtsContentTestCases | IntentTest#testFilterEquals |
| Framework | Medium | Q005 | CtsOsTestCases | BundleTest#testPutAll |
| Framework | Medium | Q006 | CtsContentTestCases | IntentTest#testClone |
| Camera | Hard | Q010 | CtsCameraTestCases | CameraManagerTest#testTorchCallback |
| Camera | Medium | Q001 | CtsCameraTestCases | CaptureResultTest#testCameraCaptureResultAllKeys |
| Camera | Medium | Q002 | CtsCameraTestCases | CaptureResultTest#testPartialResult |
| Camera | Medium | Q003 | CtsCameraTestCases | CameraManagerTest#testCameraManagerAvailabilityCallback |
| Camera | Medium | Q004 | CtsCameraTestCases | CameraDeviceTest#testSessionConfiguration |
| Camera | Medium | Q005 | CtsCameraTestCases | CameraDeviceTest#testCameraDeviceRepeatingRequest |
| Camera | Medium | Q009 | CtsCameraTestCases | CaptureRequestTest#testZoomRatio |

## 無效題目 ❌

### Framework Hard (10/10 - 全部無效)
| 題號 | 問題 | 測試方法 |
|------|------|----------|
| Q001 | METHOD_NOT_FOUND | IntentTest#testParcelableAcrossProcesses |
| Q002 | METHOD_NOT_FOUND | BundleTest#testNestedBundleParcel |
| Q003 | METHOD_NOT_FOUND | IntentTest#testClipDataUriPermission |
| Q004 | METHOD_NOT_FOUND | BundleTest#testBinderLeak |
| Q005 | CLASS_NOT_FOUND | PendingIntentTest#testPendingIntentSecurity |
| Q006 | METHOD_NOT_FOUND | BundleTest#testSparseArrayParcel |
| Q007 | METHOD_NOT_FOUND | ActivityLifecycleTests#testResumedActivityProcessPriority |
| Q008 | METHOD_NOT_FOUND | PendingIntentTest#testGetFlagsAfterCrossPackageParcel |
| Q009 | METHOD_NOT_FOUND | ContentResolverTest#testNotifyChangeFlags |
| Q010 | METHOD_NOT_FOUND | IntentFilterTest#testParceling |

### Framework Medium (6/10 無效)
| 題號 | 問題 | 測試方法 |
|------|------|----------|
| Q002 | METHOD_NOT_FOUND | IntentTest#testParcelableExtras |
| Q003 | METHOD_NOT_FOUND | BundleTest#testDeepCopy |
| Q007 | METHOD_NOT_FOUND | BundleTest#testKeySetImmutable |
| Q008 | METHOD_NOT_FOUND | ParcelTest#testReadBundleWithClassLoader |
| Q009 | METHOD_NOT_FOUND | IntentTest#testResolveType |
| Q010 | METHOD_NOT_FOUND | BundleTest#testLazyUnparcel |

### Camera Hard (9/10 無效)
| 題號 | 問題 | 測試方法 |
|------|------|----------|
| Q001 | METHOD_NOT_FOUND | LogicalCameraDeviceTest#testLogicalCameraPhysicalIds |
| Q002 | METHOD_NOT_FOUND | OfflineSessionTest#testOfflineSessionSwitch |
| Q003 | METHOD_NOT_FOUND | ReprocessCaptureTest#testReprocessJpeg |
| Q004 | METHOD_NOT_FOUND | CameraExtensionSessionTest#testExtensionSession |
| Q005 | METHOD_NOT_FOUND | CameraDeviceTest#testMultiCameraLogicalStreaming |
| Q006 | METHOD_NOT_FOUND | RecordingTest#testHighSpeedRecording |
| Q007 | METHOD_NOT_FOUND | CameraDeviceTest#testSessionSwitching |
| Q008 | METHOD_NOT_FOUND | StillCaptureTest#testRawCapture |
| Q009 | METHOD_NOT_FOUND | BurstCaptureTest#testBurstCaptureOrdering |

### Camera Medium (4/10 無效)
| 題號 | 問題 | 測試方法 |
|------|------|----------|
| Q006 | METHOD_NOT_FOUND | CaptureResultTest#testCaptureResultGet |
| Q007 | METHOD_NOT_FOUND | CaptureRequestTest#testAeModes |
| Q008 | METHOD_NOT_FOUND | CaptureResultTest#testCaptureResultGet |
| Q010 | METHOD_NOT_FOUND | ReprocessCaptureTest#testReprocessJpeg |

## 結論
題目設計時使用了虛構的測試方法名稱。需要：
1. 查詢 CTS 14_r7 中真實存在的測試方法
2. 重新設計 bug 注入點以匹配真實測試
3. 或重新產生新題目
