local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local feedbackScene = composer.newScene()
local params = nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    composer.hideOverlay( "fade", 0 )
end

local function feedbackListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
    else
        print ( "RESPONSE1: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        end
        local alert = native.showAlert( "EliteHax", "Thanks for your feedback!", { "Close" }, close )
    end
end

local function sendFeedback( event )
    if ((event.phase == "ended") and (string.len(myData.feedbackNameT.text) > 0)) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q="..params.q.."&a="..params.a.."&f="..base64Encode(myData.feedbackNameT.text)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
    end
end

local function onFeedbackEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>350) then
            myData.feedbackNameT.text = string.sub(event.text,1,350)
        end
    end
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function feedbackScene:create(event)
    NCgroup = self.view
    params = event.params

    loginInfo = localToken()

    myData.feedbackRect =  display.newImageRect( "img/feedback_rect.png",display.contentWidth-70,fontSize(700) )
    myData.feedbackRect.anchorX = 0
    myData.feedbackRect.anchorY = 0.5
    myData.feedbackRect.x,myData.feedbackRect.y = 40, display.contentHeight/2
    changeImgColor(myData.feedbackRect)

    local text = ""
    if ((params.q == 1) and (params.a == "y")) then
        text="How can we improve EliteHax?"
    elseif ((params.q == 1) and (params.a == "n")) then
        text="What you don't like about EliteHax?"
    end

    myData.feedbackName = display.newText( text, 0, 0, native.systemFont, fontSize(58) )
    myData.feedbackName.anchorX=0.5
    myData.feedbackName.anchorY=0
    myData.feedbackName.x = display.contentWidth/2
    myData.feedbackName.y = myData.feedbackRect.y-myData.feedbackRect.height/2+fontSize(130)
    myData.feedbackName:setTextColor( 0.9, 0.9, 0.9 )
    myData.feedbackNameT = native.newTextBox( display.contentWidth/2, myData.feedbackName.y+myData.feedbackName.height+fontSize(20), display.contentWidth/1.3, fontSize(285) )
    myData.feedbackNameT.isEditable = true
    myData.feedbackNameT.font = native.newFont( native.systemFontBold, fontSize(50) )
    myData.feedbackNameT.anchorX = 0.5
    myData.feedbackNameT.anchorY = 0
    myData.feedbackNameT.placeholder = "Write here your feedback (max: 350 characters)";
    myData.feedbackNameT:addEventListener( "userInput", onFeedbackEdit )

    -- Request Button
    myData.feedbackBtn = widget.newButton(
    {
        left = 40,
        top = myData.feedbackNameT.y+myData.feedbackNameT.height+fontSize(30),
        width = display.contentWidth/2,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Send Feedback",
        labelColor = tableColor1,
        onEvent = sendFeedback
    })
    myData.feedbackBtn.fn="buy"
    myData.feedbackBtn.anchorX = 0.5
    myData.feedbackBtn.x = display.contentWidth/2

    myData.feedbackBtn:addEventListener("tap", sendFeedback)

    --  Show HUD    
    NCgroup:insert(myData.feedbackRect)
    NCgroup:insert(myData.feedbackName)
    NCgroup:insert(myData.feedbackBtn)
    NCgroup:insert(myData.feedbackNameT)
end

-- Home Show
function feedbackScene:show(event)
    local taskNCgroup = self.view
    if event.phase == "will" then
    ---
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
feedbackScene:addEventListener( "create", feedbackScene )
feedbackScene:addEventListener( "show", feedbackScene )
---------------------------------------------------------------------------------

return feedbackScene