local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local OneSignal = require("plugin.OneSignal")
local playerSettingScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function goBackPlayerSettings( event )
    if (tutOverlay==false) then
        if (skinOverlay==true) then
            backSound()
            composer.hideOverlay( "fade", 0 )
            skinOverlay=false
        else
            backSound()
            composer.removeScene( "playerSettingScene" )
            composer.gotoScene("playerScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackPS( event )
    if (event.phase=="ended") then
        if (tutOverlay==false) then
            if (skinOverlay==true) then
                backSound()
                composer.hideOverlay( "fade", 0 )
                skinOverlay=false
            else
                backSound()
                composer.removeScene( "playerSettingScene" )
                composer.gotoScene("playerScene", {effect = "fade", time = 100})
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

local function openProfilePic(event)
    if (event.phase=="ended") then
        skinOverlay = true
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "changeProfilePicScene", sceneOverlayOptions) 
    end
end

local function openSkin(event)
    if (event.phase=="ended") then
        skinOverlay = true
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "changeSkinScene", sceneOverlayOptions) 
    end
end

local function getTournamentStatus(tags)
   for key,value in pairs(tags) do
      if (key=="TournamentNotification") then
            tournamentNotification=value
            if (value=="true") then
                tapSound()
                myData.notificationBtn:setLabel("Tournament Notifications: ON")
            else
                backSound()
                myData.notificationBtn:setLabel("Tournament Notifications: OFF")
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

        myData.changeIPBtn:setLabel("IP Change ("..t.ip_change..")")
        myData.changeIPBtn.num=t.ip_change
        myData.resetSTBtn:setLabel("Reset Skill Tree ("..t.st_reset..")")
        myData.resetSTBtn.num=t.st_reset

        loaded=true

    end
end

function reloadSettings(event)
    composer.removeScene( "playerSettingScene" )
    composer.gotoScene("playerSettingScene", {effect = "fade", time = 0})
end

local function changeNameAlert( event )
    if (event.phase=="ended") then
        skinOverlay = true
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "nameChangeScene", sceneOverlayOptions) 
    end
end

local function goToTutorial( event )
    if (event.phase=="ended") then
        tapSound()
        composer.removeScene( "playerSettingScene" )
        composer.gotoScene("tutorialScene", {effect = "fade", time = 100})
    end
end

local function goToSupporter( event )
    if (event.phase=="ended") then
        tapSound()
        composer.removeScene( "playerSettingScene" )
        composer.gotoScene("supporterScene", {effect = "fade", time = 100})
    end
end

local function goToAbout( event )
    if (event.phase=="ended") then
        skinOverlay = true
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "aboutScene", sceneOverlayOptions) 
    end
end

local function resetSTListener( event )
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

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Your Skill Tree has been reset. You have "..t.skill_points.." Skill Points", { "Close" } )
            myData.resetSTBtn:setLabel("Reset Skill Tree ("..t.st_reset..")")
            myData.resetSTBtn.num=t.st_reset
        end
    end
end

