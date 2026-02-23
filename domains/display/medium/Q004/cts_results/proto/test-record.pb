Ïé
$c71ad459-10ec-4b7e-8a0c-1e2dc7495995ﬂu‹u
&arm64-v8a CtsDisplayTestCases[instant]$c71ad459-10ec-4b7e-8a0c-1e2dc7495995ﬁZ€Z
&arm64-v8a CtsDisplayTestCases[instant]&arm64-v8a CtsDisplayTestCases[instant]éã
/android.display.cts.DisplayTest#testGetDisplays&arm64-v8a CtsDisplayTestCases[instant](2ë
Åjava.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Åjava.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
"
UNSET:Ùµ“Ã¿€§…Bıµ“ÃÄÄíÙ (2≈8
ö8Instrumentation run failed due to 'Process crashed.'
Java Crash Messages sorted from most recent:
Unable to start activity ComponentInfo{android.display.cts/android.display.cts.ScreenOnActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
java.lang.RuntimeException: Unable to start activity ComponentInfo{android.display.cts/android.display.cts.ScreenOnActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3993)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Caused by: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
Unable to start activity ComponentInfo{com.android.compatibility.common.deviceinfo/com.android.compatibility.common.deviceinfo.GlesStubActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
java.lang.RuntimeException: Unable to start activity ComponentInfo{com.android.compatibility.common.deviceinfo/com.android.compatibility.common.deviceinfo.GlesStubActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3993)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Caused by: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
Unable to get provider androidx.startup.InitializationProvider: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
java.lang.RuntimeException: Unable to get provider androidx.startup.InitializationProvider: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
	at android.app.ActivityThread.installProvider(ActivityThread.java:8184)
	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7694)
	at android.app.ActivityThread.handleBindApplication(ActivityThread.java:7383)
	at android.app.ActivityThread.-$$Nest$mhandleBindApplication(Unknown Source:0)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2379)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Caused by: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
	at androidx.startup.AppInitializer.doInitialize(AppInitializer.java:187)
	at androidx.startup.AppInitializer.discoverAndInitialize(AppInitializer.java:239)
	at androidx.startup.AppInitializer.discoverAndInitialize(AppInitializer.java:207)
	at androidx.startup.InitializationProvider.onCreate(InitializationProvider.java:49)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2644)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2613)
	at android.app.ActivityThread.installProvider(ActivityThread.java:8179)"$
UNSETÚINSTRUMENTATION_CRASHÄà‡:Ûµ“Ã¿ÖÜ•Bˆµ“ÃÄñµ’R"
run-isolated

FULLY_ISOLATEDR
MODULE_TEST_COUNT	
intR$
TEARDOWN_TIME
©millisecondsR
MODULE_RETRY_SUCCESS
 R 
	PREP_TIME
ÔmillisecondsR 
	TEST_TIME
©millisecondsR
MODULE_RETRY_FAILED
 R'
MODULE_RETRY_TIME
 milliseconds(:π∂“Ã¿ΩµùBπ∂“ÃÄ¬ÚùZå
,type.googleapis.com/tradefed.invoker.Context€ê
DEFAULT_DEVICE˝
13033356"
SUITE_BUILD13033356"
START_TIME_MS1771346645562"p
system_img_info]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys" 
cts:build_manufacturerGoogle"
cts:build_abis_32 "#
cts:build_reference_fingerprint "t
command_line_args_cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetDisplays -s 27161FDH20031X"!
cts:build_productaosp_panther"
cts:build_tags	test-keys":
cts:build_version_incrementaleng.simon.20260217.163627"
cts:build_brandAndroid"G
ROOT_DIR;/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../.."v
cts:build_fingerprint]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys"*
$27161FDH20031X-battery-setup -> test82"
SUITE_VERSION14_r7"

