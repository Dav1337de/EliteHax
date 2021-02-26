local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local skillTreeScene = composer.newScene()
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

local function boundCheckST(x,y)
    if (myData.infoPanelST.alpha == 0) then
        return true
    elseif ((x > (myData.infoPanelST.x-myData.infoPanelST.width/2)) and (x < myData.infoPanelST.x+myData.infoPanelST.width/2) and (y > (myData.infoPanelST.y)) and (y < (myData.infoPanelST.y+myData.infoPanelST.height))) then
        return false
    else
        return true
    end
end

local showSTStat = function(event)
    if ((myData.lastSelectedUpgrade ~= event.target.name) and (boundCheckST(event.x,event.y))) then
        tapSound()
        lvl = event.target.lvl
        if (event.target.enabled==false) then 
            myData.upgradeSTButton.alpha=0 
        else
            myData.upgradeSTButton.alpha=1
        end
        if (lvl == 5) then 
            myData.infoTextST.text = event.target.name .. "\nLevel: "..lvl.."/5 - Maximum level reached"
            if (event.target.enabled==true) then myData.upgradeSTButton.alpha = 0 end
        else
            myData.infoTextST.text = event.target.name .. "\nLevel: "..lvl.."/5"
            if (event.target.enabled==true) then myData.upgradeSTButton.alpha = 1 end
        end

        myData.infoPanelST.alpha = 1
        myData.infoTextST2.text=event.target.desc.."\n"
        myData.lastSelectedUpgrade = event.target.name
        myData.toUpgradeST = event.target.toUpgradeST
        myData.infoPanelST.height = myData.infoTextST.height+myData.infoTextST2.height
        if ((event.target.name=="Risk Manager") or (event.target.name=="Penetration Tester") or (event.target.name=="Money Chaser") or (event.target.name=="Upgrades Expeditor") or (event.target.name=="Upgrades Negotiator") or (event.target.name=="Money Hider")) then
            myData.infoPanelST.x,myData.infoPanelST.y = display.contentWidth/2, event.target.y-myData.infoPanelST.height-10
        else
            myData.infoPanelST.x,myData.infoPanelST.y = display.contentWidth/2, event.target.y+event.target.height+10
        end
        myData.infoTextST.x,myData.infoTextST.y=myData.infoPanelST.x-myData.infoPanelST.width/2+20,myData.infoPanelST.y+20
        myData.infoTextST2.x,myData.infoTextST2.y=myData.infoTextST.x,myData.infoTextST.y+myData.infoTextST.height+fontSize(30)
        myData.upgradeSTButton.x,myData.upgradeSTButton.y=myData.infoPanelST.x+myData.infoPanelST.width/2-200,myData.infoPanelST.y+fontSize(80)
    elseif (boundCheckST(event.x,event.y) or (myData.lastSelectedUpgrade == event.target.name)) then
        backSound()
        myData.infoPanelST.alpha = 0
        myData.upgradeSTButton.alpha = 0
        myData.infoTextST.text = ""
        myData.infoTextST2.text = ""
        myData.lastSelectedUpgrade = ""
        myData.toUpgradeST = ""
    end
end

