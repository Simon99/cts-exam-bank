# Q007: 答案解析

## 問題根源

`FragmentManager.java` 在 `saveAllState()` 中遍歷 BackStack 時使用了錯誤的迴圈邊界，只保存了第一個 BackStackRecord。

## Bug 位置

**檔案1**: `frameworks/base/core/java/android/app/FragmentManager.java`

```java
Parcelable saveAllState() {
    // ...
    
    // 保存 BackStack
    if (mBackStack != null) {
        int N = mBackStack.size();
        if (N > 0) {
            backStack = new BackStackState[N];
            // BUG: 迴圈條件錯誤，只執行一次
            for (int i = 0; i < 1; i++) {  // 應該是 i < N
                backStack[i] = new BackStackState(this, mBackStack.get(i));
            }
        }
    }
    
    FragmentManagerState fms = new FragmentManagerState();
    fms.mActive = active;
    fms.mAdded = added;
    fms.mBackStack = backStack;
    
    return fms;
}
```

**檔案2**: `frameworks/base/core/java/android/app/BackStackRecord.java`

```java
BackStackState(FragmentManager fm, BackStackRecord record) {
    // BUG: 沒有保存 Fragment 的 savedInstanceState
    mOps = new int[record.mOps.size() * 3];
    int pos = 0;
    for (Op op : record.mOps) {
        mOps[pos++] = op.cmd;
        mOps[pos++] = op.fragment != null ? op.fragment.mIndex : -1;
        // 缺少: 保存 fragment 的狀態
    }
    mTransition = record.mTransition;
    mName = record.mName;
    mIndex = record.mIndex;
    // 缺少: mSavedFragmentStates = saveFragmentStates(record);
}
```

## 診斷步驟

1. **添加 log 追蹤狀態保存**:
```java
// FragmentManager.java
Log.d("FragmentManager", "saveAllState: BackStack size=" + N);
for (int i = 0; i < N; i++) {
    Log.d("FragmentManager", "Saving BackStack[" + i + "]: " 
        + mBackStack.get(i).mName);
}

// 在恢復時
Log.d("FragmentManager", "restoreAllState: BackStack entries=" 
    + (fms.mBackStack != null ? fms.mBackStack.length : 0));
```

2. **觀察 log**:
```
D FragmentManager: saveAllState: BackStack size=3
D FragmentManager: Saving BackStack[0]: main
# 缺少 BackStack[1] 和 [2] 的 log！

D FragmentManager: restoreAllState: BackStack entries=3
# 但只有 [0] 有有效數據，[1][2] 是 null
```

3. **問題定位**: 
   - 迴圈只執行了一次 (`i < 1`)
   - 數組分配了正確大小 (3)
   - 但只有 index 0 被填充

## 問題分析

這是一個典型的 off-by-one / 硬編碼錯誤：
- 開發者可能在測試時用 `i < 1` 作為臨時代碼
- 忘記改回 `i < N`
- 導致只有第一個 BackStackRecord 被保存

Fragment 狀態保存的正確流程：
1. 遍歷所有 BackStackRecord
2. 每個 BackStackRecord 保存其操作和相關 Fragment 狀態
3. 恢復時按順序重建

## 正確代碼

**FragmentManager.java**:
```java
Parcelable saveAllState() {
    if (mBackStack != null) {
        int N = mBackStack.size();
        if (N > 0) {
            backStack = new BackStackState[N];
            // 正確: 遍歷所有 BackStack entries
            for (int i = 0; i < N; i++) {
                backStack[i] = new BackStackState(this, mBackStack.get(i));
            }
        }
    }
    // ...
}
```

## 修復驗證

```bash
atest android.app.cts.FragmentManagerTest#testBackStackStateRestore
```

## 難度分類理由

**Hard** - 需要理解 Fragment 生命週期和狀態保存機制，涉及 FragmentManager、BackStackRecord、FragmentState 多個類的協作，Bug 隱藏在迴圈邊界條件中。
