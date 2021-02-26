local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local terminalTutScene = composer.newScene()
local tutPage=1
local animationShow1=false
local animationShow2=false
local initialAnimation=nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.attackerTut.alpha=0
            myData.fwtut.alpha=0
            myData.fwtut.ip.alpha=0
            myData.fwtut.txt.alpha=0
            myData.fwtut.txtb.alpha=0
            attackerTutLine.alpha=0
            myData.instruction.text="You will see the stats of your victim based on your scanner and its firewall levels.\nIf you feel confident, you can attack your victim in 6 different ways."
            myData.tutImage = display.newImageRect( "img/terminal_stats.png",700, 150 )
            myData.tutImage.anchorX = 0.5
            myData.tutImage.anchorY = 0
            myData.tutImage.x, myData.tutImage.y = display.contentWidth/2,myData.instruction.y+myData.instruction.height+fontSize(80)
            tutPage=2
        elseif (tutPage==2) then
            myData.instruction.text="\nWeb Server attack uses your Exploit against your opponent IPS and Web Server to steal 30% of the victim money."
            local imageA = { type="image", filename="img/web-server.png" }
            myData.tutImage.width=150
            myData.tutImage.fill = imageA
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="\nApplication Server attack uses your Exploit against your opponent IPS and Application Server to steal 40% of the victim money."
            local imageA = { type="image", filename="img/application-server.png" }
            myData.tutImage.fill = imageA
            tutPage=4
        elseif (tutPage==4) then
            myData.instruction.text="\nDatabase Server attack uses your Exploit against your opponent IPS and Database Server to steal 50% of the victim money."
            local imageA = { type="image", filename="img/db-server.png" }
            myData.tutImage.fill = imageA
            tutPage=5    
        elseif (tutPage==5) then
            myData.instruction.text="\nMoney Malware attack uses your Malware against your opponent Antivirus to steal 45% of the victim money."
            local imageA = { type="image", filename="img/malware_money.png" }
            myData.tutImage.fill = imageA
            tutPage=6
        elseif (tutPage==6) then
            myData.instruction.text="Bot Malware attack uses your Malware against your opponent Antivirus to implant a Bot Malware on your vitctim and generate an hourly income."
            local imageA = { type="image", filename="img/malware_botnet.png" }
            myData.tutImage.fill = imageA
            tutPage=7
        elseif (tutPage==7) then
            myData.instruction.text="RAT Malware attack uses your Malware against your opponent Antivirus to implant a RAT Malware on your victim, giving you direct access from C&C."
            local imageA = { type="image", filename="img/malware_rat.png" }
            myData.tutImage.fill = imageA
            tutPage=8
        elseif (tutPage==8) then
            myData.tutImage.alpha=0
            myData.instruction.text="\n\nYou can search victims with a similar rank, use the Global search, the Manual Scan or the Target List to save your favorite victims and attack them directly."
            tutPage=9
        elseif (tutPage==9) then
            myData.instruction.text="\n\n\nChoose the best attack based on the victim defenses and become the best hacker!"
            tutPage=10
            myData.completeButton:setLabel("Close")
        elseif (tutPage==10) then
            local tutorialStatus = {
                tutTerminal = true
            }
            loadsave.saveTable( tutorialStatus, "terminalTutorialStatus.json" )
            tutOverlay = false
            composer.hideOverlay( "fade", 200 )
        end
    end
end

local function onAlert()
end

local function detectTarget(x,y)
    if ((x > myData.fwtut.x) and (x < myData.fwtut.x+myData.fwtut.width) and (y>myData.fwtut.y) and (y<myData.fwtut.y+myData.fwtut.height)) then
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fwtut.fill = imageA
        myData.fwtut.txtb.alpha=1
        myData.fwtut.txt.alpha=1
        myData.fwtut.ip.alpha=1
        return "fwtut"
    else
        local imageA = { type="image", filename="img/terminal_unknown.png" }
        local cur = "fwtut"
        if (myData[cur].scan ~= true) then
            myData[cur].fill = imageA
            myData[cur].txtb.alpha=0
            myData[cur].txt.alpha=0
            myData[cur].ip.alpha=0
            changeImgColor(myData[cur])
        end
        return "None"
    end
