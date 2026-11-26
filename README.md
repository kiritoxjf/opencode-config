# opencode-config

只同步 OpenCode 的插件列表和 MCP 服务定义。配置模板中的 `{{变量名}}` 由 PowerShell 脚本逐项询问、替换；不需要设置环境变量。

## 让 AI 帮你完成

在家里电脑的 AI 编程助手中，粘贴下面这段提示词（需要具备本机文件、终端和联网能力）：

```text
请在这台 Windows 电脑上，按 git@github.com:kiritoxjf/opencode-config.git 仓库中的 AI_SETUP.md 实际完成 OpenCode 插件和 MCP 配置。不要假设相关程序已安装：先检查 Git，缺少时从 https://git-scm.com/install/windows 安装，再克隆或更新仓库并执行 AI_SETUP.md。检查 OpenCode、browse 及浏览器扩展、支持 MCP 的微信开发者工具、Worktrunk、Codebase Memory；已有可用安装直接复用，缺少或不兼容时从官方来源安装合适版本，验证成功后再填写真实路径、备份并应用配置。必需依赖仍未就绪时保留当前配置，继续处理其他独立安装并列出阻塞项。不要只给教程，也不要将路径或 Token 设置为系统或用户环境变量。缺少 Token 时让我在本机隐藏输入，需要登录、配对或管理员权限时再让我操作；保留其他 OpenCode 设置，不要提交本机配置或凭据。
```

详细步骤见 [AI_SETUP.md](AI_SETUP.md)。若仓库是私有的，AI 所在电脑需要先获得 GitHub 仓库访问权限。

## 程序尚未安装时

AI 流程支持从零安装或补齐部分依赖：先检查，再从官方来源安装缺失项，验证成功后才生成配置。已有可用安装直接复用；需要登录、扩展配对或管理员确认时，由你完成对应操作，AI 随后继续。

| 项目 | 缺失时如何处理 |
| --- | --- |
| Git | 先从 [Git 官方入口](https://git-scm.com/install/windows) 安装，再克隆仓库；不依赖预装 winget |
| OpenCode | 从 [官方文档](https://opencode.ai/docs/) 获取适合本机架构的 Windows Desktop 或独立 CLI；已有 Desktop 不必另装 CLI |
| PowerShell | 使用 Windows PowerShell 5.1 或已有的 PowerShell 7 |
| browse | 按 [官方安装说明](https://opencode.ai/product/browse) 安装本机程序和浏览器扩展，完成配对 |
| 微信开发者工具 | 确认发行版本和下载来源支持 `wechatide.cmd mcp`，安装后登录并取得本机 MCP Token |
| Worktrunk | 按 [官方说明](https://worktrunk.dev/) 安装 Worktrunk CLI；注意区分同名的 Windows Terminal `wt.exe` |
| Codebase Memory | 安装 [上游原生 Windows 程序](https://github.com/DeusData/codebase-memory-mcp)，优先仅安装程序、跳过自动客户端配置 |
| Figma | 使用远程 MCP，无需安装 Figma Desktop；通过 `/mcps` 完成 OAuth |
| Node.js、Bun 等 | 仅在选定的安装方式确实需要时补装，不统一安装所有运行时 |

`setup.ps1` 负责交互式写入配置，本身不安装程序。五个本机变量都必填；必需程序或 Token 仍缺失时，AI 会保留当前配置、记录已完成的安装和阻塞项，待补齐后统一应用，不填假路径，也不擅自移除插件或 MCP。

## 手动运行脚本

先按上表安装所需程序，再运行配置脚本：

```powershell
git clone git@github.com:kiritoxjf/opencode-config.git
cd opencode-config
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

按提示依次输入以下内容。路径直接粘贴，不需要手动写 JSON 的双反斜杠；Token 隐藏输入。

| 变量名 | 本机填写内容 |
| --- | --- |
| `BROWSE_EXE` | browse.exe 的完整路径 |
| `WECHATIDE_CMD` | wechatide.cmd 的完整路径 |
| `WECHATIDE_MCP_TOKEN` | 微信开发者工具「设置 → 安全」中的 MCP Token |
| `WORKTRUNK_BIN` | wt.exe 的完整路径 |
| `CODEBASE_MEMORY_BIN` | codebase-memory-mcp.exe 的完整路径 |

输入值只写入本机的 OpenCode 配置，不写回仓库，也不写入系统环境变量。Token 会以明文保存在本机生成的配置和原配置备份中。

脚本优先使用 `%USERPROFILE%\.config\opencode\opencode.jsonc`；若只有 `opencode.json` 则更新它，都没有则创建 `opencode.jsonc`。支持 Windows PowerShell 5.1 和 PowerShell 7。

也可以指定目标文件：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1 -ConfigPath 'D:\local-config\opencode.jsonc'
```

## 更新范围

- 用 `plugins.json` 完整替换本机的 `plugins` 列表。
- 用 `mcp.json` 的 `servers` 完整替换本机的 `mcp.servers`；本机额外添加的 MCP 服务会被移除。
- 保留模型、provider、Skill 等其他配置值，以及 `mcp.timeout` 等其他 MCP 设置。
- 兼容 JSONC 注释和尾随逗号。写入时重新格式化为 JSON，注释会移除；原文件会先备份到同目录的 `.bak-*` 文件。

插件包由 OpenCode 根据包名加载，不同步 `node_modules`。当前列表未锁定插件版本；若需要固定版本，可把包名写成 `package-name@版本号`。

Figma 的 OAuth 登录需要每台电脑分别完成：在 OpenCode 中运行 `/mcps`，选择 Figma 登录。配置保存后会自动重新加载，必要时运行 `/reload`。

## 后续同步

```powershell
git pull --ff-only
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

每次运行都会重新逐项询问变量。要新增插件或 MCP，在 `plugins.json` / `mcp.json` 中编辑模板；新增本机参数时，在 `variables.json` 中声明 `name`、`label`、`secret`、`required`，然后在模板的字符串值中使用 `{{变量名}}`。未声明的占位符会在写入前报错。

`variables.json` 只记录变量名和提示信息，不要在其中加入真实 Token。仓库中也不保存登录凭据、会话或数据库。
