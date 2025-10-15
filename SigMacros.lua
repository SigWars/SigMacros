-- SigMacros AddOn
-- Autor: Sig  
-- Versão: 1.0

-- Banco de dados para salvar configurações
SigMacrosDB = SigMacrosDB or {}

-- Variáveis globais
local VERSION = "1.0"
local lastAutoAttackTarget = nil

-- ===== COMANDOS SLASH =====
SLASH_SIGMACROS1 = "/sig"
SLASH_SIGMACROS2 = "/sigmacros"

function SlashCmdList.SIGMACROS(msg)
    if not msg then 
        msg = ""
    end
    
    msg = string.lower(msg)
    
    if msg == "" or msg == "help" then
        SIG_ShowHelp()
    elseif msg == "version" then
        print("|cff00ff00SigMacros|r versão " .. VERSION)
    elseif msg == "hunter" then
        SIG_Hunter()
    elseif msg == "autoshot" then
        SIG_AutoShot()
    elseif msg == "raptor" then
        SIG_Raptor()
    elseif msg == "battleshout" then
        SIG_BattleShout()
    elseif msg == "autoattack" then
        SIG_AutoAttack()
    elseif msg == "attack" then
        SIG_Attack()
    elseif msg == "buffs" then
        SIG_Buffs()
    elseif msg == "debuffs" then
        SIG_Debuffs()
    elseif msg == "mybuffs" then
        SIG_MyBuffs()
    else
        print("|cffff0000SigMacros:|r Comando desconhecido '" .. msg .. "'. Use /sig help para ver os comandos disponíveis.")
    end
end

-- Mostrar ajuda
function SIG_ShowHelp()
    print("|cff00ff00=== SigMacros Comandos ===|r")
    print("|cffffff00/sig help|r - Mostra esta ajuda")
    print("|cffffff00/sig version|r - Mostra a versão do AddOn")
    print("|cff00ff00--- Comandos Slash ---")
    print("|cffffff00/sig hunter|r - Rotação completa de Hunter")
    print("|cffffff00/sig autoshot|r - Ativa tiro automático")
    print("|cffffff00/sig raptor|r - Golpe do Raptor se fora de alcance")
    print("|cffffff00/sig battleshout|r - Usa Battle Shout")
    print("|cffffff00/sig autoattack|r - Ativa auto ataque")
    print("|cffffff00/sig attack|r - Verifica e ativa ataque se necessário")
    print("|cffffff00/sig buffs|r - Lista buffs do alvo")
    print("|cffffff00/sig debuffs|r - Lista debuffs do alvo")
    print("|cffffff00/sig mybuffs|r - Lista seus buffs")
    print("|cff00ff00--- Funções para Macros ---")
    print("|cffffff00SIG_Hunter()|r - Use em macros: /script SIG_Hunter()")
    print("|cffffff00SIG_BattleShout()|r - Use em macros: /script SIG_BattleShout()")
    print("|cffffff00SIG_Attack()|r - Use em macros: /script SIG_Attack()")
    print("|cffffff00SIG_Subjugar()|r - Use em macros: /script SIG_Subjugar()")
    print("|cff00ff00SIG_OrcEnrage()|r - Use em macros: /script SIG_OrcEnrage()")
    print("|cffffff00SIG_AutoShot()|r, |cffffff00SIG_Raptor()|r, |cffffff00SIG_AutoAttack()|r")
    print("|cffffff00SIG_Buffs()|r, |cffffff00SIG_Debuffs()|r, |cffffff00SIG_MyBuffs()|r")
    print("|cff00ff00========================|r")
end

-- ===== FUNÇÕES AUXILIARES =====

-- Checa se é imune a Rend
local immuneRendMobs = {}

local rendImmuneFrame = CreateFrame("Frame")
rendImmuneFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
rendImmuneFrame:SetScript("OnEvent", function()
    if arg1 and string.find(arg1, "immune") and UnitName("target") then
        immuneRendMobs[UnitName("target")] = true
    end
end)

function SIG_IsTargetImmuneToRend()
    local name = UnitName("target")
    return name and immuneRendMobs[name]
end

-- Função para verificar múltiplos buffs em uma unidade
function SIG_WarriorDebuffs()
  
    if UnitHealth("target") < 0.3 * UnitHealthMax("target") then
        return 
    end

    if not UnitIsPlayer("target") and SIG_IsTargetImmuneToRend() then
        return -- Não ativa Rend em alvos imunes ou se for player
    end

    local i = 1
    local hasRend = false

    -- Verificar debuffs no alvo
    while UnitDebuff("target", i) do
        local debuffTexture = UnitDebuff("target", i)
        if debuffTexture then
            if string.find(debuffTexture, "Ability_Gouge") then
                hasRend = true
            end
        end
        i = i + 1
    end

    if not hasRend then
        CastSpellByName("Rend")
    end
end

-- ===== FUNÇÕES WARRIOR =====

-- AOE
function SIG_AOE()
    CastSpellByName("Cleave")
    CastSpellByName("Whirlwind")
end

