---
name: tms-story-refine-alm
description: "TMS Story Refine/Create - ALM Skill。Use when: 需要从 ALM 获取 Story 描述、refine Story、生成 Key Description、更新 ALM，或基于新需求直接创建格式良好内容清晰的 ALM Story。适用于 TMS 项目 BA 需求梳理、Story 创建、Story 规范化输出、AI 辅助需求分析。"
argument-hint: "提供 Story No（如 ST655096）进行 refine，或提供新需求描述直接创建 Story"
---

# TMS Story Refine - ALM Skill

## When to Use

- 从 ALM 获取 Story 并梳理生成 Key Description
- 基于用户提供的新需求描述，直接生成格式良好的 ALM Story
- 需求澄清：识别原始描述中的模糊点，问答式分析
- 调用 `create_story_mcp_tool` 创建新 Story
- 将 AI 梳理后的结构化方案更新回 ALM
- 标识 Story 已经 AI 加工（Story Name 追加【byAI】）

## Prerequisites

- ALM MCP 服务器已连接（`alm-mcp-prd`）
- 需要的工具：`item_details_tool`、`update_story_mcp_tool`、`create_story_mcp_tool`
- 项目：TMS，Workspace：OLL Story Workspace（ID: 11588885949）

## Mode Selection

根据用户输入选择模式：

| 模式 | 触发方式 | 使用工具 | 结果 |
|------|----------|----------|------|
| Refine Existing Story | 用户提供 Story No，如 `ST655096`，要求 refine / 梳理 / 更新已有 Story | `item_details_tool`、`update_story_mcp_tool` | 读取已有 Story，澄清后更新回 ALM |
| Create New Story | 用户提供新需求描述，要求创建 Story / 新建 Story / 直接生成 Story | `create_story_mcp_tool` | 生成完整 Story 内容并创建到 ALM |

如果用户既没有提供 Story No，也没有明确要求创建新 Story，应先询问：

1. 是要 refine 已有 ALM Story，还是直接创建新 Story？
2. 如果 refine，请提供 Story No。
3. 如果创建，请提供需求背景、目标、涉及模块、期望上线迭代或 Owner 信息。

## Procedure A：Refine Existing Story

### Step 1：获取 Story

用户提供 Story No，调用 `item_details_tool` 获取详情，提取 `STORY_DESCRIPTION`。

```
item_details_tool(ids=["<Story No>"], type="story")
```

向用户展示原始描述，确认是否继续梳理。

---

### Step 2：需求澄清（问答式分析）

识别描述中不清晰或缺失的信息，向用户提问：

**澄清维度**：
- 业务目标：为什么要做？解决什么问题？
- 业务流程：涉及哪些角色？操作步骤？
- 业务分支：分支条件和结果？
- 业务规则：约束条件、校验逻辑？
- 边界场景：异常情况如何处理？
- 影响范围：涉及哪些模块/接口/现有逻辑？
- 数据处理：是否涉及历史数据修补？

**规则**：
- 每轮 3-5 个关键问题，最多 3 轮
- 如果描述已足够清晰完整，可跳过
- 逻辑明确后告知"需求已澄清"

---

### Step 3：生成 Key Description

基于原始描述和澄清结果，输出结构化 Key Description：

#### 输出格式：

**第一部分（最精简且最重要，不输出标题）**

**1. 一句话总结**
1-2句话高度概括需求本质。

**2. 关键流程**
分支独立列出，每条不超过5步：
- 流程A：`条件 → 步骤1 → 步骤2 → 结果`
- 流程B：`条件 → 步骤1 → 步骤2 → 结果`



**【Others】（补充信息）**

**3. 核心规则**
5-7条最关键的业务规则（表格形式）：

| # | 规则 |
|---|------|
| 1 | ... |

**4. UAT 验证场景**
关键验证场景（表格形式）：

| 场景 | 预期结果 |
|------|----------|
| ... | ... |

**5. 原始参考数据**
从原始 Description 中提取 Sample 数据（如接口报文示例、字段映射表、数据格式说明）和截图（`<img>` 标签），原样保留在 Key Description 之后，作为补充参考。若原始描述未提供相关内容，则整段省略（含标题）。

