-- ═══════════════════════════════════════════════════════════════════════
--   orb-greenscreen — /screenshots selective capture menu (ox_lib)
-- ═══════════════════════════════════════════════════════════════════════
-- One command opens a context menu so operators capture exactly what they
-- need (everything / components / props / hair / per-category / per-gender)
-- instead of running the broad /screenshot* commands and waiting on images
-- they will never use. The menu hands client.js a serialisable spec which it
-- turns into a capture filter (see the 'orb-greenscreen:runBatch' handler).

-- Clothing component ids (must match config.json cameraSettings.CLOTHING).
local CLOTHING = {
    { id = 11, label = 'Tops' },
    { id = 3,  label = 'Torsos / Arms' },
    { id = 8,  label = 'Undershirts' },
    { id = 4,  label = 'Legs (Pants)' },
    { id = 6,  label = 'Shoes' },
    { id = 5,  label = 'Bags' },
    { id = 1,  label = 'Masks' },
    { id = 9,  label = 'Body Armor' },
    { id = 7,  label = 'Accessories (comp 7)' },
    { id = 2,  label = 'Hair' },
}

-- Prop ids (must match config.json cameraSettings.PROPS).
local PROPS = {
    { id = 0, label = 'Hats' },
    { id = 1, label = 'Glasses' },
    { id = 2, label = 'Earrings' },
    { id = 6, label = 'Watches' },
    { id = 7, label = 'Bracelets' },
}

local includeTextures = false

local function run(spec)
    spec.includeTextures = includeTextures
    TriggerEvent('orb-greenscreen:runBatch', spec)
end

local function buildComponents()
    local options = {
        { title = 'All components (M + F)', icon = 'shirt',
          onSelect = function() run({ genders = { 'male', 'female' }, clothing = 'all' }) end },
    }
    for _, c in ipairs(CLOTHING) do
        options[#options + 1] = {
            title = c.label,
            description = ('Component %d — male + female'):format(c.id),
            onSelect = function() run({ genders = { 'male', 'female' }, clothing = { c.id } }) end,
        }
    end
    lib.registerContext({ id = 'gs_components', title = 'Components', menu = 'gs_main', options = options })
end

local function buildProps()
    local options = {
        { title = 'All props (M + F)', icon = 'glasses',
          onSelect = function() run({ genders = { 'male', 'female' }, props = 'all' }) end },
    }
    for _, p in ipairs(PROPS) do
        options[#options + 1] = {
            title = p.label,
            description = ('Prop %d — male + female'):format(p.id),
            onSelect = function() run({ genders = { 'male', 'female' }, props = { p.id } }) end,
        }
    end
    lib.registerContext({ id = 'gs_props', title = 'Props', menu = 'gs_main', options = options })
end

local function buildGender()
    lib.registerContext({ id = 'gs_gender', title = 'By gender', menu = 'gs_main', options = {
        { title = 'Everything — Male',   icon = 'person',
          onSelect = function() run({ genders = { 'male' },   clothing = 'all', props = 'all' }) end },
        { title = 'Everything — Female', icon = 'person-dress',
          onSelect = function() run({ genders = { 'female' }, clothing = 'all', props = 'all' }) end },
    }})
end

local buildMain  -- forward declaration (texture toggle re-renders the main menu)
buildMain = function()
    lib.registerContext({ id = 'gs_main', title = 'ORB Greenscreen', options = {
        { title = 'Capture EVERYTHING', description = 'All components + props · male + female', icon = 'camera',
          onSelect = function() run({ genders = { 'male', 'female' }, clothing = 'all', props = 'all' }) end },
        { title = 'Components only', description = 'Pick clothing components', menu = 'gs_components', arrow = true },
        { title = 'Props only', description = 'Pick props (hats, glasses, watches...)', menu = 'gs_props', arrow = true },
        { title = 'Hair only', description = 'Component 2 — male + female', icon = 'scissors',
          onSelect = function() run({ genders = { 'male', 'female' }, clothing = { 2 } }) end },
        { title = 'By gender', description = 'Capture everything for one gender', menu = 'gs_gender', arrow = true },
        { title = ('Textures: %s'):format(includeTextures and 'ON' or 'OFF'),
          description = 'Also capture every texture variation (much slower)',
          icon = includeTextures and 'toggle-on' or 'toggle-off',
          onSelect = function()
              includeTextures = not includeTextures
              buildMain()
              lib.showContext('gs_main')
          end },
    }})
end

RegisterCommand('screenshots', function()
    buildComponents()
    buildProps()
    buildGender()
    buildMain()
    lib.showContext('gs_main')
end, false)

TriggerEvent('chat:addSuggestion', '/screenshots', 'Open the orb-greenscreen capture menu (selective)')
