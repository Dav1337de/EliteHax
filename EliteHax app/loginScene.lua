local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loginScene = composer.newScene()
local openssl = require("plugin.openssl")
local loadsave = require( "loadsave" )
local gpgs = require( "plugin.gpgs" )
local emailG = ""
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

local function onClose( event )
end

local function skinNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occurred...Err: 1", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            skinColor="green"
        else
            skinColor=t.skin
            --skinColor="orange"
        end
        applySkin(skinColor)
        composer.removeScene( "loginScene" )
        composer.gotoScene("homeScene")
    end
end

function loginSucceeded(token)
    --local alert = native.showAlert( "EliteHax", "Logged In!!\nID: "..player_id, { "Close" }, onClose )
    local loginStatus = {
        token = token
    }
    loadsave.saveTable( loginStatus, "loginStatus.json" )
    loginInfo = localToken()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getSkin.php", "POST", skinNetworkListener, params )
end

local function loginListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        end

        if (t.status == "KO") then
            local alert = native.showAlert( "EliteHax", "Username or Password incorrect..", { "Close" }, onClose )
        elseif (t.status == "ANON") then
            local alert = native.showAlert( "EliteHax", "You cannot login to EliteHax with an anonymous connection.\nIf you need to use a proxy please contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.status == "BAN") then
            local alert = native.showAlert( "EliteHax", "You have been banned from EliteHax.\nReason: "..t.reason.."\nIf you have any question, please contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.status == "TME") then
            local alert = native.showAlert( "EliteHax", "Too many failed attempts! Wait 15 minutes before trying again..", { "Close" }, onClose )
        elseif (t.status == "OK") then
            if (t.BAN_WARNING == "Y") then
                local alert = native.showAlert( "EliteHax", "Your account is under review for Terms and Conditions violation.\nReason: "..t.BAN_REASON.."\nIf you have any question, please contact support@elitehax.it", { "Close" } )
            end
            loginSucceeded(t.token)
        else
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        end
    end
end

local function loginGListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        end

        if (t.status == "KO") then
            local alert = native.showAlert( "EliteHax", "Google Play Game Services Authentication Failed\nPlease make sure to allow the required permission and try again.\nIf the issue persists, please contact support@elitehax.it", { "Close" } )
        elseif (t.status == "ANON") then
            local alert = native.showAlert( "EliteHax", "You cannot login to EliteHax with an anonymous connection.\nIf you need to use a proxy please contact support@elitehax.it", { "Close" }, onClose )
        elseif (t.status == "BAN") then
            local alert = native.showAlert( "EliteHax", "You have been banned from EliteHax.\nReason: "..t.reason.."\nIf you have any question, please contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.status == "NR") then
            --local alert = native.showAlert( "EliteHax", "Not yet registered", { "Close" } )
            print("Not yet registered")
            print(t.registration_token)
            --Remove!
            myData.usernameInput.isVisible=false
            myData.passwordInput.isVisible=false
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                   reg_token=t.registration_token,
                },
                isModal = true
            }
            composer.showOverlay( "registerWithGoogleScene", sceneOverlayOptions)  
        elseif (t.status == "OK") then
            if (t.BAN_WARNING == "Y") then
                local alert = native.showAlert( "EliteHax", "Your account is under review for Terms and Conditions violation.\nReason: "..t.BAN_REASON.."\nIf you have any question, please contact support@elitehax.it", { "Close" } )
            end
            loginSucceeded(t.token)
        else
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        end
    end
end

local function sendLoginBtn( event )
    if (event.phase == "ended") then
        --Validate Username length and chars
        local user = myData.usernameInput.text
        local passwd = myData.passwordInput.text
        if ((string.len(user) < 4) or (string.len(user) > 18)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" }, onClose )
        elseif (user:match("[%a%d%.%!%_%-%s]") == false) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Your username contains invalid characters\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" }, onClose )
        elseif ((string.len(passwd) < 10) or (string.len(passwd) > 30)) then
            backSound()
            local alert = native.showAlert( "EliteHax", "Password must be between 10 and 30 characters!", { "Close" }, onClose )
        else
            tapSound()
            local jsonRequest = {["user"] = user, ["password"] = passwd}
            jsonRequest = json.encode(jsonRequest)
            local encryptedData = base64Encode(cipher:encrypt(jsonRequest,login_token))
            print( "Token: "..login_token)
            print ( "Encrypted Text: " .. string.urlEncode(encryptedData) )

            local headers = {}
            local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&data="..string.urlEncode(encryptedData)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."login.php", "POST", loginListener, params )
        end
    end
end

local function registerBtn( event )
    if (event.phase=="ended") then
        composer.removeScene( "loginScene" )
        tapSound()
        composer.gotoScene("registerScene")
    end
end

local function resetPwdBtn( event )
    if (event.phase=="ended") then
        composer.removeScene( "loginScene" )
        tapSound()
        composer.gotoScene("resetPwdScene")
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.usernameInput.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.usernameInput.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
    if (event.phase == "ended") then
        if ((string.len(myData.usernameInput.text) < 4) or (string.len(myData.usernameInput.text) > 18)) then
            local alert = native.showAlert( "EliteHax", "Username is between 4 and 18 characters!", { "Close" }, onClose )
        end
    end
end

local function onPasswordEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.passwordInput.text = string.sub(event.text,1,30)
        end
    end
    if (event.phase == "ended") then
        if ((string.len(myData.passwordInput.text) < 10) or (string.len(myData.passwordInput.text) > 30)) then
            local alert = native.showAlert( "EliteHax", "Password is between 10 and 30 characters!", { "Close" }, onClose )
        end
    end
end

local function networkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        elseif (t.BAN) then
            local alert = native.showAlert( "EliteHax", "You have been banned from EliteHax.\nReason: "..t.reason.."\nIf you have any question, please contact support@elitehax.it", { "Close" }, onAlert )
        elseif ( t.login_token == nil) then
            local alert = native.showAlert( "EliteHax", "Oops.. An error occured...\nPlease contact support@elitehax.it", { "Close" }, onAlert )
        else
            login_token = t.login_token
        end
    end
end

local function onAuthCode(event)
    print("Auth Code Function")
    print("Event Name: "..event.name)
    if (event.isError) then 
        print("Error message: " .. event.errorMessage)
        print("Error code: " .. event.errorCode)
        local alert = native.showAlert( "EliteHax", "Google Play Game Services Authentication Failed.\nIf the issue persists please contact support@elitehax.it", { "Close" } )
    else
        print("OAuth Code: "..event.code)
        local tempCode=event.code
        local jsonRequest = {["email"] = emailG, ["token"] = tempCode}
        jsonRequest = json.encode(jsonRequest)
        local encryptedDataTemp = base64Encode(cipher:encrypt(jsonRequest,login_token))
        --GitHub Note: add your encryption key here:
        local encryptedData = base64Encode(cipher:encrypt(encryptedDataTemp,"XXX"))
        print( "Token: "..login_token)
        print ( "Encrypted Text: " .. string.urlEncode(encryptedData) )

        local headers = {}
        local body = "deviceid="..base64Encode(system.getInfo("deviceID")).."&data="..string.urlEncode(encryptedData)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."loginG.php", "POST", loginGListener, params )
    end
end

local function onGpgs(e)
    if e.name == "init" and e.isError == false then
        print("GPGS initialized succesfully. Trying to log in.")
        gpgs.enableDebug()
        gpgs.login( {userInitiated = true, listener = onGpgs} )
    elseif e.name == "init" and e.isError == true then
        print("Error initializing GPGS.")
    elseif e.name == "login" and e.isError == false and e.phase == "logged in" then
        print("Login function returned LOGGED IN.")
        print("gonna try to get account name")
        gpgs.getAccountName( onGpgs )
    elseif e.name == "login" and e.isError == true then
        print("Error logging in.")
        print("Error message: " .. e.errorMessage)
        print("Error code: " .. e.errorCode)
        local alert = native.showAlert( "EliteHax", "Google Play Game Services Authentication Failed\nIf the issue persists please contact support@elitehax.it", { "Close" } )
        gpgs.getAccountName( onGpgs )
    elseif e.name == "getAccountName" and e.isError == false then
        print("Account name: " .. e.accountName)
        emailG = e.accountName
        --GitHub Note: add your serverId here:
        gpgs.getServerAuthCode( {serverId="XXX.apps.googleusercontent.com",listener = onAuthCode} )
    elseif e.name == "getAccountName" and e.isError == true then
        local alert = native.showAlert( "EliteHax", "Cannot login to Google Play Game Services.\nPlease try again, the authorization is required to verify your account.", { "Close" } )
    end
end

local function googleLogin( event )
    if (event.phase=="ended") then
        tapSound()
        gpgs.init( onGpgs )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function loginScene:create(event)
    group = self.view

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

    myData.newPlayerRect = display.newImageRect( "img/new_player_rect.png",display.contentWidth-40,fontSize(420) )
    myData.newPlayerRect.anchorX = 0.5
    myData.newPlayerRect.anchorY = 0
    myData.newPlayerRect.x, myData.newPlayerRect.y = display.contentWidth/2,myData.logoImg.y+myData.logoImg.height/2+fontSize(20)

    myData.googleLoginButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.2/2),
        top = myData.newPlayerRect.y+fontSize(120),
        width = display.contentWidth/1.2,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(68),
        label = "Play Now with Google Play!",
        labelColor = tableColor1,
        onEvent = googleLogin
    })

    myData.registerButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.2/2),
        top = myData.googleLoginButton.y+myData.googleLoginButton.height/2+20,
        width = display.contentWidth/1.2,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Register a New Account",
        labelColor = tableColor1,
        onEvent = registerBtn
    })

    --Login Rect
    myData.loginRect = display.newImageRect( "img/existing_player_rect.png",display.contentWidth-40,fontSize(1000) )
    myData.loginRect.anchorX = 0.5
    myData.loginRect.anchorY = 0
    myData.loginRect.x, myData.loginRect.y = display.contentWidth/2,myData.newPlayerRect.y+myData.newPlayerRect.height+fontSize(20)

    myData.googleLoginButton2 = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.2/2),
        top = myData.loginRect.y + fontSize(130),
        width = display.contentWidth/1.2,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(68),
        label = "Login with Google Play!",
        labelColor = tableColor1,
        onEvent = googleLogin
    })

    --Username Text
    myData.userT = display.newText( "Username:", 0, 0, native.systemFont, fontSize(68) )
    myData.userT.anchorX=0.5
    myData.userT.anchorY=0
    myData.userT.x =  display.contentWidth/2
    myData.userT.y = myData.googleLoginButton2.y+myData.googleLoginButton2.height/2+fontSize(30)
    myData.userT:setTextColor( textColor1[1], strokeColor1[2], strokeColor1[3] )

    --Username Input
    myData.usernameInput = native.newTextField( display.contentWidth/2, myData.userT.y+fontSize(90), display.contentWidth/1.5, fontSize(85) )
    myData.usernameInput.anchorX = 0.5
    myData.usernameInput.anchorY = 0
    myData.usernameInput.placeholder = "Username";

    --Password Text
    myData.passwordT = display.newText( "Password:", 0, 0, native.systemFont, fontSize(68) )
    myData.passwordT.anchorX=0.5
    myData.passwordT.anchorY=0
    myData.passwordT.x =  display.contentWidth/2
    myData.passwordT.y = myData.usernameInput.y + myData.usernameInput.height+fontSize(20)
    myData.passwordT:setTextColor( textColor1[1], textColor1[2], textColor1[3] )

    --Password Input
    myData.passwordInput = native.newTextField( display.contentWidth/2, myData.passwordT.y+fontSize(90), display.contentWidth/1.5, fontSize(85) )
    myData.passwordInput.anchorX = 0.5
    myData.passwordInput.anchorY = 0
    myData.passwordInput.isSecure = true
    myData.passwordInput.placeholder = "Password";

    myData.loginButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.2/2),
        top = myData.passwordInput.y+myData.passwordInput.height+40,
        width = display.contentWidth/1.2,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Login with credentials",
        labelColor = tableColor1,
        onEvent = sendLoginBtn
    })

    myData.resetPwdButton = widget.newButton(
    {
        left = display.contentWidth/2-(display.contentWidth/1.2/2),
        top = myData.loginButton.y+myData.loginButton.height/2+20,
        width = display.contentWidth/1.2,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Forgot Password?",
        labelColor = tableColor1,
        onEvent = resetPwdBtn
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
    group:insert(myData.newPlayerRect)
    group:insert(myData.loginRect)
    group:insert(myData.userT)
    group:insert(myData.usernameInput)
    group:insert(myData.passwordT)
    group:insert(myData.passwordInput)
    group:insert(myData.loginButton)
    group:insert(myData.registerButton)
    group:insert(myData.resetPwdButton)
    group:insert(myData.googleLoginButton)
    group:insert(myData.googleLoginButton2)

    --  Button Listeners
    myData.registerButton:addEventListener("tap",registerBtn)
    myData.usernameInput:addEventListener( "userInput", onNameEdit )
    myData.passwordInput:addEventListener( "userInput", onPasswordEdit )
    myData.loginButton:addEventListener("tap",sendLoginBtn)
    myData.resetPwdButton:addEventListener("tap",resetPwdBtn)
end

-- Home Show
function loginScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        backgroundLoginSound()

        local headers = {}
        local body = "deviceid="..base64Encode(system.getInfo("deviceID"))
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getLoginToken.php", "POST", networkListener, params )
    end
    if event.phase == "did" then
        --      
    end
end

function loginScene:destroy(event)
   if myData.usernameInput then
        myData.usernameInput:removeSelf()
        myData.usernameInput = nil
   end
   if myData.passwordInput then
        myData.passwordInput:removeSelf()
        myData.passwordInput = nil
   end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
loginScene:addEventListener( "create", loginScene )
loginScene:addEventListener( "show", loginScene )
loginScene:addEventListener( "destroy", loginScene )
---------------------------------------------------------------------------------

return loginScene