#### 生成规则：
- 遵循金字塔原理：结论先行，先"做什么"再"怎么做"
- Key Description 分两大块：第一部分（1+2，不输出标题）和 `【Others】`（3+4+5）
- 第一部分与 `【Others】` 之间必须空出几个空行，强调主次关系
- 分支逻辑必须拆分呈现，禁止合并为单条流程链
- **去重优先级**：先完整写关键流程，再写核心规则；凡是流程中已完整表达的逻辑，不得在核心规则重复出现
- 核心规则仅写"跨分支、跨步骤仍成立"的全局约束，不写流程动作本身
- 语言客观精炼，保留关键业务术语和接口名称
- 禁用"大概"、"可能"、"应该"等模糊词
- **有则保留、无则省略**：原始描述中的报文示例、数据样本、格式说明、截图等，放在 Key Description 末尾的「参考数据 & 截图」区域，不做删改；若原始描述未提供，则不输出该区域及标题

---

### Step 4：用户确认

展示 Key Description，询问：
1. 内容是否准确？
2. 是否需要修改或补充？
3. 确认后是否更新到 ALM？

**必须等待用户明确确认后才执行更新。**

### Step 5：更新 ALM Story

确认后，将 Key Description 转为 HTML，**替代**原始方案部分，同时更新 Story Name。

**最终 Story Description 结构（需与附件一致）**：
```html
<p><b>【Biz Background】</b></p>
<p>...保留原始背景描述...</p>
<hr/>
<h3>【Enhancement &amp; Solution】</h3>
<p><b>一句话总结：</b>通过两个按时序执行的 LTS 定时任务，自动建立起租需求单 ↔ Tank 关联关系，并向提请人持续推送提醒。</p>
<p><b>关键流程：</b></p>
<ul>
  <li>流程A（LTS1-建关联）：每日 02:00 扫描前一日更新附件的 Tank → 识别表单名称、表单号与附件（可从附件命名末尾“_”后提取）→ Tank CF“需求单号”更新并建立关联。</li>
  <li>流程B（LTS2-推提醒）：每日 03:00 扫描由流程1已建立关联且状态为 Draft/Approved/Rejected 的租超需求单 → 以“需求单号”匹配 Tank.CF“需求单号”并统计已关联数量与状态。</li>
  <li>流程C（停止条件）：当某需求单已关联 Tank 总数 = 需求单要求 Tank 数量 → 停止该需求单提醒。</li>
</ul>
<br/><br/><br/>
<p><b>【Others】</b></p>
<p><b>核心规则：</b></p>
<table border="1" cellspacing="0" cellpadding="6">
  <tr><th>#</th><th>规则</th></tr>
  <tr><td>1</td><td>附件命名格式为“表单名称_表单号”，系统从“_”后提取表单号。</td></tr>
  <tr><td>2</td><td>同一 Tank 存在多份匹配附件时，仅取上传时间最新的一份。</td></tr>
  <tr><td>3</td><td>LTS1 与 LTS2 必须保持先后顺序：先建关联，再统计与提醒。</td></tr>
  <tr><td>4</td><td>邮件发送粒度为“每个需求单一封”，收件人为该表单提请人邮箱。</td></tr>
  <tr><td>5</td><td>Tank 状态统计仅涵盖 Draft / Approved / Rejected。</td></tr>
  <tr><td>6</td><td>停止提醒判断以“已关联 Tank 总数是否达标”为唯一标准。</td></tr>
</table>
<p><b>UAT 验证场景：</b></p>
<table border="1" cellspacing="0" cellpadding="6">
  <tr><th>场景</th><th>预期结果</th></tr>
  <tr><td>上传附件“起租需求_REQ001.pdf”后执行 LTS1</td><td>Tank CF“需求单号”被更新为 REQ001</td></tr>
  <tr><td>同一 Tank 存在两份匹配附件</td><td>仅按最新上传附件提取表单号</td></tr>
  <tr><td>需求单要求 5 个 Tank，当前关联 3 个</td><td>发送提醒邮件，并展示统计结果</td></tr>
  <tr><td>需求单要求 5 个 Tank，当前关联 5 个</td><td>不再发送提醒邮件</td></tr>
  <tr><td>LTS2 执行时状态存在 Draft/Approved/Rejected 混合</td><td>邮件中按三类状态分别统计展示</td></tr>
</table>
<!-- 当原始描述存在 Sample 数据/截图时，追加以下区块；否则整段省略 -->
<hr/>
<h3>【参考数据 &amp; 截图】</h3>
<p>...原样保留原始描述中的 Sample 报文、数据示例、截图等...</p>
```