end

local function onAttackerTutTouch( event )
    if (animationShow2) then
        if ( event.phase == "began" ) then
            display.getCurrentStage():setFocus( myData.attackerTut )
            myData.attackerTut.isFocus = true
        elseif ( event.phase == "moved" ) then
            if (attackerTutLine) then
                attackerTutLine:removeSelf()
                attackerTutLine = nil
            end
            local dX = myData.attackerTut.x+(event.x - myData.attackerTut.x)
            local dY = myData.attackerTut.y+(event.y - myData.attackerTut.y+20)
            attackerTutLine = display.newLine( dX,dY, myData.attackerTut.x+myData.attackerTut.height/2, myData.attackerTut.y+myData.attackerTut.width/2 )
            attackerTutLine:setStrokeColor( 0.7, 0, 0, 1 )
            attackerTutLine.strokeWidth = 10
            tutGroup:insert(attackerTutLine)
            tutGroup:insert(myData.attackerTut)
            tutGroup:insert(myData.attackerTut)
            detectTarget(dX,dY)
        elseif ( event.phase == "ended" ) then
            display.getCurrentStage():setFocus( nil )
            myData.attackerTut.isFocus = nil
            local dX = myData.attackerTut.x+(event.x - myData.attackerTut.x) 
            local dY = myData.attackerTut.y+(event.y - myData.attackerTut.y+20) 
            local visualTarget = detectTarget(dX,dY)
            if (visualTarget ~= "None") then
                myData[visualTarget].scan=true
                myData.completeButton.alpha=1
            else
                if (attackerTutLine) then
                attackerTutLine:removeSelf()
                attackerTutLine = newLine
                end
            end      
        end
    end
    return true
end

local function clearAnimation( event )
    if (attackerTutLine) then
        attackerTutLine:removeSelf()
        attackerTutLine = nil
    end 
    local imageA = { type="image", filename="img/terminal_unknown.png" }
    local cur = "fwtut"
    if (myData[cur].scan ~= true) then
        myData[cur].fill = imageA
        myData[cur].txtb.alpha=0
        myData[cur].txt.alpha=0
        myData[cur].ip.alpha=0
        changeImgColor(myData[cur])
    end
    if (animationShow1==false) then
        animationShow1=true
        initialAnimation()
    else
        myData.instruction.text=myData.instruction.text.."\n\nTry it!"
        animationShow2=true
    end
end

local function moveTutLine(event)
    targetI=targetI+1
    if (attackerTutLine) then
        attackerTutLine:removeSelf()
        attackerTutLine = nil
    end
    local distance=distanceX/15*targetI
    attackerTutLine = display.newLine( myData.attackerTut.x+distance, myData.attackerTut.y+myData.attackerTut.width/2, myData.attackerTut.x+myData.attackerTut.height/2, myData.attackerTut.y+myData.attackerTut.width/2 )
    attackerTutLine:setStrokeColor( 0.7, 0, 0, 1 )
    attackerTutLine.strokeWidth = 10
    tutGroup:insert(attackerTutLine)
    if (targetI==15) then
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fwtut.fill = imageA
        myData.fwtut.txtb.alpha=1
        myData.fwtut.txt.alpha=1
        myData.fwtut.ip.alpha=1
        timer.performWithDelay(1000,clearAnimation)
    end
end