local function STnetworkListener( event )
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

        myData.playerTextST.text=t.username
        if (string.len(t.username)>15) then myData.playerTextST.size = fontSize(42) end
        myData.moneyTextST.text = format_thousand(t.money)

        if (t.skill_points=="1") then 
            myData.skillPointsText.text=t.skill_points.." Skill Point"
        else
            myData.skillPointsText.text=t.skill_points.." Skill Points"
        end
        myData.skillPointsText.sp=t.skill_points

        myData.hourlyIncomeS.lvl=t.st_hourly
        myData.pentester1S.lvl=t.st_pentester
        myData.developer1S.lvl=t.st_dev1
        myData.stealthS.lvl=t.st_stealth
        myData.missionRewardS.lvl=t.st_mission_reward
        myData.missionSpeedS.lvl=t.st_mission_speed
        myData.analystS.lvl=t.st_analyst
        myData.bankExploiterS.lvl=t.st_bank_exp
        myData.upgradeCostS.lvl=t.st_upgrade_cost
        myData.upgradeSpeedS.lvl=t.st_upgrade_speed
        myData.safePaymentS.lvl=t.st_safe_pay
        myData.pentester2S.lvl=t.st_pentester2
        myData.developer2S.lvl=t.st_dev2

        myData.hourlyIncomeS.txt.text=t.st_hourly.."/5"
        myData.pentester1S.txt.text=t.st_pentester.."/5"
        myData.developer1S.txt.text=t.st_dev1.."/5"
        myData.stealthS.txt.text=t.st_stealth.."/5"
        myData.missionRewardS.txt.text=t.st_mission_reward.."/5"
        myData.missionSpeedS.txt.text=t.st_mission_speed.."/5"
        myData.analystS.txt.text=t.st_analyst.."/5"
        myData.bankExploiterS.txt.text=t.st_bank_exp.."/5"
        myData.upgradeCostS.txt.text=t.st_upgrade_cost.."/5"
        myData.upgradeSpeedS.txt.text=t.st_upgrade_speed.."/5"
        myData.safePaymentS.txt.text=t.st_safe_pay.."/5"
        myData.pentester2S.txt.text=t.st_pentester2.."/5"
        myData.developer2S.txt.text=t.st_dev2.."/5"

        if ((t.st_bank_exp>0) and (t.st_pentester==5)) then
            local imageA = { type="image", filename=myData.pentester2S.src }
            myData.pentester2S.fill = imageA
            myData.pentester2S.txtb.alpha=1
            myData.pentester2S.txt.alpha=1
            myData.pentester2S.enabled=true 
            changeImgColor(myData.pentester2S)
        end
        if ((t.st_safe_pay>0) and (t.st_dev1==5)) then
            local imageA = { type="image", filename=myData.developer2S.src }
            myData.developer2S.fill = imageA
            myData.developer2S.txt.alpha=1
            myData.developer2S.txtb.alpha=1
            myData.developer2S.enabled=true
            changeImgColor(myData.developer2S)
        end
        if (t.st_stealth>0) then
            local imageA = { type="image", filename=myData.bankExploiterS.src }
            myData.bankExploiterS.fill = imageA
            myData.bankExploiterS.txt.alpha=1
            myData.bankExploiterS.txtb.alpha=1
            myData.bankExploiterS.enabled=true
            changeImgColor(myData.bankExploiterS)
        end
        if (t.st_mission_reward>0) then
            local imageA = { type="image", filename=myData.upgradeCostS.src }
            myData.upgradeCostS.fill = imageA
            myData.upgradeCostS.txt.alpha=1
            myData.upgradeCostS.txtb.alpha=1
            myData.upgradeCostS.enabled=true       
            changeImgColor(myData.upgradeCostS)
        end
        if (t.st_mission_speed>0) then
            local imageA = { type="image", filename=myData.upgradeSpeedS.src }
            myData.upgradeSpeedS.fill = imageA
            myData.upgradeSpeedS.txt.alpha=1
            myData.upgradeSpeedS.txtb.alpha=1
            myData.upgradeSpeedS.enabled=true
            changeImgColor(myData.upgradeSpeedS)
        end
        if (t.st_analyst>0) then
            local imageA = { type="image", filename=myData.safePaymentS.src }
            myData.safePaymentS.fill = imageA
            myData.safePaymentS.txt.alpha=1
            myData.safePaymentS.txtb.alpha=1 
            myData.safePaymentS.enabled=true 
            changeImgColor(myData.safePaymentS)
        end
        if (t.st_pentester>0) then
            local imageA = { type="image", filename=myData.stealthS.src }
            myData.stealthS.fill = imageA
            myData.stealthS.txt.alpha=1
            myData.stealthS.txtb.alpha=1
            myData.stealthS.enabled=true
            changeImgColor(myData.stealthS)
            local imageA = { type="image", filename=myData.missionRewardS.src }
            myData.missionRewardS.fill = imageA
            myData.missionRewardS.txt.alpha=1
            myData.missionRewardS.txtb.alpha=1
            myData.missionRewardS.enabled=true
            changeImgColor(myData.missionRewardS)
        end
        if (t.st_dev1>0) then
            local imageA = { type="image", filename=myData.missionSpeedS.src }
            myData.missionSpeedS.fill = imageA
            myData.missionSpeedS.txt.alpha=1
            myData.missionSpeedS.txtb.alpha=1
            myData.missionSpeedS.enabled=true
            changeImgColor(myData.missionSpeedS)
            local imageA = { type="image", filename=myData.analystS.src }
            myData.analystS.fill = imageA
            myData.analystS.txtb.alpha=1
            myData.analystS.txt.alpha=1      
            myData.analystS.enabled=true   
            changeImgColor(myData.analystS) 
        end

        if (t.st_hourly>0) then
            local imageA = { type="image", filename=myData.pentester1S.src }
            myData.pentester1S.fill = imageA
            myData.pentester1S.txt.alpha=1
            myData.pentester1S.txtb.alpha=1
            myData.pentester1S.enabled=true
            changeImgColor(myData.pentester1S)
            local imageA = { type="image", filename=myData.developer1S.src }
            myData.developer1S.fill = imageA
            myData.developer1S.txt.alpha=1
            myData.developer1S.txtb.alpha=1
            myData.developer1S.enabled=true
            changeImgColor(myData.developer1S)
        end
        upgradeSTClicked = 0
   end
end