SUITE_PLANcts""
cts:build_modelAOSP on Panther"+
SUITE_FULL_NAMECompatibility Test Suite"
cts:build_devicepanther"-
'27161FDH20031X-battery-initial -> setup82"
cts:build_idAP2A.240905.003"_
vendor_img_infoLAndroid/aosp_panther/panther:14/AP2A.240905.003/12231197:userdebug/test-keys"Ä
cts:build_bootimage_fingerprint]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys"∞
DYNAMIC_CONFIG_OVERRIDE_URLêhttps://androidpartner.googleapis.com/v1/dynamicconfig/suites/CTS/modules/{module}/version/{version}?key=AIzaSyAbwX5JRlmsLeygY2WWihpIJPXFLueOQ3U"!

RESULT_DIR2026.02.18_00.44.05"
cts:build_version_sdk34""
cts:build_serial27161FDH20031X".
 cts:build_version_security_patch
2024-09-05"ì
device_kernel_info}Linux localhost 5.10.198-android13-4-00050-g12f3388846c3-ab11920634 #1 SMP PREEMPT Mon Jun 3 20:51:42 UTC 2024 aarch64 Toybox"
cts:build_abi	arm64-v8a"
cts:build_abis_64	arm64-v8a"

SUITE_NAMECTS"$
27161FDH20031X-battery-initial82"l
cts:build_vendor_fingerprintLAndroid/aosp_panther/panther:14/AP2A.240905.003/12231197:userdebug/test-keys"
cts:build_version_base_os "
cts:build_abis	arm64-v8a"
cts:build_boardpanther"
cts:build_type	userdebug"
cts:build_version_release14"
cts:build_abi2 *b
testsdirV
0Q/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases*b
cts12265765707576362692.dynamic?
DYNAMIC_CONFIG_FILE:cts$/tmp/cts12265765707576362692.dynamic*B
device_info_dir/
v1)/tmp/device-info-files14941015762801539012*com.android.tradefed.build.DeviceBuildInfo

module-abi	arm64-v8a"
module-nameCtsDisplayTestCases
module-paraminstant3
	module-id&arm64-v8a CtsDisplayTestCases[instant]!
module-isolatedFULLY_ISOLATED"
MODULE_START_TIME1771346663046‘
&system_checker_enabled_device_baseline©keep_engprod_mode_on,disable_os_auto_update,hide_error_dialogs,keep_screen_on,disable_usb_app_verification,clear_lock_screen,keep_location_mode_on,keep_setup_complete_on0
'system_checker_time_for_device_baseline10212 
MODULE_END_TIME1771346702986"»
cts
	component	frameworkG
	parameterinstant_app	multi_abisecondary_userrun_on_sdk_sandbox
active-parameterinstantx
module-dir-pathe/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDisplayTestCases
prioritize-host-configfalse 2CtsDisplayTestCases:
	arm64-v8a64¶`£`
arm64-v8a CtsDisplayTestCases$c71ad459-10ec-4b7e-8a0c-1e2dc7495995êFçF
arm64-v8a CtsDisplayTestCasesarm64-v8a CtsDisplayTestCasesÖÇ
/android.display.cts.DisplayTest#testGetDisplaysarm64-v8a CtsDisplayTestCases(2ë
Åjava.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Åjava.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
"
UNSET:ù∂“Ã¿·ù°Bû∂“Ã¿åõø (2∂$
ã$Instrumentation run failed due to 'Process crashed.'
Java Crash Messages sorted from most recent:
Unable to start activity ComponentInfo{android.display.cts/android.display.cts.ScreenOnActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
java.lang.RuntimeException: Unable to start activity ComponentInfo{android.display.cts/android.display.cts.ScreenOnActivity}: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3993)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4173)
	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:114)
	at android.app.servertransaction.TransactionExecutor.executeNonLifecycleItem(TransactionExecutor.java:231)
	at android.app.servertransaction.TransactionExecutor.executeTransactionItems(TransactionExecutor.java:152)
	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:93)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2595)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Caused by: java.lang.NullPointerException: Attempt to invoke virtual method 'int android.view.Display.getDisplayId()' on a null object reference
	at com.android.internal.policy.DecorContext.<init>(DecorContext.java:55)
	at com.android.internal.policy.PhoneWindow.generateDecor(PhoneWindow.java:2445)
	at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2824)
	at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2202)
	at android.app.ActivityTransitionState.setEnterSceneTransitionInfo(ActivityTransitionState.java:175)
	at android.app.Activity.performCreate(Activity.java:8970)
	at android.app.Activity.performCreate(Activity.java:8938)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1526)
	at androidx.test.runner.MonitoringInstrumentation.callActivityOnCreate(MonitoringInstrumentation.java:779)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3975)
