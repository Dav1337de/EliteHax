local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local crewSettingScene = composer.newScene()
widget.setTheme( "widget_theme_android_holo_dark" )
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function goBackCrewSettings( event )
    if (myData.crewDescT) then
        myData.crewDescT:removeSelf()
        myData.crewDescT = nil
    end
    backSound()
    composer.removeScene( "crewSettingScene" )
    composer.gotoScene("crewScene", {effect = "fade", time = 100})
end

local goHome = function(event)
    composer.removeScene( "crewSettingScene" )
    if (myData.crewDescT) then
        myData.crewDescT:removeSelf()
        myData.crewDescT = nil
    end
    backSound()
    composer.gotoScene("homeScene", {effect = "fade", time = 100})
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

local function deleteCrewListener( event )

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
            local alert = native.showAlert( "EliteHax", "You succesfully deleted your Crew!\nHope you will create or join a new one soon!", { "Close" }, goHome )
        end

    end
end

local function deleteCrew( event )
    local i = event.index
    if (i == 1) then
        local headers = {} 
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."deleteCrew.php", "POST", deleteCrewListener, params )
    elseif ( i == 2 ) then
        backSound()
    end 
end

local function deleteCrewAlert( event )
    if (event.phase == "ended") then
    tapSound()
        local alert = native.showAlert( "EliteHax", "Do you REALLY REALLY want to delete your Crew?\nAll members will be kicked out and your great Crew will no longer exists!!", { "Yes..", "No!"}, deleteCrew )
    end
end

local function goToCrewShop( event )
    if (event.phase == "ended") then
        if (myData.crewDescT) then
            myData.crewDescT:removeSelf()
            myData.crewDescT = nil
        end
        composer.removeScene( "crewSettingScene" )
        tapSound()
        composer.gotoScene("crewShopScene", {effect = "fade", time = 100})
    end
end

local function changeMentorListener( event )

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
            local alert = native.showAlert( "EliteHax", "Crew Mentor changed succesfully!\nYou are no longer the Crew Mentor", { "Close" }, goBackCrewSettings )
        end

    end
end

local function setNewMentor( event )
    local i = event.index
    if (i == 1) then
        local values = myData.pickerWheel:getValues()
        local allValues = columnData[1].labels
        local allUUID = columnData[1].uuid
        local currentCrewMember = values[1].value
        local currentUUID = 0
        for i=1,#allValues do
            if (allValues[i] == currentCrewMember) then
                currentUUID = allUUID[i]
            end
        end
        local headers = {} 
        local body = "id="..string.urlEncode(loginInfo.token).."&new_mentor="..currentUUID
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."crewChangeMentor.php", "POST", changeMentorListener, params )
    elseif ( i == 2 ) then
        backSound()
    end 
end

local function setNewMentorAlert( event )
    if (event.phase == "ended") then
        local values = myData.pickerWheel:getValues()
        local allValues = columnData[1].labels
        local currentCrewMember = values[1].value
        if (currentCrewMember ~= "") then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you REALLY want to give your Crew to "..currentCrewMember.."?\nYou will be demoted to The Elite", { "Yes", "No"}, setNewMentor )
        end
    end
end

local function onStepperPress( event )
    tapSound()
    if ( "increment" == event.phase ) then
        currentWallet = currentWallet + 1
    elseif ( "decrement" == event.phase ) then
        currentWallet = currentWallet - 1
    end
    myData.crewWalletStepper:setValue(currentWallet)
    myData.crewWalletPTxt.text = currentWallet.."%"
end

