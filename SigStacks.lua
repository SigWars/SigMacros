-- Retorna o número que aparece no canto do ícone do debuff
local function SIG_GetDebuffButtonCount(unit, index)
    local frameName = unit == "target" and "TargetFrameDebuff" or "PlayerFrameDebuff"
    local btn = getglobal(frameName .. index)
    if btn and btn.count and btn.count:IsShown() then
        local text = btn.count:GetText()
        return tonumber(text) or 1
    end
    return 1
end

-- Conta stacks de debuff no alvo por textura
function SIG_GetTargetDebuffStacksByTexture(texturePattern)
    if not UnitExists("target") or not texturePattern then return 0 end
    
    for i = 1, 16 do
        local texture = UnitDebuff("target", i)
        if not texture then break end
        
        if string.find(string.lower(texture), string.lower(texturePattern)) then
            return SIG_GetDebuffButtonCount("target", i)
        end
    end
    return 0
end

-- Função específica para Sunder Armor (mais confiável)
function SIG_GetSunderArmorStacks()
    return SIG_GetTargetDebuffStacksByTexture("Ability_Warrior_Sunder")
end

-- ===== COMANDOS SLASH PARA DEBUG =====
SLASH_SIGSTACKS1 = "/stacks"
function SlashCmdList.SIGSTACKS(msg)
    if not msg then msg = "" end
    msg = string.lower(string.trim(msg))
    
    if msg == "sunder" then
        local stacks = SIG_GetSunderArmorStacks()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Sunder Armor:|r " .. stacks .. " stacks")
    elseif msg == "debug" then
        if not UnitExists("target") then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Nenhum alvo selecionado!|r")
            return
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Debuffs do Alvo ===|r")
        for i = 1, 16 do
            local texture = UnitDebuff("target", i)
            if not texture then break end
            local stacks = SIG_GetDebuffButtonCount("target", i)
            local shortTexture = string.gsub(texture, ".*\\", "") -- só o nome do arquivo
            DEFAULT_CHAT_FRAME:AddMessage(string.format("%d: %s (x%d)", i, shortTexture, stacks))
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00/stacks sunder|r - Mostra stacks de Sunder")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00/stacks debug|r - Lista todos debuffs")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SigStacks|r carregado!")