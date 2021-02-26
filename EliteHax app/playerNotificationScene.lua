local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local OneSignal = require("plugin.OneSignal")
local playerNotificationScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function goBackPlayerNotifications( event )
    if (tutOverlay==false) then
        if (skinOverlay==true) then
            backSound()
            composer.hideOverlay( "fade", 0 )
            skinOverlay=false
        else
            backSound()
            composer.removeScene( "playerNotificationScene" )
            composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackPN( event )
    if (event.phase=="ended") then
        if (tutOverlay==false) then
            if (skinOverlay==true) then
                backSound()
                composer.hideOverlay( "fade", 0 )
                skinOverlay=false
            else
                backSound()
                composer.removeScene( "playerNotificationScene" )
                composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
            end
        end
    end
end

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function getTournamentStatus(tags)
   for key,value in pairs(tags) do
      if (key=="TournamentNotification") then
            tournamentNotification=value
            if (value=="true") then
                tapSound()
                myData.tournamentNotificationBtn:setLabel("Tournament Notifications: ON")
            else
                backSound()
                myData.tournamentNotificationBtn:setLabel("Tournament Notifications: OFF")
            end
      end
   end
end

local function playerNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        end

        --Money
        myData.moneyTextPlayerS.text = format_thousand(t.money)
        myData.moneyTextPlayerS.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextPlayerS.size = fontSize(42) end
        myData.playerTextPlayerS.text = t.username

        OneSignal.GetTags(getTournamentStatus)

        if (taskNotificationActive==false) then
            myData.taskNotificationBtn:setLabel("Tasks Notifications: OFF")
        end

        if (researchNotificationActive==false) then
            myData.researchNotificationBtn:setLabel("Research Notifications: OFF")
        end

        if (musicActive==false) then
            myData.musicBtn:setLabel("Background Music: OFF")
        end

        if (sfxActive==false) then
            myData.sfxBtn:setLabel("Sound Effects: OFF")
        end

        loaded=true

    end
end

