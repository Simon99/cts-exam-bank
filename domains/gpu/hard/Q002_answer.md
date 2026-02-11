# Q002: FPS 報告只回報部分圖層 - 答案

## 正確答案：B

## 解析

### Bug 位置
`frameworks/native/services/surfaceflinger/FpsReporter.cpp` 第 76 行

### Bug 描述
在 `dispatchLayerFps()` 函數中，traverse callback 錯誤地返回 `false`：

```cpp
layerHierarchy.traverse([&](const frontend::LayerHierarchy& hierarchy,
                            const frontend::LayerHierarchy::TraversalPath& traversalPath) {
    // ... 處理邏輯 ...
    return false;  // BUG: 應該是 return true
});
```

### 為什麼這是錯誤的

`LayerHierarchy::traverse()` 的 callback 返回值語義：
- **`return true`** = 繼續遍歷此節點的子節點
- **`return false`** = 跳過此節點的子節點，不再深入

當 callback 總是返回 `false` 時，遍歷只會訪問第一層的 layer，
不會深入到嵌套的子 layer。因此：
- 頂層 TaskId=100 的 RootLayer 被正確匹配
- 嵌套的 TaskId=200、300 等子 layer 完全沒有被訪問

### 修復方式

```diff
-        return false;  // BUG: Stops traversal after first layer
+        return true;   // Continue traversing child layers
```

### 選項分析

- **A) kMinDispatchDuration 設定太長** — 這只會影響 dispatch 頻率，不會影響哪些 layer 被收集
- **B) traverse callback 返回 false** — ✅ 正確，這是導致只訪問第一層的原因
- **C) computeFps() 過濾 nested layer** — computeFps 是根據傳入的 layerIds 計算，不會主動過濾
- **D) seenTasks 沒有正確初始化** — seenTasks 是正確初始化的空集合，邏輯正確

### 相關知識

**LayerHierarchy traverse 模式：**
```cpp
// traverse signature
void traverse(const Visitor& visitor) const {
    if (visitor(*this)) {  // callback 返回 true 才繼續
        for (const auto& child : mChildren) {
            child.traverse(visitor);
        }
    }
}
```

**FPS Reporting 完整流程：**
1. `dispatchLayerFps()` 遍歷 LayerHierarchy 收集 task-to-layer 映射
2. 對每個 listener 的 task，再次遍歷收集所有 layerId
3. 呼叫 `FrameTimeline.computeFps(layerIds)` 計算 FPS
4. 透過 `IFpsListener.onFpsReported()` 回報結果

### 難度：Hard

此題需要理解：
1. SurfaceFlinger 的 Layer 階層結構
2. traverse 的遍歷語義和返回值含義
3. FPS 報告的完整數據流
