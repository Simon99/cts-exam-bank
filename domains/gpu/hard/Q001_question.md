# Q001: EGL Layer Injection Causes Crash

## CTS Test
`android.opengl.cts.EglLayerTest#testLayerInjection`

## Failure Log
```
FATAL EXCEPTION: main
Process: android.opengl.cts, PID: 12345

A/libc: Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x0
A/DEBUG: backtrace:
    #00 pc 00012345  /system/lib64/libEGL.so (egl_layer_t::initLayer+128)
    #01 pc 00023456  /system/lib64/libEGL.so (LayerLoader::loadLayers+256)
    #02 pc 00034567  /system/lib64/libEGL.so (egl_init_drivers+512)

Crash occurs during EGL layer initialization
Layers loaded: [my_debug_layer.so]
```

## 現象描述
當啟用 EGL debugging layer 時，系統在初始化時崩潰。
崩潰發生在 layer 載入過程中，顯示 null pointer dereference。

## 提示
- EGL layers 是可注入的 debugging/profiling 工具
- Layer 載入涉及多個元件：Loader, LayerLoader, egl_layers
- 需要追蹤 layer 函數指針的初始化順序
- 問題可能涉及 layer initialization 和 platform 函數表的交互
