local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local dailyRewardScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    composer.hideOverlay( "fade",100 )
    timer.performWithDelay(100, function () chatOpen=0 return true end,1 )
end

local function onAlert()
end

local function showReward(event)
    rewardSound()
    local imageA = { type="image", filename=myData.rewardImg.newImg }
    myData.rewardImg.fill = imageA
    if ((myData.rewardImg.label ~= "Small Overclock Pack") and (myData.rewardImg.label ~= "Medium Overclock Pack") and (myData.rewardImg.label ~= "Large Overclock Pack")) then
        changeImgColor(myData.rewardImg)
    end
    myData.drReward.text=myData.rewardImg.label
    myData.drInstruction.text="Come back everyday to collect better rewards!"
    myData.drCloseButton.alpha=1
end

local function spinImage (event)
  transition.to( myData.rewardImg, { rotation = -1080, time=1500, onComplete=showReward} )
end

local function dailyRewardNetworkListener( event )

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

        if (t.current_activity==1) then
            myData.drName.text="Welcome "..myData.playerTextHome.text.."!"
            myData.drDays.text="This is the first day of your\nlogin streak!"
        else
            myData.drName.text="Welcome back "..myData.playerTextHome.text.."!"
            myData.drDays.text="You have been playing for\n"..t.current_activity.." consecutive days!"
        end
        myData.drInstruction.text="Tap on the pack to get your daily reward"

        if (t.reward=="small_packs") then
            myData.rewardImg.label="Small Pack"
            myData.rewardImg.newImg="img/small_packs.png"
        elseif (t.reward=="small_money") then
            myData.rewardImg.label="Small Money Pack"
            myData.rewardImg.newImg="img/small_money_packs.png"
        elseif (t.reward=="small_oc_packs") then
            myData.rewardImg.label="Small Overclock Pack"
            myData.rewardImg.newImg="img/small_overclock_pack.png"
        elseif (t.reward=="medium_packs") then
            myData.rewardImg.label="Medium Pack"
            myData.rewardImg.newImg="img/medium_packs.png"
        elseif (t.reward=="medium_money") then
            myData.rewardImg.label="Medium Money Pack"
            myData.rewardImg.newImg="img/medium_money_packs.png"
        elseif (t.reward=="medium_oc_packs") then
            myData.rewardImg.label="Medium Overclock Pack"
            myData.rewardImg.newImg="img/medium_overclock_pack.png"
        elseif (t.reward=="large_packs") then
            myData.rewardImg.label="Large Pack"
            myData.rewardImg.newImg="img/large_packs.png"
        elseif (t.reward=="large_money") then
            myData.rewardImg.label="Large Money Pack"
            myData.rewardImg.newImg="img/large_money_packs.png"
        elseif (t.reward=="large_oc_packs") then
            myData.rewardImg.label="Large Overclock Pack"
            myData.rewardImg.newImg="img/large_overclock_pack.png"
        elseif (t.reward=="ip_change") then
            myData.rewardImg.label="IP Change"
            myData.rewardImg.newImg="img/ip_change.png"
        elseif (t.reward=="skill_tree_reset") then
            myData.rewardImg.label="Skill Tree Reset"
            myData.rewardImg.newImg="img/st_reset.png"
        end

    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function dailyRewardScene:create(event)
    drGroup = self.view
    params = event.params

    loginInfo = localToken()

    diconSize=350

    myData.dailyRewardRect = display.newImageRect( "img/daily_reward.png",display.contentWidth*0.9, 1100 )
    myData.dailyRewardRect.anchorX = 0.5
    myData.dailyRewardRect.anchorY = 0.5
    myData.dailyRewardRect.x, myData.dailyRewardRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.dailyRewardRect)

    -- Welcome Message
    myData.drName = display.newText( "", 0, 0, native.systemFont, fontSize(58) )
    myData.drName.anchorX=0.5
    myData.drName.anchorY=0
    myData.drName.x =  display.contentWidth/2
    myData.drName.y = myData.dailyRewardRect.y-myData.dailyRewardRect.height/2+fontSize(100)
    myData.drName:setTextColor( 0.9, 0.9, 0.9 )

    -- Consecutive Days
    local options = 
    {
        text = "",     
        x = display.contentWidth/2,
        y = myData.drName.y+myData.drName.height+fontSize(20),
        width = 0,
        font = native.systemFont,   
        fontSize = fontSize(58),
        align = "center"  -- Alignment parameter
    }
    myData.drDays = display.newText( options )
    myData.drDays.anchorX=0.5
    myData.drDays.anchorY=0
    myData.drDays.x =  display.contentWidth/2
    myData.drDays.y = myData.drName.y+myData.drName.height+fontSize(20)
    myData.drDays:setTextColor( 0.9, 0.9, 0.9 )

    myData.rewardImg = display.newImageRect( "img/reward_unknown.png",fontSize(diconSize), fontSize(diconSize) )
    myData.rewardImg.anchorX = 0.5
    myData.rewardImg.anchorY = 0.5
    myData.rewardImg.x, myData.rewardImg.y = display.contentWidth/2,myData.drDays.y+myData.drDays.height+fontSize(280)
    changeImgColor(myData.rewardImg)
    myData.rewardImg.label=""
    myData.rewardImg.newImg=""
    myData.drReward = display.newText( options )
    myData.drReward.anchorX=0.5
    myData.drReward.anchorY=0
    myData.drReward.x =  display.contentWidth/2
    myData.drReward.y = myData.rewardImg.y+myData.rewardImg.height/2+fontSize(15)
    myData.drReward:setTextColor( 0.9, 0.9, 0.9 )

    -- Instructions
    local options = 
    {
        text = "",     
        x = display.contentWidth/2,
        y = myData.drName.y+myData.drName.height+fontSize(20),
        width = 0,
        font = native.systemFont,   
        fontSize = fontSize(44),
        align = "center"  -- Alignment parameter
    }
    myData.drInstruction = display.newText( options )
    myData.drInstruction.anchorX=0.5
    myData.drInstruction.anchorY=0
    myData.drInstruction.x =  display.contentWidth/2
    myData.drInstruction.y = myData.drReward.y+myData.drReward.height+fontSize(30)
    myData.drInstruction:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.drCloseButton = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.drInstruction.y+myData.drInstruction.height+fontSize(20),
        width = 500,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(75),
        label = "Close",
        labelColor = tableColor1,
        onRelease = close
    })
    myData.drCloseButton.x=display.contentWidth/2
    myData.drCloseButton.alpha=0

    --  Show HUD    
    drGroup:insert(myData.dailyRewardRect)
    drGroup:insert(myData.drName)
    drGroup:insert(myData.drDays)
    drGroup:insert(myData.rewardImg)
    drGroup:insert(myData.drReward)
    drGroup:insert(myData.drInstruction)
    drGroup:insert(myData.drCloseButton)

    --  Button Listeners
    myData.rewardImg:addEventListener("tap", spinImage)
    --myData.drCloseButton:addEventListener("tap", close)

end

-- Home Show
function dailyRewardScene:show(event)
    local taskdrGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getDailyReward.php", "POST", dailyRewardNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
dailyRewardScene:addEventListener( "create", dailyRewardScene )
dailyRewardScene:addEventListener( "show", dailyRewardScene )
---------------------------------------------------------------------------------

return dailyRewardScene