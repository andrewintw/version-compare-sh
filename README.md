# Vercomp: Shell-Builtin Version Compare Utility

一個專為嵌入式 Linux (OpenWrt) 環境撰寫的版本比對工具，透過 Shell 內建語法實現了 **Zero-Fork (0 外部行程分叉)** 的版本解析機制，免除 `cut`、`awk`、`sed` 或 `expr` 的 CPU 行程消耗。


## 技術特點 (Features)

* **極致效能 (Zero-Fork)**：利用 Shell 內建的 `IFS` 欄位分隔符與位置參數劫持（`set --`），在記憶體中直接完成字串拆解，相較於舊版使用 `echo | cut` 的寫法，效能有所提升。
* **字元防禦 (Suffix Stripping)**：自動物理剝離版本號中的非數字後綴（例如將 `1.0.1a` 或 `1.0.1-rc` 安全退化為純整數 `1`），杜絕 Shell 語法報錯（`integer expression expected`）。
* **補零防禦 (Auto-Padding)**：完美相容 3 位數（`1.2.3`）與 4 位數（`1.2.3.4`）版本號的不對稱比對，自動為缺失欄位補 `0`。
* **表格驅動測試 (Table-Driven Test)**：測試案例與核心邏輯徹底解耦，維護人員只需修改純文字檔即可完成多維度邊界條件測試。


## 專案目錄結構 (Architecture)

```text
version-compare-sh/
├── vercomp.sh          # 函式庫，僅包含 version_compare() 函式
├── vercomp_test.sh     # 自動化測試腳本（一列一列讀取測試資料並驗證）
└── test_case.txt       # 測試測項資料庫（可自行新增 Test Case）
```

## 回傳值規範 (API)

Usage: `version_compare "v_old" "v_new"`

* $v_old：目前設備上正在跑的舊版（現行版）
* $v_new：下載下來準備要刷進去的新版（目標版）

呼叫後的狀態碼：

* `0`：（v_new = v_old）兩版本相同 => 通常不更新
* `1`：（v_old > v_new）v_new 比 v_old 小(舊版) => 不更新
* `2`：（v_old < v_new）v_new 比 v_old 大(新版) => 進行更新


## 引用範例

```bash
#!/bin/sh
. ./vercomp.sh

version_compare "$CURRENT_VER" "$TARGET_VER"
case $? in
    0) echo "版本相同"; exit 0 ;;
    1) echo "降級拒絕"; exit 1 ;;
    2) echo "允許升級"; ./do_upgrade ;;
esac
```


## 測試與整合

```text
./vercomp_test.sh test_case.txt 
=====================================================
 Reading test_case.txt line by line for verification...
=====================================================
[PASS] Case #01: 1.2.3 = 1.2.3
[PASS] Case #02: 1.2.3.4 = 1.2.3.4
[PASS] Case #03: 2.0.0 > 1.9.9
[PASS] Case #04: 1.0.0 < 2.0.0
[PASS] Case #05: 1.5.0 > 1.4.9
[PASS] Case #06: 1.1.10 > 1.1.2
[PASS] Case #07: 0.20.10 > 0.1.99
[PASS] Case #08: 1.1.2.100 > 1.1.2.19
[PASS] Case #09: 1.2.3 = 1.2.3.0
[PASS] Case #10: 1.2 < 1.2.1
[PASS] Case #11: 0.0.1.9 > 0.0.1.8
[PASS] Case #12: 0.0.19 > 0.0.18
[PASS] Case #13: 1.0.1 = 1.0.1a
[PASS] Case #14: 1.0.1 = 1.0.1-rc
=====================================================
 TEST SUMMARY FROM FILE:
   Total Cases : 14
   Passed      : 14
   Failed      : 0
=====================================================
```
