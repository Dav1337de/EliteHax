local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local registerWithGoogleScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase=="ended") then
        myData.usernameInput.isVisible=true
        myData.passwordInput.isVisible=true
        backSound()
        composer.hideOverlay( "fade", 100 )
    end
end

local function onAlert()
end

local function registerGoogleListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it.", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it.", { "Close" }, onAlert )
        end

        if (t.status == "UE") then
            local alert = native.showAlert( "EliteHax", "Username already exists!\nPlease choose a different one..", { "Close" } )
        elseif (t.status == "IU") then
            local alert = native.showAlert( "EliteHax", "Invalid username!\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" } )
        elseif (t.status == "OK") then
            --local alert = native.showAlert( "EliteHax", "Registration almost complete!\nAn e-mail has been sent to "..myData.emailInput.text.." with a link to confirm your registration!\nIf you can't find the email, please check the Spam folder.", { "Close" } )
            print("Token: "..t.token)
            myData.usernameInput.isVisible=true
            myData.passwordInput.isVisible=true
            composer.hideOverlay( "fade", 100 )
            loginSucceeded(t.token)
        else
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured..\nPlease contact support@elitehax.it.", { "Close" }, onAlert )
        end
    end
end

local function registerGoogle(event)
    if (event.phase == "ended") then
        local user = myData.registerGoogleNameT.text
        if ((string.len(user) < 4) or (string.len(user) > 18)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" } )
        elseif (user:match("[%a%d%.%!%_%-%s]") == false) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Your username contains invalid characters\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" } )
        else
            tapSound()
            local jsonRequest = {["user"] = user}
            jsonRequest = json.encode(jsonRequest)
            local encryptedData = base64Encode(cipher:encrypt(jsonRequest,reg_token))
            print( "Token: "..reg_token)
            print ( "Encrypted Text: " .. string.urlEncode(encryptedData) )

            local headers = {}
            local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&data="..string.urlEncode(encryptedData)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."registerGoogleUser.php", "POST", registerGoogleListener, params )
        end
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.registerGoogleNameT.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.registerGoogleNameT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    elseif (event.phase == "ended") then
        if ((string.len(myData.registerGoogleNameT.text) < 4) or (string.len(myData.registerGoogleNameT.text) > 18)) then
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" } )
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function registerWithGoogleScene:create(event)
    RGgroup = self.view
    local iconSize=250

    reg_token = event.params.reg_token

    myData.registerGoogleRect =  display.newImageRect( "img/new_player.png",display.contentWidth-130,fontSize(860) )
    myData.registerGoogleRect.anchorX = 0.5
    myData.registerGoogleRect.anchorY = 0.5
    myData.registerGoogleRect.x,myData.registerGoogleRect.y = display.contentWidth/2, display.actualContentHeight/2.25
    changeImgColor(myData.registerGoogleRect)

    myData.registerGoogleName = display.newText( "  Welcome to EliteHax!\nChoose your username: ", 0, 0, native.systemFont, fontSize(60) )
    myData.registerGoogleName.anchorX=0.5
    myData.registerGoogleName.anchorY=0
    myData.registerGoogleName.x =  display.contentWidth/2
    myData.registerGoogleName.y = myData.registerGoogleRect.y-myData.registerGoogleRect.height/2+fontSize(150)
    myData.registerGoogleName:setTextColor( 0.9, 0.9, 0.9 )
    myData.registerGoogleNameT = native.newTextField( display.contentWidth/2, myData.registerGoogleName.y+myData.registerGoogleName.height+fontSize(30), display.contentWidth/1.5, fontSize(100) )
    myData.registerGoogleNameT.anchorX = 0.5
    myData.registerGoogleNameT.anchorY = 0
    myData.registerGoogleNameT.placeholder = "Name (max 18)";

    -- Request Button
    myData.registerGoogleBtn = widget.newButton(
    {
        left = 40,
        top = myData.registerGoogleNameT.y+fontSize(160),
        width = display.contentWidth/2+200,
        height = fontSize(150),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Start To Play",
        labelColor = tableColor1,
        onEvent = registerGoogle
    })
    myData.registerGoogleBtn.anchorX = 0.5
    myData.registerGoogleBtn.x = display.contentWidth/2

    -- Request Button
    myData.cancelRegisterBtn = widget.newButton(
    {
        left = 40,
        top = myData.registerGoogleBtn.y+fontSize(120),
        width = display.contentWidth/2,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Cancel",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.cancelRegisterBtn.anchorX = 0.5
    myData.cancelRegisterBtn.x = display.contentWidth/2

    --  Show HUD    
    RGgroup:insert(myData.registerGoogleRect)
    RGgroup:insert(myData.registerGoogleName)
    RGgroup:insert(myData.registerGoogleBtn)
    RGgroup:insert(myData.registerGoogleNameT)
    RGgroup:insert(myData.cancelRegisterBtn)

    --  Button Listeners
    myData.cancelRegisterBtn:addEventListener("tap", close)
    myData.registerGoogleBtn:addEventListener("tap", registerGoogle)
    myData.registerGoogleNameT:addEventListener( "userInput", onNameEdit )

end

-- Home Show
function registerWithGoogleScene:show(event)
    local taskRGgroup = self.view
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
registerWithGoogleScene:addEventListener( "create", registerWithGoogleScene )
registerWithGoogleScene:addEventListener( "show", registerWithGoogleScene )
---------------------------------------------------------------------------------

return registerWithGoogleScene