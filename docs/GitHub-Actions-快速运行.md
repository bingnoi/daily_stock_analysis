# 用 GitHub Actions 直接跑一次

不买服务器、不装 Docker，用 GitHub 免费额度在网页上点一下就能跑一次股票分析。

---

## 一、前提：代码已在 GitHub 上

- 若还没有仓库：在 GitHub 新建一个仓库，把**项目根目录**（包含 `main.py`、`requirements.txt`、`api/`、`.github/` 的这层）里的内容推上去。  
- 若你是从 ZIP 解压的，注意：**不要**把外层「解压出来的那个文件夹」当根目录推送，要把**里面**那一层（有 `main.py` 的那层）作为仓库根目录推送，否则 Actions 会找不到 `main.py`。

```bash
# 正确做法：进入“有 main.py 的那一层”再初始化
cd daily_stock_analysis-main   # 内层，里面有 main.py、.github、api 等
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/仓库名.git
git branch -M main
git push -u origin main
```

---

## 二、配置最少需要的 Secrets

1. 打开仓库 → **Settings** → **Secrets and variables** → **Actions**。
2. 点 **New repository secret**，添加：

| 名称 | 说明 | 必填 |
|------|------|------|
| `GEMINI_API_KEY` | [Google AI Studio](https://aistudio.google.com/) 里拿的 API Key | ✅ 必填（或用下面 OpenAI） |
| `STOCK_LIST` | 自选股代码，逗号分隔，如 `600519,300750,002594` | ✅ 必填 |

**不用 Gemini、改用 DeepSeek 时**：Action 支持 OpenAI 兼容 API，DeepSeek 可直接用。只配下面三项即可（不要配 `GEMINI_API_KEY`）：

| 名称 | 说明 |
|------|------|
| `OPENAI_API_KEY` | 你的 **DeepSeek API Key**（在 https://platform.deepseek.com 获取） |
| `OPENAI_BASE_URL` | 填 `https://api.deepseek.com/v1` |
| `OPENAI_MODEL` | 填 `deepseek-chat` 或 `deepseek-reasoner` |
| `STOCK_LIST` | 自选股，如 `600519,300750` |

逻辑：未配置 Gemini 时会自动使用 OpenAI 兼容 API，DeepSeek 与 OpenAI 接口兼容，因此上述配置即可用 Action 跑 DeepSeek。

至少要有 **一个 AI 配置**（Gemini 或 OpenAI 其一）+ **STOCK_LIST**，否则分析会报错。

通知（企业微信/飞书/Telegram 等）按需在同一个 Secrets 里添加，不配也可以跑，只是不会推送。

---

## 三、在网页上“启动一次”

1. 打开仓库 → 顶部 **Actions** 标签。
2. 左侧选 **「每日股票分析」**。
3. 右侧点 **Run workflow**。
4. 下拉选运行模式（一般选 **full**）→ 再点绿色 **Run workflow**。
5. 等几秒刷新，会出现一条新的 run，点进去看 **analyze** 的日志即可。

---

## 四、看结果

- **日志**：点进该次运行 → 点 **analyze** job → 看每一步输出；若报错会直接显示（例如缺 API Key、网络超时等）。
- **报告**：跑完后同一页往下拉，在 **Artifacts** 里会有一个 `analysis-reports-xxx`，可下载，解压后有 `reports/`、`logs/`。
- **通知**：若在 Secrets 里配置了企业微信/飞书等，分析完成后会推送到对应渠道。

---

## 五、常见问题

| 情况 | 处理 |
|------|------|
| 报错找不到 `main.py` 或 `requirements.txt` | 说明仓库根目录不对，要保证根目录下直接有 `main.py`、`requirements.txt`（见第一节）。 |
| 报错 API Key 相关 | 检查 Settings → Secrets 里是否配了 `GEMINI_API_KEY` 或 `OPENAI_API_KEY` 以及 `STOCK_LIST`。 |
| 想先只跑大盘 | 手动 Run workflow 时模式选 **market-only**。 |
| 定时跑 | 默认周一到周五北京时间 18:00 自动跑；时间在 `.github/workflows/daily_analysis.yml` 里用 cron 改。 |

更多 Secrets/变量说明见 [DEPLOY.md - GitHub Actions 部署](DEPLOY.md#%E6%96%B9%E6%A1%88%E5%9B%9Bgithub-actions-%E9%83%A8%E7%BD%B2%E5%85%8D%E6%9C%8D%E5%8A%A1%E5%99%A8)。
