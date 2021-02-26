--DEPRECATED
local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local videoLoadingScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    composer.hideOverlay( "fade", 400 )
    itemsLoaded=true
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function videoLoadingScene:create(event)
    group = self.view

    myData.videoLoading = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth/1.3, fontSize(200), 12 )
    myData.videoLoading.anchorX = 0.5
    myData.videoLoading.anchorY = 0.5
    myData.videoLoading.strokeWidth = 5
    myData.videoLoading:setFillColor( 0,0,0 )
    myData.videoLoading:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.videoLoading.alpha = 1

    -- Crew Name
    myData.videoLoadingTxt = display.newText( "Loading Video, please wait..", 0, 0, native.systemFont, fontSize(52) )
    myData.videoLoadingTxt.anchorX=0.5
    myData.videoLoadingTxt.anchorY=0.5
    myData.videoLoadingTxt.x =  display.contentWidth/2
    myData.videoLoadingTxt.y = myData.videoLoading.y
    myData.videoLoadingTxt:setTextColor( 0.9, 0.9, 0.9 )

    --  Show HUD    
    group:insert(myData.videoLoading)
    group:insert(myData.videoLoadingTxt)

end

-- Home Show
function videoLoadingScene:show(event)
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
videoLoadingScene:addEventListener( "create", videoLoadingScene )
videoLoadingScene:addEventListener( "show", videoLoadingScene )
---------------------------------------------------------------------------------

return videoLoadingScene