local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local resetPwdScene = composer.newScene()
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
    composer.removeScene( "resetPwdScene" )
    backSound()
    composer.gotoScene("loginScene", {effect = "fade", time = 300})
end

local function onClose()
end

local function onCompleted( event )
        composer.removeScene( "resetPwdScene" )
        composer.gotoScene( "loginScene", sceneOverlayOptions)
end

local function resetPwdListener( event )
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

        if (t.status == "PA") then
            local alert = native.showAlert( "EliteHax", "Please activate your account first", { "Close" }, goBack )
        elseif (t.status == "NA") then
            local alert = native.showAlert( "EliteHax", "Username or E-mail doesn't exist", { "Close" }, goBack )
        elseif (t.status == "WAIT") then
            local alert = native.showAlert( "EliteHax", "You already requested a password reset for your account!\nPlease wait at least 1 hour before requesting a new password reset", { "Close" }, goBack )
        elseif (t.status == "TME") then
            local alert = native.showAlert( "EliteHax", "Please wait 15 minutes before request a new password reset", { "Close" }, goBack )
        elseif (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "An e-mail has been sent to "..myData.emailInput.text.." with a link to reset your password!\nIf you can't find the email, please check the Spam folder.", { "Close" }, onCompleted )
        else
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        end
    end
end

local function resetPwdBtn( event )
    if (event.phase == "ended") then
        local user = myData.usernameInput2.text
        local email = myData.emailInput.text
        if ((string.len(user) < 4) or (string.len(user) > 18)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" }, onClose )
        elseif (user:match("[%a%d%.%!%_%-%s]") == false) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Your username contains invalid characters\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" }, onClose )
        elseif (string.len(email) < 4) then
            backSound()
            local alert = native.showAlert( "EliteHax", email.." is not a valid email address", { "Close" }, onClose )
        elseif (email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") == nil) then
            backSound()
            local alert = native.showAlert( "EliteHax", email.." is not a valid email address", { "Close" }, onClose )
        else
            tapSound()
            local jsonRequest = {["user"] = user, ["email"] = email}
            jsonRequest = json.encode(jsonRequest)
            local encryptedData = base64Encode(cipher:encrypt(jsonRequest,reg_token))
            local headers = {}
            local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&data="..string.urlEncode(encryptedData)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."resetPwd.php", "POST", resetPwdListener, params )
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
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        end

        if ( t.registration_token == nil) then
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        else
            reg_token = t.registration_token
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function resetPwdScene:create(event)
    group = self.view

    --App Name Rect
    myData.appNameRect = display.newRoundedRect( display.contentWidth/2, display.actualContentHeight/9+topPadding(), display.contentWidth/1.5, 200, 12 )
    myData.appNameRect.anchorX = 0.5
    myData.appNameRect.anchorY = 0.5
    myData.appNameRect.strokeWidth = 5
    myData.appNameRect:setFillColor( 0,0,0 )
    myData.appNameRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.appNameRect.alpha = 1

    --App Name
    myData.appNameT = display.newText( "EliteHax", 0, 0, native.systemFont, 150 )
    myData.appNameT.anchorX=0.5
    myData.appNameT.anchorY=0.5
    myData.appNameT.x =  display.contentWidth/2
    myData.appNameT.y = display.actualContentHeight/9+topPadding()
    myData.appNameT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Login Rect
    myData.registerRect = display.newRoundedRect( display.contentWidth/2, display.actualContentHeight/2+topPadding(), display.contentWidth/1.2, display.actualContentHeight/2.5, 12 )
    myData.registerRect.anchorX = 0.5
    myData.registerRect.anchorY = 0.5
    myData.registerRect.strokeWidth = 5
    myData.registerRect:setFillColor( 0,0,0,0.7 )
    myData.registerRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.registerRect.alpha = 1

    --Username Text
    myData.userT = display.newText( "Username:", 0, 0, native.systemFont, 80 )
    myData.userT.anchorX=0.5
    myData.userT.anchorY=0
    myData.userT.x =  display.contentWidth/2
    myData.userT.y = myData.registerRect.y - myData.registerRect.height/2+40
    myData.userT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Username Input
    myData.usernameInput2 = native.newTextField( display.contentWidth/2, myData.userT.y+120, display.contentWidth/1.5, 100 )
    myData.usernameInput2.anchorX = 0.5
    myData.usernameInput2.anchorY = 0
    myData.usernameInput2.placeholder = "Username (4-18 characters)";

    --Email Text
    myData.emailT = display.newText( "E-Mail:", 0, 0, native.systemFont, 80 )
    myData.emailT.anchorX=0.5
    myData.emailT.anchorY=0
    myData.emailT.x =  display.contentWidth/2
    myData.emailT.y = myData.usernameInput2.y + myData.usernameInput2.height+20
    myData.emailT:setTextColor( textColor1[1],textColor1[2],textColor1[3] )

    --Email Input
    myData.emailInput = native.newTextField( display.contentWidth/2, myData.emailT.y+120, display.contentWidth/1.5, 100 )
    myData.emailInput.anchorX = 0.5
    myData.emailInput.anchorY = 0
    myData.emailInput.placeholder = "E-Mail";

    myData.resetPwdButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.4/2),
        top = myData.emailInput.y+myData.emailInput.height+60+topPadding(),
        width = display.contentWidth/1.4,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Reset Password",
        labelColor = tableColor1,
        onEvent = resetPwdBtn
    })

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = 80,
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
    group:insert(myData.appNameRect)
    group:insert(myData.appNameT)
    group:insert(myData.registerRect)
    group:insert(myData.userT)
    group:insert(myData.usernameInput2)
    group:insert(myData.emailT)
    group:insert(myData.emailInput)
    group:insert(myData.resetPwdButton)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.resetPwdButton:addEventListener("tap",resetPwdBtn)
    myData.usernameInput2:addEventListener( "userInput", onNameEdit )
    myData.emailInput:addEventListener("userInput", onMailEdit )

end

-- Home Show
function resetPwdScene:show(event)
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

function resetPwdScene:destroy(event)
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
resetPwdScene:addEventListener( "create", resetPwdScene )
resetPwdScene:addEventListener( "show", resetPwdScene )
resetPwdScene:addEventListener( "destroy", resetPwdScene )
---------------------------------------------------------------------------------

return resetPwdScene