local function upgradeSTListener( event )
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
        if ( t.status == "MAX_LVL") then
            myData.infoTextST.text =  myData.lastSelectedUpgrade  .. "\nLevel: 5/5 - Maximum level reached"
        end
        if ( t.status == "OK") then
            if (t.new_lvl == 5) then 
                myData.infoTextST.text = myData.lastSelectedUpgrade .. "\nLevel: 5/5 - Maximum level reached"
                myData.upgradeSTButton.alpha = 0
            else
                myData.infoTextST.text = myData.lastSelectedUpgrade .. "\nLevel: "..t.new_lvl.."/5"
                myData.upgradeSTButton.alpha = 1
            end
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getST.php", "POST", STnetworkListener, params )
    end
end

local function upgradeST( event )
    if ((upgradeSTClicked == 0) and (event.phase == "ended")) then
        if (tonumber(myData.skillPointsText.sp)>0) then
            upgradeSTClicked = 1  
            tapSound()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&type="..myData.toUpgradeST
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."upgradeST.php", "POST", upgradeSTListener, params )
        else
            local alert = native.showAlert( "EliteHax", "You don't have enough Skill Points", { "Close" } )
        end
    end
end

function goBackST(event)
    if (tutOverlay==false) then
        backSound()
        composer.removeScene( "skillTreeScene" )
        composer.gotoScene("playerScene", {effect = "fade", time = 100})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function skillTreeScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=fontSize(190)

    upgradeSTClicked=0

    --Top Money/Name Background
    myData.top_backgroundST = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_backgroundST.anchorX = 0.5
    myData.top_backgroundST.anchorY = 0
    myData.top_backgroundST.x, myData.top_backgroundST.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_backgroundST)

    --Money
    myData.moneyTextST = display.newText("",115,myData.top_backgroundST.y+myData.top_backgroundST.height/2,native.systemFont, fontSize(48))
    myData.moneyTextST.anchorX = 0
    myData.moneyTextST.anchorY = 0.5
    myData.moneyTextST:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextST = display.newText("",display.contentWidth-250,myData.top_backgroundST.y+myData.top_backgroundST.height/2,native.systemFont, fontSize(48))
    myData.playerTextST.anchorX = 0.5
    myData.playerTextST.anchorY = 0.5
    myData.playerTextST:setFillColor( 0.9,0.9,0.9 )

    --Skill Tree Rectangle
    myData.st_rect = display.newImageRect( "img/skill_tree_rect.png",display.contentWidth-20, fontSize(1660))
    myData.st_rect.anchorX = 0.5
    myData.st_rect.anchorY = 0
    myData.st_rect.x, myData.st_rect.y = display.contentWidth/2,myData.top_backgroundST.y+myData.top_backgroundST.height+10
    changeImgColor(myData.st_rect)

    myData.skillPointsLabel = display.newImageRect( "img/label.png",400, fontSize(80))
    myData.skillPointsLabel.anchorX = 0.5
    myData.skillPointsLabel.anchorY = 0
    myData.skillPointsLabel.x, myData.skillPointsLabel.y = display.contentWidth/2,myData.st_rect.y+fontSize(100)
    changeImgColor(myData.skillPointsLabel)
    myData.skillPointsText = display.newText("0 Skill Points",myData.skillPointsLabel.x,myData.skillPointsLabel.y+myData.skillPointsLabel.height/2,native.systemFont, fontSize(48))
    myData.skillPointsText.sp=0
    myData.skillPointsText.anchorX = 0.5
    myData.skillPointsText.anchorY = 0.5
    myData.skillPointsText:setFillColor( 0.9,0.9,0.9 )

    myData.st_bg = display.newImageRect( "img/skill_tree.png",1000, fontSize(1300))
    myData.st_bg.anchorX = 0.5
    myData.st_bg.anchorY = 0
    myData.st_bg.x, myData.st_bg.y = display.contentWidth/2,myData.skillPointsLabel.y+myData.skillPointsLabel.height+fontSize(50)
    changeImgColor(myData.st_bg)

    myData.hourlyIncomeS = display.newImageRect( "img/st_investor.png",iconSize, iconSize)
    myData.hourlyIncomeS.anchorX = 0.5
    myData.hourlyIncomeS.anchorY = 0
    myData.hourlyIncomeS.x, myData.hourlyIncomeS.y = display.contentWidth/2,myData.skillPointsLabel.y+myData.skillPointsLabel.height+fontSize(60)
    changeImgColor(myData.hourlyIncomeS)
    myData.hourlyIncomeS.name="Investor"
    myData.hourlyIncomeS.src="img/st_investor.png"
    myData.hourlyIncomeS.srch="img/st_investor.png"
    myData.hourlyIncomeS.enabled=true
    myData.hourlyIncomeS.toUpgradeST="st_hourly"
    myData.hourlyIncomeS.desc="Investor Skill enhances your investments and increases your hourly income.\n\n1 Skill Point = +20k Hourly Income, +5% Hourly Income\n"
    myData.hourlyIncomeS.lvl = 0
    myData.hourlyIncomeS.txtb = display.newRoundedRect(myData.hourlyIncomeS.x,myData.hourlyIncomeS.y+myData.hourlyIncomeS.height,120,fontSize(52),12)
    myData.hourlyIncomeS.txtb.anchorX=0.5
    myData.hourlyIncomeS.txtb.anchorY=1
    myData.hourlyIncomeS.txtb.strokeWidth = 5
    myData.hourlyIncomeS.txtb:setFillColor( 0,0,0 )
    myData.hourlyIncomeS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.hourlyIncomeS.txt = display.newText(myData.hourlyIncomeS.lvl.."/5",myData.hourlyIncomeS.txtb.x,myData.hourlyIncomeS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.hourlyIncomeS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    myData.pentester1S = display.newImageRect( "img/st_pentester1_hidden.png",iconSize, iconSize)
    myData.pentester1S.anchorX = 0.5
    myData.pentester1S.anchorY = 0
    myData.pentester1S.x, myData.pentester1S.y = display.contentWidth/4+18,myData.hourlyIncomeS.y+myData.hourlyIncomeS.height+fontSize(78)
    myData.pentester1S.name="Vulnerability Researcher"
    myData.pentester1S.src="img/st_pentester1.png"
    myData.pentester1S.srch="img/st_pentester1_hidden.png"
    myData.pentester1S.enabled=false
    myData.pentester1S.toUpgradeST="st_pentester"
    myData.pentester1S.desc="Vulnerability Researcher Skill enhances your exploits raising your chance of successfully attacking targets.\n\n1 Skill Point = +1% Success Chance with Exploit Attacks\n"
    myData.pentester1S.lvl = 0
    myData.pentester1S.txtb = display.newRoundedRect(myData.pentester1S.x,myData.pentester1S.y+myData.pentester1S.height,120,fontSize(52),12)
    myData.pentester1S.txtb.anchorX=0.5
    myData.pentester1S.txtb.anchorY=1
    myData.pentester1S.txtb.strokeWidth = 5
    myData.pentester1S.txtb:setFillColor( 0,0,0 )
    myData.pentester1S.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.pentester1S.txtb.alpha=0
    myData.pentester1S.txt = display.newText(myData.pentester1S.lvl.."/5",myData.pentester1S.txtb.x,myData.pentester1S.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.pentester1S.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.pentester1S.txt.alpha=0

    myData.developer1S = display.newImageRect( "img/st_dev1_hidden.png",iconSize, iconSize)
    myData.developer1S.anchorX = 0.5
    myData.developer1S.anchorY = 0
    myData.developer1S.x, myData.developer1S.y = display.contentWidth/4*3-20,myData.pentester1S.y
    myData.developer1S.name="Great Developer"
    myData.developer1S.src="img/st_dev1.png"
    myData.developer1S.srch="img/st_dev1_hidden.png"
    myData.developer1S.enabled=false
    myData.developer1S.toUpgradeST="st_dev1"
    myData.developer1S.desc="Great Developer Skill enhances the protection of your assets raising your chance of successfully defend against exploits.\n\n1 Skill Point = +1% Defending Chance from Exploit Attacks\n"
    myData.developer1S.lvl = 0
    myData.developer1S.txtb = display.newRoundedRect(myData.developer1S.x,myData.developer1S.y+myData.developer1S.height,120,fontSize(52),12)
    myData.developer1S.txtb.anchorX=0.5
    myData.developer1S.txtb.anchorY=1
    myData.developer1S.txtb.strokeWidth = 5
    myData.developer1S.txtb:setFillColor( 0,0,0 )
    myData.developer1S.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.developer1S.txtb.alpha=0
    myData.developer1S.txt = display.newText(myData.developer1S.lvl.."/5",myData.developer1S.txtb.x,myData.developer1S.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.developer1S.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.developer1S.txt.alpha=0

    myData.stealthS = display.newImageRect( "img/st_stealth_hidden.png",iconSize, iconSize)
    myData.stealthS.anchorX = 0.5
    myData.stealthS.anchorY = 0
    myData.stealthS.x, myData.stealthS.y = display.contentWidth/8+20,myData.developer1S.y+myData.developer1S.height+fontSize(70)
    myData.stealthS.name="Stealth"
    myData.stealthS.src="img/st_stealth.png"
    myData.stealthS.srch="img/st_stealth_hidden.png"
    myData.stealthS.enabled=false
    myData.stealthS.toUpgradeST="st_stealth"
    myData.stealthS.desc="Stealth Skill enhances your chance of being anonymous while attacking targets.\n\n1 Skill Point = +2% Anonymous chance\n"
    myData.stealthS.lvl = 0
    myData.stealthS.txtb = display.newRoundedRect(myData.stealthS.x,myData.stealthS.y+myData.stealthS.height,120,fontSize(52),12)
    myData.stealthS.txtb.anchorX=0.5
    myData.stealthS.txtb.anchorY=1
    myData.stealthS.txtb.strokeWidth = 5
    myData.stealthS.txtb:setFillColor( 0,0,0 )
    myData.stealthS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.stealthS.txtb.alpha=0
    myData.stealthS.txt = display.newText(myData.stealthS.lvl.."/5",myData.stealthS.txtb.x,myData.stealthS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.stealthS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.stealthS.txt.alpha=0

    myData.missionRewardS = display.newImageRect( "img/st_mission_reward_hidden.png",iconSize, iconSize)
    myData.missionRewardS.anchorX = 0.5
    myData.missionRewardS.anchorY = 0
    myData.missionRewardS.x, myData.missionRewardS.y = display.contentWidth/8*3+20,myData.stealthS.y
    myData.missionRewardS.name="Missions' Negotiator"
    myData.missionRewardS.src="img/st_mission_reward.png"
    myData.missionRewardS.srch="img/st_mission_reward_hidden.png"
    myData.missionRewardS.enabled=false
    myData.missionRewardS.toUpgradeST="st_mission_reward"
    myData.missionRewardS.desc="Missions' Negotiator Skill enhances the reward that you get from missions.\n\n1 Skill Point = +2% Mission Rewards\n"
    myData.missionRewardS.lvl = 0
    myData.missionRewardS.txtb = display.newRoundedRect(myData.missionRewardS.x,myData.missionRewardS.y+myData.missionRewardS.height,120,fontSize(52),12)
    myData.missionRewardS.txtb.anchorX=0.5
    myData.missionRewardS.txtb.anchorY=1
    myData.missionRewardS.txtb.strokeWidth = 5
    myData.missionRewardS.txtb:setFillColor( 0,0,0 )
    myData.missionRewardS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.missionRewardS.txtb.alpha=0
    myData.missionRewardS.txt = display.newText(myData.missionRewardS.lvl.."/5",myData.missionRewardS.txtb.x,myData.missionRewardS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.missionRewardS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.missionRewardS.txt.alpha=0

    myData.missionSpeedS = display.newImageRect( "img/st_mission_speed_hidden.png",iconSize, iconSize)
    myData.missionSpeedS.anchorX = 0.5
    myData.missionSpeedS.anchorY = 0
    myData.missionSpeedS.x, myData.missionSpeedS.y = display.contentWidth/8*5-20,myData.stealthS.y
    myData.missionSpeedS.name="Missions' Enthusiast"
    myData.missionSpeedS.src="img/st_mission_speed.png"
    myData.missionSpeedS.srch="img/st_mission_speed_hidden.png"
    myData.missionSpeedS.enabled=false
    myData.missionSpeedS.toUpgradeST="st_mission_speed"
    myData.missionSpeedS.desc="Missions' Enthusiast Skill reduces the time needed to complete missions.\n\n1 Skill Point = +2% Mission Speed\n"
    myData.missionSpeedS.lvl = 0
    myData.missionSpeedS.txtb = display.newRoundedRect(myData.missionSpeedS.x,myData.missionSpeedS.y+myData.missionSpeedS.height,120,fontSize(52),12)
    myData.missionSpeedS.txtb.anchorX=0.5
    myData.missionSpeedS.txtb.anchorY=1
    myData.missionSpeedS.txtb.strokeWidth = 5
    myData.missionSpeedS.txtb:setFillColor( 0,0,0 )
    myData.missionSpeedS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.missionSpeedS.txtb.alpha=0
    myData.missionSpeedS.txt = display.newText(myData.missionSpeedS.lvl.."/5",myData.missionSpeedS.txtb.x,myData.missionSpeedS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.missionSpeedS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.missionSpeedS.txt.alpha=0

    myData.analystS = display.newImageRect( "img/st_analyst_hidden.png",iconSize, iconSize)
    myData.analystS.anchorX = 0.5
    myData.analystS.anchorY = 0
    myData.analystS.x, myData.analystS.y = display.contentWidth/8*7-20,myData.stealthS.y
    myData.analystS.name="SOC Analyst"
    myData.analystS.src="img/st_analyst.png"
    myData.analystS.srch="img/st_analyst_hidden.png"
    myData.analystS.enabled=false
    myData.analystS.toUpgradeST="st_analyst"
    myData.analystS.desc="SOC Analyst Skill enhances your ability to detect the attackers IP addresses.\n\n1 Skill Point = +2% Detection Chance\n"
    myData.analystS.lvl = 0
    myData.analystS.txtb = display.newRoundedRect(myData.analystS.x,myData.analystS.y+myData.analystS.height,120,fontSize(52),12)
    myData.analystS.txtb.anchorX=0.5
    myData.analystS.txtb.anchorY=1
    myData.analystS.txtb.strokeWidth = 5
    myData.analystS.txtb:setFillColor( 0,0,0 )
    myData.analystS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.analystS.txtb.alpha=0
    myData.analystS.txt = display.newText(myData.analystS.lvl.."/5",myData.analystS.txtb.x,myData.analystS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.analystS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.analystS.txt.alpha=0

    myData.bankExploiterS = display.newImageRect( "img/st_bank_exp_hidden.png",iconSize, iconSize)
    myData.bankExploiterS.anchorX = 0.5
    myData.bankExploiterS.anchorY = 0
    myData.bankExploiterS.x, myData.bankExploiterS.y = display.contentWidth/8+20,myData.stealthS.y+myData.stealthS.height+fontSize(70)
    myData.bankExploiterS.name="Money Chaser"
    myData.bankExploiterS.src="img/st_bank_exp.png"
    myData.bankExploiterS.srch="img/st_bank_exp_hidden.png"
    myData.bankExploiterS.enabled=false
    myData.bankExploiterS.toUpgradeST="st_bank_exp"
    myData.bankExploiterS.desc="Money Chaser Skill increases the money that you steal by successfully attacking targets.\n\n1 Skill Point = +2% Money Stolen\n"
    myData.bankExploiterS.lvl = 0
    myData.bankExploiterS.txtb = display.newRoundedRect(myData.bankExploiterS.x,myData.bankExploiterS.y+myData.bankExploiterS.height,120,fontSize(52),12)
    myData.bankExploiterS.txtb.anchorX=0.5
    myData.bankExploiterS.txtb.anchorY=1
    myData.bankExploiterS.txtb.strokeWidth = 5
    myData.bankExploiterS.txtb:setFillColor( 0,0,0 )
    myData.bankExploiterS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.bankExploiterS.txtb.alpha=0
    myData.bankExploiterS.txt = display.newText(myData.bankExploiterS.lvl.."/5",myData.bankExploiterS.txtb.x,myData.bankExploiterS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.bankExploiterS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.bankExploiterS.txt.alpha=0

    myData.upgradeCostS = display.newImageRect( "img/st_mission_reward_hidden.png",iconSize, iconSize)
    myData.upgradeCostS.anchorX = 0.5
    myData.upgradeCostS.anchorY = 0
    myData.upgradeCostS.x, myData.upgradeCostS.y = display.contentWidth/8*3+20,myData.bankExploiterS.y
    myData.upgradeCostS.name="Upgrades Negotiator"
    myData.upgradeCostS.src="img/st_mission_reward.png"
    myData.upgradeCostS.srch="img/st_mission_reward_hidden.png"
    myData.upgradeCostS.enabled=false
    myData.upgradeCostS.toUpgradeST="st_upgrade_cost"
    myData.upgradeCostS.desc="Upgrades' Negotiator Skill decreases the cost of your upgrades.\n\n1 Skill Point = -2% Upgrade Cost\n"
    myData.upgradeCostS.lvl = 0
    myData.upgradeCostS.txtb = display.newRoundedRect(myData.upgradeCostS.x,myData.upgradeCostS.y+myData.upgradeCostS.height,120,fontSize(52),12)
    myData.upgradeCostS.txtb.anchorX=0.5
    myData.upgradeCostS.txtb.anchorY=1
    myData.upgradeCostS.txtb.strokeWidth = 5
    myData.upgradeCostS.txtb:setFillColor( 0,0,0 )
    myData.upgradeCostS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.upgradeCostS.txtb.alpha=0
    myData.upgradeCostS.txt = display.newText(myData.upgradeCostS.lvl.."/5",myData.upgradeCostS.txtb.x,myData.upgradeCostS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.upgradeCostS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeCostS.txt.alpha=0

    myData.upgradeSpeedS = display.newImageRect( "img/st_mission_speed_hidden.png",iconSize, iconSize)
    myData.upgradeSpeedS.anchorX = 0.5
    myData.upgradeSpeedS.anchorY = 0
    myData.upgradeSpeedS.x, myData.upgradeSpeedS.y = display.contentWidth/8*5-20,myData.bankExploiterS.y
    myData.upgradeSpeedS.name="Upgrades' Expeditor"
    myData.upgradeSpeedS.src="img/st_mission_speed.png"
    myData.upgradeSpeedS.srch="img/st_mission_speed_hidden.png"
    myData.upgradeSpeedS.enabled=false
    myData.upgradeSpeedS.toUpgradeST="st_upgrade_speed"
    myData.upgradeSpeedS.desc="Upgrades' Expeditor Skill decreases the time needed for your upgrades.\n\n1 Skill Point = +2% Upgrade Speed\n"
    myData.upgradeSpeedS.lvl = 0
    myData.upgradeSpeedS.txtb = display.newRoundedRect(myData.upgradeSpeedS.x,myData.upgradeSpeedS.y+myData.upgradeSpeedS.height,120,fontSize(52),12)
    myData.upgradeSpeedS.txtb.anchorX=0.5
    myData.upgradeSpeedS.txtb.anchorY=1
    myData.upgradeSpeedS.txtb.strokeWidth = 5
    myData.upgradeSpeedS.txtb:setFillColor( 0,0,0 )
    myData.upgradeSpeedS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.upgradeSpeedS.txtb.alpha=0
    myData.upgradeSpeedS.txt = display.newText(myData.upgradeSpeedS.lvl.."/5",myData.upgradeSpeedS.txtb.x,myData.upgradeSpeedS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.upgradeSpeedS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeSpeedS.txt.alpha=0

    myData.safePaymentS = display.newImageRect( "img/st_safe_pay_hidden.png",iconSize, iconSize)
    myData.safePaymentS.anchorX = 0.5
    myData.safePaymentS.anchorY = 0
    myData.safePaymentS.x, myData.safePaymentS.y = display.contentWidth/8*7-20,myData.bankExploiterS.y
    myData.safePaymentS.name="Money Hider"
    myData.safePaymentS.src="img/st_safe_pay.png"
    myData.safePaymentS.srch="img/st_safe_pay_hidden.png"
    myData.safePaymentS.enabled=false
    myData.safePaymentS.toUpgradeST="st_safe_pay"
    myData.safePaymentS.desc="Money Hider Skill decreases the money that attackers can steal from you.\n\n1 Skill Point = -2% Money stolen when receiving attacks\n"
    myData.safePaymentS.lvl = 0
    myData.safePaymentS.txtb = display.newRoundedRect(myData.safePaymentS.x,myData.safePaymentS.y+myData.safePaymentS.height,120,fontSize(52),12)
    myData.safePaymentS.txtb.anchorX=0.5
    myData.safePaymentS.txtb.anchorY=1
    myData.safePaymentS.txtb.strokeWidth = 5
    myData.safePaymentS.txtb:setFillColor( 0,0,0 )
    myData.safePaymentS.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.safePaymentS.txtb.alpha=0
    myData.safePaymentS.txt = display.newText(myData.safePaymentS.lvl.."/5",myData.safePaymentS.txtb.x,myData.safePaymentS.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.safePaymentS.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.safePaymentS.txt.alpha=0

    myData.pentester2S = display.newImageRect( "img/st_pentester2_hidden.png",iconSize, iconSize)
    myData.pentester2S.anchorX = 0.5
    myData.pentester2S.anchorY = 0
    myData.pentester2S.x, myData.pentester2S.y = display.contentWidth/8*2+20,myData.bankExploiterS.y+myData.bankExploiterS.height+fontSize(70)
    myData.pentester2S.name="Penetration Tester"
    myData.pentester2S.src="img/st_pentester2.png"
    myData.pentester2S.srch="img/st_pentester2_hidden.png"
    myData.pentester2S.enabled=false
    myData.pentester2S.toUpgradeST="st_pentester2"
    myData.pentester2S.desc="Penetration Tester Skill greatly enhances your exploits raising your chance of successfully attacking targets.\n\n1 Skill Point = +2% Success Chance with Exploit Attacks\n"
    myData.pentester2S.lvl = 0
    myData.pentester2S.txtb = display.newRoundedRect(myData.pentester2S.x,myData.pentester2S.y+myData.pentester2S.height,120,fontSize(52),12)
    myData.pentester2S.txtb.anchorX=0.5
    myData.pentester2S.txtb.anchorY=1
    myData.pentester2S.txtb.strokeWidth = 5
    myData.pentester2S.txtb:setFillColor( 0,0,0 )
    myData.pentester2S.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.pentester2S.txtb.alpha=0
    myData.pentester2S.txt = display.newText(myData.pentester2S.lvl.."/5",myData.pentester2S.txtb.x,myData.pentester2S.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.pentester2S.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.pentester2S.txt.alpha=0

    myData.developer2S = display.newImageRect( "img/st_dev2_hidden.png",iconSize, iconSize)
    myData.developer2S.anchorX = 0.5
    myData.developer2S.anchorY = 0
    myData.developer2S.x, myData.developer2S.y = display.contentWidth/8*6-20,myData.pentester2S.y
    myData.developer2S.name="Risk Manager"
    myData.developer2S.src="img/st_dev2.png"
    myData.developer2S.srch="img/st_dev2_hidden.png"
    myData.developer2S.enabled=false
    myData.developer2S.toUpgradeST="st_dev2"
    myData.developer2S.desc="Risk Manager Skill greatly enhances the protection of your assets raising your chance of successfully defending against exploits.\n\n1 Skill Point = +2% Defending Chance from Exploit Attacks\n"
    myData.developer2S.lvl = 0
    myData.developer2S.txtb = display.newRoundedRect(myData.developer2S.x,myData.developer2S.y+myData.developer2S.height,120,fontSize(52),12)
    myData.developer2S.txtb.anchorX=0.5
    myData.developer2S.txtb.anchorY=1
    myData.developer2S.txtb.strokeWidth = 5
    myData.developer2S.txtb:setFillColor( 0,0,0 )
    myData.developer2S.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.developer2S.txtb.alpha=0
    myData.developer2S.txt = display.newText(myData.developer2S.lvl.."/5",myData.developer2S.txtb.x,myData.developer2S.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.developer2S.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.developer2S.txt.alpha=0

    myData.infoPanelST = display.newRoundedRect( 10000, 10000, display.contentWidth-100, fontSize(200), 12 )
    myData.infoPanelST.anchorX = 0.5
    myData.infoPanelST.anchorY = 0
    myData.infoPanelST.strokeWidth = 5
    myData.infoPanelST:setFillColor( 0,0,0 )
    myData.infoPanelST:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.infoPanelST.alpha = 1

    myData.infoTextST = display.newText("",40,20,myData.infoPanelST.width-60,0,native.systemFont, fontSize(52))
    myData.infoTextST.anchorX = 0
    myData.infoTextST.anchorY = 0
    myData.infoTextST:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.infoTextST2 = display.newText("",40,20,myData.infoPanelST.width-60,0,native.systemFont, fontSize(44))
    myData.infoTextST2.anchorX = 0
    myData.infoTextST2.anchorY = 0
    myData.infoTextST2:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeSTButton = widget.newButton(
        {
            left = myData.infoPanelST.width-(iconSize/1.2)-60,
            top = 20,
            width = 300,
            height = fontSize(90),
            defaultFile = skillColor,
            onEvent = upgradeST
        })
    myData.upgradeSTButton.alpha = 0
    
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
        labelColor = { default=textColor1 },
        onEvent = goBackST
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.top_backgroundST)
    group:insert(myData.moneyTextST)
    group:insert(myData.playerTextST)
    group:insert(myData.st_rect)
    group:insert(myData.st_bg)
    group:insert(myData.skillPointsLabel)
    group:insert(myData.skillPointsText)
    group:insert(myData.hourlyIncomeS)
    group:insert(myData.pentester1S)
    group:insert(myData.developer1S)
    group:insert(myData.stealthS)
    group:insert(myData.missionRewardS)
    group:insert(myData.missionSpeedS)
    group:insert(myData.analystS)
    group:insert(myData.bankExploiterS)
    group:insert(myData.upgradeCostS)
    group:insert(myData.upgradeSpeedS)
    group:insert(myData.safePaymentS)
    group:insert(myData.pentester2S)
    group:insert(myData.developer2S)
    group:insert(myData.hourlyIncomeS.txtb)
    group:insert(myData.pentester1S.txtb)
    group:insert(myData.developer1S.txtb)
    group:insert(myData.stealthS.txtb)
    group:insert(myData.missionRewardS.txtb)
    group:insert(myData.missionSpeedS.txtb)
    group:insert(myData.analystS.txtb)
    group:insert(myData.bankExploiterS.txtb)
    group:insert(myData.upgradeCostS.txtb)
    group:insert(myData.upgradeSpeedS.txtb)
    group:insert(myData.safePaymentS.txtb)
    group:insert(myData.pentester2S.txtb)
    group:insert(myData.developer2S.txtb)
    group:insert(myData.hourlyIncomeS.txt)
    group:insert(myData.pentester1S.txt)
    group:insert(myData.developer1S.txt)
    group:insert(myData.stealthS.txt)
    group:insert(myData.missionRewardS.txt)
    group:insert(myData.missionSpeedS.txt)
    group:insert(myData.analystS.txt)
    group:insert(myData.bankExploiterS.txt)
    group:insert(myData.upgradeCostS.txt)
    group:insert(myData.upgradeSpeedS.txt)
    group:insert(myData.safePaymentS.txt)
    group:insert(myData.pentester2S.txt)
    group:insert(myData.developer2S.txt)
    group:insert(myData.infoPanelST)
    group:insert(myData.infoTextST)
    group:insert(myData.infoTextST2)
    group:insert(myData.upgradeSTButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackST)
    myData.upgradeSTButton:addEventListener("tap",upgradeST)
    myData.hourlyIncomeS:addEventListener("tap",showSTStat)
    myData.pentester1S:addEventListener("tap",showSTStat)
    myData.developer1S:addEventListener("tap",showSTStat)
    myData.stealthS:addEventListener("tap",showSTStat)
    myData.missionRewardS:addEventListener("tap",showSTStat)
    myData.missionSpeedS:addEventListener("tap",showSTStat)
    myData.analystS:addEventListener("tap",showSTStat)
    myData.bankExploiterS:addEventListener("tap",showSTStat)
    myData.upgradeCostS:addEventListener("tap",showSTStat)
    myData.upgradeSpeedS:addEventListener("tap",showSTStat)
    myData.safePaymentS:addEventListener("tap",showSTStat)
    myData.pentester2S:addEventListener("tap",showSTStat)
    myData.developer2S:addEventListener("tap",showSTStat)
end

-- Home Show
function skillTreeScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "skillTreeTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutSkillTree ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "skillTreeTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getST.php", "POST", STnetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
skillTreeScene:addEventListener( "create", skillTreeScene )
skillTreeScene:addEventListener( "show", skillTreeScene )
---------------------------------------------------------------------------------

return skillTreeScene