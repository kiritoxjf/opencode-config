# 给家里电脑 AI 的配置提示词

把下面整段复制给具有本机文件、终端和联网能力的 AI。也可以让 AI 克隆本仓库后直接阅读并执行本文件。

```text
请帮我在这台 Windows 家用电脑上，实际完成 OpenCode 插件和 MCP 配置。请执行操作并验证结果，不要只给我教程。

配置仓库：git@github.com:kiritoxjf/opencode-config.git
网页地址：https://github.com/kiritoxjf/opencode-config

我授权你为本任务查找本机程序、从官方来源安装缺少的用户级依赖、备份并更新本机 OpenCode 配置。常规检查和配置请直接继续；需要登录、扫码、Token、管理员权限，或遇到无法确认的软件来源时，再让我处理对应步骤。

目标与约束：
- 只同步 plugins.json 中的插件，以及 mcp.json 中的 MCP 服务；变量以 variables.json 为准。
- 不同步或更改 Skills、模型、provider、API Key、代理、权限、会话和数据库；保留目标配置中的其他设置。
- 不把路径或 Token 设置为系统或用户环境变量，也不使用 {env:...} 保存这些输入值。
- mcp.json 自带的 environment 是 MCP 子进程设置，请原样保留。
- 不把真实 Token、OAuth 凭据、生成后的本机配置或备份提交到仓库，不打印这些内容。此任务不需要 git commit 或 git push。

请按以下步骤完成：

1. 准备仓库并确认配置规则
   - 如果仓库已在本机，使用已有目录；有未提交修改时先检查，不能覆盖。工作区干净时可以 git pull --ff-only。
   - 如果尚未克隆，在合适的用户目录克隆。SSH 未授权时让我完成 GitHub 登录或密钥授权，不要更改仓库可见性或覆盖我的 SSH 配置。
   - 阅读 README.md、setup.ps1、plugins.json、mcp.json、variables.json，以实际文件为准，不要硬编码公司电脑上的用户名、盘符、安装路径或 Token。
   - 读取 OpenCode 当前官方文档 https://opencode.ai/docs/config 和 https://opencode.ai/docs/mcp-servers，核实本机版本和配置位置。此仓库使用 V2 的 plugins 和 mcp.servers；不要顺带迁移其他配置。
   - 确认实际生效的全局配置。默认优先 ~/.config/opencode/opencode.jsonc，其次 opencode.json；若本机已有自定义配置目录，以实际生效位置为准。setup.ps1 支持用 -ConfigPath 指定目标。

2. 自动查找依赖并填写本机变量
   - 优先使用现有安装和现有配置，结合 Get-Command、常见安装目录、已安装程序信息及软件文档查找；先做有针对性的检查，不要直接递归扫描整个磁盘。
   - BROWSE_EXE：browse.exe 的真实完整路径。
   - WECHATIDE_CMD：支持 MCP 的微信开发者工具中 wechatide.cmd 的真实完整路径。
   - WECHATIDE_MCP_TOKEN：这台电脑微信开发者工具提供的 MCP Token。
   - WORKTRUNK_BIN：Worktrunk 的 wt.exe 的真实完整路径。
   - CODEBASE_MEMORY_BIN：codebase-memory-mcp.exe 的真实完整路径。
   - 验证文件存在，并通过安全的版本或帮助命令确认程序身份。不要启动一个会无限等待的 MCP stdio 服务来当作版本检查。
   - 缺少程序时，先从相应插件的包元数据、上游仓库或官方文档确认依赖和安装方法，选择适合本机架构的正式版本。不要仅凭同名搜索结果安装软件，也不要猜测下载地址。
   - 可以自动完成的用户级安装直接完成；必须手动运行安装器、配对浏览器扩展或确认管理员权限时，给我明确的单步操作，完成后继续。
   - browse 需要检查浏览器扩展和配对状态。微信开发者工具必须确认当前版本支持 wechatide.cmd mcp；仅安装普通开发者工具并不能证明 MCP 可用。
   - 不要编造路径、Token 或空壳程序，也不要为了通过检查擅自删除插件或 MCP。暂时无法完成的依赖要明确标为待处理，并继续其他独立工作。

3. 处理 Token 和登录
   - 若本机已配置可用的微信 MCP Token，可在本机程序中复用，不输出原值。
   - 若缺少 Token，打开或引导我进入微信开发者工具「设置 → 安全」，复制 MCP 配置中的本机 Token。优先让我在本机终端通过隐藏输入完成，不要求我把 Token 发到聊天里。
   - 不要将 Token 作为安装脚本参数或调试命令的一部分，也不要写入 Shell 历史、日志、临时测试样例或 Git 跟踪文件。按此仓库设计，它最终会以明文保存在本机 OpenCode 配置及其备份中，由配置中的微信 MCP 启动参数使用。
   - Figma 使用每台电脑独立的 OAuth 登录，不复制其他电脑的 auth.json 或其他登录凭据，不用 API Key 替代 OAuth。

4. 应用配置
   - 优先运行仓库的 setup.ps1，并使用步骤 2 找到的路径。若终端可以让我直接交互，运行：
     powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
     如实际配置位置不同，追加 -ConfigPath 指向准确的目标文件。
   - setup.ps1 会逐项询问；Token 使用 Read-Host -AsSecureString。不要通过管道向该脚本灌入输入，也不要在当前 AI 会话里替换或模拟 Read-Host 来绕过交互。
   - 如果你的工具无法让我操作交互式终端，可以按同等规则直接生成配置：读取三个模板文件，用自动发现的本机路径和通过本机隐藏输入获取的 Token 替换 {{变量名}}，正确进行 JSON 字符串转义，只替换 plugins 和 mcp.servers。
   - 直接生成时仍需正确解析 JSONC 注释和尾随逗号、保留其他配置值、先备份原文件，并通过同目录临时文件安全替换。如果写入前发现原配置已被其他程序修改，重新读取后再处理，不能覆盖新修改。
   - 这两个配置项按模板完整替换；本机额外插件和 MCP 服务也会被替换。备份后按此范围执行，不要误删 mcp.timeout 等同级设置。
   - 仓库现有脚本写入时会移除 JSONC 注释并重新格式化，原文件备份需保留。
   - 所有试运行和输入模拟只对隔离的临时配置进行，必须显式指定临时目标；不能拿真实配置做测试。

5. 验证并完成连接
   - 重新读取生成文件，在不显示敏感值的前提下验证：JSON 可解析；插件和 MCP 与模板一致；所有声明变量都已替换；本机路径存在；无意外嵌套的 plugins 数组；其他配置值保持不变。
   - OpenCode 会按插件包名加载插件，无需从其他电脑复制 node_modules。检查实际加载日志或状态，排查插件依赖错误。
   - 配置保存后应自动重新加载；必要时让我运行 /reload，不要仅为了应用配置要求重启 OpenCode。
   - 如本机 opencode CLI 可用，用 opencode mcp list 检查连接；否则通过本机 OpenCode 的 /mcps、工具列表或日志核实。不要因为 CLI 不在 PATH 就判定 OpenCode 未安装。
   - Figma 需要认证时，让我在 OpenCode 中运行 /mcps，选择 Figma 完成浏览器授权；不要在不可交互的 Shell 中运行 opencode mcp auth。
   - browse 需核实扩展已连接；微信 MCP 需核实开发者工具登录与 Token；Worktrunk 和 Codebase Memory 需核实插件实际识别到了对应程序。
   - 验证只做只读或无副作用检查；不要为了测试去发布微信小程序、部署云函数、修改 Figma 文件或删除索引。
   - 授权或依赖未完成时，不要声称全部可用。明确区分「配置已写入」「插件已加载」「MCP 已连接」「待用户授权」。

最后简要报告：实际配置路径、备份路径、各插件和 MCP 的验证结果，以及仍需我完成的具体操作。不要显示 Token 或完整敏感配置。
```
