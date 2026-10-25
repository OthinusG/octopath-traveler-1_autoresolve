local root = assert(arg[1], 'project root required')
local script = root .. '/mod/OT1AutoResolve/Scripts/main.lua'
local catalog = dofile(root .. '/mod/OT1AutoResolve/Scripts/catalog.lua')
local names = {
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
local first_group = 'ENG_Mou_Fie_1_1_1_1'

local function fname(value) return {ToString = function() return value end} end
local function object(value)
    value.IsValid = function() return true end
    return value
end

local function fixture(options)
    options = options or {}
    local state = {money = 0, exp = {}, jp = {}, drops = {}, hints = {}, logs = {}, selections = 0, resets = 0, recovered = {}, achievement = {}}
    local config_path = root .. '/mod/OT1AutoResolve/Scripts/../config.ini'
    local files = {[config_path] = options.config or '[AutoResolve]\nEnabled=1\nToggleKey=F6\nLevelMargin=1\nShowUI=1\n'}
    local member = {[names.id] = 1, [names.level] = options.level or 3, [names.exp] = 0, [names.jp] = 0, [names.hp] = options.hp or 100}
    local save = object({PlayerParty = {[names.main] = options.slots or {0}}, PlayerMember = {member}})
    save.AddPlayerMoney = function(_, amount) state.money = state.money + amount end
    local manager = object({
        StepCount = options.step or 4, PrePlayerPos = {X = 0, Y = 0}, DangerLevel = options.danger or 2,
        EncountMode = options.mode or 0, EncountEnable = true, HasActiveEncount = true,
        SingleBattleMode = false, Debug_FixedEncount = false, FirstEncount = true,
        CurrentEncounter = {[names.first] = 1, [names.groups] = {{[names.group_id] = fname(options.group or first_group), [names.appearance] = 100}}},
        GetFullName = function() return 'EncountManagerBP_C Test' end,
    })
    manager.ResetEncountStep = function(self)
        state.resets = state.resets + 1
        if not options.reset_failure then self.StepCount = 300 end
    end
    local libraries = {}
    libraries.LibAccessor_SaveGame = object({GetSaveData = function(_, _, out)
        if not options.missing_save then out.KSSaveGame = save end
    end})
    libraries.LibBattle = object({LotteryEncountData = function(_, _, _, _, out)
        error('UE4SS 3.0.1 cannot pass encounter struct inputs')
    end})
    libraries.LibCharacter = object({
        CheckCharacterSupportAbility = function(_, id, support, _, out)
            if not options.bad_support then out.enable = not not (options.support and options.support[id] and options.support[id][support]) end
        end,
        GetCharacterEquipmentSingle = function(_, id, slot)
            return fname(options.equipment and options.equipment[id] and options.equipment[id][slot] or 'None')
        end,
        AddCharacterExp = function(_, id, amount, _, out)
            state.exp[id] = (state.exp[id] or 0) + amount
            out.LevelUp = options.level_up == true and not state.recovered[id]
            if options.reentrant then state.encounter() end
            if options.toggle_during_award and not state.did_toggle then
                state.did_toggle = true
                state.toggle()
            end
        end,
        FullRecoveryCharacter = not options.missing_recovery and function(_, id)
            assert(state.exp[id] and not state.jp[id], 'recover after EXP and before JP')
            state.recovered[id] = (state.recovered[id] or 0) + 1
        end or nil,
        AddJobPoint = function(_, id, amount) state.jp[id] = (state.jp[id] or 0) + amount end,
    })
    libraries.LibGetParam = object({GetBattleParamToFloat = function(_, name, _, out, maximum, initial, value)
        assert(out == maximum and out == initial and out == value, 'all four native outputs require table arguments')
        if not options.bad_param then
            out.param = ({SUPPORT_PARAM_MERCHANT_001 = 1.1, SUPPORT_PARAM_WEAPON_MASTER_001 = 1.5,
                SUPPORT_PARAM_ASTRONOMY_002 = 1.5})[name:ToString()]
        end
    end})
    libraries.LibAchievement = object({CheckAndSetTotalLeafAchievement = not options.missing_achievement and function(_, amount)
        assert(state.money >= amount, 'achievement after money')
        state.achievement[#state.achievement + 1] = amount
    end or nil})
    libraries.ItemFunction = object({
        GetBackpackItemMax = function(_, _, out) out.Max = options.inventory_max or 99 end,
        GetBackpackItemNum = function(_, _, _, out) out.itemNum = options.inventory_count or 0 end,
        AddBackpackItem = function(_, id, amount, _, out)
        out.Success = not options.inventory_failure
        if out.Success then state.drops[id:ToString()] = amount end
    end})
    libraries.LibUIUtil = object({CommonNotification = function(_, text)
        if options.hint_failure then error('hint unavailable') end
        state.hints[#state.hints + 1] = text
    end})
    libraries.KSGameStatics = object({
        GetBattleMode = function() return options.battle_active or false end,
        GetLanguage = function()
            if options.language_error then error('language unavailable') end
            return options.language == nil and 7 or options.language
        end,
    })
    libraries.EventFunction = object({IsEventPlaying = function() return options.event_active or false end})
    local env = setmetatable({
        FName = fname, FText = function(value) return value end,
        FindFirstOf = function() return options.already_loaded and manager or nil end,
        LoadAsset = function() end, Key = {F6 = 117},
        StaticFindObject = function(path)
            for label, value in pairs(libraries) do
                if path:find('Default__' .. label, 1, true) or path == '/Script/Octopath_Traveler.' .. label then
                    if options.missing_character and label == 'LibCharacter' then return nil end
                    return value
                end
            end
        end,
        RegisterBeginPlayPostHook = function(callback) state.begin = callback end,
        RegisterHook = function(path, callback)
            assert(path:find(':UpdatePlayerStep', 1, true), 'only the movement function may be hooked')
            state.path, state.step_hook = path, callback
            return 1, 2
        end,
        RegisterKeyBind = function(_, callback) state.toggle = callback end,
        ExecuteInGameThread = function(callback) callback() end,
        print = function(text) state.logs[#state.logs + 1] = text end,
        math = setmetatable({random = function() return options.drop_roll or 100 end}, {__index = math}),
        io = {open = function(path, mode)
            if mode == 'r' then
                if not files[path] then return nil end
                return {lines = function() return files[path]:gmatch('[^\r\n]+') end,
                    read = function() return files[path] end, close = function() return true end}
            end
            local buffer = ''
            return {write = function(_, text)
                if options.config_write_failure then return nil, 'disk full' end
                buffer = buffer .. text
                return true
            end, close = function() files[path] = buffer; return true end}
        end},
        os = {remove = function(path) files[path] = nil; return true end,
            rename = function(from, to)
                if not files[from] or files[to] then return nil end
                files[to], files[from] = files[from], nil
                return true
            end},
    }, {__index = _G})
    assert(loadfile(script, 't', env))()
    state.begin({get = function() return manager end})
    assert(state.step_hook, 'movement hook missing')
    state.raw_encounter = function(initial)
        if initial ~= nil then return initial end
        return manager.StepCount <= 0
    end
    state.step = function(updated)
        state.step_hook({get = function() return manager end}, {get = function() return updated ~= false end})
    end
    state.encounter = function()
        state.step()
        manager.StepCount = manager.StepCount - 4
        manager.PrePlayerPos.X = manager.PrePlayerPos.X + 1
        state.step()
        return state.raw_encounter()
    end
    state.manager, state.files, state.config_path, state.save = manager, files, config_path, save
    return state
end

local count = 0
local function test(name, action)
    action()
    count = count + 1
    print('PASS: ' .. name)
end

test('level-up recovers only once after EXP; later non-leveling rewards do not recover', function()
    local s = fixture({level_up = true})
    s.encounter()
    assert(s.recovered[1] == 1 and s.jp[1] > 0)
    s.manager.StepCount = 4
    s.encounter()
    assert(s.recovered[1] == 1)
end)
test('non-leveling rewards do not recover HP or MP', function()
    local s = fixture()
    s.encounter()
    assert(next(s.recovered) == nil and s.exp[1] > 0)
end)
test('missing recovery interface leaves normal battle without awarding rewards', function()
    local s = fixture({missing_recovery = true})
    assert(s.encounter() and s.money == 0 and s.resets == 0 and next(s.exp) == nil)
end)
test('native static support and equipment bonuses add rather than multiply', function()
    local s = fixture({support = {[1] = {[0] = true, [32] = true, [41] = true}},
        equipment = {[1] = {[9] = 'ITM_AC_036', [10] = 'ITM_AC_038'}}})
    s.encounter()
    assert(s.exp[1] == 6 and s.jp[1] == 4 and s.money == 22)
    assert(#s.achievement == 1 and s.achievement[1] == 22)
end)
test('duplicate party support does not stack; equipment contributions do stack', function()
    local s = fixture({slots = {0, 1}, support = {[1] = {[32] = true}, [2] = {[32] = true}},
        equipment = {[1] = {[9] = 'ITM_AC_036'}, [2] = {[9] = 'ITM_AC_036'}}})
    s.save.PlayerMember[2] = {[names.id] = 2, [names.level] = 3, [names.hp] = 100}
    s.encounter()
    assert(s.exp[1] == 7 and s.exp[2] == 7)
end)
test('knocked-out member contributes equipment/support but receives no EXP JP or healing', function()
    local s = fixture({slots = {0, 1}, level_up = true, support = {[2] = {[32] = true}},
        equipment = {[2] = {[9] = 'ITM_AC_036'}}})
    s.save.PlayerMember[2] = {[names.id] = 2, [names.level] = 3, [names.hp] = 0}
    s.encounter()
    assert(s.exp[1] == 6 and s.recovered[1] == 1)
    assert(not s.exp[2] and not s.jp[2] and not s.recovered[2])
end)
test('all knocked-out party leaves normal encounter and no rewards', function()
    local s = fixture({hp = 0})
    assert(s.encounter() and s.money == 0 and #s.achievement == 0)
end)
test('maximum-level member receives JP without EXP or healing', function()
    local s = fixture({level = 99, level_up = true})
    s.encounter()
    assert(not s.exp[1] and s.jp[1] == 2 and not s.recovered[1])
end)
test('modifier and achievement preflight failures do not suppress combat or award anything', function()
    for _, options in ipairs({{bad_support = true}, {bad_param = true, support = {[1] = {[32] = true}}}, {missing_achievement = true}}) do
        local s = fixture(options)
        assert(s.encounter() and s.resets == 0 and s.money == 0 and #s.achievement == 0)
    end
end)

test('threshold equality resolves exactly once and uses native reward functions', function()
    local s = fixture()
    assert(s.encounter() == false)
    assert(s.money == 20 and s.exp[1] == 3 and s.jp[1] == 2)
    assert(s.resets == 1 and not s.manager.FirstEncount)
    s.encounter()
    assert(s.money == 20 and s.resets == 1)
end)
test('first encounter uses the configured one-based group index without calling native struct input', function()
    local s = fixture()
    s.manager.CurrentEncounter[names.groups][2] = {[names.group_id] = fname('ENG_Mou_Fie_1_1_1_2'), [names.appearance] = 0}
    s.manager.CurrentEncounter[names.first] = 2
    s.manager.CurrentEncounter[names.groups][1][names.appearance] = 0
    assert(not s.encounter() and s.money == 40)
end)
test('weighted selection handles zero weights and exact cumulative boundaries', function()
    for _, roll in ipairs({1, 30, 31, 100}) do
        local s = fixture({drop_roll = roll})
        s.manager.FirstEncount = false
        local groups = s.manager.CurrentEncounter[names.groups]
        groups[1][names.appearance] = 0
        groups[2] = {[names.group_id] = fname(first_group), [names.appearance] = 30}
        groups[3] = {[names.group_id] = fname('ENG_Mou_Fie_1_1_1_2'), [names.appearance] = 70}
        assert(not s.encounter() and s.resets == 1)
        assert(s.money == (roll <= 30 and 20 or 40))
    end
end)
test('invalid weights keep ordinary combat when no first encounter override applies', function()
    for _, weight in ipairs({-1, 0, 0.5}) do
        local s = fixture()
        s.manager.FirstEncount = false
        s.manager.CurrentEncounter[names.groups][1][names.appearance] = weight
        assert(s.encounter() and s.money == 0 and s.resets == 0)
    end
end)
test('empty None slots are accepted only with zero appearance weight', function()
    for _, weight in ipairs({0, 1}) do
        local s = fixture()
        s.manager.CurrentEncounter[names.groups][2] = {[names.group_id] = fname('None'), [names.appearance] = weight}
        if weight == 0 then assert(not s.encounter() and s.money == 20)
        else assert(s.encounter() and s.money == 0) end
    end
end)
test('reloading on an existing map installs the same guarded hooks', function()
    local s = fixture({already_loaded = true})
    assert(not s.encounter() and s.resets == 1 and s.money == 20)
end)
test('a retained wipe direction flag does not block an ordinary field', function()
    local s = fixture()
    s.manager.BattleStartWipe = true
    assert(not s.encounter() and s.money == 20)
end)
test('below area threshold leaves the encounter and rewards unchanged', function()
    local s = fixture({level = 2})
    assert(s.encounter() and s.money == 0 and s.selections == 0 and s.resets == 0)
end)
test('enemy level independently prevents resolution', function()
    local group
    for id, members in pairs(catalog.groups) do
        if catalog.enemies[members[1]].level >= 10 then group = id; break end
    end
    assert(group)
    local s = fixture({group = group})
    assert(s.encounter() and s.money == 0 and s.resets == 0)
end)
test('all nonordinary encounter modes remain untouched', function()
    for mode = 1, 3 do
        local s = fixture({mode = mode})
        assert(s.encounter() and s.resets == 0 and s.selections == 0)
    end
end)
test('active battle and story state block resolution even after encounter mode resets', function()
    for _, options in ipairs({{battle_active = true}, {event_active = true}}) do
        local s = fixture(options)
        assert(s.encounter() and s.money == 0 and s.resets == 0 and s.selections == 0)
        s.toggle()
        assert(#s.hints == 0, 'F6 must not display field UI in protected battles or scenes')
    end
end)
test('an encounter decision without a movement callback cannot award or suppress', function()
    local s = fixture()
    s.manager.StepCount = 0
    assert(s.raw_encounter() and s.money == 0 and s.resets == 0)
end)
test('a true update without recorded movement cannot award', function()
    local s = fixture()
    s.step()
    s.manager.StepCount = 0
    s.step()
    s.step()
    assert(s.raw_encounter() and s.money == 0 and s.resets == 0)
end)
test('a first observation of expired steps cannot award', function()
    local s = fixture({step = 0})
    s.step()
    assert(s.raw_encounter() and s.money == 0)
end)
test('a failed update invalidates previous movement evidence', function()
    local s = fixture()
    s.step()
    s.step(false)
    s.manager.StepCount, s.manager.PrePlayerPos.X = 0, 10
    s.step()
    assert(s.raw_encounter() and s.money == 0 and s.resets == 0)
end)
test('switching to an event before the movement callback preserves normal combat', function()
    local s = fixture()
    s.step()
    s.manager.EncountMode = 1
    assert(s.encounter() and s.money == 0 and s.resets == 0)
end)
test('a different actor cannot reuse movement observations', function()
    local s = fixture()
    s.step()
    local other = object({StepCount = 0, PrePlayerPos = {X = 10, Y = 0}, GetFullName = function() return 'EncountManagerBP_C Other' end})
    s.step_hook({get = function() return other end}, {get = function() return true end})
    assert(s.money == 0 and s.resets == 0)
end)
test('boss and unknown groups remain untouched', function()
    for _, group in ipairs({'ENG_BOS_Olb_001', 'unknown'}) do
        local s = fixture({group = group})
        assert(s.encounter() and s.resets == 0 and s.money == 0)
    end
end)
test('inactive, disabled, fixed and single-character battles remain untouched', function()
    for key, value in pairs({HasActiveEncount = false, EncountEnable = false, Debug_FixedEncount = true, SingleBattleMode = true}) do
        local s = fixture()
        s.manager[key] = value
        assert(s.encounter() and s.money == 0)
    end
end)
test('invalid or duplicate party slots leave normal combat', function()
    for _, slots in ipairs({{1}, {-1}, {0, 0}}) do
        local s = fixture({slots = slots})
        assert(s.encounter() and s.money == 0)
    end
end)
test('empty -1 slots do not disable a valid partial party', function()
    for _, slots in ipairs({{0, -1, -1, -1}, {-1, 0, -1, -1}}) do
        local s = fixture({slots = slots})
        assert(not s.encounter() and s.money == 20 and s.exp[1] == 3)
    end
end)
test('missing active save disables without suppressing combat', function()
    local s = fixture({missing_save = true})
    assert(s.encounter() and s.resets == 0 and s.money == 0)
    assert(s.encounter() and s.money == 0)
end)
test('missing reward interface is detected before suppression', function()
    local s = fixture({missing_character = true})
    assert(s.encounter() and s.resets == 0 and s.money == 0)
end)
test('failed step reset awards nothing and disables retries', function()
    local s = fixture({reset_failure = true})
    assert(s.encounter() and s.money == 0)
    assert(s.encounter() and s.resets == 1)
end)
test('partial reward failure disables without duplicate awards', function()
    local s = fixture({drop_roll = 1, inventory_failure = true})
    assert(not s.encounter() and s.money == 20)
    s.manager.StepCount = 0
    assert(s.encounter() and s.money == 20)
end)
test('a full inventory does not reject otherwise valid battle rewards', function()
    local s = fixture({drop_roll = 1, inventory_count = 99, inventory_failure = true})
    assert(not s.encounter() and s.money == 20 and s.exp[1] == 3 and s.jp[1] == 2)
    assert(next(s.drops) == nil)
end)
test('drops are limited to the available native inventory capacity', function()
    local s = fixture({group = 'ENG_Mou_Fie_1_1_1_2', drop_roll = 1, inventory_count = 98})
    assert(not s.encounter() and s.money == 40 and s.drops.ITM_078 == 1)
end)
test('successful drops show their quantity without additional text-object construction', function()
    local s = fixture({drop_roll = 1})
    assert(not s.encounter())
    assert(s.drops.ITM_078 == 1)
    assert(s.hints[1]:find('EXP +3', 1, true) and s.hints[1]:find('掉落道具 ×1', 1, true))
end)
test('hint failure does not duplicate or disable successful rewards', function()
    local s = fixture({hint_failure = true})
    assert(not s.encounter() and s.money == 20)
    s.manager.StepCount = 4
    assert(not s.encounter() and s.money == 40)
end)
test('reentrant callbacks cannot award twice', function()
    local s = fixture({reentrant = true})
    assert(not s.encounter() and s.money == 20 and s.resets == 1 and s.exp[1] == 3)
end)
test('toggling F6 during a reward completes it once and clears movement safely', function()
    local s = fixture({toggle_during_award = true})
    assert(not s.encounter() and s.money == 20 and s.exp[1] == 3 and s.jp[1] == 2)
    assert(s.files[s.config_path]:find('Enabled=0', 1, true))
    s.manager.StepCount = 4
    assert(s.encounter() and s.money == 20)
end)
test('F6 toggles disabled state and persists both directions', function()
    local s = fixture({config = '[AutoResolve]\nEnabled=0\nToggleKey=F6\nLevelMargin=1\nShowUI=1\n'})
    assert(s.encounter() and s.money == 0)
    s.toggle()
    assert(s.files[s.config_path]:find('Enabled=1', 1, true))
    assert(not s.encounter() and s.money == 20)
    s.toggle()
    assert(s.files[s.config_path]:find('Enabled=0', 1, true))
end)
test('failed config write preserves the original file', function()
    local s = fixture({config_write_failure = true})
    local before = s.files[s.config_path]
    s.toggle()
    assert(s.files[s.config_path] == before)
end)
test('ShowUI=0 still awards rewards', function()
    local s = fixture({config = '[AutoResolve]\nEnabled=1\nToggleKey=F6\nLevelMargin=1\nShowUI=0\n'})
    assert(not s.encounter() and s.money == 20 and #s.hints == 0)
end)
test('negative and invalid margins fall back to one', function()
    for _, value in ipairs({'-1', '1.5', 'invalid'}) do
        local s = fixture({level = 2, config = '[AutoResolve]\nEnabled=1\nLevelMargin=' .. value .. '\n'})
        assert(s.encounter() and s.money == 0)
    end
end)
test('all non-Chinese language IDs use English reward and toggle notices', function()
    for _, language in ipairs({0, 1, 2, 3, 4, 5, 8, 9, -1, 255}) do
        local s = fixture({language = language, drop_roll = 1})
        assert(not s.encounter())
        assert(s.hints[1] == 'Auto-resolve: EXP +3  JP +2  Leaves +20  Items x1')
        s.toggle()
        assert(s.hints[#s.hints] == 'Auto-resolve: OFF')
        s.toggle()
        assert(s.hints[#s.hints] == 'Auto-resolve: ON')
    end
end)
test('simplified and traditional Chinese notices follow text language', function()
    for _, variant in ipairs({{7, '自动结算', '等级压制：已关闭'}, {6, '自動結算', '等級壓制：已關閉'}}) do
        local s = fixture({language = variant[1]})
        assert(not s.encounter() and s.hints[1]:find(variant[2], 1, true))
        s.toggle()
        assert(s.hints[#s.hints] == variant[3])
    end
end)
test('language lookup failure falls back to English without affecting rewards', function()
    local s = fixture({language_error = true, drop_roll = 1})
    assert(not s.encounter() and s.money == 20)
    assert(s.hints[1] == 'Auto-resolve: EXP +3  JP +2  Leaves +20  Items x1')
end)
test('changing the language uses fresh text for the next notification', function()
    local options = {language = 7}
    local s = fixture(options)
    assert(not s.encounter() and s.hints[1]:find('自动结算', 1, true))
    options.language = 0
    s.manager.StepCount = 4
    assert(not s.encounter() and s.hints[2]:find('Auto-resolve:', 1, true))
end)
test('catalog references valid ordinary-group enemies and item labels', function()
    for _, members in pairs(catalog.groups) do
        assert(#members > 0)
        for _, id in ipairs(members) do
            local enemy = assert(catalog.enemies[id])
            assert(id:match('^ENE_') and enemy.level >= 1 and enemy.level <= 99)
            if enemy.item then assert(enemy.item:match('^ITM_')) end
        end
    end
end)
print(string.format('%d tests passed; these mock tests do not establish in-game compatibility.', count))
