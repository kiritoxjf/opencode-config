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
   - 不要假设本机已安装 Git、OpenCode、browse、微信开发者工具、Worktrunk 或 Codebase Memory；从零安装和只缺部分程序都需要支持。
   - 先检查 Windows 版本、系统架构、PowerShell 和 Git。Git 未安装时，先从 https://git-scm.com/install/windows 获取适合本机的正式安装包或便携版，完成安装并验证后再克隆；不要用未核实的 winget 包名。Git 已安装但不在 PATH 时，使用找到的绝对路径。
   - 如果仓库已在本机，使用已有目录；有未提交修改时先检查，不能覆盖。工作区干净时可以 git pull --ff-only。
   - 如果尚未克隆，在合适的用户目录克隆。SSH 未授权时，可使用已登录 GitHub 的 HTTPS 凭据访问；仍无权限时让我完成 GitHub 登录或密钥授权，不要更改仓库可见性或覆盖我的 SSH 配置。
   - 阅读 README.md、setup.ps1、plugins.json、mcp.json、variables.json，以实际文件为准，不要硬编码公司电脑上的用户名、盘符、安装路径或 Token。
   - 读取 OpenCode 当前官方文档 https://opencode.ai/docs/config 和 https://opencode.ai/docs/mcp-servers，核实本机版本和配置位置。此仓库使用 V2 的 plugins 和 mcp.servers；不要顺带迁移其他配置。
   - 确认实际生效的全局配置。默认优先 ~/.config/opencode/opencode.jsonc，其次 opencode.json；若本机已有自定义配置目录，以实际生效位置为准。setup.ps1 支持用 -ConfigPath 指定目标。

2. 检查依赖，安装缺少的程序，再填写本机变量
   - 先列出依赖检查表，每项记录「已安装且可用 / 已安装但版本不兼容 / 未安装 / 待用户操作」、版本、路径和准备采用的安装来源。优先复用可用安装，不重复安装，不为本任务升级无关软件。
   - 逐项检查 plugins.json 中插件的包元数据和官方使用说明，确认是否还有外部 CLI 或运行时依赖；插件包由 OpenCode 加载，外部程序则需要单独安装。缺少某个服务商的登录授权时标记待授权，不要改动我的模型或 provider 配置。
   - 结合 Get-Command、现有配置、常见安装目录及已安装程序信息查找；先做有针对性的检查，不要直接递归扫描整个磁盘。命令不在 PATH 不等于未安装，可以用绝对路径运行。
   - OpenCode：若没有安装，从 https://opencode.ai/docs/ 选择 Windows 对应架构的正式 Desktop 安装包或独立 CLI。已经有 Desktop 时不必额外安装 CLI，也不要因为 CLI 不在 PATH 就覆盖现有安装。
   - Git：用于拉取仓库和 Worktrunk。按步骤 1 安装并验证。
   - PowerShell：Windows PowerShell 5.1 或 PowerShell 7 均可，不要为了运行 setup.ps1 强制升级到 7。
   - browse：从 https://opencode.ai/product/browse 核实当前安装方法；需要本机 browse.exe、受支持的 Chromium 浏览器和 browse 扩展。优先复用 Edge/Chrome 等现有浏览器；安装扩展、配对后继续验证。BROWSE_EXE 必须指向真实 browse.exe，不能把 npm 生成的 browse.cmd 当作 exe 填入。
   - 微信开发者工具：先查明支持 wechatide.cmd mcp 的发行版本和可信安装来源，安装后检查 MCP 功能。不要把名称相近的 CLI 或不支持 MCP 的版本当作已就绪；无法确认支持的发行版时，向我索取下载入口并继续其他独立安装。WECHATIDE_CMD 是实际 wechatide.cmd 完整路径，WECHATIDE_MCP_TOKEN 在安装和登录完成后从本机获取。
   - Worktrunk：插件 @auron-labs/opencode-worktrunk 不会安装 wt。参考插件上游 https://github.com/auron-labs/opencode-plugins/tree/main/packages/opencode-worktrunk 和 https://worktrunk.dev/ 的 Windows 安装方法；优先采用正式预编译版本，避免为单个工具无必要地安装完整编译环境。WORKTRUNK_BIN 是 Worktrunk 的 wt.exe，注意 Windows Terminal 也有同名 wt.exe，必须用版本或帮助输出区分。
   - Codebase Memory：插件 @auron-labs/opencode-codebase-memory 不会安装原生程序。参考插件上游 https://github.com/auron-labs/opencode-plugins/tree/main/packages/opencode-codebase-memory 和 https://github.com/DeusData/codebase-memory-mcp 的正式 Windows 发布；CODEBASE_MEMORY_BIN 是原生 codebase-memory-mcp.exe。优先选择仅安装二进制的方式；若使用上游 install.ps1，先核实并使用 --skip-config，避免重复注册 MCP 或安装额外 Skills、hooks。原生版本不应为了安装而额外引入 Docker、Python 或 Node.js。
   - Figma：模板使用远程 MCP https://mcp.figma.com/mcp，不要求安装 Figma Desktop，安装依赖阶段只需确认可联网，OAuth 按下一步完成。
   - Node.js/npm、Bun、winget、解压工具等只在选定的官方安装方式明确需要时补装；不要把所有包管理器、语言运行时和编译器都装一遍。Node.js 和 Bun 的官方入口分别为 https://nodejs.org/ 和 https://bun.sh/。先确认目标程序是否可用独立二进制安装。
   - 对清单中的每个缺失项，先确认官方来源、版本和系统架构，再实际下载、安装到用户可写目录，并重新发现和验证最终路径。已有包管理器可复用；未安装 winget 时直接采用上游安装包或便携版，不把安装 winget 作为前置条件。
   - 安装器可能顺带注册 AI 客户端或修改配置。安装前先备份已有 OpenCode 配置，优先选择仅安装程序、跳过自动配置的选项；最后统一按本仓库模板配置，不让安装器额外改动 Skills 或其他客户端设置。
   - 安装后检查退出码、实际文件以及安全的版本或帮助输出。安装命令返回不代表程序可用；当前终端未刷新 PATH 时用最终绝对路径验证。不启动会无限等待的 MCP stdio 服务来做版本检查。
   - 可以自动完成的用户级安装直接完成；必须手动安装、登录、配对或确认管理员权限时，给出准确的来源、所需操作和完成标准，待我操作后再次检测，从已完成的步骤继续，避免重复下载和安装。
   - 下载失败时先检查具体网络错误，重试或选择上游正式替代来源；不要擅自更改系统代理、关闭安全软件或安装无法确认来源的替代包。记录失败项并继续其他独立工作。
   - 不编造路径、Token 或空壳程序，不为通过检查删除插件或 MCP。setup.ps1 的五个变量均为必填；若必需程序或 Token 仍缺失，先不替换真实配置，保留已完成的安装和检查结果，明确阻塞项，解决后再统一应用。

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

最后简要报告：已复用或新安装的程序及版本、仍缺失或不兼容的依赖、实际配置路径和备份路径、各插件与 MCP 的验证结果，以及仍需我完成的具体操作。若尚未应用配置，明确说明原因。不要显示 Token 或完整敏感配置。
```
