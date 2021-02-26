local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local overclockScene = composer.newScene()

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        backSound()
        overclockOverlay = false
        composer.hideOverlay( "fade", 100 )
    end
end

local function onAlert()
end

local function addFinishOverclockConfirm( event )
    if (ocReceived==true) then
        if (tonumber(myData.boosters.text) > 4) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to finish all your tasks for 5 Overclocks?", { "Yes", "No"}, addFinishOverclock )
        else
            backSound()
            local alert = native.showAlert( "EliteHax", "You don't have enough overclocks. You need 5 Overclocks for this feature.", { "Close"} )
        end
    end
end

local function addHourOverclockConfirm( event )
    if (ocReceived==true) then
        if (tonumber(myData.boosters.text) > 0) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to skip 1h for all your tasks for 1 Overclock?", { "Yes", "No"}, addHourOverclock )
        else
            backSound()
            local alert = native.showAlert( "EliteHax", "You don't have enough overclocks. You need 5 Overclock for this feature.", { "Close"} )
        end
    end
end

local function addOverclockConfirm( event )
    if (ocReceived==true) then
        if (tonumber(myData.boosters.text) > 0) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to activate the Overclock for 1 Overclock?", { "Yes", "No"}, addOverclock )
        else
            backSound()
            local alert = native.showAlert( "EliteHax", "You don't have enough overclocks. You need 1 Overclock for this feature.", { "Close"} )
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function overclockScene:create(event)
    ocGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    myData.overclockRect = display.newImageRect( "img/overclock_rect.png",display.contentWidth/1.1, display.contentHeight / 2.2 )
    myData.overclockRect.anchorX = 0.5
    myData.overclockRect.anchorY = 0.5
    myData.overclockRect.x, myData.overclockRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.overclockRect)

    local options = 
    {
        text = "\nDaily Overclocks Used: "..event.params.daily_oc.."/15\n\nSelect an Overclock type:\n",
        x = myData.overclockRect.x,
        y = myData.overclockRect.y-myData.overclockRect.height/2+fontSize(90),
        width = myData.overclockRect.width-80,
        font = native.systemFont,   
        fontSize = 52,
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0

    myData.normalOverclockBtn = display.newImageRect( "img/overclock.png",fontSize(200), fontSize(200))
    myData.normalOverclockBtn.anchorX = 0.5
    myData.normalOverclockBtn.anchorY = 0
    myData.normalOverclockBtn.x, myData.normalOverclockBtn.y = myData.overclockRect.x-myData.overclockRect.width/3.2,myData.instruction.y+myData.instruction.height
    myData.normalOverclockBtn.txt = display.newText("Overclock",myData.normalOverclockBtn.x,myData.normalOverclockBtn.y+myData.normalOverclockBtn.height+fontSize(30),native.systemFont, fontSize(50))
    myData.normalOverclockBtn.txt.anchorY=0.5

    myData.hourOverclockBtn = display.newImageRect( "img/overclockHour.png",fontSize(240), fontSize(240))
    myData.hourOverclockBtn.anchorX = 0.5
    myData.hourOverclockBtn.anchorY = 0
    myData.hourOverclockBtn.x, myData.hourOverclockBtn.y = myData.overclockRect.x,myData.normalOverclockBtn.y-fontSize(20)
    myData.hourOverclockBtn.txt = display.newText("Skip 1h",myData.hourOverclockBtn.x,myData.hourOverclockBtn.y+myData.hourOverclockBtn.height+fontSize(10),native.systemFont, fontSize(50))
    myData.hourOverclockBtn.txt.anchorY=0.5

    myData.finishOverclockBtn = display.newImageRect( "img/overclockFinish.png",fontSize(200), fontSize(200))
    myData.finishOverclockBtn.anchorX = 0.5
    myData.finishOverclockBtn.anchorY = 0
    myData.finishOverclockBtn.x, myData.finishOverclockBtn.y = myData.overclockRect.x+myData.overclockRect.width/3.2,myData.normalOverclockBtn.y
    myData.finishOverclockBtn.txt = display.newText("Finish Tasks",myData.finishOverclockBtn.x,myData.finishOverclockBtn.y+myData.finishOverclockBtn.height+fontSize(30),native.systemFont, fontSize(50))
    myData.finishOverclockBtn.txt.anchorY=0.5

    myData.closeButton = widget.newButton(
    {
        left = myData.overclockRect.x-myData.overclockRect.width/2+60,
        top = myData.normalOverclockBtn.txt.y+myData.normalOverclockBtn.txt.height+fontSize(80),
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Close",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.closeButton.anchorX=0.5
    myData.closeButton.anchorY=1
    myData.closeButton.x = myData.overclockRect.x

    --  Show HUD    
    ocGroup:insert(myData.overclockRect)
    ocGroup:insert(myData.instruction)
    ocGroup:insert(myData.normalOverclockBtn)
    ocGroup:insert(myData.hourOverclockBtn)
    ocGroup:insert(myData.finishOverclockBtn)
    ocGroup:insert(myData.normalOverclockBtn.txt)
    ocGroup:insert(myData.hourOverclockBtn.txt)
    ocGroup:insert(myData.finishOverclockBtn.txt)
    ocGroup:insert(myData.closeButton)

    --  Button Listeners
    myData.closeButton:addEventListener("tap", close)
    myData.normalOverclockBtn:addEventListener("tap",addOverclockConfirm)
    myData.hourOverclockBtn:addEventListener("tap",addHourOverclockConfirm)
    myData.finishOverclockBtn:addEventListener("tap",addFinishOverclockConfirm)

end

-- Home Show
function overclockScene:show(event)
    local taskocGroup = self.view
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
overclockScene:addEventListener( "create", overclockScene )
overclockScene:addEventListener( "show", overclockScene )
---------------------------------------------------------------------------------

return overclockScene