-- Octopath Traveler I, Windows Steam build 5272616, official UE4SS 3.0.1.
local folder = assert(debug.getinfo(1, 'S').source:match('^@(.+[\\/])'), 'script path unavailable')
local catalog = dofile(folder .. 'catalog.lua')
local messages = dofile(folder .. 'messages.lua')
local config_path = folder .. '../config.ini'
local prefix = '[OT1AutoResolve] '
local hooked, busy, manager = false, false, nil
local previous_step
local settings = { Enabled = true, ToggleKey = 'F6', LevelMargin = 1, ShowUI = true }

local fields = {
    main = 'MainMemberID_26_B4144D6B4009D87793E65DB3D8FD1F30',
    id = 'CharacterID_6_AB6BE4BD426A49AE64EA458F343F22C7',
    level = 'Level_7_2387E0754078BE22EED8E689263C5693',
    exp = 'Exp_63_D85F37A949C1283D8A677883021D4C04',
    jp = 'JobPoint_119_60C799BF46DFB8A5D05CBBB18809FFE3',
    hp = 'RawHP_68_62DA206543C83DEA4C616D90E3CDAD12',
    groups = 'Group_10_057136E8448CFCD745DE10885179E34E',
    group_id = 'GroupID_5_5D98C1AA42C068BC7B5DFD92DFCF13CF',
    first = 'FirstEncount_15_2D5431F8446E97E819C7498447847B6B',
    appearance = 'Appearance_7_41D2B65E46409B12F74D31BCBC64D124',
}

local function log(message)
    print(prefix .. tostring(message) .. '\n')
end

local function valid(object, label)
    if not object or not object:IsValid() then error(label .. ' unavailable') end
    return object
end

local function library(asset, path)
    local object = StaticFindObject(path)
    if (not object or not object:IsValid()) and asset then
        LoadAsset(asset)
        object = StaticFindObject(path)
    end
    return valid(object, path)
end

local function current_messages()
    local ok, language = pcall(function()
        return library(nil, '/Script/Octopath_Traveler.Default__KSGameStatics'):GetLanguage()
    end)
    return messages(ok and tonumber(language) or nil)
end

local function read_config()
    local file = io.open(config_path, 'r')
    if not file then return end
    local section = ''
    for raw_line in file:lines() do
        local line = raw_line:gsub('%s*[;#].*$', ''):match('^%s*(.-)%s*$')
        local heading = line:match('^%[([^%]]+)%]$')
        if heading then
            section = heading:lower()
        elseif section == 'autoresolve' then
            local key, value = line:match('^([%w_]+)%s*=%s*(.-)%s*$')
            if key == 'Enabled' or key == 'ShowUI' then
                if value == '0' or value == '1' then settings[key] = value == '1'
                else settings[key] = false; log('invalid ' .. key .. '; disabled') end
            elseif key == 'LevelMargin' then
                local number = tonumber(value)
                if number and number == math.floor(number) and number >= 0 and number <= 99 then
                    settings.LevelMargin = number
                else log('invalid LevelMargin; using 1') end
            elseif key == 'ToggleKey' then
                settings.ToggleKey = value
            end
        end
    end
    file:close()
end

local function persist_enabled()
    local file = assert(io.open(config_path, 'r'), 'config read failed')
    local content = file:read('*a')
    file:close()
    local value = settings.Enabled and '1' or '0'
    local updated, count = content:gsub('(Enabled%s*=%s*)[01]', '%1' .. value, 1)
    if count ~= 1 then error('config Enabled entry missing') end
    local temporary, backup = config_path .. '.tmp', config_path .. '.autoresolve-backup'
    local output = assert(io.open(temporary, 'w'), 'config temporary file unavailable')
    local written, reason = output:write(updated)
    local closed = output:close()
    if not written or not closed then os.remove(temporary); error(reason or 'config write failed') end
    if not os.rename(config_path, backup) then os.remove(temporary); error('config backup failed') end
    if not os.rename(temporary, config_path) then
        local restored = os.rename(backup, config_path)
        error(restored and 'config replace failed; original restored' or 'config restore failed; original retained in backup')
    end
    os.remove(backup)
