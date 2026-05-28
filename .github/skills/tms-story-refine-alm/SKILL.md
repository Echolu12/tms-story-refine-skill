---
name: tms-story-refine-alm
description: "TMS Story Refine - ALM Skill。Use when: 需要从 ALM 获取 Story 描述，通过需求澄清生成结构化 Key Description，并更新回 ALM。适用于 TMS 项目 BA 需求梳理、Story 规范化输出、AI 辅助需求分析。"
argument-hint: "提供 Story No（如 ST655096）开始流程"
---

# TMS Story Refine - ALM Skill

## When to Use

- 从 ALM 获取 Story 并梳理生成 Key Description
- 需求澄清：识别原始描述中的模糊点，问答式分析
- 将 AI 梳理后的结构化方案更新回 ALM
- 标识 Story 已经 AI 加工（Story Name 追加【byAI】）

## Prerequisites

- ALM MCP 服务器已连接（`alm-mcp-prd`）
- 需要的工具：`item_details_tool`、`update_story_mcp_tool`
- 项目：TMS，Workspace：OLL Story Workspace（ID: 11588885949）

## Procedure

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

**1. 一句话总结**
1-2句话高度概括需求本质。

**2. 关键流程**
分支独立列出，每条不超过5步：
- 流程A：`条件 → 步骤1 → 步骤2 → 结果`
- 流程B：`条件 → 步骤1 → 步骤2 → 结果`

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

---

### Step 5：更新 ALM Story

确认后，将 Key Description 转为 HTML，**替代**原始方案部分，同时更新 Story Name。

**最终 Story Description 结构**：
```html
<p><b>【Biz Background】</b></p>
<p>...保留原始背景描述...</p>
<hr/>
<h3>【Enhancement &amp; Solution】</h3>
<p><b>一句话总结：</b>...</p>
<p><b>关键流程：</b></p>
<ul><li>...</li></ul>
<p><b>核心规则：</b></p>
<table>...</table>
<p><b>UAT 验证场景：</b></p>
<table>...</table>
<!-- 当原始描述存在 Sample 数据/截图时，追加以下区块；否则整段省略 -->
<hr/>
<h3>【参考数据 &amp; 截图】</h3>
<p>...原样保留原始描述中的 Sample 报文、数据示例、截图等...</p>
```

**更新规则**：
- 保留【Biz Background】/【Current Situation】，用 Key Description 替代方案部分的文字描述
- **保留原始描述中的 Sample 数据和截图**，放在【参考数据 & 截图】区域；若原始描述未提供则整段省略（含标题）
- Story Name 末尾追加【byAI】标识
- OWNER_NAME / BA_OWNER_NAME 使用 domain ID（如 LUEC）

**操作**：
```
update_story_mcp_tool(params={
  "STORY_ID": "<Story No>",
  "STORY_NAME": "<原始 Story Name>【byAI】",
  "STORY_DESCRIPTION": "<重组后的完整 HTML>"
})
```

---

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
