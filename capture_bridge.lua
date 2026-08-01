-- CLIENT-SIDE Lua bridge.
-- Calls screenshot-basic/screencapture's CLIENT export (captures in CEF,
-- returns base64 directly, zero server upload involved).
-- Then sends the base64 to server via TriggerLatentServerEvent.

AddEventHandler('orb-greenscreen:doCapture', function(filename, type)
    print('[orb-greenscreen] Lua capture bridge: ' .. filename)

    exports['screenshot-basic']:requestScreenshot({
        encoding = 'png',
        quality  = 1.0,
    }, function(data)
        print('[orb-greenscreen] Lua capture callback: ' .. tostring(data and #data or 'nil') .. ' bytes')
        if data and #data > 0 then
            TriggerLatentServerEvent('orb-greenscreen:saveCapture', 5000000, filename, type, data)
        end
    end)
end)