end

local function notify(text, context)
    local ui = library('/Game/Library/LibUIUtil', '/Game/Library/LibUIUtil.Default__LibUIUtil_C')
    ui:CommonNotification(FText(text), context)
end

local function ordinary_map(context)
    if not context.HasActiveEncount or not context.EncountEnable or tonumber(context.EncountMode) ~= 0
        or context.SingleBattleMode or context.Debug_FixedEncount then return false end
    local world = library(nil, '/Script/Octopath_Traveler.Default__KSGameStatics')
    local event = library(nil, '/Script/Octopath_Traveler.Default__EventFunction')
    return not world:GetBattleMode(context) and not event:IsEventPlaying()
end

local function party(save)
    local slots, members = save.PlayerParty[fields.main], save.PlayerMember
    if #slots < 1 or #slots > 4 or #members < 1 or #members > 64 then return nil end
    local result, seen, highest, alive = {}, {}, 0, false
    for i = 1, #slots do
        local index = tonumber(slots[i])
        if index ~= -1 then
            if not index or index ~= math.floor(index) or index < 0 or index >= #members or seen[index] then return nil end
            local member = members[index + 1]
            local id, level, hp = tonumber(member[fields.id]), tonumber(member[fields.level]), tonumber(member[fields.hp])
            if not id or id < 1 or id > 8 or not level or level < 1 or level > 99 then return nil end
            if not hp or hp < 0 or hp ~= math.floor(hp) then return nil end
            seen[index] = true
            highest = math.max(highest, level)
            alive = alive or hp > 0
            result[#result + 1] = {id = id, level = level, alive = hp > 0}
        end
    end
    if #result == 0 or not alive then return nil end
    return result, highest
end

local function apply_reward_modifiers(reward, context)
    local char = reward.char
    assert(char.CheckCharacterSupportAbility and char.GetCharacterEquipmentSingle, 'reward modifiers unavailable')
    local param = library('/Game/GameParam/LibGetParam', '/Game/GameParam/LibGetParam.Default__LibGetParam_C')
    assert(param.GetBattleParamToFloat, 'reward parameters unavailable')
    local rules = {
        {stat = 'money', support = 0, param = 'SUPPORT_PARAM_MERCHANT_001'},
        {stat = 'exp', support = 32, param = 'SUPPORT_PARAM_WEAPON_MASTER_001'},
        {stat = 'jp', support = 41, param = 'SUPPORT_PARAM_ASTRONOMY_002'},
    }
    local equipment = {exp = 0, jp = 0}
    for _, member in ipairs(reward.members) do
        for slot = 0, 10 do
            local item = char:GetCharacterEquipmentSingle(member.id, slot, context):ToString()
            local bonus = catalog.reward_items[item]
            if bonus then
                for stat, amount in pairs(bonus) do equipment[stat] = equipment[stat] + amount end
            end
        end
    end
    for _, rule in ipairs(rules) do
        local enabled = false
        for _, member in ipairs(reward.members) do
            local result = {}
            char:CheckCharacterSupportAbility(member.id, rule.support, context, result)
            local flag = result.Enable
            if flag == nil then flag = result.enable end
            assert(type(flag) == 'boolean', 'support state unavailable')
            enabled = enabled or flag
        end
        local ratio = 1
        if enabled then
            local result = {}
            param:GetBattleParamToFloat(FName(rule.param), context, result, result, result, result)
            ratio = assert(tonumber(result.Param or result.param), 'reward ratio unavailable')
            assert(ratio >= 1 and ratio <= 1000, 'invalid reward ratio')
        end
        -- Native CalcGetReward adds static modifiers, then truncates with a 0.01 tolerance.
        reward[rule.stat] = math.floor(reward[rule.stat] * (ratio + (equipment[rule.stat] or 0)) + 0.01)
    end
end

local function prepare(context)
    if not ordinary_map(context) or tonumber(context.StepCount) > 0 then return nil end
    local danger = tonumber(context.DangerLevel)
    if not danger or danger < 1 or danger > 99 then return nil end
    local accessor = library('/Game/Library/LibAccessor_SaveGame',
        '/Game/Library/LibAccessor_SaveGame.Default__LibAccessor_SaveGame_C')
    local output = {}
    accessor:GetSaveData(context, output)
    local save = valid(output.KSSaveGame, 'active save')
    local members, highest = party(save)
    if not members or highest < danger + settings.LevelMargin then return nil end
    local encounter = context.CurrentEncounter
    local options = encounter[fields.groups]
    if #options < 1 or #options > 64 then return nil end
    for i = 1, #options do
        local id = options[i][fields.group_id]:ToString()
        if not catalog.groups[id] and not (id == 'None' and tonumber(options[i][fields.appearance]) == 0) then return nil end
    end
    -- UE4SS 3.0.1 cannot pass this nested array; mirror OT1's verified Blueprint lottery.
    local index = tonumber(encounter[fields.first])
    if not context.FirstEncount or not index or index < 1 or index > #options then
        local total = 0
        for i = 1, #options do
            local weight = tonumber(options[i][fields.appearance])
            if not weight or weight < 0 or weight ~= math.floor(weight) then return nil end
            total = total + weight
        end
        if total < 1 or total > 2147483647 then return nil end
        local roll = math.random(total)
        for i = 1, #options do
            roll = roll - tonumber(options[i][fields.appearance])
            if roll <= 0 then index = i; break end
        end
    end
    local group_id = options[index][fields.group_id]:ToString()
    local group = catalog.groups[group_id]
    if not group then return nil end
    local reward = {save = save, members = members, group = group_id, exp = 0, jp = 0, money = 0, drops = {}}
    for _, id in ipairs(group) do
        local enemy = assert(catalog.enemies[id], 'enemy unavailable')
        if highest < enemy.level + settings.LevelMargin then return nil end
        reward.exp, reward.jp, reward.money = reward.exp + enemy.exp, reward.jp + enemy.jp, reward.money + enemy.money
        if enemy.item and math.random(100) <= enemy.drop then
            reward.drops[enemy.item] = (reward.drops[enemy.item] or 0) + 1
        end
    end
    reward.char = library('/Game/Library/LibCharacter', '/Game/Library/LibCharacter.Default__LibCharacter_C')
    reward.item = library('/Game/Item/BP/ItemFunction', '/Game/Item/BP/ItemFunction.Default__ItemFunction_C')
    assert(reward.char.AddCharacterExp and reward.char.FullRecoveryCharacter and reward.char.AddJobPoint and reward.item.AddBackpackItem
        and save.AddPlayerMoney and context.ResetEncountStep, 'reward interface unavailable')
    reward.achievement = library(nil, '/Script/Octopath_Traveler.Default__LibAchievement')
    assert(reward.achievement.CheckAndSetTotalLeafAchievement, 'money achievement interface unavailable')
    apply_reward_modifiers(reward, context)
    if next(reward.drops) then
        local limit = {}
        reward.item:GetBackpackItemMax(context, limit)
        local maximum = tonumber(limit.Max)
        assert(maximum and maximum >= 1 and maximum == math.floor(maximum), 'inventory limit unavailable')
        for id, count in pairs(reward.drops) do
            local current = {}
            reward.item:GetBackpackItemNum(FName(id), context, current)
            local owned = tonumber(current.itemNum)
            assert(owned and owned >= 0 and owned == math.floor(owned), 'inventory count unavailable')
            local accepted = math.min(count, math.max(0, maximum - owned))
            reward.drops[id] = accepted > 0 and accepted or nil
        end
    end
    return reward
end

local function grant(context, reward)
    -- The original IsEncount runs next and reads this reset before deciding to start battle.
    context:ResetEncountStep()
    assert(tonumber(context.StepCount) and tonumber(context.StepCount) > 0, 'encounter reset failed')
    context.FirstEncount = false
    reward.save:AddPlayerMoney(reward.money)
    reward.achievement:CheckAndSetTotalLeafAchievement(reward.money, context)
    for _, member in ipairs(reward.members) do
        if member.alive then
            if member.level < 99 then
                local result = {}
                reward.char:AddCharacterExp(member.id, reward.exp, context, result)
                if result.LevelUp == true then reward.char:FullRecoveryCharacter(member.id, context) end
            end
            reward.char:AddJobPoint(member.id, reward.jp, context)
        end
    end
    for id, count in pairs(reward.drops) do
        local success = {}
        reward.item:AddBackpackItem(FName(id), count, context, success)
        assert(success.Success == true, 'inventory rejected ' .. id)
    end
    log(string.format('resolved %s: EXP %d, JP %d, leaves %d', reward.group, reward.exp, reward.jp, reward.money))
end

local function show_reward(reward, context)
    if not settings.ShowUI then return end
    local text = current_messages()
    local message = string.format(text.reward, reward.exp, reward.jp, reward.money)
    local count = 0
    for _, number in pairs(reward.drops) do count = count + number end
    if count > 0 then message = message .. string.format(text.drops, count) end
    notify(message, context)
end

local function on_player_step(context, updated)
    if busy then return end
    if not settings.Enabled or not updated:get() then previous_step = nil; return end
    local actor = context:get()
    if not actor or not actor:IsValid() then previous_step = nil; return end
    local position, step = actor.PrePlayerPos, tonumber(actor.StepCount)
    local x, y = tonumber(position.X), tonumber(position.Y)
    if not x or not y or not step then previous_step = nil; return end
    local name, before = actor:GetFullName(), previous_step
    previous_step = {actor = name, x = x, y = y, step = step}
    if not before or before.actor ~= name or step >= before.step
        or (x == before.x and y == before.y) or step > 0 then return end
    manager, busy = actor, true
    local ok, reward = pcall(prepare, actor)
    if ok and reward then
        ok, reward.error = pcall(grant, actor, reward)
        if ok then
            local shown, reason = pcall(show_reward, reward, actor)
            if not shown then log('hint failed: ' .. tostring(reason)) end
        else log('reward failed; disabled: ' .. tostring(reward.error)) end
    elseif not ok then log('prepare failed; disabled: ' .. tostring(reward)) end
    busy = false
    if previous_step then previous_step.step = tonumber(actor.StepCount) or step end
    if not ok then settings.Enabled = false end
end

read_config()

local function install_hooks(actor)
    if hooked then return end
    if not actor or not actor:IsValid() then return end
    if not actor:GetFullName():find('EncountManagerBP_C', 1, true) then return end
    manager = actor
    local path = '/Game/Battle/BP/EncountManagerBP.EncountManagerBP_C:UpdatePlayerStep'
    local registered, reason = pcall(RegisterHook, path, on_player_step)
    if registered then hooked = true; log('hooked ' .. path)
    else log('hook registration failed: ' .. tostring(reason)) end
end

RegisterBeginPlayPostHook(function(context)
    local ok, actor = pcall(function() return context:get() end)
    if ok then install_hooks(actor) end
end)
ExecuteInGameThread(function()
    install_hooks(FindFirstOf('EncountManagerBP_C'))
end)

if settings.ToggleKey ~= 'None' then
    local number = tonumber(settings.ToggleKey:match('^F(%d+)$'))
    if number and number >= 1 and number <= 24 then
        RegisterKeyBind(Key[settings.ToggleKey], function()
            ExecuteInGameThread(function()
                settings.Enabled = not settings.Enabled
                previous_step = nil
                local saved, reason = pcall(persist_enabled)
                if not saved then log('setting not saved: ' .. tostring(reason)) end
                log('enabled = ' .. tostring(settings.Enabled))
                local checked, is_map = pcall(function() return manager and manager:IsValid() and ordinary_map(manager) end)
                if checked and is_map then
                    local text = current_messages()
                    local shown, error_message = pcall(notify, settings.Enabled and text.on or text.off, manager)
                    if not shown then log('toggle hint failed: ' .. tostring(error_message)) end
                end
            end)
        end)
    else log('invalid ToggleKey; use F1-F24 or None') end
end

log(string.format('loaded: enabled=%s, margin=%d; UE4SS 3.0.1 target', tostring(settings.Enabled), settings.LevelMargin))
