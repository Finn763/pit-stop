# pit-stop — SPEC v3（2026-09-06）

一句话：跨端通用 Skill，一句指令让 agent 全自动跑完「读代码→找缺点→改代码→跑测试→汇报」，
中途不问人，刹车只写报告。名字：pit-stop（F1 进站：开进来修好，出去更快，不用下车）。

## 1. 问题与非目标

- 问题：没有"一句话改进整个项目"的全闭环 skill。PR 评审 agent 只审 PR；
  单文件评审 skill 只诊断不执行；阶段式技能只教阶段、无端到端配方；
  架构改进类技能止于"出报告+烤问"，不动手。
- 非目标：不做独立 CLI；不拆多 skill（跑顺 3 个项目再拆）；
  脚本化护栏 v1 只做敏感词终扫内联命令。

## 2. 触发契约

- Skill 名：`pit-stop`；description 只写触发条件，不写流程（SDO 铁律，写了流程 agent 会照描述偷工）：
  `Use when 用户要求全面改进/体检/重构一个项目，或说出 pit-stop 时。`
- 用户指令格式：`用 pit-stop 改进 <项目路径> [禁区]`
- 预算：用户拍板不设硬停。替代刹车：每阶段汇报累计花费预估；单阶段烧超 $20 自动停手写报告。
- 缺禁区 → 默认最严（见 §4）。

## 3. 五阶段（顺序执行，每段产物固定格式）

1. **装载**：读 README/AGENTS.md（或同类）+ `git status` + 最近 20 commits 热区。
   产物：项目一句话 + 脏区清单。（范围先于扫描，近改动权重优先）
   开工前先过 MODE 表：写下"什么算 finding、什么直接拒"——缺关键信息问一次，
   不瞎猜（问一次答不上来就按默认最严开工，不问第二遍）。
2. **找缺点**：先定范围再扫（用户点了名就听用户的；否则 git 热区优先，无热点才全仓）。
   硬规则：每条 `路径:行号` 证据；已记录的决策/已知坑不重审（除非摩擦大到值得重开）；
   输出用 tag（`delete/stdlib/native/yagni/shrink/perf/security/obs`）一行一条，
   每条挂推荐强度徽章（`Strong / Worth exploring / Speculative`），Speculative 只报不修。
   空态：`Lean already. Ship.`（没活就直说，不凑数）。
3. **给建议**：Strong 项 = 现象 + 证据 + 影响 + 最小修复 + 成本；另列"不做"清单（含触发条件）。
4. **执行**：遵守 §4 护栏。单轮修完派独立 reviewer 复查（reviewer 与 fixer 分离，
   复查最好换模型/换视角）；修→查循环直到干净或撞 `--max-rounds`（默认 3 轮）上限；
   跨轮 findings ledger 防重复修同一条；失败尝试也进 ledger，同一死路不试第二遍；
   连续两轮不收敛 → 升级为"需人定"停手。
   失败（测试红/撞禁区/单阶段超 $20）→ 停手，写进 §5 未做区，不硬猜不绕路。
5. **汇报**：头标注"本报告由 pit-stop 全自动生成"；固定四块——改了什么 / 验过什么（工具输出）
   / 没验什么 / 剩下什么（需人定）。禁止无工具输出的口头成功。

## 4. 判断与约束机制（三层：能强制的不只写文档）

- **L1 文档约束（跨端）**：禁止清单——删文件、`push --force`、读/写密钥凭据、改 CI 发布链与密钥、
  写生产数据库、对外发布（npm/PyPI/Release）。提交/推送默认不动手，等"推"字令。
- **L2 hooks 强制（Claude 系宿主）**：附 `hooks/block-destructive.sh`（PreToolUse 拦命令位 rm——含
  sudo/env/nohup/time/xargs/路径/`\rm` 前缀、`find -exec rm`/`-delete`、git push/reset --hard/clean -f/-D/
  checkout ./restore ./git rm；纯 bash+awk 无 jq/grep 依赖，解析不了 fail-closed；矩阵
  `hooks/test-block-destructive.sh` 90 例双提取模式，CI 三 OS），宿主支持就装，不支持就跳过，不强依赖。
