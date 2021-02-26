local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local widget = require( "widget" )
local loadsave = require( "loadsave" )
local statisticsScene = composer.newScene()
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

local goBack = function(event)
    if (event.phase=="ended") then
        backSound()
        composer.gotoScene("playerScene", {effect = "fade", time = 100})
    end
end

function goBackPlayerStat(event)
    if (tutOverlay==false) then
        backSound()
        composer.gotoScene("playerScene", {effect = "fade", time = 100})
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

        --Attack&Defense Rate = 0
        if (t.attack == "0") then
            attack_wr = 0
            attack_lr = 0
        else
            attack_wr = t.attack_w/t.attack*100
            attack_lr = t.attack_l/t.attack*100
        end
        if (t.defense == "0") then
            defense_wr = 0
            defense_lr = 0
        else
            defense_wr = t.defense_w/t.defense*100
            defense_lr = t.defense_l/t.defense*100
        end
        --Attack Stats
		myData.attackMStat.text = "Attacks: "..format_thousand(t.attack).."\nAttacks Won: "..format_thousand(t.attack_w).." ("..string.format("%4.2f",attack_wr).."%)\nAttacks Lost: "..format_thousand(t.attack_l).." ("..string.format("%4.2f",attack_lr).."%)"
        myData.defenseMStat.text = "Defenses: "..format_thousand(t.defense).."\nDefenses Won: "..format_thousand(t.defense_w).." ("..string.format("%4.2f",defense_wr).."%)\nDefenses Lost: "..format_thousand(t.defense_l).." ("..string.format("%4.2f",defense_lr).."%)"
        myData.moneyMStat.text = "Money Won: +$"..format_thousand(t.money_w).."\nMoney Lost: -$"..format_thousand(t.money_l).."\nBest Attack: +$"..format_thousand(t.best_attack).."\nHighest Loss: -$"..format_thousand(t.worst_defense)
        myData.upgradesMStat.text = "Total Upgrades: "..format_thousand(t.upgrades).."\nMoney Spent: $"..format_thousand(t.money_spent)
        --Money
        myData.moneyTextS.text = format_thousand(t.money)

        --Statistic
        if (string.len(t.user)>15) then myData.playerTextS.size = fontSize(42) end
        myData.playerTextS.text = t.user

    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function statisticsScene:create(event)
	local group = self.view

    loginInfo = localToken()
    iconSize=300

    --TOP
    myData.top_backgroundStat = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_backgroundStat.anchorX = 0.5
    myData.top_backgroundStat.anchorY = 0
    myData.top_backgroundStat.x, myData.top_backgroundStat.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_backgroundStat)

    --Money
    myData.moneyTextS = display.newText("",115,myData.top_backgroundStat.y+myData.top_backgroundStat.height/2,native.systemFont, fontSize(48))
    myData.moneyTextS.anchorX = 0
    myData.moneyTextS.anchorY = 0.5
    myData.moneyTextS:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextS = display.newText("",display.contentWidth-250,myData.top_backgroundStat.y+myData.top_backgroundStat.height/2,native.systemFont, fontSize(48))
    myData.playerTextS.anchorX = 0.5
    myData.playerTextS.anchorY = 0.5
    myData.playerTextS:setFillColor( 0.9,0.9,0.9 )

-- Attacking Stats Rectangle
    myData.attackRect = display.newImageRect( "img/statistics_attack.png",display.contentWidth-20,fontSize(320))
    myData.attackRect.anchorX=0.5
    myData.attackRect.anchorY=0
    myData.attackRect.x, myData.attackRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10
    changeImgColor(myData.attackRect)

    --Attacking Statistic
    myData.attackMStat = display.newText("",myData.attackRect.x-myData.attackRect.width/2+40, myData.attackRect.y+fontSize(100) ,native.systemFont, fontSize(52))
    myData.attackMStat.anchorX = 0
    myData.attackMStat.anchorY = 0
    myData.attackMStat:setFillColor( 0.9,0.9,0.9 )

    -- Defense Stats Rectangle
    myData.defenseRect = display.newImageRect( "img/statistics_defense.png",display.contentWidth-20,fontSize(320))
    myData.defenseRect.anchorX=0.5
    myData.defenseRect.anchorY=0
    myData.defenseRect.x, myData.defenseRect.y = display.contentWidth/2,myData.attackRect.y+myData.attackRect.height
    changeImgColor(myData.defenseRect)

    --Defense Statistic
    myData.defenseMStat = display.newText("",myData.attackRect.x-myData.attackRect.width/2+40, myData.defenseRect.y+fontSize(100),native.systemFont, fontSize(52))
    myData.defenseMStat.anchorX = 0
    myData.defenseMStat.anchorY = 0
    myData.defenseMStat:setFillColor( 0.9,0.9,0.9 )

    -- Money Stats Rectangle
    myData.moneyRect = display.newImageRect( "img/statistics_money.png",display.contentWidth-20,fontSize(380))
    myData.moneyRect.anchorX=0.5
    myData.moneyRect.anchorY=0
    myData.moneyRect.x, myData.moneyRect.y = display.contentWidth/2,myData.defenseRect.y+myData.defenseRect.height
    changeImgColor(myData.moneyRect)

    --Money Statistic
    myData.moneyMStat = display.newText("",myData.attackRect.x-myData.attackRect.width/2+40, myData.moneyRect.y+fontSize(100) ,native.systemFont, fontSize(52))
    myData.moneyMStat.anchorX = 0
    myData.moneyMStat.anchorY = 0
    myData.moneyMStat:setFillColor( 0.9,0.9,0.9 )

    -- Upgrade Stats Rectangle
    myData.upgradesRect = display.newImageRect( "img/statistics_upgrade.png",display.contentWidth-20,fontSize(300))
    myData.upgradesRect.anchorX=0.5
    myData.upgradesRect.anchorY=0
    myData.upgradesRect.x, myData.upgradesRect.y = display.contentWidth/2,myData.moneyRect.y+myData.moneyRect.height
    changeImgColor(myData.upgradesRect)

    --Upgrades Statistic
    myData.upgradesMStat = display.newText("",myData.attackRect.x-myData.attackRect.width/2+40, myData.upgradesRect.y+fontSize(110),native.systemFont, fontSize(52))
    myData.upgradesMStat.anchorX = 0
    myData.upgradesMStat.anchorY = 0
    myData.upgradesMStat:setFillColor( 0.9,0.9,0.9 )

    --Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.1
    changeImgColor(myData.background)

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

    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.attackRect)
    group:insert(myData.attackMStat)
    group:insert(myData.defenseRect)
    group:insert(myData.defenseMStat)
    group:insert(myData.moneyRect)
    group:insert(myData.moneyMStat)
    group:insert(myData.upgradesRect)
    group:insert(myData.upgradesMStat)
    group:insert(myData.top_backgroundStat)
	group:insert(myData.moneyTextS)
	group:insert(myData.playerTextS)

--	Button Listeners
	myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function statisticsScene:show(event)
	local homeGroup = self.view
	if event.phase == "will" then
		-- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "playerStatTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutPlayerStat ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "playerStatTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
		network.request( host().."getStats.php", "POST", networkListener, params )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
statisticsScene:addEventListener( "create", statisticsScene )
statisticsScene:addEventListener( "show", statisticsScene )
---------------------------------------------------------------------------------

return statisticsScene