initialAnimation = function ( event )
    attackerTutLine = display.newLine( myData.attackerTut.x+myData.attackerTut.height/2, myData.attackerTut.y+myData.attackerTut.width/2, myData.attackerTut.x+myData.attackerTut.height/2, myData.attackerTut.y+myData.attackerTut.width/2 )
    attackerTutLine:setStrokeColor( 0.7, 0, 0, 1 )
    attackerTutLine.strokeWidth = 10
    tutGroup:insert(attackerTutLine)
    targetI=0
    targetX=myData.fwtut.x+myData.fwtut.width/2
    targetY=myData.fwtut.y+myData.fwtut.height/2
    distanceX=targetX-myData.attackerTut.x
    local animationTimer = timer.performWithDelay(20,moveTutLine,15)
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function terminalTutScene:create(event)
    tutGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    myData.terminalTutRect = display.newImageRect( "img/terminal_tutorial.png",display.contentWidth/1.2, display.contentHeight / 2.5 )
    myData.terminalTutRect.anchorX = 0.5
    myData.terminalTutRect.anchorY = 0.5
    myData.terminalTutRect.x, myData.terminalTutRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.terminalTutRect)

    local options = 
    {
        text = "Drag your finger from the Attacker Workstation to the target to see its firewall.\nRelease the finger on the target to scan it.",     
        x = myData.terminalTutRect.x,
        y = myData.terminalTutRect.y-myData.terminalTutRect.height/2+fontSize(130),
        width = myData.terminalTutRect.width-80,
        font = native.systemFont,   
        fontSize = 42,
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0

    myData.attackerTut = display.newImageRect( "img/attacker.png",iconSize,iconSize )
    myData.attackerTut.id="attackerTut"
    myData.attackerTut.anchorX = 0
    myData.attackerTut.anchorY = 0
    myData.attackerTut.x, myData.attackerTut.y = myData.terminalTutRect.x-myData.terminalTutRect.width/2.5,myData.terminalTutRect.y-fontSize(50)

    myData.fwtut = display.newImageRect( "img/terminal_unknown.png",iconSize/1.1,iconSize/1.1 )
    myData.fwtut.id="fwtut"
    myData.fwtut.anchorX = 0
    myData.fwtut.anchorY = 0
    myData.fwtut.x, myData.fwtut.y = myData.terminalTutRect.x+myData.terminalTutRect.width/6,myData.terminalTutRect.y-fontSize(50)
    changeImgColor(myData.fwtut)
    myData.fwtut.txtb = display.newRoundedRect(myData.fwtut.x+myData.fwtut.width/2,myData.fwtut.y,70,70,12)
    myData.fwtut.txtb.anchorX=0.5
    myData.fwtut.txtb.anchorY=0
    myData.fwtut.txtb.strokeWidth = 5
    myData.fwtut.txtb:setFillColor( 0,0,0 )
    myData.fwtut.txtb:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.fwtut.txtb.alpha=0
    myData.fwtut.txt = display.newText("1",myData.fwtut.x+myData.fwtut.width/2,myData.fwtut.txtb.y-10,native.systemFont, fontSize(72))
    myData.fwtut.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwtut.txt.alpha=0
    myData.fwtut.txt.anchorY=0
    myData.fwtut.ip = display.newText("127.0.0.1",myData.fwtut.x+myData.fwtut.width/2,myData.fwtut.y+myData.fwtut.height+20,native.systemFont, fontSize(40))
    myData.fwtut.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwtut.ip.alpha=0

    myData.completeButton = widget.newButton(
    {
        left = myData.terminalTutRect.x-myData.terminalTutRect.width/2+60,
        top = myData.fwtut.y+myData.fwtut.height+fontSize(120),
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Next",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.completeButton.alpha=0
    myData.completeButton.anchorX=0.5
    myData.completeButton.anchorY=1
    myData.completeButton.x = myData.terminalTutRect.x

    --  Show HUD    
    tutGroup:insert(myData.terminalTutRect)
    tutGroup:insert(myData.instruction)
    tutGroup:insert(myData.attackerTut)
    tutGroup:insert(myData.fwtut)
    tutGroup:insert(myData.fwtut.txtb)
    tutGroup:insert(myData.fwtut.txt)
    tutGroup:insert(myData.fwtut.ip)
    tutGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.attackerTut:addEventListener( "touch", onAttackerTutTouch )
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function terminalTutScene:show(event)
    local tasktutGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
    end
    if event.phase == "did" then
        timer.performWithDelay(5000,initialAnimation())
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
terminalTutScene:addEventListener( "create", terminalTutScene )
terminalTutScene:addEventListener( "show", terminalTutScene )
---------------------------------------------------------------------------------

return terminalTutScene