Unable to get provider androidx.startup.InitializationProvider: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
java.lang.RuntimeException: Unable to get provider androidx.startup.InitializationProvider: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
	at android.app.ActivityThread.installProvider(ActivityThread.java:8184)
	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7694)
	at android.app.ActivityThread.handleBindApplication(ActivityThread.java:7383)
	at android.app.ActivityThread.-$$Nest$mhandleBindApplication(Unknown Source:0)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2379)
	at android.os.Handler.dispatchMessage(Handler.java:107)
	at android.os.Looper.loopOnce(Looper.java:232)
	at android.os.Looper.loop(Looper.java:317)
	at android.app.ActivityThread.main(ActivityThread.java:8592)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:580)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:878)
Caused by: androidx.startup.StartupException: java.lang.NullPointerException: Attempt to invoke virtual method 'float android.view.DisplayInfo.getRefreshRate()' on a null object reference
	at androidx.startup.AppInitializer.doInitialize(AppInitializer.java:187)
	at androidx.startup.AppInitializer.discoverAndInitialize(AppInitializer.java:239)
	at androidx.startup.AppInitializer.discoverAndInitialize(AppInitializer.java:207)
	at androidx.startup.InitializationProvider.onCreate(InitializationProvider.java:49)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2644)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2613)
	at android.app.ActivityThread.installProvider(ActivityThread.java:8179)"$
UNSETÚINSTRUMENTATION_CRASHÄà‡:õ∂“Ã¿’¢˜Bü∂“ÃÄ∑ú∞R
MODULE_TEST_COUNT	
intR$
TEARDOWN_TIME
≥millisecondsR
MODULE_RETRY_SUCCESS
 R 
	PREP_TIME
òmillisecondsR 
	TEST_TIME
·millisecondsR
MODULE_RETRY_FAILED
 R'
MODULE_RETRY_TIME
 milliseconds(:π∂“Ã¿∆ØûBπ∂“Ã¿∆ØûZ™
,type.googleapis.com/tradefed.invoker.Context˘ê
DEFAULT_DEVICE˝
13033356"
SUITE_BUILD13033356"
START_TIME_MS1771346645562"p
system_img_info]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys" 
cts:build_manufacturerGoogle"
cts:build_abis_32 "#
cts:build_reference_fingerprint "t
command_line_args_cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetDisplays -s 27161FDH20031X"!
cts:build_productaosp_panther"
cts:build_tags	test-keys":
cts:build_version_incrementaleng.simon.20260217.163627"
cts:build_brandAndroid"G
ROOT_DIR;/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../.."v
cts:build_fingerprint]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys"*
$27161FDH20031X-battery-setup -> test82"
SUITE_VERSION14_r7"

SUITE_PLANcts""
cts:build_modelAOSP on Panther"+
SUITE_FULL_NAMECompatibility Test Suite"
cts:build_devicepanther"-
'27161FDH20031X-battery-initial -> setup82"
cts:build_idAP2A.240905.003"_
vendor_img_infoLAndroid/aosp_panther/panther:14/AP2A.240905.003/12231197:userdebug/test-keys"Ä
cts:build_bootimage_fingerprint]Android/aosp_panther/panther:14/AP2A.240905.003/eng.simon.20260217.163627:userdebug/test-keys"∞
DYNAMIC_CONFIG_OVERRIDE_URLêhttps://androidpartner.googleapis.com/v1/dynamicconfig/suites/CTS/modules/{module}/version/{version}?key=AIzaSyAbwX5JRlmsLeygY2WWihpIJPXFLueOQ3U"!

