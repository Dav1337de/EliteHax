local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local tutorialScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

function goBackTutorial (event)
    myData.webView:removeSelf()
    myData.webView = nil
    backSound()
    composer.removeScene( "tutorialScene" )
    composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
end

local function goBackTutorial(event)
    if (event.phase=="ended") then
        myData.webView:removeSelf()
        myData.webView = nil
        backSound()
        composer.removeScene( "tutorialScene" )
        composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function tutorialScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=200

    myData.webView = native.newWebView(0, 0, display.contentWidth, display.actualContentHeight-(display.actualContentHeight/15)-10 )
    myData.webView.anchorX=0
    myData.webView.anchorY=0
    myData.webView:request( "http://app.elitehax.it/tutorial/index.html" )
    myData.webView:reload()

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15) + topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBackTutorial
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.webView)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackTutorial)
end

-- Home Show
function tutorialScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
tutorialScene:addEventListener( "create", tutorialScene )
tutorialScene:addEventListener( "show", tutorialScene )
---------------------------------------------------------------------------------

return tutorialScene