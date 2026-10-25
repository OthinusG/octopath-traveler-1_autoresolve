# 八方旅人 1 · 等级压制自动结算

[English](README.en.md) · [使用说明](mod/README.md) · [验证记录](docs/VALIDATION.md)

基于 **UE4SS 3.0.1** 的《八方旅人 1》Mod：队伍等级明显高于普通暗雷敌人时，跳过战斗转场，直接获得奖励。

适配目标：**Windows Steam build 5272616**。当前版本：**0.1.3**。

## 实现效果

- **仅处理地图行走触发的普通随机暗雷**。地图 Boss、剧情战、固定事件战、比试和唆使不参与；无法确认的遭遇保留正常战斗。
- 上场队伍最高等级达到「地区危险等级与抽中敌群最高等级的较高值 + 等级差」时生效；默认等级差为 **1**。
- 发放 EXP、JP、金钱和概率掉落，计算已装备的队伍奖励被动、EXP/JP 奖励饰品加成，按原生规则叠加和取整。掉落遵守原生背包上限。
- 倒下角色不获得 EXP/JP，也不会因自动结算升级复活；存活的满级角色仍获得 JP。
- 角色升级时回满该角色的 HP/MP；获得的金钱计入原生累计金钱成就记录。
- **F6** 开关并保存状态，使用原生非阻塞提示。提示跟随界面语言：简体／繁体中文显示对应中文，其他语言使用英文，与语音设置无关。

## 安装

本仓库和打包工具生成的安装包均**不包含 UE4SS 加载器**。

1. 退出游戏，先安装官方 [UE4SS 正式版 3.0.1](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/v3.0.1)。本项目按该版本验证。
2. [下载仓库 ZIP](https://github.com/OthinusG/octopath-traveler-1_autoresolve/archive/refs/heads/main.zip)，解压后将 `mod/OT1AutoResolve` 文件夹复制到：

   ```text
   OCTOPATH TRAVELER/Octopath_Traveler/Binaries/Win64/Mods/
   ```

3. 在现有 `Mods/mods.txt` 中增加一行，保留其他 Mod 条目：

   ```text
   OT1AutoResolve : 1
   ```

4. 启动游戏，进入地图即可生效；按 F6 可以关闭。

**升级已有安装**：只替换 `OT1AutoResolve/Scripts`，保留自己的 `config.ini`，不要覆盖其他 Mod、加载器或 UE4SS 设置。

## 设置

配置文件：`Mods/OT1AutoResolve/config.ini`。手动修改后重启游戏。

```ini
[AutoResolve]
Enabled=1
ToggleKey=F6
LevelMargin=1
ShowUI=1
```

| 设置 | 含义 |
| --- | --- |
| `Enabled` | 1 开启、0 关闭；F6 会保存此值 |
| `ToggleKey` | F1–F24；`None` 禁用快捷键 |
| `LevelMargin` | 等级差，0–99；默认 1，0 允许同等级结算 |
| `ShowUI` | 1 显示奖励提示，0 隐藏 |

Mod 不主动保存游戏。原生接口不可用时保留正常战斗；奖励写入异常会停止后续自动结算，错误记录在 `Win64/UE4SS.log`。

## 验证与范围

49 项 Lua 测试通过，覆盖遇敌保护、门槛、奖励加成叠加、倒下与满级角色、背包容量、界面语言和 F6 持久化。原生接口检查及 0.1.3 冷启动通过；早期核心版本完成过 11 次实际暗雷结算验证。

**0.1.3 的加成／倒下队伍组合、残血角色升级恢复，以及成就实际解锁仍未完成完整实机验证。** Boss／剧情保护已做源码和模拟测试，未逐场推进所有受保护战斗。详见[验证范围](docs/VALIDATION.md)。

不模拟破防、一回合、无伤等战斗表现奖励、战斗中产生的额外倍率、偷窃、捕获或后期稀有猫替换；不添加首次怪物发现记录，也不执行战斗内超上限血蓝的收尾清理。

## 源码与打包

日常测试和打包不需要游戏资源：数值目录 `catalog.lua` 已随源码提交。

```sh
# Lua 5.4+
lua tests/test_mod.lua "$PWD"

# Python 3.9+，仅使用标准库
python3 tools/package_mod.py
```

输出：`dist/OT1AutoResolve-0.1.3-mod-only.zip` 和 SHA256 校验文件。可选的数值目录重新生成流程见[开发说明](docs/DEVELOPMENT.md)。

```text
mod/OT1AutoResolve/   Mod 源码与默认配置
mod/README.md        中文使用说明
tests/               可独立运行的 Lua 测试
tools/               打包与可选目录生成工具
docs/                开发与验证说明
LICENSES/            上游许可证说明
```

## 卸载

退出游戏，删除 `Mods/OT1AutoResolve`，并移除 `Mods/mods.txt` 中的对应条目。其他 Mod 仍需要 UE4SS 时保留加载器。

## 来源与许可证

本项目参考 OT2AutoResolve 与 FFRS AutoResolve v1.0.1 的交互和逻辑，并针对 OT1 验证接口与数据。仓库由 UE4SS fork 整理而来，保留上游历史和[原 MIT 许可证说明](LICENSES/UE4SS-MIT.txt)；本 Mod 源码尚未单独选择开源许可证。参见 [NOTICE](NOTICE.md)。

仓库不包含游戏原始资源、SDK／蓝图提取文件、存档或 UE4SS 二进制。本项目是非官方 Mod，与游戏发行方无关联。