local function toggleTournamentNotification( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (tournamentNotification=="true") then
            backSound()
            OneSignal.SendTag("TournamentNotification", "false")   
            myData.tournamentNotificationBtn:setLabel("Tournament Notifications: OFF")
            tournamentNotification="false"
        else
            tapSound()
            OneSignal.SendTag("TournamentNotification", "true")   
            myData.tournamentNotificationBtn:setLabel("Tournament Notifications: ON")
            tournamentNotification="true"
        end
    end
end

local function toggleTaskNotification( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (taskNotificationActive==true) then
            backSound()
            myData.taskNotificationBtn:setLabel("Tasks Notifications: OFF")
            taskNotificationActive=false
            local notificationStatus = {
                taskActive = false,
                researchActive = researchNotificationActive
            }
            loadsave.saveTable( notificationStatus, "localNotification.json" )
        else
            tapSound()
            myData.taskNotificationBtn:setLabel("Tasks Notifications: ON")
            taskNotificationActive=true
            local notificationStatus = {
                taskActive = true,
                researchActive = researchNotificationActive
            }
            loadsave.saveTable( notificationStatus, "localNotification.json" )
        end
    end
end

local function toggleResearchNotification( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (researchNotificationActive==true) then
            backSound()
            myData.researchNotificationBtn:setLabel("Research Notifications: OFF")
            researchNotificationActive=false
            local notificationStatus = {
                taskActive = taskNotificationActive,
                researchActive = false
            }
            loadsave.saveTable( notificationStatus, "localNotification.json" )
        else
            tapSound()
            myData.researchNotificationBtn:setLabel("Research Notifications: ON")
            researchNotificationActive=true
            local notificationStatus = {
                taskActive = taskNotificationActive,
                researchActive = true
            }
            loadsave.saveTable( notificationStatus, "localNotification.json" )
        end
    end
end

local function toggleMusic( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (musicActive==true) then
            backSound()
            myData.musicBtn:setLabel("Background Music: OFF")
            musicActive=false
            local musicStatus = {
                active = false
            }
            loadsave.saveTable( musicStatus, "localMusic.json" )
        else
            tapSound()
            myData.musicBtn:setLabel("Background Music: ON")
            musicActive=true
            local musicStatus = {
                active = true
            }
            loadsave.saveTable( musicStatus, "localMusic.json" )
        end
        backgroundSound()
    end
end

local function toggleSfx( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (sfxActive==true) then
            myData.sfxBtn:setLabel("Sound Effects: OFF")
            sfxActive=false
            local sfxStatus = {
                active = false
            }
            loadsave.saveTable( sfxStatus, "localSfx.json" )
        else
            myData.sfxBtn:setLabel("Sound Effects: ON")
            sfxActive=true
            local sfxStatus = {
                active = true
            }
            loadsave.saveTable( sfxStatus, "localSfx.json" )
            tapSound()
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function playerNotificationScene:create(event)
    group = self.view

    loginInfo = localToken()

    currentWallet = 2
    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextPlayerS = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextPlayerS.anchorX = 0
    myData.moneyTextPlayerS.anchorY = 0.5
    myData.moneyTextPlayerS:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextPlayerS = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextPlayerS.anchorX = 0.5
    myData.playerTextPlayerS.anchorY = 0.5
    myData.playerTextPlayerS:setFillColor( 0.9,0.9,0.9 )

    --Player Setting Rect
    myData.playerSRect = display.newImageRect( "img/player_setting_rect.png",display.contentWidth-20, fontSize(1680))
    myData.playerSRect.anchorX = 0.5
    myData.playerSRect.anchorY = 0
    myData.playerSRect.x, myData.playerSRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.playerSRect)

    myData.tournamentNotificationBtn = widget.newButton(
    {
        left = 60,
        top = myData.playerSRect.y+fontSize(120),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Tournament Notifications: ON",
        labelColor = tableColor1,
        onEvent = toggleTournamentNotification
    })

    myData.taskNotificationBtn = widget.newButton(
    {
        left = 60,
        top = myData.tournamentNotificationBtn.y+myData.tournamentNotificationBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Tasks Notifications: ON",
        labelColor = tableColor1,
        onEvent = toggleTaskNotification
    })

    myData.researchNotificationBtn = widget.newButton(
    {
        left = 60,
        top = myData.taskNotificationBtn.y+myData.taskNotificationBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Research Notifications: ON",
        labelColor = tableColor1,
        onEvent = toggleResearchNotification
    })

    myData.musicBtn = widget.newButton(
    {
        left = 60,
        top = myData.researchNotificationBtn.y+myData.researchNotificationBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Background Music: ON",
        labelColor = tableColor1,
        onEvent = toggleMusic
    })

    myData.sfxBtn = widget.newButton(
    {
        left = 60,
        top = myData.musicBtn.y+myData.musicBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Sound Effects: ON",
        labelColor = tableColor1,
        onEvent = toggleSfx
    })

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBackPN
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.playerTextPlayerS)
    group:insert(myData.moneyTextPlayerS)
    group:insert(myData.backButton)
    group:insert(myData.playerSRect)
    group:insert(myData.tournamentNotificationBtn)
    group:insert(myData.taskNotificationBtn)
    group:insert(myData.researchNotificationBtn)
    group:insert(myData.musicBtn)
    group:insert(myData.sfxBtn)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackPN)
    myData.tournamentNotificationBtn:addEventListener("tap",toggleTournamentNotification)
    myData.taskNotificationBtn:addEventListener("tap",toggleTaskNotification)
    myData.researchNotificationBtn:addEventListener("tap",toggleResearchNotification)
    myData.musicBtn:addEventListener("tap",toggleMusic)
    myData.sfxBtn:addEventListener("tap",toggleSfx)
end

-- Home Show
function playerNotificationScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        loaded=false
        local tutCompleted = loadsave.loadTable( "playerSettingsTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutPlayerSettings ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "playerSettingsTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getPlayerSettings.php", "POST", playerNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
playerNotificationScene:addEventListener( "create", playerNotificationScene )
playerNotificationScene:addEventListener( "show", playerNotificationScene )
playerNotificationScene:addEventListener( "destroy", playerNotificationScene )
---------------------------------------------------------------------------------

return playerNotificationScene