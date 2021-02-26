-- Main ----------------------------------------------------------
local OneSignal = require("plugin.OneSignal")
local composer = require("composer")
local json = require("json")
local myData = require("mydata")
local loadsave = require( "loadsave" )
local lfs = require( "lfs" )
display.setStatusBar( display.HiddenStatusBar )

----------------TEST PUSH NOTIFICATION WITH OneSignal----------------------------
-- This function gets called when the user opens a notification or one is received when the app is open and active.
-- Change the code below to fit your app's needs.
function DidReceiveRemoteNotification(message, additionalData, isActive)
end

-- Memory Check for Memory Leaks
-- local function checkMem()
--    collectgarbage("collect")
--    local memUsage_str = string.format( "MEMORY= %.3f KB", collectgarbage( "count" ) )
--    print( memUsage_str .. " | TEXTURE= "..(system.getInfo("textureMemoryUsed")/1048576) )
-- end
-- timer.performWithDelay( 1000, checkMem, 0 )

--GitHub Note: OneSignal is used for Push notifications - https://documentation.onesignal.com/docs/corona-sdk
local function onSystemEvent( event )
    if event.type == "applicationStart" then
    --GitHub Note: Here you have to put your OneSignal appId and googleProjectNumber:
    OneSignal.Init("XXX", "XXX", DidReceiveRemoteNotification)
    OneSignal.EnableInAppAlertNotification(true)
    OneSignal.EnableNotificationsWhenActive(true)
    OneSignal.SendTag("ChatActive", "true")
    OneSignal.SendTag("version", "v1.1.2")
    elseif event.type == "applicationExit" then
    --this block executed just prior to the app quitting
    --OS closes least recently used app, user explicitly quits, etc.
    OneSignal.SendTag("ChatActive", "false")
    elseif event.type == "applicationSuspend" then
    --this block executed when app goes into “suspend” state
    --e.g. user receives phone call, presses home button, etc.
    OneSignal.SendTag("ChatActive", "false")
    elseif event.type == "applicationResume" then
    --this block executed when app resumes from “suspend” state
    --e.g. user goes back into app (while it is still running in bg)
    OneSignal.SendTag("ChatActive", "true")
    end
end
Runtime:addEventListener( "system", onSystemEvent )

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function skinNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occurred...Err: 1", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            skinColor="green"
        else
            skinColor=t.skin
            --skinColor="aqua"
        end
        applySkin(skinColor)
        composer.gotoScene("homeScene")
    end
end

local function renewSucceeded(token)
    --local alert = native.showAlert( "EliteHax", "Logged In!!\nID: "..player_id, { "Close" }, onClose )
    local loginStatus = {
        token = token
    }
    loadsave.saveTable( loginStatus, "loginStatus.json" )
    --GetSkin
    loginInfo = localToken()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getSkin.php", "POST", skinNetworkListener, params )
end

