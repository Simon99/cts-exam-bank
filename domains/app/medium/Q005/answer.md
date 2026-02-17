# Q005: 答案解析

## 問題根源

在 `FragmentManager.java` 的 `addFragment()` 方法中，沒有正確設置 Fragment 的 `mAdded` 標誌。

## Bug 位置

`frameworks/base/core/java/android/app/FragmentManager.java`

```java
public void addFragment(Fragment fragment, boolean moveToStateNow) {
    // ... validation ...
    
    if (mAdded == null) {
        mAdded = new ArrayList<Fragment>();
    }
    mAdded.add(fragment);
    
    // BUG: 缺少設置 fragment.mAdded = true
    // fragment.mAdded = true;  <-- 這行被移除了
    
    if (moveToStateNow) {
        moveToState(fragment);
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// FragmentManager.addFragment
Log.d("FragmentManager", "addFragment: " + fragment);
Log.d("FragmentManager", "Before: mAdded=" + fragment.mAdded);
mAdded.add(fragment);
// fragment.mAdded = true;  // BUG: 這行不存在
Log.d("FragmentManager", "After: mAdded=" + fragment.mAdded);

// Fragment.isAdded
Log.d("Fragment", "isAdded called, mAdded=" + mAdded);
```

2. **觀察 log**:
```
D FragmentManager: addFragment: CorrectFragment{...}
D FragmentManager: Before: mAdded=false
D FragmentManager: After: mAdded=false   // 應該是 true！
D Fragment: isAdded called, mAdded=false
```

## 問題分析

FragmentManager 維護了一個 mAdded 列表，但 Fragment 自己也有 mAdded 標誌：
- `mAdded.add(fragment)` 只是加入列表
- `fragment.mAdded = true` 才會讓 `isAdded()` 返回 true
- Bug 移除了後者

## 正確代碼

```java
public void addFragment(Fragment fragment, boolean moveToStateNow) {
    if (mAdded == null) {
        mAdded = new ArrayList<Fragment>();
    }
    mAdded.add(fragment);
    fragment.mAdded = true;  // 必須設置 Fragment 的標誌
    
    if (moveToStateNow) {
        moveToState(fragment);
    }
}
```

## 修復驗證

```bash
atest android.app.cts.FragmentTransactionTest#testAddTransactionWithValidFragment
```

## 難度分類理由

**Medium** - 涉及 Fragment 和 FragmentManager 兩個類，需要追蹤 Fragment 添加流程，理解 mAdded 標誌在兩處的作用。
