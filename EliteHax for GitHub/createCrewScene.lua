local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local createCrewScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    createOverlay=0
    backSound()
    composer.hideOverlay( "fade", 100 )
end

local function onAlert()
end

local function requestListener( event )

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

        if (t.status == "NE") then
            local alert = native.showAlert( "EliteHax", "Crew Name already exists!", { "Close" }, onAlert )
        end

        if (t.status == "TE") then
            local alert = native.showAlert( "EliteHax", "Crew TAG already exists!", { "Close" }, onAlert )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Crew succesfully created!", { "Close" }, onAlert )
            composer.hideOverlay( "fade", 400 )
            composer.removeScene( "newCrewScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 300})
        end

    end
end

local request = function(event)
    if (string.len(myData.crewNameT.text)<4) then
        backSound()
        local alert = native.showAlert( "EliteHax", "Crew Name must be at least 4 characters", { "Close" } )
    elseif (string.len(myData.crewNameT.text)>18) then
        backSound()
        local alert = native.showAlert( "EliteHax", "Crew Name is too long", { "Close" } )
    elseif (string.len(myData.crewTagT.text)<3) then
        backSound()
        local alert = native.showAlert( "EliteHax", "Crew Tag must be at least 3 characters", { "Close" } )   
    elseif (string.len(myData.crewTagT.text)>5) then
        backSound()
        local alert = native.showAlert( "EliteHax", "Crew Tag is too long", { "Close" } )      
    else
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&crew_name="..myData.crewNameT.text.."&crew_tag="..myData.crewTagT.text.."&crew_desc="..myData.crewDescT.text
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."createCrew.php", "POST", requestListener, params )    
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.crewNameT.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.crewNameT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function onTagEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>5) then
            myData.crewTagT.text = string.sub(event.text,1,5)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-]")) then
            myData.crewTagT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function onDescEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>35) then
            myData.crewDescT.text = string.sub(event.text,1,35)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.crewDescT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function createCrewScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    iconSize=250

    myData.crewRect = display.newRoundedRect( 40, display.contentHeight/2, display.contentWidth-70, display.contentHeight /2.4, 12 )
    myData.crewRect.anchorX = 0
    myData.crewRect.anchorY = 0.5
    myData.crewRect.strokeWidth = 5
    myData.crewRect:setFillColor( 0,0,0 )
    myData.crewRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    -- Crew Name
    myData.crewName = display.newText( "Crew Name: ", 0, 0, native.systemFont, 60 )
    myData.crewName.anchorX=0
    myData.crewName.anchorY=0
    myData.crewName.x =  80
    myData.crewName.y = myData.crewRect.y-myData.crewRect.height/2+150
    myData.crewName:setTextColor( 0.9, 0.9, 0.9 )
    myData.crewNameT = native.newTextField( myData.crewName.x+myData.crewName.width+30, myData.crewName.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.crewNameT.anchorX = 0
    myData.crewNameT.anchorY = 0
    myData.crewNameT.placeholder = "Crew Name (max 18)";

    -- Crew Tag
    myData.crewTag = display.newText( "Crew TAG: ", 0, 0, native.systemFont, 60 )
    myData.crewTag.anchorX=0
    myData.crewTag.anchorY=0
    myData.crewTag.x =  myData.crewName.x
    myData.crewTag.y = myData.crewName.y+myData.crewName.height+50
    myData.crewTag:setTextColor( 0.9, 0.9, 0.9 )
    myData.crewTagT = native.newTextField( myData.crewNameT.x, myData.crewTag.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.crewTagT.anchorX = 0
    myData.crewTagT.anchorY = 0
    myData.crewTagT.placeholder = "Crew Tag (max 5)";

    -- Crew Desc
    myData.crewDesc = display.newText( "Crew Description", 0, 0, native.systemFont, 60 )
    myData.crewDesc.anchorX=0.5
    myData.crewDesc.anchorY=0
    myData.crewDesc.x =  display.contentWidth/2
    myData.crewDesc.y = myData.crewTag.y+myData.crewTag.height+50
    myData.crewDesc:setTextColor( 0.9, 0.9, 0.9 )
    myData.crewDescT = native.newTextField( myData.crewTag.x, myData.crewDesc.y+80, display.contentWidth-150, fontSize(85) )
    myData.crewDescT.anchorX = 0
    myData.crewDescT.anchorY = 0
    myData.crewDescT.placeholder = "Crew Description (max 35)";

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.crewRect.width+20, myData.crewRect.y-myData.crewRect.height/2+20
    changeImgColor(myData.closeBtn)

    -- Request Button
    myData.requestButton = widget.newButton(
    {
        left = 40,
        top = myData.crewDescT.y+150,
        width = display.contentWidth/2,
        height = fontSize(100),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Create Crew",
        labelColor = tableColor1,
        --onEvent = manualScan
    })
    myData.requestButton.anchorX = 0.5
    myData.requestButton.x = display.contentWidth/2

    --  Show HUD    
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.crewTag)
    group:insert(myData.crewDesc)
    group:insert(myData.requestButton)
    group:insert(myData.crewNameT)
    group:insert(myData.crewTagT)
    group:insert(myData.crewDescT)
    group:insert(myData.closeBtn)

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)
    myData.requestButton:addEventListener("tap", request)
    myData.crewNameT:addEventListener( "userInput", onNameEdit )
    myData.crewTagT:addEventListener( "userInput", onTagEdit )
    myData.crewDescT:addEventListener( "userInput", onDescEdit )

end

-- Home Show
function createCrewScene:show(event)
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
createCrewScene:addEventListener( "create", createCrewScene )
createCrewScene:addEventListener( "show", createCrewScene )
---------------------------------------------------------------------------------

return createCrewScene