- **L3 终扫脚本**：推送/收尾前敏感词终扫（内联命令，0 命中才过）。
- **Step 0 scope truth**：动手前先审"承诺"——用户要的和实际 build 的对上没有；
  对着没 build 的东西报"无 bug"是最危险的报告。
- **claims 审计**：注释、文档、测试名里的每个保证都是 CLAIM，
  必须找到代码里兑现它的路径；兑现不了的就是 finding。
- **证据卫生**：报告、日志、终端摘录里只放"说服人"的信息；
  密钥、token、他人 PII、内网路径一律打码或删掉，和 L3 终扫是同一条线的两道锁（一道习惯、一道机器）。
- **验证门**：IDENTIFY→RUN→READ→VERIFY 四步，跳步 = 说谎；
  汇报分"验过/没验"两区；信任子代理自报前先看 diff（子代理自报成功≠成功）。
- **双轴复核**：执行后 diff 过两轴——规范轴（跟仓库既有风格）+ 需求轴（跟本轮建议），
  小改动可自查，大改动派独立 reviewer。

## 5. 跨端兼容与体积

- 正文只用通用动作：读文件 / 改文件 / 跑 shell / 上网查。Hermes 专属（todo/delegate/cron）进可选段。
- SKILL.md < 500 词核心；阶段细节进 `references/`；报告模板进 `templates/`。
- frontmatter 固定：`name` + `description`（触发条件+关键词轰炸，多种 phrasing 同一意图）+
  `argument-hint: "<项目路径> [--禁区 ...]"` + `allowed-tools` 白名单。
- 汇报铁律：不许"可以优化"而不说改哪、为什么——每条建议必须可执行。
- 关键词覆盖：improve/refactor/audit/tech-debt/review/verify/guardrail（SDO：按症状词写）。

## 6. 验证计划（TDD + 诚实数字）

- 基线：2 个真实项目跑"无 skill 会怎么干"，记录瞎搞点（red）。
- 定稿重跑：证据率 / 测试门遵守率 / 口头成功零容忍（green），补 rationalization 表。
- 发布数字必须诚实：注明 baseline、样本数、模型，区分 single-shot 和 agentic 数字，
  不许拿单次最优当平均。
- 每次实战回来只补实测到的条目，不预写。

## 7. 仓库布局与发布

```text
pit-stop/
  skills/pit-stop/SKILL.md   # 本体（~/.agents/skills/pit-stop）
  skills/pit-stop/references/{audit,fix,review,report,guardrails,verification}.md
  skills/pit-stop/templates/report.md
  hooks/block-destructive.sh  hooks/test-block-destructive.sh  # L2（Claude 系）+ 90 例矩阵
  .claude/settings.json  .github/workflows/ci.yml  # 自挂 hook + CI 矩阵
  commands/pit-stop.toml  .opencode/command/    # slash 入口
  examples/before-after.md   # 真实战果 before/after（传播弹药）
  AGENTS.md  GEMINI.md  gemini-extension.json  package.json  CHANGELOG.md  LICENSE(MIT)
  README.md  README.zh-CN.md
  .claude-plugin/  .codex-plugin/  .cursor-plugin/  .devin-plugin/  .kimi-plugin/
  .hermes-plugin/  .cursor/  .windsurf/  .pi/extensions/    # 多端适配
  assets/  docs/SPEC.md  docs/architecture.{html,svg}+zh-CN  docs/release-notes/
```

- 安装 v1：一行拷贝进 `~/.agents/skills/`（以后再做订阅式更新，先拷文件）。
- README 英文为主，一句话 + 安装 + 示例报告链接；受众是全网 agent 用户。
- 发布清单：多语言 README（至少中英）、benchmark 可复现说明、
  examples/ 真实 before-after、CHANGELOG。

## 8. 待用户拍板（实现前确认）

- [x] 名字 pit-stop（已定；三处全空：GitHub 无同名仓、npm 404、无 skill 重名）
- [x] 预算不设硬停，改单阶段 $20 熔断（用户定）
- [x] "提交/推送默认不动手"保留（用户定：全自动里唯一的回头路）
- [x] 实战验证跳过，写完直接发布（用户定：从真实使用中迭代，不做预设小白鼠）