-- Função para Battle Shout
function SIG_BattleShout()
    for i = 1, 30 do
        local buff = UnitBuff("player", i)
        if not buff then
            break
        end
        if string.find(buff, "Ability_Warrior_BattleShout") then
            return -- Já tem o buff
        end
    end
    CastSpellByName("Battle Shout")
end

-- dismount
function SIG_Dismount()
    local i = 0
    local g = GetPlayerBuff
    while not (g(i) == -1) do
        local tex = GetPlayerBuffTexture(g(i))
        if tex and strfind(tex, "Ability_Mount") then
            CancelPlayerBuff(g(i))
            return
        end
        i = i + 1
    end
end

function SIG_ChargeInterceptIntervene()
    -- dismount se estiver montado
    SIG_Dismount()
    
    local g = GetShapeshiftFormInfo
    local c = CastSpellByName

    local inCombat = PlayerFrame.inCombat -- UnitAffectingCombat("player")
    local _, _, bas = g(1)  -- Battle Stance
    local _, _, ber = g(3)  -- Berserker Stance

    if inCombat then
        -- Em combate: garantir Berserker Stance e usar Intercept
        if not ber then
            c("Berserker Stance")
        else
            c("Intercept")
        end
    else
        -- Fora de combate: garantir Battle Stance e usar Charge
        if not bas then
            c("Battle Stance")
        else
            c("Charge")
        end
    end
end

function SIG_BerserkerStance()
    local g = GetShapeshiftFormInfo
    local t, n, ber = g(3)  -- Berserker Stance
    if not ber then
        CastSpellByName("Berserker Stance")
    end
end

function SIG_BattleStance()
    local g = GetShapeshiftFormInfo
    local t, n, bas = g(1)  -- Battle Stance
    if not bas then
        CastSpellByName("Battle Stance")
    end
end

function SIG_DebugActionSlots()
    for slot = 1, 120 do
        local texture = GetActionTexture(slot)
        local name = nil

        -- Procurar no spellbook por um spell com o mesmo ícone
        if texture then
            local i = 1
            while true do
                local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
                if not spellName then break end
                local spellTexture = GetSpellTexture(i, BOOKTYPE_SPELL)
                if spellTexture == texture then
                    name = spellName
                    break
                end
                i = i + 1
            end
        end

        if name then
            DEFAULT_CHAT_FRAME:AddMessage("Slot " .. slot .. ": " .. name)
        elseif texture then
            DEFAULT_CHAT_FRAME:AddMessage("Slot " .. slot .. ": [ícone: " .. texture .. "]")
        end
    end
end

-- ===== FUNÇÕES DE DEBUG =====

-- Função para listar buffs do alvo
function SIG_Buffs()
    local target = "target"
    if UnitExists(target) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Buffs do Alvo ===|r")
        for i = 1, 16 do
            local buff = UnitBuff(target, i)
            if buff then
                DEFAULT_CHAT_FRAME:AddMessage("Buff " .. i .. ": " .. buff)
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Nenhum alvo selecionado!|r")
    end
end

-- Função para listar debuffs do alvo
function SIG_Debuffs()
    local target = "target"
    if UnitExists(target) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Debuffs do Alvo ===|r")
        for i = 1, 16 do
            local debuff = UnitDebuff(target, i)
            if debuff then
                DEFAULT_CHAT_FRAME:AddMessage("Debuff " .. i .. ": " .. debuff)
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Nenhum alvo selecionado!|r")
    end
end

-- Função para listar buffs do player
function SIG_MyBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Meus Buffs ===|r")
    for i = 1, 16 do
        local buff = UnitBuff("player", i)
        if buff then
            DEFAULT_CHAT_FRAME:AddMessage("Buff " .. i .. ": " .. buff)
        end
    end
end

-- Casta Execute
function SIG_Execute()
    local playerrage = UnitMana("player")
    local healthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
    if healthPercent <= 20 and playerrage >= 15 then
        SpellStopCasting()
        CastSpellByName("Execute")
    end
end

function SIG_Overpower()
    if UnitMana("player") >= 5 then
        CastSpellByName("Overpower")
    end
end

-- Função para auto ataque
function SIG_AutoAttack()
    -- Ativa o ataque automático se não estiver ativo
    if GetUnitName("target")==nil then 
        TargetNearestEnemy()
    end

    for z = 1, 172 do
        if IsAttackAction(z) then
            if not IsCurrentAction(z) then
                -- UseAction(z)
                AttackTarget()
            end
        end
    end
end

function SIG_OrcEnrage()
    CastSpellByName("Blood Fury")
    -- CastSpellByName("Death Wish")
    -- CastSpellByName("Berserker Rage")
    CastSpellByName("Bloodrage")
end

function SIG_Tank(Shield)
    if Shield == nil then Shield = false end
    if Shield then
        CastSpellByName("Shield Block")
        CastSpellByName("Revenge")
        CastSpellByName("Heroic Strike")
    else
        local rage = UnitMana("player")
        if rage >= 20 then
            CastSpellByName("Heroic Strike")
        end
        CastSpellByName("Cleave")
        CastSpellByName("Revenge")
        if SIG_HasSpellCooldownPassed("Thunder Clap", 10) then
            CastSpellByName("Thunder Clap")
        end
    end

    -- if SIG_GetTargetDebuffStacksByTexture("Ability_Warrior_Sunder") < 5 then
    --     CastSpellByName("Sunder Armor")
    -- end
