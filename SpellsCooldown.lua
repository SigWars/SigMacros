-- ===== SISTEMA DE TIMER DE SPELLS =====
local SIG_SpellTimers = {}

-- Registra quando uma spell foi castada
function SIG_RegisterSpellCast(spellName)
    if not spellName then return end
    SIG_SpellTimers[spellName] = GetTime()
end

-- Checa se passou o tempo especificado desde o último cast
function SIG_HasSpellCooldownPassed(spellName, seconds)
    if not spellName or not seconds then return true end
    
    local lastCast = SIG_SpellTimers[spellName]
    if not lastCast then return true end -- nunca foi castada
    
    local elapsed = GetTime() - lastCast
    return elapsed >= seconds
end

-- Retorna quantos segundos faltam para completar o tempo especificado
function SIG_GetSpellTimeRemaining(spellName, seconds)
    if not spellName or not seconds then return 0 end
    
    local lastCast = SIG_SpellTimers[spellName]
    if not lastCast then return 0 end -- nunca foi castada
    
    local elapsed = GetTime() - lastCast
    local remaining = seconds - elapsed
    return remaining > 0 and remaining or 0
end

-- Limpa o timer de uma spell específica
function SIG_ClearSpellTimer(spellName)
    if spellName then
        SIG_SpellTimers[spellName] = nil
    end
end

-- Registra automaticamente os casts via eventos (adicione após o frame de cast existente, linha ~415)
local spellTimerFrame = CreateFrame("Frame")
spellTimerFrame:RegisterEvent("SPELLCAST_START")
spellTimerFrame:RegisterEvent("SPELLCAST_STOP")
spellTimerFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
spellTimerFrame:SetScript("OnEvent", function()
    if event == "SPELLCAST_START" then
        local spellName = arg1
        if spellName then
            SIG_RegisterSpellCast(spellName)
        end
    elseif event == "SPELLCAST_STOP" then
        -- Spell completada com sucesso, já foi registrada no START
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        -- Captura spells instantâneas via log
        local msg = tostring(arg1 or "")
        local _, _, spellName = string.find(msg, "^Your (.+) ")
        if spellName then
            -- Remove texto extra (hits, crits, etc.)
            spellName = string.gsub(spellName, " hits.*", "")
            spellName = string.gsub(spellName, " crits.*", "")
            SIG_RegisterSpellCast(spellName)
        end
    end
end)