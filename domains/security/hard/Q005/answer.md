# Q005 Answer

## 正確答案：B

## 解析

### 問題根因
返回語句中的條件邏輯寫反了。程式碼寫的是：
```java
return diff == 0 ? false : true;
```
這表示「如果 diff 為 0（沒有差異），返回 false」——完全相反於預期行為。

### 正確程式碼
```java
// 方法 1：修正三元運算符
return diff == 0 ? true : false;

// 方法 2：直接返回比較結果（更簡潔）
return diff == 0;
```

### Bug 程式碼 vs 正確程式碼對照
```java
// Bug 版本
public boolean verifyChallenge(byte[] expected) {
    // ... 長度檢查 ...
    
    int diff = 0;
    for (int i = 0; i < mChallenge.length; i++) {
        diff |= mChallenge[i] ^ expected[i];
    }
    
    return diff == 0 ? false : true;  // BUG: 邏輯反了
}

// 正確版本
public boolean verifyChallenge(byte[] expected) {
    // ... 長度檢查 ...
    
    int diff = 0;
    for (int i = 0; i < mChallenge.length; i++) {
        diff |= mChallenge[i] ^ expected[i];
    }
    
    return diff == 0;  // 正確：diff 為 0 表示沒有差異，返回 true
}
```

### Constant-Time Comparison 原理
```
Byte XOR 運算：
- 相同的位元組：67 ^ 67 = 0
- 不同的位元組：67 ^ 68 = 3

OR 累積：
- 如果所有 XOR 結果都是 0，diff 保持為 0
- 只要有一個 XOR 結果非 0，diff 就會變成非 0

最終判斷：
- diff == 0 → 所有位元組都相同 → 應該返回 true
- diff != 0 → 至少有一個位元組不同 → 應該返回 false
```

### 為什麼其他選項不對

**A) XOR 產生負數導致問題**
- 這個推論部分正確：byte XOR byte 確實會提升為 int
- 例如 `(byte)0xFF ^ (byte)0xFF = 0`（int 型）
- 但 XOR 的結果範圍是 0-255（當兩個輸入都是 byte 時），不會產生負數
- 即使有負數，`|=` 累積後，完全匹配的情況下 diff 仍然會是 0
- 實際問題出在返回值的邏輯，不是 XOR 運算

**C) `|=` 導致負數累積**
- byte 在 Java 中是有符號的（-128 到 127）
- 但 `byte ^ byte` 的結果被提升為 int，範圍是 0 到 255
- 例如：`(byte)0x80 ^ (byte)0x80 = 0`，不會是負數
- `|=` 只會累積非負的 XOR 結果
- 如果所有位元組匹配，diff 確實會是 0

**D) 應該用 `&=` 而非 `|=`**
- 這完全錯誤。使用 `&=` 的話：
  - 初始 `diff = 0`
  - `0 & anything = 0`
  - diff 永遠保持 0，無法檢測差異
- 正確做法就是用 `|=`，累積所有差異位元

### 關鍵洞察
這是一個典型的「off-by-one logic error」變體——不是索引錯誤，而是布林邏輯反轉。開發者可能在寫程式時想的是「有差異就返回 true」，但變數名和語義應該是「驗證通過返回 true」。

這種 bug 特別危險：
1. 程式碼可以正常編譯
2. constant-time 邏輯本身是正確的
3. 只有實際執行驗證時才會發現問題
4. 會導致所有有效挑戰值被拒絕，所有無效挑戰值被接受（嚴重安全問題）

### 安全影響
如果這個 bug 進入生產環境：
- 合法的 attestation 會被拒絕（denial of service）
- 更糟的是，如果系統對驗證失敗有 fallback 處理，可能導致安全降級
- 實際上是一個安全漏洞（logic flaw）