**更新规则**：
- 保留【Biz Background】/【Current Situation】，方案部分统一输出为【Enhancement & Solution】+【Others】结构
- **保留原始描述中的 Sample 数据和截图**，放在【参考数据 & 截图】区域；若原始描述未提供则整段省略（含标题）
- Story Name 末尾追加【byAI】标识
- OWNER_NAME / BA_OWNER_NAME 使用 domain ID（如 LUEC）

**操作**：
```json
{
  "STORY_ID": "<Story No>",
  "STORY_NAME": "<原始 Story Name>【byAI】",
  "STORY_DESCRIPTION": "<重组后的完整 HTML>"
}
```

调用方式：
```
update_story_mcp_tool(params={...})
```

## Constraints

- 必须先获取原始 Description，不能凭空编造
- 必须等待用户确认后才能更新 ALM
- 保留背景，替代方案部分
- **原始描述中的 Sample 数据（报文示例、字段映射等）和截图若存在则必须保留**，放在末尾【参考数据 & 截图】区域；若不存在则不输出该区域及标题
- Description 必须是 HTML 格式
- 如果原始描述为空或过于简略，提醒用户补充信息

## ALM MCP Notes

### Custom Field 传参方式
自定义字段作为**顶层 key-value** 传入（Display Name 作为 key）：
```json
{
  "STORY_ID": "ST655096",
  "TMS Customer": "BASF",
  "Group": "Group 1"
}
```

### 常用 Custom Field ID Mapping
参考 [references/custom-fields.md](./references/custom-fields.md)

---

## Procedure B：Create New Story Directly

当用户希望“不先创建再 refine”，而是直接基于需求描述创建 ALM Story 时，使用本流程。

### Step 1：收集创建 Story 所需信息

先从用户输入中提取已知信息。若关键信息缺失，按优先级提问，每轮最多 3-5 个问题。

**必需信息**：

| 信息 | 说明 | 缺失时处理 |
|------|------|------------|
| 需求标题 | 用于生成 `STORY_NAME` | 必问 |
| 业务背景 | 为什么要做，当前痛点是什么 | 必问 |
| 目标/方案 | 期望系统如何变化 | 必问 |
| UAT 验证点 | 用户如何验收 | 可由 AI 先生成，再请用户确认 |

**建议确认的信息**：

| 信息 | 默认值 / 来源 | 说明 |
|------|---------------|------|
| `PROJECT_NAME` | `TMS` | 固定项目名 |
| `STORY_STATE` | `Business Analysis` | 新建 Story 默认状态 |
| `STORY_PRIORITY` | `408` | 默认优先级 |
| `ITERATION_NAME` | 询问用户；未知则保留模板值 | 目标迭代 |
| `OWNER_NAME` | 参考 `create_story_template.json` | 使用 domain ID |
| `BA_OWNER_NAME` | 参考 `create_story_template.json` | 使用 domain ID |
| `Owner_BA` | 参考 `create_story_template.json` | 使用显示名 |
| `TMS Module` | 根据需求判断；不确定则询问 | 如 Contract&Tariff、Billing、Execution |
| `Group` | 参考模板或询问用户 | 如 Group3 |
| `TMS Customer` | 根据需求判断；不确定则询问 | 如 OLL、OCS、BASF |
| `UAT Type` | `ByBA` | 默认由 BA 验证 |
| `估计人天` | 询问用户；未知可先用 `0.1` 占位 | 需用户最终确认 |

参考默认字段模板：`create_story_template.json`。

### Step 2：需求澄清（创建前）

如果用户提供的新需求不够清晰，先进行轻量澄清。

**澄清重点**：
- 业务对象：涉及订单、合同、报价单、账单、供应商、客户还是接口？
- 使用角色：谁会操作或受影响？
- 触发时机：在哪个页面、流程或业务节点发生？
- 处理规则：系统需要新增、调整、校验或限制什么？
- 例外场景：无数据、重复数据、权限不足、状态不满足时如何处理？
- 验收方式：UAT 需要验证哪些关键路径？

如果用户只想快速创建，可基于当前信息先生成草稿，但必须标注需要用户确认的假设。

