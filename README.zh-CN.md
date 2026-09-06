# Pit-Stop

*开进来，修好，出去更快。你不用下车。*

[![License: MIT](https://img.shields.io/badge/License-MIT-3fb950?style=flat-square&labelColor=black)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-1-8957e5?style=flat-square&labelColor=black)](#仓库结构)

[English](README.md) | 中文

评审 agent 停在"指出问题"。Pit-stop 是一个跨端 agent skill，把活干完：
**一句话跑完整个改进闭环——读代码→找缺点→改→验证→汇报，中途不问你。**

```
用 pit-stop 改进 <项目路径>
```

你只说一句。agent 装载上下文，找缺点（每条带 `路径:行号` 证据），
修→复查循环里改完，用真实工具输出验证，最后一次性给报告
（分已验证/未验证/待定）。推送和发布永远要你亲口说才动手。

## 为什么做 pit-stop

为修三个每个 agent 用户都见过的毛病：

- **#1：只说不干。** 评审以"你应该……"结尾，diff 永远没来。**修法：** 循环不停在
  finding——改完复查（最多 3 轮，跨轮台账，不收敛升级），然后才汇报。
- **#2："好了"但没证据。** "修好了！"、"测试过了！"——背后没有一条命令输出。
  **修法：** 先证据后结论。本轮没跑验证命令，就不许说成功。报告里只放工具输出。
- **#3：越改越臃肿。** 建议全是没人要的抽象。**修法：** 每条发现打 tag
 （`delete/stdlib/native/yagni/shrink/security/obs`），Speculative 只报不修。
  没活就直说：`Lean already. Ship.`。

## 运行环

![pit-stop 运行环](docs/architecture.zh-CN.svg)

五阶段一遍过，中途零打扰——护栏在上，升级出口在下。
[▶ 交互版](https://finn763.github.io/pit-stop/architecture.zh-CN.html)

## 安装（30 秒）

```bash
npx skills add Finn763/pit-stop
```

按提示选 agent，以后 `npx skills update` 更新。分端：

| 端 | 装法 |
|---|---|
| Claude Code | `/plugin marketplace add Finn763/pit-stop`，再 `/plugin install pit-stop@pit-stop` |
| Codex | `.codex-plugin` 插件，或上面 `npx skills` |
| Cursor | `.cursor-plugin` 插件，或 `/add-plugin pit-stop` |
| Gemini CLI | `gemini extensions install https://github.com/Finn763/pit-stop` |
| Pi | `package.json` 即 pi-package，或拷 `skills/` |
| OpenCode | `.opencode/` 自动发现 |
| Hermes | `.hermes-plugin` 插件，或拷 `skills/` |
| 其他 | `cp -r skills/pit-stop ~/.agents/skills/` |

无需每仓配置——没东西可配。

## 理念

先证据后结论 · 复查的是改动不是承诺 · 推送要人话 ·
便宜且诚实（每阶段报花费，单阶段超 $20 自己停手）。

## 仓库结构

```
skills/pit-stop/SKILL.md          # skill 本体（<500 词核心）
skills/pit-stop/references/       # 阶段、护栏、验证三份细节
skills/pit-stop/templates/        # 报告模板
hooks/block-destructive.sh        # L2 护栏（Claude 系 hooks）
commands/ .opencode/              # slash 命令入口
.claude-plugin/ .codex-plugin/ .hermes-plugin/ .cursor/ .windsurf/
examples/before-after.md          # 真实战果
docs/SPEC.md                      # 完整 spec（v3）
```

MIT。站在 superpowers、mattpocock/skills、ponytail、Trail of Bits skills、
BugHunter、code-review-graph 肩膀上，详见 `docs/SPEC.md`。
