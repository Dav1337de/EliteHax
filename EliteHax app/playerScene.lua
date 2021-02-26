local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local widget = require ("widget")
local playerScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
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

local function goToSkillTree(event)
    tapSound()
    composer.removeScene("playerScene")
    composer.gotoScene("skillTreeScene", {effect = "fade", time = 100})
end

local function goToPlayerSettings(event)
    tapSound()
    composer.removeScene("playerScene")
    composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
end

local function goToStats(event)
    tapSound()
    composer.removeScene("playerScene")
    composer.gotoScene("statisticsScene", {effect = "fade", time = 100})
end

function goBackPlayer(event)
    if (tutOverlay==false) then
        backSound()
        if (detailsOverlay==true) then
            detailsOverlay=false
            composer.hideOverlay( "fade",0 )
        else
            composer.removeScene("playerScene")
            composer.gotoScene("homeScene", {effect = "fade", time = 100})     
        end   
    end
end

local goBack = function(event)
    if (event.phase=="ended") then
        backSound()
        composer.removeScene("playerScene")
        composer.gotoScene("homeScene", {effect = "fade", time = 100})
    end
end

local function playerNetworkListener( event )

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

        if (t.crew == "Y") then
            crew_name = t.crew_name
        else
            crew_name = "None"
        end

        if (t.pic==1) then
            local playerPic= { type="image", filename="img/profile_pic_black.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==2) then
            local playerPic= { type="image", filename="img/profile_pic_gray.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==3) then
            local playerPic= { type="image", filename="img/profile_pic_ghost.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==4) then
            local playerPic= { type="image", filename="img/profile_pic_pirate.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==5) then
            local playerPic= { type="image", filename="img/profile_pic_ninja.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==6) then
            local playerPic= { type="image", filename="img/profile_pic_anon.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==7) then
            local playerPic={ type="image", filename="img/profile_pic_cyborg.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==8) then
            local playerPic={ type="image", filename="img/profile_pic_wolf.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==9) then
            local playerPic={ type="image", filename="img/profile_pic_tiger.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==10) then
            local playerPic={ type="image", filename="img/profile_pic_santa.png" }
            myData.playerImg.fill=playerPic
        elseif (t.pic==11) then
            local playerPic={ type="image", filename="img/profile_pic_gas_mask.png" }
            myData.playerImg.fill=playerPic
        end

        --Name and IP
        myData.playerName.text = "Player Name:\n"..t.user.."\n\nIP Address: \n"..t.ip

        --Main Stats
		myData.playerMStat.text = "Score: "..t.score.."          Reputation: "..t.reputation.."\n\nRank: "..t.rank.."\n\nCrew: "..crew_name

        --Money
        myData.moneyTextP.text = format_thousand(t.money)

        --Player
        if (string.len(t.user)>15) then myData.playerTextP.size = fontSize(42) end
        myData.playerTextP.text = t.user

        --Skill Points
        myData.skillText.text=t.skill_points

        --XP Progress View
        local percent=((t.xp-t.base_xp)/(t.next_lvl-t.base_xp))
        myData.xpProgressView:setProgress( percent )
        myData.xpText.text="XP: "..t.xp.."/"..t.next_lvl
        myData.lvlText.text="Level: "..t.lvl
    end
end

local function previewProfile( event )
    if (event.phase=="ended") then
        detailsOverlay=true
        local sceneOverlayOptions = 
        {
            time = 200,
            effect = "crossFade",
            params = { 
                id = myData.playerTextP.text
            },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "playerDetailsScene", sceneOverlayOptions)
    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function playerScene:create(event)
	local group = self.view
    loginInfo = localToken()

    iconSize=300
    detailsOverlay=false

    --TOP
    myData.top_backgroundP = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_backgroundP.anchorX = 0.5
    myData.top_backgroundP.anchorY = 0
    myData.top_backgroundP.x, myData.top_backgroundP.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_backgroundP)

    --Money
    myData.moneyTextP = display.newText("",115,myData.top_backgroundP.y+myData.top_backgroundP.height/2,native.systemFont, fontSize(48))
    myData.moneyTextP.anchorX = 0
    myData.moneyTextP.anchorY = 0.5
    myData.moneyTextP:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextP = display.newText("",display.contentWidth-250,myData.top_backgroundP.y+myData.top_backgroundP.height/2,native.systemFont, fontSize(48))
    myData.playerTextP.anchorX = 0.5
    myData.playerTextP.anchorY = 0.5
    myData.playerTextP:setFillColor( 0.9,0.9,0.9 )

    --Player Details Rectangle
    myData.pDetailsRect = display.newImageRect( "img/player_details_rect.png",display.contentWidth-80,fontSize(650))
    myData.pDetailsRect.anchorX=0.5
    myData.pDetailsRect.anchorY=0
    myData.pDetailsRect.x, myData.pDetailsRect.y = display.contentWidth/2,myData.top_backgroundP.y+myData.top_backgroundP.height
    changeImgColor(myData.pDetailsRect)

    -- Player Image
    myData.playerImg = display.newImageRect( "img/profile_pic.png",fontSize(350),fontSize(350) )
    myData.playerImg.anchorX = 0
    myData.playerImg.anchorY = 0
    myData.playerImg.x, myData.playerImg.y = myData.pDetailsRect.x-myData.pDetailsRect.width/2+50,myData.pDetailsRect.y+fontSize(110)

    --Player Name
    myData.playerName = display.newText("Player Name:\n",myData.playerImg.x+myData.playerImg.width+50,myData.playerImg.y+fontSize(35) ,native.systemFont, fontSize(55))
    myData.playerName.anchorX = 0
    myData.playerName.anchorY = 0

    --Player Main Stats Rectangle
    myData.pMStatsRect = display.newImageRect( "img/player_mstat_rect.png",display.contentWidth-80,fontSize(550))
    myData.pMStatsRect.anchorX=0.5
    myData.pMStatsRect.anchorY=0
    myData.pMStatsRect.x, myData.pMStatsRect.y = display.contentWidth/2,myData.pDetailsRect.y+myData.pDetailsRect.height
    changeImgColor(myData.pMStatsRect)

    --Player Main Stats
    myData.playerMStat = display.newText("",myData.pMStatsRect.x-myData.pMStatsRect.width/2+40, myData.pMStatsRect.y+fontSize(120),native.systemFont, fontSize(55))
    myData.playerMStat.anchorX = 0
    myData.playerMStat.anchorY = 0
    
    myData.previewButton = widget.newButton(
        {
            left = myData.pMStatsRect.x-50,
            top = myData.pMStatsRect.y+myData.pMStatsRect.height/2-fontSize(40),
            width = 450,
            height = display.actualContentHeight/15-5,
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(55),
            label = "Preview Profile",
            labelColor = tableColor1,
            onEvent = previewProfile
        }
    )

    --Player Settings
    myData.setting = display.newImageRect( "img/player_setting.png",iconSize,iconSize )
    myData.setting.anchorX = 1
    myData.setting.anchorY = 0
    myData.setting.x, myData.setting.y = iconSize+50,myData.pMStatsRect.y+myData.pMStatsRect.height+20
    changeImgColor(myData.setting)

    --Player Stats
    myData.stats = display.newImageRect( "img/player_stats.png",iconSize,iconSize )
    myData.stats.anchorX = 1
    myData.stats.anchorY = 0
    myData.stats.x, myData.stats.y = myData.setting.x+iconSize+30,myData.setting.y
    changeImgColor(myData.stats)

    --Player Skills
    myData.skill = display.newImageRect( "img/player_skills.png",iconSize,iconSize )
    myData.skill.anchorX = 1
    myData.skill.anchorY = 0
    myData.skill.x, myData.skill.y = myData.stats.x+iconSize+30,myData.setting.y
    changeImgColor(myData.skill)
    myData.skillCircle = display.newCircle( myData.skill.x-40,myData.skill.y+fontSize(40), fontSize(40) )
    myData.skillCircle:setFillColor( 0 )
    myData.skillCircle.strokeWidth = 5
    myData.skillCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.skillText = display.newText("",myData.skill.x-40,myData.skill.y+fontSize(40),native.systemFont, fontSize(50))
    myData.skillText.anchorX = 0.5
    myData.skillText.anchorY = 0.5
    myData.skillText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    -- Back Button
    myData.backButton = widget.newButton(
        {
            left = 20,
            top = display.actualContentHeight - (display.actualContentHeight/15) + topPadding(),
            width = display.contentWidth - 40,
            height = display.actualContentHeight/15-5,
            defaultFile = buttonColor1080,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(80),
            label = "Back",
            labelColor = tableColor1,
            onEvent = goBack
        }
    )

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.xpProgressView = widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillOuterWidth = 50,
            fillOuterHeight = 50,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            fillWidth = 50,
            fillHeight = 50,
            left = myData.pDetailsRect.x-myData.pDetailsRect.width/2+40,
            top = myData.pDetailsRect.y+myData.pDetailsRect.height-fontSize(90),
            width = myData.pDetailsRect.width-80,
            isAnimated = true
        }
    )    
    myData.lvlText = display.newText("",myData.playerImg.x+myData.playerImg.width/2,myData.playerImg.y+myData.playerImg.height+fontSize(35) ,native.systemFont, fontSize(50))
    myData.lvlText.anchorX = 0.5
    myData.lvlText.anchorY = 1
    myData.xpText = display.newText("",myData.pDetailsRect.x,myData.xpProgressView.y-30,native.systemFont, fontSize(48))
    myData.xpText.anchorX = 0.5
    myData.xpText.anchorY = 1

--	Show HUD	
	group:insert(myData.backButton)
    group:insert(myData.top_backgroundP)
    group:insert(myData.pDetailsRect)
	group:insert(myData.playerImg)
	group:insert(myData.playerName)
    group:insert(myData.pMStatsRect)
	group:insert(myData.playerMStat)
	group:insert(myData.setting)
	group:insert(myData.stats)
	group:insert(myData.skill)
    group:insert(myData.skillCircle)
    group:insert(myData.skillText)
	group:insert(myData.moneyTextP)
	group:insert(myData.playerTextP)
    group:insert(myData.lvlText)
    group:insert(myData.xpProgressView)
    group:insert(myData.xpText)
    group:insert(myData.previewButton)

--	Button Listeners
	myData.backButton:addEventListener("tap",goBack)
    myData.stats:addEventListener("tap",goToStats)
    myData.setting:addEventListener("tap",goToPlayerSettings)
    myData.skill:addEventListener("tap",goToSkillTree)
end

-- Home Show
function playerScene:show(event)
	local homeGroup = self.view
	if event.phase == "will" then
		-- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "playerTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutPlayer ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "playerTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
		network.request( host().."gethome.php", "POST", playerNetworkListener, params )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
playerScene:addEventListener( "create", playerScene )
playerScene:addEventListener( "show", playerScene )
---------------------------------------------------------------------------------

return playerScene