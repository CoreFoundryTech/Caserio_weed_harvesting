Locale = {}

-- Get locale from server config, default to Spanish
local rawLocale = GetConvar('qb_locale', GetConvar('locale', 'es'))
Locale.CurrentLocale = string.match(rawLocale, '^([a-z]+)') or 'es'
Locale.Fallback = 'es' -- Changed fallback to Spanish
Locale.Translations = {}

function Locale.RegisterLocale(locale, translations)
    Locale.Translations[locale] = translations
end

function _L(key, ...)
    local locale = Locale.CurrentLocale
    local translations = Locale.Translations[locale]
    
    -- Try current locale
    if translations and translations[key] then
        if ... then 
            return string.format(translations[key], ...) 
        end
        return translations[key]
    end
    
    -- Try fallback
    local fallback = Locale.Translations[Locale.Fallback]
    if fallback and fallback[key] then
        if ... then 
            return string.format(fallback[key], ...) 
        end
        return fallback[key]
    end
    
    -- Return key if nothing found
    return key
end

CreateThread(function()
    Wait(500)
    print('^2[Caserio Weed]^7 Locale: ^3' .. Locale.CurrentLocale .. '^7 | Translations loaded: ^3' .. (Locale.Translations['es'] and 'ES' or 'NO') .. '^7')
end)