local function crewNetworkListener( event )
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
        myData.moneyTextCrewS.text = format_thousand(t.money)
        myData.moneyTextCrewS.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextCrewS.size = fontSize(42) end
        myData.playerTextCrewS.text = t.username

        --Details
        initialDesc = t.desc
        initialWallet = t.wallet_p
        currentWallet = t.wallet_p
        myData.crewDescT.text = t.desc
        myData.crewWalletPTxt.text = currentWallet.."%"
        myData.crewWalletStepper:setValue(currentWallet)
        if (t.crew_role == 1) then
            myData.crewMentorRect = display.newImageRect( "img/crew_mentor_rect.png",display.contentWidth-20, fontSize(600))
            myData.crewMentorRect.anchorX = 0.5
            myData.crewMentorRect.anchorY = 0
            myData.crewMentorRect.x, myData.crewMentorRect.y = display.contentWidth/2,myData.crewWalletRect.y+myData.crewWalletRect.height
            changeImgColor(myData.crewMentorRect)

            columnData =
            {
                {
                    align = "center",
                    width = display.contentWidth-200,
                    startIndex = 1,
                    labels = {""},
                    uuid = {}
                }
            }
            for i in pairs( t.elite ) do
                columnData[1].labels[i]=t.elite[i].username
                columnData[1].uuid[i]=t.elite[i].player_id
            end

            myData.pickerWheel = widget.newPickerWheel(
            {
                x = 60,
                top = myData.crewMentorRect.y+fontSize(110),
                width = display.contentWidth-200,
                style = "resizable",
                fontSize = fontSize(70),
                rowHeight = fontSize(60),
                fontColor = textColor1,
                fontColorSelected = textColor2,
                columnColor = { 0, 0, 0 },
                columns = columnData
            })  
            myData.pickerWheel.anchorX = 0.5
            myData.pickerWheel.x = display.contentWidth/2

            myData.crewSetNewMentor = widget.newButton(
            {
                left = display.contentWidth/2,
                top = myData.pickerWheel.y+myData.pickerWheel.height/2+20,
                width = display.contentWidth-100,
                height = display.actualContentHeight/15-5,
                defaultFile = buttonColor1080,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(70),
                label = "Set New Crew Mentor",
                labelColor = tableColor1,
                onEvent = setNewMentorAlert
            })
            myData.crewSetNewMentor.anchorX = 0.5
            myData.crewSetNewMentor.x = (display.contentWidth/2)
            
            group:insert(myData.crewMentorRect)
            group:insert(myData.pickerWheel)
            group:insert(myData.crewSetNewMentor) 
            myData.crewSetNewMentor:addEventListener("tap",setNewMentor)
        end
        myData.goToCrewShopBtn = widget.newButton(
        {
            left = display.contentWidth/2,
            top = myData.crewWalletRect.y+myData.crewWalletRect.height+20,
            width = display.contentWidth-100,
            height = display.actualContentHeight/15-5,
            defaultFile = buttonColor1080,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(70),
            label = "Crew Shop",
            labelColor = tableColor1,
            onEvent = goToCrewShop
        })
        myData.goToCrewShopBtn.anchorX = 0.5
        myData.goToCrewShopBtn.x = (display.contentWidth/2)
        if (t.crew_role == 1) then myData.goToCrewShopBtn.y = myData.crewMentorRect.y+myData.crewMentorRect.height+fontSize(80)
        else myData.goToCrewShopBtn.y = myData.crewWalletRect.y+myData.crewWalletRect.height+fontSize(140) end
        group:insert(myData.goToCrewShopBtn)
        myData.goToCrewShopBtn:addEventListener("tap",goToCrewShop)

        if (t.crew_role == 1) then
            myData.crewDelete = widget.newButton(
            {
                left = display.contentWidth/2,
                top = myData.goToCrewShopBtn.y+myData.goToCrewShopBtn.height/2+20,
                width = display.contentWidth-100,
                height = display.actualContentHeight/15-5,
                defaultFile = buttonColor1080,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(70),
                label = "Delete Crew",
                labelColor = tableColor1,
                onEvent = deleteCrewAlert
            })
            myData.crewDelete.anchorX = 0.5
            myData.crewDelete.x = (display.contentWidth/2)
            group:insert(myData.crewDelete)
            myData.crewDelete:addEventListener("tap",deleteCrewAlert)
        end
    end
end

local function changeWalletListener( event )

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
            local alert = native.showAlert( "EliteHax", "Crew Wallet percentage changed succesfully!", { "Close" } )
        end

    end
end

local function changeWalletP( event )
    if ((event.phase == "ended") and (currentWallet ~= initialWallet)) then
        local headers = {} 
        local body = "id="..string.urlEncode(loginInfo.token).."&new_walletp="..currentWallet
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."crewChangeWalletP.php", "POST", changeWalletListener, params )
    end 
end

local function changeDescListener( event )

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
            local alert = native.showAlert( "EliteHax", "Crew description changed succesfully!", { "Close" } )
        end

    end
end

local function changeDesc(event)
    if ((event.phase == "ended") and (myData.crewDescT.text ~= initialDesc)) then
        local text=myData.crewDescT.text
        print(text)
        if (string.match(text,"[^%a%d%.%!%_%-%'%s]")) then
            backSound()
            local alert = native.showAlert( "EliteHax", "The description contains invalid characters\nAllowed characters (A-Za-z0-9.-'_ )!", { "Close" } )
        else
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&new_desc="..string.urlEncode(myData.crewDescT.text)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."crewChangeDescription.php", "POST", changeDescListener, params )
        end
    end
end

