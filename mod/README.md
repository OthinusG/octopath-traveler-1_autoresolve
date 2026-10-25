# 八方旅人 1 等级压制

适配目标：Windows Steam build 5272616，UE4SS 正式版 3.0.1。

版本 0.1.3。已在上述版本实测普通暗雷跳过、奖励、升级、等级门槛、默认遇敌间隔和原生提示。默认开启，详细记录见 VALIDATION.md。

## 使用效果

仅处理地图行走触发的随机暗雷。当上场队伍的最高等级达到「地区危险等级、抽中敌群的最高等级两者较高值 + 等级差」时，跳过战斗转场，发放该普通敌群的基础 EXP、JP、金钱及概率掉落。

地图 Boss、剧情战、固定事件战、比试和唆使不参与结算。只接受原生地图移动检查通过后的遇敌判定；无法确认的遭遇保留正常战斗。

奖励包含已装备的 EXP/JP/金钱队伍被动，以及原版 EXP/JP 奖励饰品加成，按原生叠加和取整规则计算。倒下角色不获得 EXP/JP，满级角色仍获得 JP；金钱计入原生累计获得金钱的成就记录。

自动结算导致角色升级时，该角色会按升级后的上限回满 HP/MP；未升级角色不恢复。

F6 切换开关并保存状态。奖励使用游戏原生的非阻塞提示，不增加菜单。

提示跟随游戏界面语言：简体中文、繁体中文使用对应中文，其余语言统一使用英文；读取语言失败时也回退英文。语音语言不影响提示。

## 安装

本源码包及其生成的 mod-only 安装包不包含 UE4SS 二进制。

1. 退出游戏，打开 `OCTOPATH TRAVELER\Octopath_Traveler\Binaries\Win64`。
2. 未安装 UE4SS：先通过文末官方链接安装正式版 3.0.1。
3. 源码目录复制 `mod\OT1AutoResolve`（mod-only 安装包则复制 `Win64\Mods\OT1AutoResolve`）到游戏的 `Mods` 文件夹，并在现有 `Mods\mods.txt` 中增加 `OT1AutoResolve : 1`。保留现有 DLL、设置和其他 Mod 条目。

升级已安装的本 Mod：只替换 `OT1AutoResolve\Scripts` 文件夹，保留自己的 `config.ini`。

首次安装后进入地图即生效；按 F6 可关闭。

## 设置

编辑 `Mods\OT1AutoResolve\config.ini`，手动修改后重启游戏：

```ini
[AutoResolve]
Enabled=1
ToggleKey=F6
LevelMargin=1
ShowUI=1
```

- `Enabled`：1 开启，0 关闭；F6 切换会写回此值。
- `ToggleKey`：F1–F24；`None` 禁用快捷键。
- `LevelMargin`：0–99，默认 1；0 允许同等级结算。
- `ShowUI`：1 显示奖励提示，0 隐藏。

按普通敌群基础奖励结算，不模拟战斗内额外奖励、偷窃、捕获或稀有猫替换。提示仅显示掉落数量；道具通过原生接口加入背包，在背包中查看名称和详情。

背包掉落按游戏原生数量上限截断，满堆叠不影响 EXP、JP 和金钱结算。

Boss、剧情和固定战通过独立入口、原生状态检查及敌群白名单隔离；未逐场推进全部 Boss 和剧情进行测试。

Mod 不主动保存游戏。接口或奖励写入异常时停止后续自动结算，避免重复发奖；详情记录于 `Win64\UE4SS.log`。

## 卸载

退出游戏，删除 `Mods\OT1AutoResolve`，移除 `Mods\mods.txt` 中的对应条目。其他 Mod 仍需 UE4SS 时保留共享 DLL。

UE4SS：https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/v3.0.1