RESULT_DIR2026.02.18_00.44.05"
cts:build_version_sdk34""
cts:build_serial27161FDH20031X".
 cts:build_version_security_patch
2024-09-05"ì
device_kernel_info}Linux localhost 5.10.198-android13-4-00050-g12f3388846c3-ab11920634 #1 SMP PREEMPT Mon Jun 3 20:51:42 UTC 2024 aarch64 Toybox"
cts:build_abi	arm64-v8a"
cts:build_abis_64	arm64-v8a"

SUITE_NAMECTS"$
27161FDH20031X-battery-initial82"l
cts:build_vendor_fingerprintLAndroid/aosp_panther/panther:14/AP2A.240905.003/12231197:userdebug/test-keys"
cts:build_version_base_os "
cts:build_abis	arm64-v8a"
cts:build_boardpanther"
cts:build_type	userdebug"
cts:build_version_release14"
cts:build_abi2 *b
testsdirV
0Q/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases*b
cts12265765707576362692.dynamic?
DYNAMIC_CONFIG_FILE:cts$/tmp/cts12265765707576362692.dynamic*B
device_info_dir/
v1)/tmp/device-info-files14941015762801539012*com.android.tradefed.build.DeviceBuildInfo

module-abi	arm64-v8a"
module-nameCtsDisplayTestCases*
	module-idarm64-v8a CtsDisplayTestCases"
MODULE_START_TIME1771346702988‘
&system_checker_enabled_device_baseline©keep_engprod_mode_on,disable_os_auto_update,hide_error_dialogs,keep_screen_on,disable_usb_app_verification,clear_lock_screen,keep_location_mode_on,keep_setup_complete_on0
'system_checker_time_for_device_baseline10195 
MODULE_END_TIME1771346744705"´
cts
	component	frameworkG
	parameterinstant_app	multi_abisecondary_userrun_on_sdk_sandboxx