local function resetST( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        tapSound()
        network.request( host().."resetST.php", "POST", resetSTListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function resetSTAlert( event )
    if ((event.phase=="ended") and (loaded==true)) then
        if (myData.resetSTBtn.num>0) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you really want to reset your Skill Tree?", { "Yes", "No"}, resetST )
        else
            local alert = native.showAlert( "EliteHax", "You don't have any Skill Tree Reset. You can buy one from the Items screen", { "Close"} )
        end
    end
end

local function changeIPListener( event )
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

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Your new in-game IP Address is "..t.new_ip, { "Close" } )
            myData.changeIPBtn:setLabel("IP Change ("..t.ip_change..")")
            myData.changeIPBtn.num=t.ip_change
        end
    end
end

local function changeIP( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."changeIP.php", "POST", changeIPListener, params )
    elseif ( i == 2 ) then
        --Nothing
        backSound()
    end
end

local function changeIPAlert( event )
    if ((event.phase=="ended") and (loaded==true)) then
        tapSound()
        if (myData.changeIPBtn.num>0) then
            local alert = native.showAlert( "EliteHax", "Do you really want to change your in-game IP Address?", { "Yes", "No"}, changeIP )
        else
            local alert = native.showAlert( "EliteHax", "You don't have any IP Change. You can buy one from the Items screen", { "Close"} )
        end
    end
end

local function toggleTournamentNotification( event )
    if (event.phase=="ended") then
        tapSound()
        composer.removeScene( "playerSettingScene" )
        composer.gotoScene("playerNotificationScene", {effect = "fade", time = 100})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function playerSettingScene:create(event)
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

    myData.changeNameBtn = widget.newButton(
    {
        left = 60,
        top = myData.playerSRect.y+fontSize(120),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Change Name",
        labelColor = tableColor1,
        onEvent = changeNameAlert
    })

    myData.changeIPBtn = widget.newButton(
    {
        left = 60,
        top = myData.changeNameBtn.y+myData.changeNameBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Change IP",
        labelColor = tableColor1,
        onEvent = changeIPAlert
    })

    myData.resetSTBtn = widget.newButton(
    {
        left = 60,
        top = myData.changeIPBtn.y+myData.changeIPBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Reset Skill Tree",
        labelColor = tableColor1,
        onEvent = resetSTAlert
    })

    myData.changeProfilePicBtn = widget.newButton(
    {
        left = 60,
        top = myData.resetSTBtn.y+myData.resetSTBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Change Profile Picture",
        labelColor = tableColor1,
        onEvent = openProfilePic
    })

    myData.changeSkinBtn = widget.newButton(
    {
        left = 60,
        top = myData.changeProfilePicBtn.y+myData.changeProfilePicBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Change Skin",
        labelColor = tableColor1,
        onEvent = openSkin
    })

    myData.notificationBtn = widget.newButton(
    {
        left = 60,
        top = myData.changeSkinBtn.y+myData.changeSkinBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Sounds & Notifications",
        labelColor = tableColor1,
        onEvent = toggleTournamentNotification
    })

    myData.tutorialBtn = widget.newButton(
    {
        left = 60,
        top = myData.notificationBtn.y+myData.notificationBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Tutorial",
        labelColor = tableColor1,
        onEvent = goToTutorial
    })

    myData.supporterBtn = widget.newButton(
    {
        left = 60,
        top = myData.tutorialBtn.y+myData.tutorialBtn.height/2+fontSize(20),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Supporter Subscriptions",
        labelColor = tableColor1,
        onEvent = goToSupporter
    })

    myData.aboutBtn = widget.newButton(
    {
        left = 60,
        top = myData.playerSRect.y+myData.playerSRect.height - (display.actualContentHeight/15) - fontSize(30),
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "About",
        labelColor = tableColor1,
        onEvent = goToAbout
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
        onEvent = goBackPS
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
    group:insert(myData.changeNameBtn)
    group:insert(myData.changeIPBtn)
    group:insert(myData.resetSTBtn)
    group:insert(myData.changeProfilePicBtn)
    group:insert(myData.changeSkinBtn)
    group:insert(myData.notificationBtn)
    group:insert(myData.tutorialBtn)
    group:insert(myData.supporterBtn)
    group:insert(myData.aboutBtn)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackPS)
    myData.changeIPBtn:addEventListener("tap",changeIPAlert)
    myData.resetSTBtn:addEventListener("tap",resetSTAlert)
    myData.changeNameBtn:addEventListener("tap",changeNameAlert)
    myData.notificationBtn:addEventListener("tap",toggleTournamentNotification)
    myData.tutorialBtn:addEventListener("tap",goToTutorial)
    myData.supporterBtn:addEventListener("tap",goToSupporter)
    myData.aboutBtn:addEventListener("tap",goToAbout)
end

-- Home Show
function playerSettingScene:show(event)
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
playerSettingScene:addEventListener( "create", playerSettingScene )
playerSettingScene:addEventListener( "show", playerSettingScene )
playerSettingScene:addEventListener( "destroy", playerSettingScene )
---------------------------------------------------------------------------------

return playerSettingScene