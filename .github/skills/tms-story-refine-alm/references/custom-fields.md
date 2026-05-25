# TMS Story Custom Field ID Mapping

## 传参方式
自定义字段作为**顶层 key-value** 传入 `create_story_mcp_tool` 或 `update_story_mcp_tool`，用 Display Name 作为 key。

**示例**：
```json
{
  "STORY_ID": "ST655096",
  "TMS Customer": "BASF",
  "Group": "Group 1",
  "UAT Type": "ByBA"
}
```

## 完整 Mapping 表

| Custom Field ID | Display Name | Type | 可选值 |
|-----------------|--------------|------|--------|
| 11684514800 | Data Patch | boolean | — |
| 11684517486 | Owner_BA | dropdown | 95人 |
| 39880529522 | TMS Module | dropdown | Appointment, Billing, Common, Contract&Tariff, Execution, Fleet, Interface, Print, Profile, Report, Retro, SR&TP&Tjob, SupplierPortal, Weika |
| 49081753003 | QA | dropdown | Baicheng Ye, Christian Li, EDWARD ZHOU, Emma Yang 等 |
| CF100041 | Is Assessed? | boolean | — |
| CF100042 | Group | dropdown | Framework, Group 1, Group 2, Group3, Group4, DevOps, DataAnalysis, B2B |
| CF100103 | TMS Customer | dropdown | OCS, BASF, Covestro, OLL TMS 等 50+ |
| CF100303 | 有权限变更 | boolean | — |
| CF101844 | 公共需求 | boolean | — |
| CF102254 | 未完成 | boolean | — |
| CF102271 | 未准时提交 | boolean | — |
| CF102430 | 培训材料 | boolean | — |
| CF102970 | 1.1_产品方向 | dropdown | YES |
| CF102971 | 1.3_前置需求 | dropdown | YES |
| CF102972 | 1.4_频繁使用 | dropdown | YES |
| CF102974 | 估计人天 | text | — |
| CF102975 | 1.2_紧急要求 | dropdown | YES, 非常紧急 |
| CF103730 | FRMWK相关 | boolean | — |
| CF104990 | 新接口 | boolean | — |
| CF106672 | Interesting Story | boolean | — |
| CF106992 | UAT Type | dropdown | ByUser, ByBA, NoNeed |

## 标准字段注意事项

| 字段 | 说明 |
|------|------|
| OWNER_NAME | 使用 domain ID（如 LUEC），不是显示名 |
| BA_OWNER_NAME | 同上 |
| STORY_STATE | Business Analysis / Defined / In-Progress / Completed / Accepted / Released |
| STORY_DESCRIPTION | 必须是 HTML 格式 |
| STORY_PRIORITY | 数值（如 208, 308, 408, 508） |
