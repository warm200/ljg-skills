# NAS 笔记输出约定（本 fork 专用，优先于技能正文）

这个文件由 `scripts/nas/patch.py` 复制进每个 ljg 技能目录。技能正文里凡是关于**保存位置、目录、Denote/Emacs 检查**的规定，和本文冲突时一律以本文为准。正文的写作要求（结构、语气、模板正文）照常遵守。

## 1. 存到哪里

- 存到用户的**记忆服务器**（已连接的 MCP 记忆服务器），用工具 `upsert_memory_file` 写入。
- 路径：`notes/{YYYY-MM}/{文件名}`，例如 `notes/2026-11/20261123T101500--追本-为什么拖延__think.md`。`{YYYY-MM}` 取保存时的年月。
- 技能正文里出现的 `notes/{YYYY-MM}/`、`~/Documents/notes/`、`~/Context/`，都是指这里。**不要**在本机或沙盒里创建任何笔记目录或笔记文件当作成品。
- 记忆服务器连不上：把完整笔记贴在回复里，明确告诉用户"没存进 notes/"，不要退回写本地文件。

## 2. 什么时候存

- 每次用 ljg 技能做出成品，都存一份。包括正文写着"默认只在对话中展示""默认不写笔记""默认只读"的技能（如 ljg-explain、ljg-map、ljg-mechanism、ljg-read、ljg-analogy、ljg-teach、ljg-word）：本 fork 里它们也要存。
- 例外：用户说"不落盘""只分析""别存""read-only"时不存。
- 只存最终稿。中间稿、内部分析表、检查清单、研究记录不存（除非技能正文要求把它写进成品）。

## 3. 文件名

- 沿用技能自己规定的 Denote 文件名（`{YYYYMMDDTHHMMSS}--{主题}__{类别}.md`，ljg-writes 是 `{时间戳}==z--{标题}__write.md`）。技能没规定文件名的，用 `{时间戳}--{主题}__{技能名去掉 ljg- 前缀}.md`，例如 `__explain.md`。
- 时间戳用用户本地时间。能运行 `date +%Y%m%dT%H%M%S` 就用它；不能运行命令时，用对话里已知的当前日期时间，不确定的部分不要编造，按已知的最接近时间填。
- 主题部分：不要出现 `/ \ : * ? " < > |`、换行，不要以 `.` 开头；空格换成 `-`。
- 同名文件已存在时不要覆盖，把时间戳秒数加 1。

## 4. 文件头（服务器强制，不合格会被拒）

保留技能模板里的字段（`title`、`date`、`identifier`、`description` 等），再保证下面几项齐全：

```yaml
---
title: 追本：为什么拖延            # 技能模板的标题
type: note                         # 固定写 note
summary: 一行话：这篇笔记讲什么    # 必填，单行；可以用 description 的第一句
skill: ljg-think                   # 产出它的技能
identifier: 20261123T101500        # 和文件名里的时间戳一致
date: [2026-11-23 Mon 10:15]       # 技能模板有就保留
tags: [think, 拖延]                # 必须是 YAML 列表
---
```

- 技能模板里写成 `tags: blind weread topology` 或 `tags: constraint` 的，改成 `tags: [blind, weread, topology]`、`tags: [constraint]`。
- 不要写 `updated`，服务器会自动加。
- 原技能如果写 Org 文件头（`#+title:`），改成上面的 YAML。

## 5. 怎么调用

```
upsert_memory_file(
  relative_path = "notes/2026-11/20261123T101500--追本-为什么拖延__think.md",
  content       = "<完整文件内容，含文件头>",
  commit_message= "note: ljg-think 为什么拖延",
  index_impact  = "none"
)
```

- 新笔记**不需要**更新 `MEMORY_INDEX.md`，`index_impact` 一律填 `none`。
- 单个文件上限 512KB。超了就拆成 `...__book-1.md`、`...__book-2.md`，每个都带完整文件头。

## 6. 检查和读回

- 正文要求"用真实 Emacs 读回""denote-retrieve-filename-identifier""consult-notes""Denote 接受检查"的步骤：**跳过**。
- 改为：写入后用 `read_memory_file` 读回，核对文件名、标题、identifier 和正文完整。
- 需要本地文件的校验器（如 `bun .../Validate*.ts`、`check_*.py`）：能运行代码时，先把同样内容写到 `/tmp` 下的临时文件跑校验，修好后再存进记忆库，最后删掉临时文件；不能运行代码时跳过，并在回复里说明没跑校验。

## 7. 图片、HTML 等成品

ljg-card、ljg-present、ljg-business-model、ljg-classic 这类产出 PNG/HTML/JSON 的技能：成品照技能正文交付（本机 `~/Downloads` 或对话附件，记忆库不存二进制文件）。另外在 `notes/{YYYY-MM}/` 存一篇 Markdown 记录：主题、成品里的核心文字内容、成品文件名和位置。

## 8. 隐私

- 保存前遵守记忆库 `MEMORY_INDEX.md` 里的禁忌（对话开始时用 `read_memory_index` 读）。
- 第一次往 `notes/` 保存前读一遍 `notes/README.md`：哪些内容不落盘、要加什么标签，以它为准。
- 不存密码、密钥、证件号、账户余额。

## 9. 回复用户

保存成功后，在回复末尾写一行：`已存：notes/2026-11/<文件名>`。
