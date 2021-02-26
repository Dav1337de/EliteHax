local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local crewDetailsScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    composer.hideOverlay( "fade",0 )
    detailsOverlay=false
end

local function onAlert()
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

        --Details
        myData.crewName.text = t.name
        myData.crewTag.text = "("..t.tag..")"
        if (string.len(t.desc)>20) then myData.crewDesc.size = fontSize(54) end
        myData.crewDesc.text = t.desc
        myData.crewStats.text = "Rank: "..format_thousand(t.crank).."\nMembers: "..t.members.."\nScore: "..format_thousand(t.cscore).."\n"
        if (t.tournament_best=="1") then
            myData.crewStats.text=myData.crewStats.text.."\nTournaments Won: "..t.tournament_won
        elseif (t.tournament_best=="0") then
            myData.crewStats.text=myData.crewStats.text
        else
            myData.crewStats.text=myData.crewStats.text.."\nBest Tournaments Rank: "..t.tournament_best
        end

    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewDetailsScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    diconSize=250

    myData.crewRect = display.newRoundedRect( 40, display.actualContentHeight/2, display.contentWidth-70, display.actualContentHeight /2.1, 12 )
    myData.crewRect.anchorX = 0
    myData.crewRect.anchorY = 0.5
    myData.crewRect.strokeWidth = 5
    myData.crewRect:setFillColor( 0,0,0 )
    myData.crewRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewRect.alpha = 1

    -- Crew Name
    myData.crewName = display.newText( "", 0, 0, native.systemFont, fontSize(80) )
    myData.crewName.anchorX=0.5
    myData.crewName.anchorY=0
    myData.crewName.x =  display.contentWidth/2
    myData.crewName.y = myData.crewRect.y-myData.crewRect.height/2+fontSize(80)
    myData.crewName:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Tag
    myData.crewTag = display.newText( "", 0, 0, native.systemFont, fontSize(80) )
    myData.crewTag.anchorX=0.5
    myData.crewTag.anchorY=0
    myData.crewTag.x =  display.contentWidth/2
    myData.crewTag.y = myData.crewName.y+myData.crewName.height+fontSize(20)
    myData.crewTag:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Desc
    myData.crewDesc = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.crewDesc.anchorX=0.5
    myData.crewDesc.anchorY=0
    myData.crewDesc.x =  display.contentWidth/2
    myData.crewDesc.y = myData.crewTag.y+myData.crewTag.height+fontSize(50)
    myData.crewDesc:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Stats
    myData.crewStats = display.newText( "", 0, 0, native.systemFont, fontSize(58) )
    myData.crewStats.anchorX=0
    myData.crewStats.anchorY=0
    myData.crewStats.x =  80
    myData.crewStats.y = myData.crewDesc.y+myData.crewDesc.height+fontSize(50)
    myData.crewStats:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",diconSize/2.5,diconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.crewRect.width+20, myData.crewRect.y-myData.crewRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.crewTag)
    group:insert(myData.crewDesc)
    group:insert(myData.crewStats)
    group:insert(myData.closeBtn)

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function crewDetailsScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&crew_id="..params.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewDetails.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewDetailsScene:addEventListener( "create", crewDetailsScene )
crewDetailsScene:addEventListener( "show", crewDetailsScene )
---------------------------------------------------------------------------------

return crewDetailsScene