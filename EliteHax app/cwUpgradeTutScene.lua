local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local cwUpgradeTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="The External Firewall is your first line of defense.\nThis is the first item that an attacker must bypass, but also the easiest one."
            myData.tutImage = display.newImageRect( "img/dc-fwext-g.png",fontSize(175), fontSize(175) )
            myData.tutImage.anchorX = 0.5
            myData.tutImage.anchorY = 0
            myData.tutImage.x, myData.tutImage.y = display.contentWidth/2+fontSize(60),myData.instruction.y
            myData.tutImage.rotation=90
            alertGroup:insert(myData.tutImage)
            tutPage=2
        elseif (tutPage==2) then
            local imageA = { type="image", filename="img/dc-ips-g.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="After bypassing the External Firewall, the attacker must evade your IPS that is a bit more difficult to attack."
            tutPage=3
        elseif (tutPage==3) then
            local imageA = { type="image", filename="img/dc-siem-g.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="After evading the IPS, the attacker can proceed with different attack paths.\nA clever step could be to attack and disable the SIEM to remain anonymous during the next steps."
            tutPage=4     
        elseif (tutPage==4) then
            local imageA = { type="image", filename="img/dc-fwint1-g.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="At this point you have two Internal Firewall to protect your Production and Test environments. The Internal Firewalls are more difficult to bypass."
            tutPage=5  
        elseif (tutPage==5) then
            local imageA = { type="image", filename="img/dc-mf1-g.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="As the final step, the attacker must hack your Crew Mainframe where your crew wallet is stored. This is the most difficult step!"
            tutPage=6
        elseif (tutPage==6) then
            --local imageA = { type="image", filename="img/dc-prod.png" }
            myData.tutImage.alpha=0
            myData.instruction.text="Your datacenter includes a Production and a Test Mainframe. Only the Prod Mainframe contains your Crew Wallet, but the attacker won't know which one is the right one!\nIf you think that too many enemy crews have discovered your production mainframe, you can swap the two environments by reaching 50/50 on the Test label."
            tutPage=7    
        elseif (tutPage==7) then
            local imageA = { type="image", filename="img/dc-relocate.png" }
            myData.tutImage.fill=imageA
            myData.tutImage.alpha=1
            myData.instruction.text="Likewise, if you think that too many enemy crews have discovered your Datacenter location, you can relocate it in a new region after reaching 100/100 on the Relocate item."
            tutPage=8
        elseif (tutPage==8) then
            local imageA = { type="image", filename="img/dc-anon.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="And now it's time for some attack stuff! Let's start with the Anonymizer that allows you to remain anonymous while attacking other crew datacenters."
            tutPage=9
        elseif (tutPage==9) then
            local imageA = { type="image", filename="img/dc-scanner.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="The Scanner will let you see the current level of the enemy datacenter items and calculate the Success Chances and Anonymous Chances."
            tutPage=10
        elseif (tutPage==10) then
            local imageA = { type="image", filename="img/dc-exploit.png" }
            myData.tutImage.fill=imageA
            myData.instruction.text="Finally, there is the Exploit Framework that is the tool that your Crew uses to bypass the enemy firewalls, evade the IPS, disable the SIEM and hack the Mainframe!"
            tutPage=11
        elseif (tutPage==11) then
            myData.tutImage.alpha=0
            myData.instruction.text="Upgrading an item consumes 1 point.\nYou can use 2 points per hour and your Crew can use a total of 50 daily points.\nPoints can be used for Upgrade, Defend and Attack, choose the best strategy with your crew members!"
            tutPage=12
            myData.completeButton:setLabel("Close")
        elseif (tutPage==12) then
            local tutorialStatus = {
                cwUpgradeTutorial = true
            }
            loadsave.saveTable( tutorialStatus, "cwUpgradeTutorialStatus.json" )
            tutOverlay = false
            composer.hideOverlay( "fade", 100 )
        end
    end
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function cwUpgradeTutScene:create(event)
    alertGroup = self.view

    loginInfo = localToken()
    params = event.params

    tutIconSize=fontSize(300)

    myData.alertRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentHeight/1.3, fontSize(500), 15 )
    myData.alertRect.anchorX = 0.5
    myData.alertRect.anchorY = 0.5
    myData.alertRect.strokeWidth = 5
    myData.alertRect:setFillColor( 0,0,0 )
    myData.alertRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.alertRect.rotation=90

    local options = 
    {
        text = "\nThe Datacenter screen allows you to view and upgrade your Crew Datacenter stats.\nIn the following pages of this tutorial, you will learn the purpose of each item.\n",     
        x = myData.alertRect.x+fontSize(200),
        y = myData.alertRect.y,
        width = myData.alertRect.width-80,
        font = native.systemFont,   
        fontSize = fontSize(42),
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0
    myData.instruction.rotation=90

    myData.completeButton = widget.newButton(
    {
        left = myData.alertRect.x-myData.alertRect.width,
        top = myData.alertRect.y,
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Next",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.completeButton.anchorX=0.5
    myData.completeButton.anchorY=0
    myData.completeButton.x = myData.alertRect.x-myData.alertRect.height/2+myData.completeButton.height+fontSize(30)
    myData.completeButton.y = myData.alertRect.y
    myData.completeButton.rotation=90

    --  Show HUD    
    alertGroup:insert(myData.alertRect)
    alertGroup:insert(myData.instruction)
    alertGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function cwUpgradeTutScene:show(event)
    local taskalertGroup = self.view
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
cwUpgradeTutScene:addEventListener( "create", cwUpgradeTutScene )
cwUpgradeTutScene:addEventListener( "show", cwUpgradeTutScene )
---------------------------------------------------------------------------------

return cwUpgradeTutScene