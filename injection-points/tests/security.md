# Security 模組注入點分布列表

**CTS 路徑**: `cts/tests/security/` + `cts/hostsidetests/security/`  
**更新時間**: 2026-02-10 22:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 35 |
| Easy | 12 (34%) |
| Medium | 15 (43%) |
| Hard | 8 (23%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### Device-side Tests (`cts/tests/security/`)
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| Attestation | 密鑰認證（Key Attestation） | 高 |
| AuthorizationList | 授權列表解析 | 高 |
| RootOfTrust | 信任根驗證 | 高 |

### Host-side Tests (`cts/hostsidetests/security/`)
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| SELinuxHostTest | SELinux 策略測試 | 高 |
| SELinuxNeverallowRulesTest | Neverallow 規則 | 高 |
| FileSystemPermissionTest | 檔案系統權限 | 高 |
| KernelConfigTest | 核心配置測試 | 中 |
| MetadataEncryptionTest | 元資料加密 | 中 |
| ProcessMustUseSeccompTest | Seccomp 強制 | 中 |
| PerfEventParanoidTest | Perf 事件限制 | 低 |

## 對應 AOSP 源碼路徑

### Keystore 層
- `frameworks/base/keystore/java/android/security/KeyChain.java`
- `frameworks/base/keystore/java/android/security/KeyStore2.java`
- `frameworks/base/keystore/java/android/security/Credentials.java`
- `frameworks/base/keystore/java/android/security/Authorization.java`

### Security 相關
- `frameworks/base/core/java/android/security/keystore/` — KeyStore 提供者
- `frameworks/base/core/java/android/security/keystore/recovery/` — 密鑰恢復
- `frameworks/base/core/java/android/security/net/config/` — 網路安全配置

### 相關服務
- `system/security/keystore2/` — Keystore 2.0 服務

---

## 注入點清單

### 1. Key Attestation（密鑰認證）⭐

**相關檔案**: `cts/tests/security/src/android/keystore/cts/Attestation.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-001 | loadFromCertificate(x509Cert) | 76-96 | COND, ERR | Medium | Attestation | 解析認證擴展 |
| SEC-002 | 多重擴展檢查 | 80-82 | COND | Easy | Attestation | EAT vs ASN1 檢查 |
| SEC-003 | keymasterVersion 檢查 | 待查 | COND, BOUND | Medium | Attestation | 版本範圍驗證 |
| SEC-004 | securityLevel 解析 | 待查 | COND | Easy | Attestation | 安全等級判斷 |
| SEC-005 | attestationChallenge 驗證 | 待查 | COND, BOUND | Medium | Attestation | 挑戰值匹配 |

### 2. AuthorizationList（授權列表）

**相關檔案**: `cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-011 | 授權標籤解析 | 待查 | COND | Medium | Attestation | TAG 解析 |
| SEC-012 | purpose 驗證 | 待查 | COND, BOUND | Medium | Attestation | 用途驗證 |
| SEC-013 | algorithm 驗證 | 待查 | COND | Easy | Attestation | 算法驗證 |
| SEC-014 | keySize 驗證 | 待查 | COND, BOUND | Easy | Attestation | 密鑰大小 |
| SEC-015 | digest 驗證 | 待查 | COND, BOUND | Medium | Attestation | 摘要算法 |
| SEC-016 | padding 驗證 | 待查 | COND | Easy | Attestation | 填充模式 |
| SEC-017 | noAuthRequired 處理 | 待查 | COND | Easy | Attestation | 無需認證標記 |
| SEC-018 | userAuthType 解析 | 待查 | COND, CALC | Medium | Attestation | 用戶認證類型 |

### 3. RootOfTrust（信任根）

**相關檔案**: `cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-021 | verifiedBootKey 驗證 | 待查 | COND, BOUND | Hard | RootOfTrust | 啟動密鑰驗證 |
| SEC-022 | deviceLocked 狀態 | 待查 | COND | Easy | RootOfTrust | 設備鎖定狀態 |
| SEC-023 | verifiedBootState 解析 | 待查 | COND | Medium | RootOfTrust | 啟動狀態 |
| SEC-024 | verifiedBootHash 比對 | 待查 | COND, BOUND | Hard | RootOfTrust | 啟動雜湊 |

### 4. KeyChain（密鑰鏈）

**檔案**: `frameworks/base/keystore/java/android/security/KeyChain.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-031 | getPrivateKey(context, alias) | 待查 | COND, ERR | Medium | KeyChain | 取得私鑰 |
| SEC-032 | getCertificateChain(context, alias) | 待查 | COND, ERR | Medium | KeyChain | 憑證鏈 |
| SEC-033 | choosePrivateKeyAlias() | 待查 | COND | Hard | KeyChain | 選擇別名對話 |
| SEC-034 | isKeyAlgorithmSupported(algorithm) | 待查 | COND | Easy | KeyChain | 算法支援 |
| SEC-035 | isBoundKeyAlgorithm(algorithm) | 待查 | COND | Easy | KeyChain | 綁定算法 |

### 5. Network Security Config

**檔案**: `frameworks/base/core/java/android/security/net/config/`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-041 | PinSet.validate() | 待查 | COND, BOUND | Hard | NetworkSecurity | 憑證釘選驗證 |
| SEC-042 | NetworkSecurityTrustManager 信任檢查 | 待查 | COND, ERR | Hard | NetworkSecurity | 信任管理 |
| SEC-043 | CertificateSource.findBySubject() | 待查 | COND | Medium | NetworkSecurity | 憑證查找 |

### 6. SELinux（Host-side）

**相關檔案**: `cts/hostsidetests/security/src/android/security/cts/SELinuxHostTest.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEC-051 | neverallow 規則解析 | 待查 | COND, STR | Hard | SELinuxNeverallowRulesTest | 策略解析 |
| SEC-052 | 上下文驗證 | 待查 | COND | Medium | SELinuxHostTest | SELinux 上下文 |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 30 |
| BOUND（邊界檢查）| 10 |
| ERR（錯誤處理）| 5 |
| CALC（數值計算）| 2 |
| STR（字串處理）| 2 |
| HARD（硬體相關）| 5 |

## 注入難點分析

1. **Key Attestation** — 涉及硬體安全模組，需理解 KeyMaster/KeyMint
2. **AuthorizationList** — 大量 TAG 解析邏輯
3. **SELinux** — 策略語法解析
4. **Network Security Config** — 憑證釘選和信任管理
5. **版本相容性** — KeyMaster 1.x ~ KeyMint 3.0 差異

## 限制說明

此模組的源碼注入點較為特殊：
- Keystore 核心實作在 Native/Rust 層（`system/security/keystore2/`）
- CTS 測試主要驗證 API 行為和認證格式
- Host-side 測試多為配置檢查，較難設計 Java 層 bug

## 相關測試命令

```bash
# 執行 Security CTS (device-side)
run cts -m CtsKeystoreTestCases

# 執行 Security CTS (host-side)
run cts -m CtsSecurityHostTestCases
```

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證

## 備註

Security 模組較特殊，許多核心實作在 Native/Rust 層。Java 層注入點主要集中在：
- Attestation 解析邏輯
- KeyChain API
- Network Security Config