### Step 3：生成 Story 内容

生成清晰、业务可读的 `STORY_NAME` 和 HTML 格式 `STORY_DESCRIPTION`。

**Story Name 规则**：
- 简短表达业务目标，建议格式：`【模块/客户】动作 + 对象 + 目的`
- 不追加 `【byAI】`，除非用户明确要求
- 避免过长标题和纯技术描述

**Story Description HTML 结构（需与附件一致）**：

```html
<p><b>【Biz Background】</b></p>
<p>说明当前业务背景、痛点和为什么需要该需求。</p>
<hr/>
<h3>【Enhancement &amp; Solution】</h3>
<p><b>一句话总结：</b>...</p>
<p><b>关键流程：</b></p>
<ul>
  <li>流程A：条件 → 步骤1 → 步骤2 → 结果</li>
  <li>流程B：条件 → 步骤1 → 步骤2 → 结果</li>
</ul>
<br/><br/><br/>
<p><b>【Others】</b></p>
<p><b>核心规则：</b></p>
<table border="1" cellspacing="0" cellpadding="6">
  <tr><th>#</th><th>规则</th></tr>
  <tr><td>1</td><td>...</td></tr>
</table>
<p><b>UAT 验证场景：</b></p>
<table border="1" cellspacing="0" cellpadding="6">
  <tr><th>场景</th><th>预期结果</th></tr>
  <tr><td>...</td><td>...</td></tr>
</table>
<!-- 若有原始 Sample 数据/截图则追加；无则省略整个区块 -->
<hr/>
<h3>【参考数据 &amp; 截图】</h3>
<p>...Sample 数据、字段映射、截图等原样保留...</p>
```

**内容规则**：
- 结论先行，先写“做什么”和“业务结果”，再写规则细节
- 分支逻辑分开写，避免合并成长流程
- 核心规则只写跨流程通用约束，不重复关键流程动作
- UAT 场景覆盖主流程、关键分支、异常或边界场景
- 保持业务语言为主；技术字段、接口名仅在用户明确提供或需求必要时出现
- 禁用“大概”“可能”“应该”等模糊词

### Step 4：展示创建预览并等待确认

创建前必须向用户展示：

1. `STORY_NAME`
2. `STORY_DESCRIPTION` 的可读版摘要
3. 将传给 `create_story_mcp_tool` 的字段清单（不要隐藏关键业务字段）
4. 仍需用户确认或补充的假设

询问用户：

> 是否确认创建到 ALM？如需修改，请指出标题、描述、字段或 UAT 场景需要调整的部分。

**必须等待用户明确确认后才能调用 `create_story_mcp_tool`。**

### Step 5：调用 create_story_mcp_tool 创建 Story

确认后，将字段作为顶层 key-value 传入 `create_story_mcp_tool`。自定义字段使用 Display Name 作为 key。

**最小参数示例**：

```json
{
  "PROJECT_NAME": "TMS",
  "STORY_NAME": "<生成后的 Story 标题>",
  "STORY_DESCRIPTION": "<生成后的完整 HTML>",
  "STORY_STATE": "Business Analysis",
  "STORY_PRIORITY": 408,
  "ITERATION_NAME": "<迭代>",
  "OWNER_NAME": "<domain ID>",
  "BA_OWNER_NAME": "<domain ID>",
  "Owner_BA": "<BA 显示名>",
  "TMS Module": "<模块>",
  "Group": "<Group>",
  "TMS Customer": "<客户>",
  "公共需求": "false",
  "UAT Type": "ByBA",
  "估计人天": "<人天>"
}
```

调用方式：

```
create_story_mcp_tool(params={...})
```

创建成功后，向用户返回：

- 新 Story No / ID
- Story Name
- 关键字段摘要
- 后续是否需要继续 refine 或补充附件、截图、样例数据

## Create Story Constraints

- 不得在用户未确认时创建 Story
- 不得凭空伪造客户、迭代、Owner、Group；不确定时使用模板默认值前必须明确告知用户
- `STORY_DESCRIPTION` 必须是 HTML 格式
- `OWNER_NAME` / `BA_OWNER_NAME` 必须使用 domain ID
- 自定义字段必须作为顶层 key-value 传入，Display Name 作为 key
- 创建 Story 后不得自动再次 update，除非用户明确要求继续 refine / update