end

function SIG_ArmsRotation()
    CastSpellByName("Overpower")
    CastSpellByName("Mortal Strike");
    if not SIG_IsMortalStrikeReady() then
        if st_timer>UnitAttackSpeed("player")*0.9 then 
            CastSpellByName("Slam") 
        end
        CastSpellByName("Heroic Strike");
    end
end

-- ROTAÇÕES --

function SIG_FuryRotation(isPVP)
    -- Cast overpower
    SIG_Overpower()
   
    if isPVP then
        CastSpellByName("Bloodthirst");
        -- CastSpellByName("Whirlwind");
        if not SIG_IsBloodthirstReady() then
            CastSpellByName("Heroic Strike");
        end
    else
        local primarySpells = SIG_IsBloodthirstReady() or SIG_IsWhirlwindReady()
        if not primarySpells then
            if st_timer>UnitAttackSpeed("player")*0.9 then 
                CastSpellByName("Slam") 
            end
            if UnitMana("player")>12 then 
                CastSpellByName("Heroic Strike") 
            end
        else
            -- SpellStopCasting()
            CastSpellByName("Bloodthirst");
            CastSpellByName("Whirlwind");
        end
    end
end

function SIG_CastSlam()
    if SIG_GetMHSwingTime() >= 2.5 then
        CastSpellByName("Slam")
    end
end

function SIG_ArmsPvp(isPVP)
    -- Cast overpower
    SIG_Overpower()
   
    local primarySpells = SIG_IsMortalStrikeReady() or SIG_IsWhirlwindReady()
    if not primarySpells then
        local rage = UnitMana("player");
        if SIG_IsCastingSlam() then
            CastSpellByName("Heroic Strike");
        end
        if not isPVP then
            CastSpellByName("Slam");
            CastSpellByName("Heroic Strike");
        end
        -- SIG_CastSlam()
    else
        -- SpellStopCasting()
        CastSpellByName("Mortal Strike");
        -- CastSpellByName("Whirlwind");
    end
end

function SIG_IsBloodthirstReady()
    local slot = 26 -- slot onde está o Bloodthirst (verifique se está correto)
    if HasAction(slot) then
        local isUsable, notEnoughMana = IsUsableAction(slot)
        local start, duration, enable = GetActionCooldown(slot)
        local isReady = (start == 0 or duration == 0)
        if isReady then
            return isUsable or notEnoughMana
        end
    end
    return false
end

function SIG_IsWhirlwindReady()
    local slot = 25 -- slot onde está o Whirlwind (verifique se está correto)
    if HasAction(slot) then
        local isUsable, notEnoughMana = IsUsableAction(slot)
        local start, duration, enable = GetActionCooldown(slot)
        local isReady = (start == 0 or duration == 0)
        if isReady then
            return isUsable or notEnoughMana
        end
    end
    return false
end

-- Rastreador por eventos (player) e checar Slam
local SIG_CurrentCast = { name=nil, endsAt=0 }
local f = CreateFrame("Frame")
f:RegisterEvent("SPELLCAST_START")
f:RegisterEvent("SPELLCAST_STOP")
f:RegisterEvent("SPELLCAST_FAILED")
f:RegisterEvent("SPELLCAST_INTERRUPTED")
f:RegisterEvent("SPELLCAST_DELAYED")
f:SetScript("OnEvent", function()
    if event == "SPELLCAST_START" then
        SIG_CurrentCast.name = arg1 or ""
        SIG_CurrentCast.endsAt = GetTime() + (arg2 or 0)/1000
    elseif event == "SPELLCAST_DELAYED" then
        SIG_CurrentCast.endsAt = SIG_CurrentCast.endsAt + (arg1 or 0)/1000
    else
        SIG_CurrentCast.name = nil
        SIG_CurrentCast.endsAt = 0
    end
end)

function SIG_IsCastingSlam()
    return SIG_CurrentCast.name == "Slam" and GetTime() < SIG_CurrentCast.endsAt
end

function SIG_IsMortalStrikeReady()
    local slot = 26 -- slot onde está o Mortal Strike (verifique se está correto)
    if HasAction(slot) then
        local isUsable, notEnoughMana = IsUsableAction(slot)
        local start, duration, enable = GetActionCooldown(slot)
        local isReady = (start == 0 or duration == 0)
        return isUsable and isReady
    end
    return false
end

-- ===== INICIALIZAÇÃO =====
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "SigMacros" then
        print("|cff00ff00SigMacros|r v" .. VERSION .. " carregado com sucesso!")
        print("|cff00ff00SigMacros:|r Digite /sig help para ver os comandos.")
        
        -- Inicializar banco de dados se necessário
        if not SigMacrosDB.initialized then
            SigMacrosDB.initialized = true
            SigMacrosDB.settings = {}
            print("|cff00ff00SigMacros:|r Configurações inicializadas.")
        end
    end
end)