local function renewListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occurred... Err: 2", { "Close" }, onAlert )
    else
        print ( "RESPONSE TOKEN: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            composer.gotoScene("loginScene")
        elseif (t.BAN) then
            local alert = native.showAlert( "EliteHax", "You have been banned from EliteHax.\nReason: "..t.reason.."\nIf you have any question, please contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.ANON) then
            local alert = native.showAlert( "EliteHax", "You cannot login to EliteHax with an anonymous connection.\nIf you need to use a proxy please contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.status == "OK") then
            renewSucceeded(t.token)
        end
    end
end

local function appPackageCheck(event)
    if  system.getInfo("platformName")=="Android" then
        print("Package: "..system.getInfo("androidAppPackageName"))
        if (system.getInfo("androidAppPackageName") ~= "it.EliteHax") then
            native.requestExit()
        end
    end
end

local function checkCertificate(event)
    if ((cert == nil) and (retries<10)) then
        retries=retries+1
        cert = conn:getpeercertificate()
        timer.performWithDelay(500,checkCertificate)
    else
        local sha512 = cert:digest("sha512")
        print("SHA: "..sha512)
        conn:close()

        checkCert=false
        for k, v in pairs(cert:issuer()) do
          for i, j in pairs(v) do
            print(i, j)
            if (j=="COMODO ECC Domain Validation Secure Server CA 2") then 
                checkCert=true
            elseif (j=="Encryption Everywhere DV TLS CA - G1") then
                checkCert=true
            end
          end
        end
        if (checkCert==false) then 
            if (system.getInfo("platformName")=="Android") then
                native.requestExit()
            else
                os.exit() 
            end
        end
        if ((sha512 ~= "962ab5d31cbc60c3b4420df76eaaae2c5861232bc12831fd1c06e071738e8cdc21f4491baf44e42a9df3fd35b7948f44e434ffb9fbd30b1f71d36ac42f131d47") and (sha512 ~= "11a8dafe019caa5573bc1437cf63901c971d50273c0cda785585cafd2e0d88d51f3c476e9d1b6ca56dcab60226dc39cadcad1dc67dc19a55d3ea67cdcfd2aa3a")) then
            if (system.getInfo("platformName")=="Android") then
                native.requestExit()
            else
                os.exit() 
            end
        end
    end
end

local function downloadUpdateClose(event)
    system.openURL( "https://play.google.com/store/apps/details?id=it.EliteHax" )
    if  system.getInfo("platformName")=="Android" then
        native.requestExit()
    else
        os.exit() 
    end
end

local function downloadUpdate(event)
    local i = event.index
    if ( i == 1 ) then
        system.openURL( "https://play.google.com/store/apps/details?id=it.EliteHax" )
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    elseif ( i == 2 ) then
        --Nothing
    end
end

local function checkSystemListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occurred... Please retry with a stable internet connection.\nIf the issue persists, please contact support@elitehax.it", { "Close" }, onAlert )
    else
        print ( "RESPONSE TOKEN: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        local now = os.time()
        local diff= os.difftime(now, os.time(os.date("!*t", now)))/3600
        local lang = system.getPreference( "ui", "language" )
        local country = system.getPreference( "locale", "country" ) 
        local jsonRequest = {["tz"] = diff, ["lang"] = lang, ["country"] = country}
        jsonRequest = base64Encode(json.encode(jsonRequest))

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. An error occurred...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.status == "OK") then
            --Retrieve Login Info
            loginInfo = loadsave.loadTable( "loginStatus.json" )
            system.setTapDelay( 1 )
            if (loginInfo == nil) then 
                composer.gotoScene("loginScene")
            else
                local headers = {}
                local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&id="..string.urlEncode(loginInfo.token).."&env="..string.urlEncode(jsonRequest)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."renewToken.php", "POST", renewListener, params )
            end
        elseif (t.status == "US") then
            --Retrieve Login Info
            local alert = native.showAlert( "EliteHax", "A new EliteHax update is available on Google Play Store!", { "Download", "Skip" }, downloadUpdate )
            loginInfo = loadsave.loadTable( "loginStatus.json" )
            system.setTapDelay( 1 )
            if (loginInfo == nil) then 
                composer.gotoScene("loginScene")
            else
                local headers = {}
                local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&id="..string.urlEncode(loginInfo.token).."&env="..string.urlEncode(jsonRequest)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."renewToken.php", "POST", renewListener, params )
            end
        elseif (t.status == "UR") then
            --Retrieve Login Info
            local alert = native.showAlert( "EliteHax", "A new EliteHax update is required to continue.", { "Download" }, downloadUpdateClose )
        elseif (t.status == "CM") then
            --Retrieve Login Info
            if (t.login=="Y") then
                local alert = native.showAlert( "EliteHax", t.message, { "Close" } )
                loginInfo = loadsave.loadTable( "loginStatus.json" )
                system.setTapDelay( 1 )
                if (loginInfo == nil) then 
                    composer.gotoScene("loginScene")
                else
                    local headers = {}
                    local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&id="..string.urlEncode(loginInfo.token).."&env="..string.urlEncode(jsonRequest)
                    local params = {}
                    params.headers = headers
                    params.body = body
                    network.request( host().."renewToken.php", "POST", renewListener, params )
                end
            else
                local alert = native.showAlert( "EliteHax", t.message, { "Close" }, onAlert )
            end
        end
    end
end

--Certificate Pinning!
local socket = require("socket")
local ssl    = require("plugin.openssl")
local plugin_luasec_ssl = require('plugin_luasec_ssl')
local params = {
  mode = "client",
  protocol = "tlsv1_2",
  verify = "none",
  options = "single_ecdh_use",
}
conn = socket.tcp()
conn:settimeout(3000)
conn:connect("app.elitehax.it", 443)
conn = plugin_luasec_ssl.wrap(conn, params)
conn:sni("app.elitehax.it")
conn:dohandshake()
conn:send("GET / HTTP/1.1\nHost: www.elitehax.it\nUser-Agent: EliteHax 3.0.7\nAccept: */*\n\n")
retries=0
cert = conn:getpeercertificate()
local line, err = conn:receive()
--GitHub Note: here you can enable/disable Certificate Pinning - to mitigate MITM
--timer.performWithDelay(200,checkCertificate)

--App Package Name Check!
appPackageCheck()

--Local Notification
localNotification = loadsave.loadTable( "localNotification.json" )
if (localNotification == nil) then 
    taskNotificationActive=true
    researchNotificationActive=true
    local notificationStatus = {
        taskActive = true,
        researchActive = true
    }
    loadsave.saveTable( notificationStatus, "localNotification.json" )
else
    if (localNotification.taskActive==false) then
        taskNotificationActive = localNotification.taskActive
    else
        taskNotificationActive = true
    end
    if (localNotification.researchActive==false) then
        researchNotificationActive = localNotification.researchActive
    else
        researchNotificationActive = true
    end
end

--Local Music
localMusic = loadsave.loadTable( "localMusic.json" )
if (localMusic == nil) then 
    musicActive=true
    local musicStatus = {
        active = true
    }
    loadsave.saveTable( musicStatus, "localMusic.json" )
else
    musicActive = localMusic.active
end

--Local Sound Effects
localSfx = loadsave.loadTable( "localSfx.json" )
if (localSfx == nil) then 
    sfxActive=true
    local sfxStatus = {
        active = true
    }
    loadsave.saveTable( sfxStatus, "localSfx.json" )
else
    sfxActive = localSfx.active
end

notificationActive = loadsave.loadTable( "localNotificationStatus.json" )
if (notificationActive == nil) then
    notificationActive = {
        task = nil,
        taskTime = 0,
        research = nil,
        researchTime = 0
    }
end

--Random Init
math.randomseed(os.time())
math.random() math.random() math.random()

mclickSound = audio.loadSound( "audio/UI_Quirky7.mp3" )
mbackSound = audio.loadSound( "audio/UI_Quirky8.mp3" )
mrewardSound = audio.loadSound( "audio/PowerUp17.mp3" )
mwin = audio.loadSound("audio/SynthChime2.mp3")
mlose = audio.loadSound("audio/Creepy4.mp3")
mtarget = audio.loadSound("audio/Creepy-Roll-Over-1.mp3")

function tapSound(event)
    if (sfxActive==true) then
        audio.play(mclickSound)
    end
end

function backSound(event)
    if (sfxActive==true) then
        audio.play(mbackSound)
    end
end

function rewardSound(event)
    if (sfxActive==true) then
        audio.play(mrewardSound)
    end
end

function winSound(event)
    if (sfxActive==true) then
        audio.play(mwin)
    end
end

function loseSound(event)
    if (sfxActive==true) then
        audio.play(mlose)
    end
end

function targetSound(event)
    if (sfxActive==true) then
        if (targetAudio==true) then
            audio.play(mtarget)
            targetAudio=false
        end
    end
end

function backgroundLoginSound(event)
    if (musicActive==true) then
        if (backgroundMusicChannel) then
            audio.stop(backgroundMusicChannel)
            audio.dispose(backgroundMusicChannel)
        end
        backgroundMusic = audio.loadStream( "audio/Dystopic-Technology_Looping.mp3" )
        backgroundMusicChannel2 = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=1000 } )
    end
end

function backgroundSound(event)
    if (musicActive==true) then
        if (backgroundMusicChannel2) then
            audio.stop(backgroundMusicChannel2)
            audio.dispose(backgroundMusicChannel2)
        end
        if (backgroundMusicChannel==nil) then
            backgroundMusic = audio.loadStream( "audio/Cyber-REM_Looping.mp3" )
            backgroundMusicChannel = audio.play( backgroundMusic, { loops=-1, fadein=1000 } )
        end
    else
        if (backgroundMusicChannel) then
            audio.stop()
            audio.dispose(backgroundMusicChannel)
        end
    end
end

local headers = {}
local body = ""
local params = {}
params.headers = headers
params.body = body
network.request( host().."checkSystem.php", "POST", checkSystemListener, params )