local function onDescEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>35) then
            myData.crewDescT.text = string.sub(event.text,1,35)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%'%s]")) then
            myData.crewDescT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewSettingScene:create(event)
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
    myData.moneyTextCrewS = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCrewS.anchorX = 0
    myData.moneyTextCrewS.anchorY = 0.5
    myData.moneyTextCrewS:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextCrewS = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCrewS.anchorX = 0.5
    myData.playerTextCrewS.anchorY = 0.5
    myData.playerTextCrewS:setFillColor( 0.9,0.9,0.9 )

    --Crew Rect
    myData.crewRect = display.newImageRect( "img/crew_desc_rect.png",display.contentWidth-20, fontSize(380))
    myData.crewRect.anchorX = 0.5
    myData.crewRect.anchorY = 0
    myData.crewRect.x, myData.crewRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.crewRect)

    myData.crewDescT = native.newTextField( 75, myData.crewRect.y+fontSize(110), display.contentWidth-150, fontSize(85) )
    myData.crewDescT.anchorX = 0
    myData.crewDescT.anchorY = 0
    myData.crewDescT.placeholder = "Crew Description (max 35)";

    myData.changeDescBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.crewDescT.y+myData.crewDescT.height+20,
        width = display.contentWidth-100,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Change Description",
        labelColor = tableColor1,
        onEvent = changeDesc
    })
    myData.changeDescBtn.anchorX = 0.5
    myData.changeDescBtn.x = (display.contentWidth/2)

    --Crew Wallet
    myData.crewWalletRect = display.newImageRect( "img/crew_wallet_p_rect.png",display.contentWidth-20, fontSize(370))
    myData.crewWalletRect.anchorX = 0.5
    myData.crewWalletRect.anchorY = 0
    myData.crewWalletRect.x, myData.crewWalletRect.y = display.contentWidth/2,myData.crewRect.y+myData.crewRect.height
    changeImgColor(myData.crewWalletRect)
    myData.crewWalletPTxt = display.newText( "  %", 0, 0, native.systemFont, fontSize(60) )
    myData.crewWalletPTxt.anchorX=0.5
    myData.crewWalletPTxt.anchorY=0
    myData.crewWalletPTxt.x =  (display.contentWidth/2)-80
    myData.crewWalletPTxt.y = myData.crewWalletRect.y+fontSize(110)
    myData.crewWalletPTxt:setTextColor( textColor1[1], textColor1[2], textColor1[3] )
    local options = {
        width = 196,
        height = fontSize(100),
        numFrames = 5,
        sheetContentWidth = 980,
        sheetContentHeight = 100
    }
    myData.stepperSheet = graphics.newImageSheet( stepperColor, options )
    myData.crewWalletStepper = widget.newStepper(
    {
        width = 196,
        height = fontSize(100),
        sheet = myData.stepperSheet,
        initialValue = 2,
        defaultFrame = 1,
        noMinusFrame = 2,
        noPlusFrame = 3,
        minusActiveFrame = 4,
        plusActiveFrame = 5,
        minimumValue = 2,
        maximumValue = 10,
        onPress = onStepperPress
    })
    myData.crewWalletStepper.x = myData.crewWalletPTxt.x+myData.crewWalletPTxt.width+80
    myData.crewWalletStepper.y = myData.crewWalletPTxt.y+30
    myData.saveWalletBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.crewWalletPTxt.y+myData.crewWalletPTxt.height+fontSize(30),
        width = display.contentWidth-100,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Save Crew Wallet %",
        labelColor = tableColor1,
        onEvent = changeWalletP
    })
    myData.saveWalletBtn.anchorX = 0.5
    myData.saveWalletBtn.x = (display.contentWidth/2)

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
        onEvent = goBackCrewSettings
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.playerTextCrewS)
    group:insert(myData.moneyTextCrewS)
    group:insert(myData.backButton)
    group:insert(myData.crewRect)
    group:insert(myData.changeDescBtn)
    group:insert(myData.crewWalletRect)
    group:insert(myData.crewWalletPTxt)
    group:insert(myData.crewWalletStepper)
    group:insert(myData.saveWalletBtn)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackCrewSettings)
    myData.crewDescT:addEventListener( "userInput", onDescEdit )
    myData.changeDescBtn:addEventListener("tap",changeDesc)
    myData.saveWalletBtn:addEventListener("tap",changeWalletP)
end

-- Home Show
function crewSettingScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMyCrewSettings.php", "POST", crewNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

function crewSettingScene:destroy(event)
    if (myData.crewChatInput) then
        myData.crewChatInput:removeSelf()
        myData.crewChatInput = nil
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewSettingScene:addEventListener( "create", crewSettingScene )
crewSettingScene:addEventListener( "show", crewSettingScene )
crewSettingScene:addEventListener( "destroy", crewSettingScene )
---------------------------------------------------------------------------------

return crewSettingScene