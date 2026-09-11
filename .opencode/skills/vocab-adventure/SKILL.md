---
name: vocab-adventure
description: Use when the user gives an English vocabulary list or photo (單字表, 背單字, 英文遊戲, 聽力練習, 單字測驗) and wants an interactive learning webpage for elementary kids. Builds a capybara RPG single-page game with human-voice audio and publishes to GitHub Pages.
---

# Vocab Adventure 單字大冒險

把國小英文單字表變成卡皮巴拉 RPG 互動網頁：情境闖關＋聽力＋拼字魔王＋真人發音，並推送到 GitHub Pages。

## 1. 讀取單字表

- 用戶會給照片（先用 Read 讀圖）或文字。整理出每字：英文、中文、詞性。
- 每字再配：生活化例句＋中文翻譯、給聰明孩子的「為什麼」好奇知識、3 個聽力干擾項（相似音，如 ninety/nineteen）、1 個情境填空題（3 選項）。
- 目標對象預設國小中年級；小孩喜歡的主題角色可換（預設卡皮巴拉咖皮隊長）。

## 2. 建遊戲（單一 index.html＋audio/，無依賴）

- 開新資料夾 `<主題>-vocab-adventure/`，可參考本專案 `capybara-vocab-adventure/index.html` 的結構直接改。
- 必備機制（都是之前踩過坑後的定案）：
  - 5 個世界地圖，每世界 5 字；**每關 5 題混合出題（聽力＋情境穿插），每字只考一次不重複**。
  - 選項每次洗牌（Fisher-Yates，答案不可永遠是 A）。
  - 情境題播**完整句子**練聽力；答對後鼓勵音→例句**排隊播不重疊**（播完 onended 才接下一段，換題要作廢舊排程 uiToken）。
  - 單一全域 Audio 元件播 MP3，播不出來才 fallback 瀏覽器 TTS（英文自動挑 Aria/Jenny/Google 美音等自然語音）。
  - 最終魔王預設**上鎖**，集滿 5 世界才開；魔王是**聽寫拼字**（給中文＋發音，鍵盤拼出，10 取隨機、對 8 過關，2 次機會）。
  - 進度 localStorage；淺色鎖定（`color-scheme: light`，防深色外掛反轉）；詞性標籤顯示但 `aria-hidden`，例句加乾淨 `aria-label`。
  - 卡皮巴拉用內聯 SVG 畫（`capySVG(mode)`：shop/detective/happy/study/bath/sleep/fight/party），加漂浮腳印裝飾。
- 手機朗讀會把整卡唸出是正常的（系統行為）；遊戲按鈕只播純錄音。

## 3. 錄真人音檔（edge-tts）

```powershell
pip install edge-tts
```

- 英文用 `en-US-AriaNeural`、`--rate=-10%`：每字錄單字、完整例句、空格版三檔 → `audio/<word>.mp3`、`audio/<word>_s.mp3`、`audio/<word>_b.mp3`。
- 中文固定台詞用 `zh-TW-HsiaoChenNeural`、`--rate=-5%`：答對鼓勵、過關、打敗魔王、開場、魔王上鎖（還差 N 個世界各一版）。
- 音檔文字必須和 DATA 內文字**完全一致**（建議寫腳本從 index.html 用 regex 抽句子來錄，不要手打）。
- 驗證：75 檔 hash 須互不相同；MP3 幀數須和句子長短成正比；短單字檔小是正常的。

## 4. 驗證＋上線（Windows PowerShell 注意事項）

- 沒有 `head`、`&&` 可用；多指令串接用 `;`，條件串接用 `; if ($?) { ... }`。
- JS 語法檢查：把 `<script>` 抽出存檔再 `node --check`。
- 本機預覽用 `python -m http.server`（瀏覽器擋 `file://`）；改完提醒用戶 **Ctrl+F5** 強制更新。
- `git add/commit/push`（git credential 可直接 push；`gh` 可能沒登入不用理它）。
- Pages 若 404：請用戶到 repo Settings → Pages → Deploy from branch → main → /(root)，等 1–2 分鐘。分享網址形如 `https://<帳號>.github.io/lets-talk-ai/<資料夾>/`。
- 只動新增的檔案，不動 repo 原有內容；commit 訊息寫清楚改了什麼。
