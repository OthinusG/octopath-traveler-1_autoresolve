local english = {
    reward = 'Auto-resolve: EXP +%d  JP +%d  Leaves +%d',
    drops = '  Items x%d',
    on = 'Auto-resolve: ON',
    off = 'Auto-resolve: OFF',
}
local chinese = {
    [7] = {
        reward = '自动结算：EXP +%d  JP +%d  金钱 +%d',
        drops = '  掉落道具 ×%d',
        on = '等级压制：已开启',
        off = '等级压制：已关闭',
    },
    [6] = {
        reward = '自動結算：EXP +%d  JP +%d  金錢 +%d',
        drops = '  掉落道具 ×%d',
        on = '等級壓制：已開啟',
        off = '等級壓制：已關閉',
    },
}
return function(language)
    return chinese[language] or english
end
