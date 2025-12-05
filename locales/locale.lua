Locale = {}
local rawLocale = GetConvar('qb_locale', GetConvar('locale', 'en'))
Locale.CurrentLocale = string.match(rawLocale, '^([a-z]+)') or rawLocale
Locale.Fallback = 'en'
Locale.Translations = {}

function Locale.RegisterLocale(locale, translations)
    Locale.Translations[locale] = translations
end

function _L(key, ...)
    local locale = Locale.CurrentLocale
    local translations = Locale.Translations[locale]
    if not translations then translations = Locale.Translations[Locale.Fallback] end
    local translation = translations and translations[key]
    if not translation and locale ~= Locale.Fallback then
        local fallbackTranslations = Locale.Translations[Locale.Fallback]
        translation = fallbackTranslations and fallbackTranslations[key]
    end
    if not translation then return key end
    if ... then return string.format(translation, ...) end
    return translation
end

CreateThread(function()
    Wait(1000)
    print('^2[mriprops_weed]^7 Locale set to: ^3' .. Locale.CurrentLocale .. '^7')
end)
