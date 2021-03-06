local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local registerScene = composer.newScene()
local openssl = require("plugin.openssl")
cipher = openssl.get_cipher("aes-256-cbc")
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------

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

local goBack = function(event)
    if (event.phase=="ended") then
        composer.removeScene( "registerScene" )
        backSound()
        composer.gotoScene("loginScene", {effect = "fade", time = 300})
    end
end

local function onClose()
end

local function onCompleted( event )
        composer.removeScene( "registerScene" )
        composer.gotoScene( "loginScene", sceneOverlayOptions)
end

local function registerListener( event )
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
            local alert = native.showAlert( "EliteHax", "Username already exists!\nPlease choose a different one..", { "Close" }, onClose )
        elseif (t.status == "EE") then
            local alert = native.showAlert( "EliteHax", "It seems that there is an account already registered with this e-mail address..", { "Close" }, onClose )
        elseif (t.status == "EN") then
            local alert = native.showAlert( "EliteHax", "The e-mail domain is not authorized. Please use a different e-mail address", { "Close" }, onClose )
        elseif (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Registration almost complete!\nAn e-mail has been sent to "..myData.emailInput.text.." with a link to confirm your registration!\nIf you can't find the email, please check the Spam folder.", { "Close" }, onCompleted )
        else
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it.", { "Close" }, onAlert )
        end
    end
end

local function sendRegisterBtn( event )
    if (event.phase == "ended") then
        --Validate Username length and chars
        local user = myData.usernameInput2.text
        local passwd1 = myData.passwordInput2.text
        local passwd2 = myData.passwordCInput2.text
        local email = myData.emailInput.text
        if ((string.len(user) < 4) or (string.len(user) > 18)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" }, onClose )
        elseif (user:match("[%a%d%.%!%_%-%s]") == false) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Your username contains invalid characters\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" }, onClose )
        elseif ((string.len(passwd1) < 10) or (string.len(passwd1) > 30)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Password must be between 10 and 30 characters!", { "Close" }, onClose )
        elseif (passwd1 ~= passwd2) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Password and Confirm Password don't match", { "Close" }, onClose )
        elseif (email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") == nil) then
            backSound()
            local alert = native.showAlert( "EliteHax", email.." is not a valid email address", { "Close" }, onClose )
        else
            tapSound()
            local jsonRequest = {["user"] = user, ["password"] = passwd1, ["email"] = email}
            jsonRequest = json.encode(jsonRequest)
            local encryptedData = base64Encode(cipher:encrypt(jsonRequest,reg_token))
            print( "Token: "..reg_token)
            print ( "Encrypted Text: " .. string.urlEncode(encryptedData) )

            local headers = {}
            local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&data="..string.urlEncode(encryptedData)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."registerUser.php", "POST", registerListener, params )
        end
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.usernameInput2.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.usernameInput2.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
    if (event.phase == "ended") then
        if ((string.len(myData.usernameInput2.text) < 4) or (string.len(myData.usernameInput2.text) > 18)) then
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" }, onClose )
        end
    end
end

local function onPasswordEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.passwordInput2.text = string.sub(event.text,1,30)
        end
    end
    if (event.phase == "ended") then
        if ((string.len(myData.passwordInput2.text) < 10) or (string.len(myData.passwordInput2.text) > 30)) then
            local alert = native.showAlert( "EliteHax", "Password must be between 10 and 30 characters!", { "Close" }, onClose )
        end
    end
end

local function onPasswordEdit2( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.passwordCInput2.text = string.sub(event.text,1,30)
        end
    end
    if (event.phase == "ended") then
        if (myData.passwordInput2.text ~= myData.passwordCInput2.text) then
            local alert = native.showAlert( "EliteHax", "Password and Confirm Password don't match", { "Close" }, onClose )
        end
    end
end

local function onMailEdit(event)
    if (event.phase == "ended") then
        local email = myData.emailInput.text 
        if (email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
            --print(email .. " is a valid email address")
        else
            local alert = native.showAlert( "EliteHax", email.." is not a valid email address", { "Close" }, onClose )
        end
    end
end

local function networkListener( event )
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

        if ( t.registration_token == nil) then
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it.", { "Close" }, onAlert )
        else
            reg_token = t.registration_token
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function registerScene:create(event)
    group = self.view

    iconSize=200

    --EliteHax Logo
    myData.logoImg = display.newImageRect( "img/icon_login.png",fontSize(350),fontSize(350) )
    myData.logoImg.anchorX = 0.5
    myData.logoImg.anchorY = 0.5
    myData.logoImg.x, myData.logoImg.y = display.contentWidth/2,fontSize(200)

    myData.logoRect = display.newRoundedRect( display.contentWidth/2, fontSize(175), display.contentWidth+100, fontSize(200), 12 )
    myData.logoRect.anchorY=0.5
    myData.logoRect.strokeWidth=5
    myData.logoRect.y=fontSize(200)
    myData.logoRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.logoRect:setFillColor(0,0,0,0.9)

    --Login Rect
    local rectHeight = display.actualContentHeight/(1.6*display.actualContentHeight/display.contentHeight)
    myData.registerRect = display.newRoundedRect( display.contentWidth/2, myData.logoImg.y+myData.logoImg.height/2+fontSize(50)+rectHeight/2, display.contentWidth/1.2, rectHeight, 12 )
    myData.registerRect.anchorX = 0.5
    myData.registerRect.anchorY = 0.5
    myData.registerRect.strokeWidth = 5
    myData.registerRect:setFillColor( 0,0,0,0.7 )
    myData.registerRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.registerRect.alpha = 1

    --Username Text
    myData.userT = display.newText( "Username:", 0, 0, native.systemFont, fontSize(80) )
    myData.userT.anchorX=0.5
    myData.userT.anchorY=0
    myData.userT.x =  display.contentWidth/2
    myData.userT.y = myData.registerRect.y - myData.registerRect.height/2+40
    myData.userT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Username Input
    myData.usernameInput2 = native.newTextField( display.contentWidth/2, myData.userT.y+120, display.contentWidth/1.5, fontSize(85) )
    myData.usernameInput2.anchorX = 0.5
    myData.usernameInput2.anchorY = 0
    myData.usernameInput2.placeholder = "Username (4-18 characters)";

    --Password Text
    myData.passwordT = display.newText( "Password:", 0, 0, native.systemFont, fontSize(80) )
    myData.passwordT.anchorX=0.5
    myData.passwordT.anchorY=0
    myData.passwordT.x =  display.contentWidth/2
    myData.passwordT.y = myData.usernameInput2.y + myData.usernameInput2.height+20
    myData.passwordT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Password Input
    myData.passwordInput2 = native.newTextField( display.contentWidth/2, myData.passwordT.y+120, display.contentWidth/1.5, fontSize(85) )
    myData.passwordInput2.anchorX = 0.5
    myData.passwordInput2.anchorY = 0
    myData.passwordInput2.isSecure = true
    myData.passwordInput2.placeholder = "Password (10-30 characters)";

    --Password Confirm Text
    myData.passwordCT = display.newText( "Confirm Password:", 0, 0, native.systemFont, fontSize(80) )
    myData.passwordCT.anchorX=0.5
    myData.passwordCT.anchorY=0
    myData.passwordCT.x =  display.contentWidth/2
    myData.passwordCT.y = myData.passwordInput2.y + myData.passwordInput2.height+20
    myData.passwordCT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Password Confirm Input
    myData.passwordCInput2 = native.newTextField( display.contentWidth/2, myData.passwordCT.y+120, display.contentWidth/1.5, fontSize(85) )
    myData.passwordCInput2.anchorX = 0.5
    myData.passwordCInput2.anchorY = 0
    myData.passwordCInput2.isSecure = true
    myData.passwordCInput2.placeholder = "Confirm Password";

    --Email Text
    myData.emailT = display.newText( "E-Mail:", 0, 0, native.systemFont, fontSize(80) )
    myData.emailT.anchorX=0.5
    myData.emailT.anchorY=0
    myData.emailT.x =  display.contentWidth/2
    myData.emailT.y = myData.passwordCInput2.y + myData.passwordCInput2.height+20
    myData.emailT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Email Input
    myData.emailInput = native.newTextField( display.contentWidth/2, myData.emailT.y+120, display.contentWidth/1.5, fontSize(85) )
    myData.emailInput.anchorX = 0.5
    myData.emailInput.anchorY = 0
    myData.emailInput.placeholder = "E-Mail";

    myData.registerButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/3/2),
        top = myData.emailInput.y+myData.emailInput.height+40,
        width = display.contentWidth/3,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Register",
        labelColor = tableColor1,
        onEvent = sendRegisterBtn
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
        onEvent = goBack
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.logoRect)
    group:insert(myData.logoImg)
    group:insert(myData.registerRect)
    group:insert(myData.userT)
    group:insert(myData.usernameInput2)
    group:insert(myData.passwordT)
    group:insert(myData.passwordInput2)
    group:insert(myData.passwordCT)
    group:insert(myData.passwordCInput2)
    group:insert(myData.emailT)
    group:insert(myData.emailInput)
    group:insert(myData.registerButton)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.registerButton:addEventListener("tap",sendRegisterBtn)
    myData.usernameInput2:addEventListener( "userInput", onNameEdit )
    myData.passwordInput2:addEventListener( "userInput", onPasswordEdit )
    myData.passwordCInput2:addEventListener( "userInput", onPasswordEdit2 )
    myData.emailInput:addEventListener("userInput", onMailEdit )
end

-- Home Show
function registerScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "deviceid="..base64Encode(system.getInfo("deviceID"))
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRegistrationToken.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

function registerScene:destroy(event)
   if myData.usernameInput2 then
        myData.usernameInput2:removeSelf()
        myData.usernameInput2 = nil
   end
   if myData.passwordInput2 then
        myData.passwordInput2:removeSelf()
        myData.passwordInput2 = nil
   end
   if myData.passwordCInput2 then
        myData.passwordCInput2:removeSelf()
        myData.passwordCInput2 = nil
   end
   if myData.emailInput then
        myData.emailInput:removeSelf()
        myData.emailInput = nil
   end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
registerScene:addEventListener( "create", registerScene )
registerScene:addEventListener( "show", registerScene )
registerScene:addEventListener( "destroy", registerScene )
---------------------------------------------------------------------------------

return registerScene