module-dir-pathe/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDisplayTestCases
prioritize-host-configfalse 2CtsDisplayTestCases:
	arm64-v8a64(:π∂“ÃÄπ¯úBû∑“Ã¿øÌ!Zö∏
,type.googleapis.com/tradefed.invoker.ContextË∑
ctsÊ
DEFAULT_DEVICE”
13033356"+
SUITE_FULL_NAMECompatibility Test Suite"t
command_line_args_cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetDisplays -s 27161FDH20031X"
SUITE_BUILD13033356"

SUITE_NAMECTS"
START_TIME_MS1771346645562"G
ROOT_DIR;/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../.."
SUITE_VERSION14_r7"

SUITE_PLANcts"∞
DYNAMIC_CONFIG_OVERRIDE_URLêhttps://androidpartner.googleapis.com/v1/dynamicconfig/suites/CTS/modules/{module}/version/{version}?key=AIzaSyAbwX5JRlmsLeygY2WWihpIJPXFLueOQ3U"!

RESULT_DIR2026.02.18_00.44.05*b
testsdirV
0Q/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases2*com.android.tradefed.build.DeviceBuildInfo
invocation-id1t
command_line_args_cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetDisplays -s 27161FDH20031Xd
 invocation-external-dependencies@com.android.tradefed.dependencies.connectivity.NetworkDependencyÑ
adb_versionu1.0.41 subVersion: 35.0.1-eng.simon.20250807.040149 install path: /home/simon/aosp-panther/out/host/linux-x86/bin/adb
java_version17.0.4.1•Æ
java_classpathëÆ/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/tradefed.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/ats_console_deploy.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/ats_olc_server_local_mode_deploy.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/compatibility-host-util.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/compatibility-tradefed.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/cts-tradefed.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/cts-tradefed-tests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/tools/loganalysis.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest982HostTestCases/CtsJvmtiRunTest982HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest914HostTestCases/CtsJvmtiRunTest914HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest926HostTestCases/CtsJvmtiRunTest926HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1971HostTestCases/CtsJvmtiRunTest1971HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpTunnelHostTestCases/jdi-support.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpTunnelHostTestCases/CtsJdwpTunnelHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsGpuMetricsHostTestCases/CtsGpuMetricsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest911HostTestCases/CtsJvmtiRunTest911HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsGrammaticalInflectionHostTestCases/CtsGrammaticalInflectionHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSecurityHostTestCases/CtsSecurityHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHostsideWebViewTests/CtsHostsideWebViewTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2007HostTestCases/CtsJvmtiRunTest2007HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHostsideTvTests/CtsHostsideTvTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsMediaBitstreamsTestCases/CtsMediaBitstreamsTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDeqpTestCases/CtsDeqpTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest931HostTestCases/CtsJvmtiRunTest931HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiAttachingHostTestCases/CtsJvmtiAttachingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsInstallHostTestCases/CtsInstallHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1934HostTestCases/CtsJvmtiRunTest1934HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDumpsysHostTestCases/CtsDumpsysHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsClasspathDeviceInfoTestCases/CtsClasspathDeviceInfoTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsBiometricsHostTestCases/CtsBiometricsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSampleHostTestCases/CtsSampleHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1916HostTestCases/CtsJvmtiRunTest1916HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest903HostTestCases/CtsJvmtiRunTest903HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsMediaHostTestCases/CtsMediaHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art-run-test-018-stack-overflow/arm64/art-run-test-018-stack-overflow.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHdmiCecHostTestCases/CtsHdmiCecHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiTrackingHostTestCases/CtsJvmtiTrackingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1995HostTestCases/CtsJvmtiRunTest1995HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1912HostTestCases/CtsJvmtiRunTest1912HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1998HostTestCases/CtsJvmtiRunTest1998HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCarrierApiTargetPrep/CtsCarrierApiTargetPrep.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsMediaParserHostTestCases/CtsMediaParserHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/MicrodroidTestPreparer/MicrodroidTestPreparer.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest942HostTestCases/CtsJvmtiRunTest942HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2006HostTestCases/CtsJvmtiRunTest2006HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsClassloaderSplitsHostTestCases/CtsClassloaderSplitsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest945HostTestCases/CtsJvmtiRunTest945HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest992HostTestCases/CtsJvmtiRunTest992HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest990HostTestCases/CtsJvmtiRunTest990HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDynamicMimeHostTestCases/CtsDynamicMimeHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2004HostTestCases/CtsJvmtiRunTest2004HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1967HostTestCases/CtsJvmtiRunTest1967HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsExtractNativeLibsHostTestCases/CtsExtractNativeLibsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1962HostTestCases/CtsJvmtiRunTest1962HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1989HostTestCases/CtsJvmtiRunTest1989HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/compatibility-host-telephony-preconditions/compatibility-host-telephony-preconditions.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest905HostTestCases/CtsJvmtiRunTest905HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest984HostTestCases/CtsJvmtiRunTest984HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest996HostTestCases/CtsJvmtiRunTest996HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsClasspathsTestCases/CtsClasspathsTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1981HostTestCases/CtsJvmtiRunTest1981HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCarHostTestCases/CtsCarHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1975HostTestCases/CtsJvmtiRunTest1975HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsTelephonyProviderHostCases/CtsTelephonyProviderHostCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest912HostTestCases/CtsJvmtiRunTest912HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1911HostTestCases/CtsJvmtiRunTest1911HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1979HostTestCases/CtsJvmtiRunTest1979HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCarHostNonRecoverableTestCases/CtsCarHostNonRecoverableTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1977HostTestCases/CtsJvmtiRunTest1977HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsIncrementalInstallHostTestCases/CtsIncrementalInstallHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAngleIntegrationHostTestCases/AngleIntegrationTestCommon.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAngleIntegrationHostTestCases/CtsAngleIntegrationHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsInputMethodServiceCommon/arm64/CtsInputMethodServiceCommon.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1928HostTestCases/CtsJvmtiRunTest1928HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1940HostTestCases/CtsJvmtiRunTest1940HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1969HostTestCases/CtsJvmtiRunTest1969HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCppToolsTestCases/CtsCppToolsTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1900HostTestCases/CtsJvmtiRunTest1900HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSystemUiHostTestCases/CtsSystemUiHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAbiOverrideHostTestCases/CtsAbiOverrideHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAdServicesHostTests/CtsAdServicesHostTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest924HostTestCases/CtsJvmtiRunTest924HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1958HostTestCases/CtsJvmtiRunTest1958HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest922HostTestCases/CtsJvmtiRunTest922HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest920HostTestCases/CtsJvmtiRunTest920HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1939HostTestCases/CtsJvmtiRunTest1939HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsVoiceInteractionHostTestCases/CtsVoiceInteractionHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAtraceHostTestCases/CtsAtraceHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1992HostTestCases/CtsJvmtiRunTest1992HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/cts-dalvik-host-test-runner/cts-dalvik-host-test-runner.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCallLogTestCases/CtsCallLogTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2002HostTestCases/CtsJvmtiRunTest2002HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsIcu4cTestCases/CtsIcu4cTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsIcu4cTestCases/ICU4CTestRunner.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsGpuToolsHostTestCases/CtsGpuToolsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest997HostTestCases/CtsJvmtiRunTest997HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1968HostTestCases/CtsJvmtiRunTest1968HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1974HostTestCases/CtsJvmtiRunTest1974HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest988HostTestCases/CtsJvmtiRunTest988HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art-run-test-048-reflect-v8/arm64/art-run-test-048-reflect-v8.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsStatsdAtomHostTestCases/CtsStatsdAtomHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1925HostTestCases/CtsJvmtiRunTest1925HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsStatsdHostTestCases/CtsStatsdHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDomainVerificationHostTestCases/CtsDomainVerificationHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsInstalledLoadingProgressHostTests/CtsInstalledLoadingProgressHostTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest918HostTestCases/CtsJvmtiRunTest918HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsPackageSettingHostTestCases/CtsPackageSettingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1982HostTestCases/CtsJvmtiRunTest1982HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2005HostTestCases/CtsJvmtiRunTest2005HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1908HostTestCases/CtsJvmtiRunTest1908HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsEdiHostTestCases/CtsEdiHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsPackageManagerParsingHostTestCases/CtsPackageManagerParsingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest940HostTestCases/CtsJvmtiRunTest940HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1909HostTestCases/CtsJvmtiRunTest1909HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1978HostTestCases/CtsJvmtiRunTest1978HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1910HostTestCases/CtsJvmtiRunTest1910HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCarBuiltinApiHostTestCases/CtsCarBuiltinApiHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDevicePolicyManagerTestCases/CtsDevicePolicyManagerTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHostsideNetworkTests/CtsHostsideNetworkTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAccountsHostTestCases/CtsAccountsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest917HostTestCases/CtsJvmtiRunTest917HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1976HostTestCases/CtsJvmtiRunTest1976HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsTelecomHostCases/CtsTelecomHostCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsUsesNativeLibraryTest/CtsUsesNativeLibraryTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppSecurityHostTestCases/CtsAppSecurityHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/odsign_e2e_tests/odsign_e2e_tests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1915HostTestCases/CtsJvmtiRunTest1915HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsOsHostTestCases/CtsOsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsScopedStorageHostTest/CtsScopedStorageHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1920HostTestCases/CtsJvmtiRunTest1920HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsThemeHostTestCases/CtsThemeHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest995HostTestCases/CtsJvmtiRunTest995HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest913HostTestCases/CtsJvmtiRunTest913HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1926HostTestCases/CtsJvmtiRunTest1926HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest907HostTestCases/CtsJvmtiRunTest907HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpTestCases/arm64/CtsJdwpTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpTestCases/cts-dalvik-device-test-runner.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1991HostTestCases/CtsJvmtiRunTest1991HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1903HostTestCases/CtsJvmtiRunTest1903HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsBlobStoreHostTestCases/CtsBlobStoreHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest993HostTestCases/CtsJvmtiRunTest993HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1953HostTestCases/CtsJvmtiRunTest1953HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1996HostTestCases/CtsJvmtiRunTest1996HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/MicrodroidHostTestCases/MicrodroidHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/compatibility-host-provider-preconditions/compatibility-host-provider-preconditions.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsTaggingHostTestCases/CtsTaggingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsThreadLocalRandomHostTest/CtsThreadLocalRandomHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest994HostTestCases/CtsJvmtiRunTest994HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAdbHostTestCases/CtsAdbHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSyncContentHostTestCases/CtsSyncContentHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDexMetadataHostTestCases/CtsDexMetadataHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpSecurityHostTestCases/CtsJdwpSecurityHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJdwpSecurityHostTestCases/CtsJdwpApp.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1930HostTestCases/CtsJvmtiRunTest1930HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsPackageManagerMultiUserHostTestCases/CtsPackageManagerMultiUserHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1921HostTestCases/CtsJvmtiRunTest1921HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHarmfulAppWarningHostTestCases/CtsHarmfulAppWarningHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest951HostTestCases/CtsJvmtiRunTest951HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1907HostTestCases/CtsJvmtiRunTest1907HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest944HostTestCases/CtsJvmtiRunTest944HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/cts-dynamic-config/cts-dynamic-config.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest928HostTestCases/CtsJvmtiRunTest928HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsGwpAsanTestCases/CtsGwpAsanTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1924HostTestCases/CtsJvmtiRunTest1924HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAdbManagerHostTestCases/CtsAdbManagerHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1937HostTestCases/CtsJvmtiRunTest1937HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppUsageHostTestCases/CtsAppUsageHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsLocationTimeZoneManagerHostTest/CtsLocationTimeZoneManagerHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppCloningMediaProviderHostTest/CtsAppCloningMediaProviderHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsDeviceIdleHostTestCases/CtsDeviceIdleHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSeccompHostTestCases/CtsSeccompHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1902HostTestCases/CtsJvmtiRunTest1902HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest904HostTestCases/CtsJvmtiRunTest904HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1927HostTestCases/CtsJvmtiRunTest1927HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsUsbTests/CtsUsbTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsPackageManagerStatsHostTestCases/CtsPackageManagerStatsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsStagedInstallHostTestCases/CtsStagedInstallHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1914HostTestCases/CtsJvmtiRunTest1914HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSignedConfigHostTestCases/CtsSignedConfigHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsLocaleManagerHostTestCases/CtsLocaleManagerHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2003HostTestCases/CtsJvmtiRunTest2003HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1942HostTestCases/CtsJvmtiRunTest1942HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsBootStatsTestCases/CtsBootStatsTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSilentUpdateHostTestCases/CtsSilentUpdateHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsNNAPIStatsdAtomHostTestCases/CtsNNAPIStatsdAtomHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest930HostTestCases/CtsJvmtiRunTest930HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest985HostTestCases/CtsJvmtiRunTest985HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1997HostTestCases/CtsJvmtiRunTest1997HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsTelephonyHostCases/CtsTelephonyHostCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1999HostTestCases/CtsJvmtiRunTest1999HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest991HostTestCases/CtsJvmtiRunTest991HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppBindingHostTestCases/CtsAppBindingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsMultiUserHostTestCases/CtsMultiUserHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest2001HostTestCases/CtsJvmtiRunTest2001HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1913HostTestCases/CtsJvmtiRunTest1913HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsInputMethodServiceHostTestCases/CtsInputMethodServiceHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1932HostTestCases/CtsJvmtiRunTest1932HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest947HostTestCases/CtsJvmtiRunTest947HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHostsideNumberBlockingTestCases/CtsHostsideNumberBlockingTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsStrictJavaPackagesTestCases/CtsStrictJavaPackagesTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest919HostTestCases/CtsJvmtiRunTest919HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1933HostTestCases/CtsJvmtiRunTest1933HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsVideoEncodingQualityHostTestCases/CtsVideoEncodingQualityHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHostsideHiddenapiTests/CtsHostsideHiddenapiTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest932HostTestCases/CtsJvmtiRunTest932HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest986HostTestCases/CtsJvmtiRunTest986HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsBootDisplayModeTestCases/CtsBootDisplayModeTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest983HostTestCases/CtsJvmtiRunTest983HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest902HostTestCases/CtsJvmtiRunTest902HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsScopedStorageCoreHostTest/CtsScopedStorageCoreHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsGpuProfilingDataTestCases/CtsGpuProfilingDataTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsTestHarnessModeTestCases/CtsTestHarnessModeTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest906HostTestCases/CtsJvmtiRunTest906HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1994HostTestCases/CtsJvmtiRunTest1994HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1917HostTestCases/CtsJvmtiRunTest1917HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1988HostTestCases/CtsJvmtiRunTest1988HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSettingsHostTestCases/CtsSettingsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1970HostTestCases/CtsJvmtiRunTest1970HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest923HostTestCases/CtsJvmtiRunTest923HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1983HostTestCases/CtsJvmtiRunTest1983HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSustainedPerformanceHostTestCases/CtsSustainedPerformanceHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsHealthConnectHostTestCases/CtsHealthConnectHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1984HostTestCases/CtsJvmtiRunTest1984HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppSearchHostTestCases/CtsAppSearchHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest908HostTestCases/CtsJvmtiRunTest908HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsUsesLibraryHostTestCases/CtsUsesLibraryHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsCompilationTestCases/CtsCompilationTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1923HostTestCases/CtsJvmtiRunTest1923HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1941HostTestCases/CtsJvmtiRunTest1941HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1990HostTestCases/CtsJvmtiRunTest1990HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsRollbackManagerHostTestCases/CtsRollbackManagerHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest989HostTestCases/CtsJvmtiRunTest989HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1931HostTestCases/CtsJvmtiRunTest1931HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsApexTestCases/CtsApexTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiTaggingHostTestCases/CtsJvmtiTaggingHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1904HostTestCases/CtsJvmtiRunTest1904HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1943HostTestCases/CtsJvmtiRunTest1943HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsInputMethodServiceLib/arm64/CtsInputMethodServiceLib.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsShortcutHostTestCases/CtsShortcutHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsWifiBroadcastsHostTestCases/CtsWifiBroadcastsHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppCompatHostTestCases/CtsAppCompatHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/net-tests-utils-host-common/net-tests-utils-host-common.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsBackupHostTestCases/CtsBackupHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRedefineClassesHostTestCases/CtsJvmtiRedefineClassesHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest927HostTestCases/CtsJvmtiRunTest927HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsPackageManagerPreferredActivityHostTestCases/CtsPackageManagerPreferredActivityHostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsAppCloningHostTest/CtsAppCloningHostTest.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1901HostTestCases/CtsJvmtiRunTest1901HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsSdkSandboxHostSideTests/CtsSdkSandboxHostSideTests.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1936HostTestCases/CtsJvmtiRunTest1936HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1906HostTestCases/CtsJvmtiRunTest1906HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest910HostTestCases/CtsJvmtiRunTest910HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/vm-tests-tf/vm-tests-tf.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest1922HostTestCases/CtsJvmtiRunTest1922HostTestCases.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-Main.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-MainStripped.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-Nested.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-MultiDexUncompressedAligned.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-MultiDex.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm64/art-gtest-jars-MultiDexModifiedSecondary.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-Main.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-MainStripped.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-Nested.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-MultiDexUncompressedAligned.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-MultiDex.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/art_standalone_dex2oat_cts_tests/arm/art-gtest-jars-MultiDexModifiedSecondary.jar:/home/simon/cts/14_r7-linux_x86-arm/android-cts/tools/../../android-cts/testcases/CtsJvmtiRunTest915HostTestCases/CtsJvmtiRunTest915HostTestCases.jar">8
SERVER_REFERENCE$6f20623f-1dc1-48df-863e-2b1ea9faf752 