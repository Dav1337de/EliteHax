local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local widget = require( "widget" )
local notifications = require( "plugin.notifications" )
local upgradeAttackerScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function boundCheckUA(x,y)
    if (myData.infoPanelUA.alpha == 0) then
        return true
    elseif ((x > (myData.infoPanelUA.x-myData.infoPanelUA.width/2)) and (x < myData.infoPanelUA.x+myData.infoPanelUA.width/2) and (y > (myData.infoPanelUA.y-myData.infoPanelUA.height/2)) and (y < (myData.infoPanelUA.y+myData.infoPanelUA.height/2))) then
        return false
    else
        return true
    end
end

local showStats = function(event)
	if ((myData.lastSelectedUpgrade ~= event.target.name) and (boundCheckUA(event.x,event.y))) then
        tapSound()
		myData.infoPanelUA.alpha = 1
		myData.upgradeButton2.alpha = 1
        lvl = event.target.lvl
        if ((event.target.name == "CPU") or (event.target.name == "RAM") or (event.target.name == "Encrypted Disk") or (event.target.name == "Cooling System") or (event.target.name == "Cryptominer")) then
            if (lvl == 10) then 
                if (event.target.name == "Encrypted Disk") then lvl = hddLvltoName(lvl) end
                myData.upgradeButton2.alpha = 0 
                myData.infoTextUA.text = event.target.name .. "\nLevel: "..lvl.."\nMaximum level reached\n\n"..event.target.desc
            else
                if (event.target.name == "Encrypted Disk") then lvl = hddLvltoName(lvl) end
                myData.infoTextUA.text = event.target.name .. "\nLevel: "..lvl.."\nCost: $"..format_thousand(event.target.cost).."\nDuration: "..timeText(event.target.time).."\n\n"..event.target.desc
            end
        else
            local lvlrtext = ""
            if (event.target.lvlr>0) then
                lvlrtext=" ("..event.target.lvlr..")"
            end
            myData.infoTextUA.text = event.target.name .. "\nLevel: "..lvl..""..lvlrtext.."\nCost: $"..format_thousand(event.target.cost).."\nDuration: "..timeText(event.target.time).."\n\n"..event.target.desc
        end
        myData.lastSelectedUpgrade = event.target.name
        myData.toUpgrade = event.target.toUpgrade
        myData.infoPanelUA.height = myData.infoTextUA.height-30
        myData.infoPanelUA.x,myData.infoPanelUA.y = event.target.panelX, event.target.panelY
        myData.infoTextUA.x,myData.infoTextUA.y=myData.infoPanelUA.x-myData.infoPanelUA.width/2+20,myData.infoPanelUA.y-myData.infoPanelUA.height/2+20
        myData.upgradeButton2.x,myData.upgradeButton2.y=myData.infoPanelUA.x+myData.infoPanelUA.width/2-(iconSize/1.8),myData.infoPanelUA.y-myData.infoPanelUA.height/2+iconSize/2+10
 	elseif (boundCheckUA(event.x,event.y)) then
        backSound()
		myData.infoPanelUA.alpha = 0
		myData.upgradeButton2.alpha = 0
		myData.infoTextUA.text = ""
		myData.lastSelectedUpgrade = ""
		myData.toUpgrade = ""
	end
end

function goBackAttackerW(event)
    if (tutOverlay==false) then
        if (upgradeClickedUA == 0) then
        	if (myData.infoPanelUA.alpha == 1) then
        		myData.infoPanelUA.alpha = 0
        		myData.upgradeButton2.alpha = 0
        		myData.infoTextUA.text = ""
        		myData.lastSelectedUpgrade = ""
        	else
                upgradeClickedUA=1
                backSound()
                composer.removeScene( "upgradeAttackerScene" )
            	composer.gotoScene("upgradeScene", {effect = "fade", time = 0})
            end
        end
    end
end

function goBack(event)
    if (event.phase=="ended") then
        if (tutOverlay==false) then
            if (upgradeClickedUA == 0) then
                if (myData.infoPanelUA.alpha == 1) then
                    myData.infoPanelUA.alpha = 0
                    myData.upgradeButton2.alpha = 0
                    myData.infoTextUA.text = ""
                    myData.lastSelectedUpgrade = ""
                    upgradeClickedUA=1
                    backSound()
                    composer.removeScene( "upgradeAttackerScene" )
                    composer.gotoScene("upgradeScene", {effect = "fade", time = 0})
                end
            end
        end
    end
end

local function onAlert( event )
    if ( event.action == "clicked" ) then
       	if  system.getInfo("platformName")=="Android" then
        	native.requestExit()
       	else
        	os.exit() 
    	end
    end
end

local function lastTaskNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        else
            if ((t.oc_secs>1) and (t.secs>t.oc_secs)) then
                t.secs=t.oc_secs+(t.secs-t.oc_secs)*2
            end
            --Local Notification
            if ((taskNotificationActive==true) and (t.secs>0)) then
                if (notificationGlobal) then 
                    notifications.cancelNotification(notificationGlobal) 
                    notificationGlobal=nil
                end
                --notifications.cancelNotification()
                local utcTime = os.date( "!*t", os.time() + t.secs )
                notificationActive.task=utcTime
                notificationActive.taskTime=os.date(os.time() + t.secs)
                loadsave.saveTable( notificationActive, "localNotificationStatus.json" )
                setNewNotifications()
            end
        end
   end
end

local function networkUpgradeListener( event )
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

        if ( t.status == "NO_MONEY") then
        	local alert = native.showAlert( "EliteHax", "Oops.. It seems you don't have enough money...", { "Ok" }, nil )
        end

        if ( t.status == "MAX_TASK") then
            local alert = native.showAlert( "EliteHax", "Max task number reached", { "Ok" }, nil )
        end

        if ( t.status == "MAX_LVL") then
            myData.infoTextUA.text =  myData.lastSelectedUpgrade .. "\nLevel: MAX\n\n"..myData[myData.toUpgrade].desc
        end

    	if ( t.status == "OK") then
    		myData[myData.toUpgrade].lvl = t.new_lvl
            if (myData.toUpgrade == "hdd") then lvl = hddLvltoName(t.new_lvl) end
            if (myData.toUpgrade=="cryptominer") then
                myData.cryptominer.desc = "Cryptominer upgrades give you an hourly Cryptocoins income.\nHourly Income: "..t.new_lvl.." CC\nMax collectable CC: "..(t.new_lvl*48).."\n\n"
            end

            if ((myData.toUpgrade == "cpu") or (myData.toUpgrade == "ram") or (myData.toUpgrade == "fan") or (myData.toUpgrade == "hdd") or (myData.toUpgrade == "cryptominer")) then
                if (myData[myData.toUpgrade].lvl == 10) then 
                    myData.upgradeButton2.alpha = 0 
                    myData.infoTextUA.text = myData.lastSelectedUpgrade .. "\nLevel: "..t.new_lvl.."\nMaximum level reached\n\n"..myData[myData.toUpgrade].desc
                else
                    myData.infoTextUA.text =  myData.lastSelectedUpgrade .. "\nLevel: " .. t.new_lvl.."\nCost: $"..format_thousand(t.new_cost).."\nDuration: "..timeText(t.new_time).."\n\n"..myData[myData.toUpgrade].desc
                end
            else
                local lvlrtext = ""
                if (myData[myData.toUpgrade].lvlr>0) then
                    myData[myData.toUpgrade].lvlr=myData[myData.toUpgrade].lvlr+1
                    lvlrtext=" ("..(myData[myData.toUpgrade].lvlr)..")"
                end
                myData.infoTextUA.text =  myData.lastSelectedUpgrade .. "\nLevel: " .. t.new_lvl..""..lvlrtext.."\nCost: $"..format_thousand(t.new_cost).."\nDuration: "..timeText(t.new_time).."\n\n"..myData[myData.toUpgrade].desc
            end
    		myData[myData.toUpgrade].txt.text = t.new_lvl
            myData[myData.toUpgrade].cost = t.new_cost
       		myData.moneyTextAU.text = format_thousand(t.money)

            --Get Last Task for Local Notification
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getLastTask.php", "POST", lastTaskNetworkListener, params )      
    	end
        upgradeClickedUA = 0
	end
end

local function upgradeUA(event)
    if ((upgradeClickedUA == 0) and (event.phase == "ended")) then
        upgradeClickedUA = 1
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token).."&type="..myData.toUpgrade.."&data="..string.urlEncode(generateNonce())
		local params = {}
		params.headers = headers
		params.body = body
        tapSound()
		network.request( host().."doupgrade.php", "POST", networkUpgradeListener, params )
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

        --CPU
        myData.cpu.lvl = t.cpu
        myData.cpu.lvlr = t.cpu_r
        digit = string.len(tostring(myData.cpu.lvl))
        myData.cpu.txtb.width = 70+(30*digit)
        myData.cpu.txt.text = myData.cpu.lvl   
        myData.cpu.cost = t.cpu_cost
        myData.cpu.time = t.cpu_time

        --RAM
        myData.ram.lvl = t.ram
        myData.ram.lvlr = t.ram_r
        digit = string.len(tostring(myData.ram.lvl))
        myData.ram.txtb.width = 70+(30*digit)
        myData.ram.txt.text = myData.ram.lvl
        myData.ram.cost = t.ram_cost
        myData.ram.time = t.ram_time

        --HDD
        myData.hdd.lvl = t.hdd
        myData.hdd.lvlr = t.hdd_r
        digit = string.len(hddLvltoName(myData.hdd.lvl))
        myData.hdd.txtb.width = 70+(30*digit)
        myData.hdd.txt.text = hddLvltoName(myData.hdd.lvl)
        myData.hdd.cost = t.hdd_cost
        myData.hdd.time = t.hdd_time

        --GPU
        myData.gpu.lvl = t.gpu
        myData.gpu.lvlr = t.gpu_r
        digit = string.len(tostring(myData.gpu.lvl))
        myData.gpu.txtb.width = 70+(30*digit)
        myData.gpu.txt.text = myData.gpu.lvl
        myData.gpu.cost = t.gpu_cost
        myData.gpu.time = t.gpu_time

        --FAN
        myData.fan.lvl = t.fan
        myData.fan.lvlr = t.fan_r
        digit = string.len(tostring(myData.fan.lvl))
        myData.fan.txtb.width = 70+(30*digit)
        myData.fan.txt.text = myData.fan.lvl
        myData.fan.cost = t.fan_cost
        myData.fan.time = t.fan_time

        --Antivirus
        myData.av.lvl = t.av
        myData.av.lvlr = t.av_r
        digit = string.len(tostring(myData.av.lvl))
        myData.av.txtb.width = 70+(30*digit)
        myData.av.txt.text = myData.av.lvl
        myData.av.cost = t.av_cost
        myData.av.time = t.av_time

        --Malware
        myData.malware.lvl = t.malware
        myData.malware.lvlr = t.malware_r
        digit = string.len(tostring(myData.malware.lvl))
        myData.malware.txtb.width = 70+(30*digit)
        myData.malware.txt.text = myData.malware.lvl
        myData.malware.cost = t.malware_cost
        myData.malware.time = t.malware_time

        --Exploit
        myData.exploit.lvl = t.exploit
        myData.exploit.lvlr = t.exploit_r
        digit = string.len(tostring(myData.exploit.lvl))
        myData.exploit.txtb.width = 70+(30*digit)
        myData.exploit.txt.text = myData.exploit.lvl      
        myData.exploit.cost = t.exploit_cost
        myData.exploit.time = t.exploit_time

        --Scan
        myData.scan.lvl = t.scan
        myData.scan.lvlr = t.scan_r
        digit = string.len(tostring(myData.scan.lvl))
        myData.scan.txtb.width = 70+(30*digit)
        myData.scan.txt.text = myData.scan.lvl
        myData.scan.cost = t.scan_cost      
        myData.scan.time = t.scan_time

        --cryptominer
        myData.cryptominer.lvl = t.cryptominer
        myData.cryptominer.lvlr = t.cryptominer_r
        digit = string.len(tostring(myData.cryptominer.lvl))
        myData.cryptominer.txtb.width = 70+(30*digit)
        myData.cryptominer.txt.text = myData.cryptominer.lvl
        myData.cryptominer.cost = t.cryptominer_cost      
        myData.cryptominer.time = t.cryptominer_time
        myData.cryptominer.desc = "Cryptominer upgrades give you an hourly Cryptocoins income.\nHourly Income: "..t.cryptominer.." CC\nMax collectable CC: "..(t.cryptominer*48).."\n\n"

        --Money
        myData.moneyTextAU.text = format_thousand(t.money)  

        --Player
        if (string.len(t.user)>15) then myData.playerTextAU.size = fontSize(42) end
        myData.playerTextAU.text = t.user

    end
end

hddLvltoName = function(lvl)
    name = "16 TB"
    if (lvl == 1) then 
        name = "32 GB"
    elseif (lvl == 2) then
        name = "64 GB"
    elseif (lvl == 3) then
        name = "128 GB"
    elseif (lvl == 4) then
        name = "256 GB"
    elseif (lvl == 5) then
        name = "512 GB"
    elseif (lvl == 6) then
        name = "1 TB"
    elseif (lvl == 7) then
        name = "2 TB"
    elseif (lvl == 8) then
        name = "4 TB"
    elseif (lvl == 9) then
        name = "8 TB"
    end
    return name
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
-- Scene Creation
function upgradeAttackerScene:create(event)
	local group = self.view

    loginInfo = localToken()

    upgradeClickedUA = 0
    iconSize=(display.contentWidth-100)/4*display.actualContentHeight/display.contentHeight

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.2
    changeImgColor(myData.background)

    -- CPU
    myData.cpu = display.newImageRect( "img/cpu.png",iconSize,iconSize )
    myData.cpu.name = "CPU"
    myData.cpu.toUpgrade = "cpu"
    myData.cpu.src = "img/cpu.png"
    myData.cpu.desc = "CPU upgrades reduce upgrade time\n "
    myData.cpu.lvl = 0
    myData.cpu.cost = 0
    myData.cpu.time = 0
    myData.cpu.anchorX = 1
    myData.cpu.anchorY = 1
    myData.cpu.x, myData.cpu.y = display.contentWidth/3, iconSize+fontSize(240)+topPadding()
    myData.cpu.panelX = myData.cpu.x+myData.cpu.width/2
    myData.cpu.panelY = myData.cpu.y+myData.cpu.height+20
    digit = string.len(tostring(myData.cpu.lvl))
    myData.cpu.txtb = display.newRoundedRect(myData.cpu.x-50-(15*digit),myData.cpu.y-30,70+(30*digit),70,12)
    myData.cpu.txtb.strokeWidth = 5
    myData.cpu.txtb:setFillColor( 0,0,0 )
    myData.cpu.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.cpu.txt = display.newText(myData.cpu.lvl,myData.cpu.x-50-(15*digit),myData.cpu.y-30 ,native.systemFont, fontSize(72))
    myData.cpu.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- RAM
    myData.ram = display.newImageRect( "img/ram.png",iconSize,iconSize )
    myData.ram.name = "RAM"
    myData.ram.toUpgrade = "ram"
    myData.ram.src = "img/ram.png"
    myData.ram.desc = "RAM upgrades increase the number of tasks you can run simultaneously\n "
    myData.ram.lvl = 0
    myData.ram.cost = 0
    myData.ram.time = 0
    myData.ram.anchorX = 1
    myData.ram.anchorY = 1
    myData.ram.x, myData.ram.y = myData.cpu.x + iconSize+70, myData.cpu.y
    myData.ram.panelX = myData.ram.x-myData.ram.width/2
    myData.ram.panelY = myData.ram.y+myData.ram.height+40
    digit = string.len(tostring(myData.ram.lvl))
    myData.ram.txtb = display.newRoundedRect(myData.ram.x-50-(15*digit),myData.ram.y-30,70+(30*digit),70,12)
    myData.ram.txtb.strokeWidth = 5
    myData.ram.txtb:setFillColor( 0,0,0 )
    myData.ram.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.ram.txt = display.newText(myData.ram.lvl,myData.ram.x-50-(15*digit),myData.ram.y-30 ,native.systemFont, fontSize(72))
    myData.ram.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- HDD
    myData.hdd = display.newImageRect( "img/hdd.png",iconSize,iconSize )
    myData.hdd.name = "Encrypted Disk"
    myData.hdd.toUpgrade = "hdd"
    myData.hdd.src = "img/hdd.png"
    myData.hdd.desc = "Encrypted Disk upgrades increase the size of your encrypted storage that contains unhackable money.\n1GB=1K Unhackable Money\n "
    myData.hdd.lvl = 0
    myData.hdd.cost = 0
    myData.hdd.time = 0
    myData.hdd.anchorX = 1
    myData.hdd.anchorY = 1
    myData.hdd.x, myData.hdd.y = myData.ram.x + iconSize+70, myData.cpu.y
    myData.hdd.panelX = myData.hdd.x-myData.hdd.width*1.5
    myData.hdd.panelY = myData.hdd.y+myData.hdd.height+40
    digit = string.len(hddLvltoName(myData.hdd.lvl))
    myData.hdd.txtb = display.newRoundedRect(myData.hdd.x-50-(15*digit),myData.hdd.y-30,70+(30*digit),70,12)
    myData.hdd.txtb.strokeWidth = 5
    myData.hdd.txtb:setFillColor( 0,0,0 )
    myData.hdd.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.hdd.txt = display.newText(hddLvltoName(myData.hdd.lvl),myData.hdd.x-50-(15*digit),myData.hdd.y-30 ,native.systemFont, fontSize(72))
    myData.hdd.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- GPU
    myData.gpu = display.newImageRect( "img/gpu.png",iconSize,iconSize )
    myData.gpu.name = "GPU"
    myData.gpu.toUpgrade = "gpu"
    myData.gpu.src = "img/gpu.png"
    myData.gpu.desc = "GPU upgrades increase the rewards of missions\n "
    myData.gpu.lvl = 0
    myData.gpu.cost = 0
    myData.gpu.time = 0
    myData.gpu.anchorX = 1
    myData.gpu.anchorY = 1
    myData.gpu.x, myData.gpu.y = myData.cpu.x+(iconSize/2), myData.cpu.y+iconSize+50
    myData.gpu.panelX = myData.gpu.x
    myData.gpu.panelY = myData.gpu.y+myData.gpu.height+10
    digit = string.len(tostring(myData.gpu.lvl))
    myData.gpu.txtb = display.newRoundedRect(myData.gpu.x-50-(15*digit),myData.gpu.y-30,70+(30*digit),70,12)
    myData.gpu.txtb.strokeWidth = 5
    myData.gpu.txtb:setFillColor( 0,0,0 )
    myData.gpu.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.gpu.txt = display.newText(myData.gpu.lvl,myData.gpu.x-50-(15*digit),myData.gpu.y-30 ,native.systemFont, fontSize(72))
    myData.gpu.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Cooling
    myData.fan = display.newImageRect( "img/fan.png",iconSize,iconSize )
    myData.fan.name = "Cooling System"
    myData.fan.toUpgrade = "fan"
    myData.fan.src = "img/fan.png"
    myData.fan.desc = "Cooling System increase the duration of your Overclocks.\n+12m Overclock time for each level.\n "
    myData.fan.lvl = 0
    myData.fan.cost = 0
    myData.fan.time = 0
    myData.fan.anchorX = 1
    myData.fan.anchorY = 1
    myData.fan.x, myData.fan.y = myData.gpu.x+iconSize+100, myData.gpu.y
    myData.fan.panelX = myData.fan.x-myData.fan.width
    myData.fan.panelY = myData.fan.y+myData.fan.height+40
    digit = string.len(tostring(myData.fan.lvl))
    myData.fan.txtb = display.newRoundedRect(myData.fan.x-50-(15*digit),myData.fan.y-30,70+(30*digit),70,12)
    myData.fan.txtb.strokeWidth = 5
    myData.fan.txtb:setFillColor( 0,0,0 )
    myData.fan.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fan.txt = display.newText(myData.fan.lvl,myData.fan.x-50-(15*digit),myData.fan.y-30 ,native.systemFont, fontSize(72))
    myData.fan.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Antivirus
    myData.av = display.newImageRect( "img/antivirus.png",iconSize,iconSize )
    myData.av.name = "Antivirus"
    myData.av.toUpgrade = "av"
    myData.av.src = "img/antivirus.png"
    myData.av.desc = "Antivirus upgrades protects you from malwares of higher levels\n "
    myData.av.lvl = 0
    myData.av.cost = 0
    myData.av.time = 0
    myData.av.anchorX = 1
    myData.av.anchorY = 1
    myData.av.x, myData.av.y = myData.cpu.x, myData.gpu.y+iconSize+fontSize(175)
    myData.av.panelX = myData.av.x+myData.av.width/2
    myData.av.panelY = myData.av.y+myData.av.height+30
    digit = string.len(tostring(myData.av.lvl))
    myData.av.txtb = display.newRoundedRect(myData.av.x-50-(15*digit),myData.av.y-30,70+(30*digit),70,12)
    myData.av.txtb.strokeWidth = 5
    myData.av.txtb:setFillColor( 0,0,0 )
    myData.av.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.av.txt = display.newText(myData.av.lvl,myData.av.x-50-(15*digit),myData.av.y-30 ,native.systemFont, fontSize(72))
    myData.av.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Malware Framework
    myData.malware = display.newImageRect( "img/malware.png",iconSize,iconSize )
    myData.malware.name = "Malware Framework"
    myData.malware.toUpgrade = "malware"
    myData.malware.src = "img/malware.png"
    myData.malware.desc = "Malware Framework upgrades allow you to create more powerful malwares\n "
    myData.malware.lvl = 0
    myData.malware.cost = 0
    myData.malware.time = 0
    myData.malware.anchorX = 1
    myData.malware.anchorY = 1
    myData.malware.x, myData.malware.y = myData.av.x+iconSize+70, myData.av.y
    myData.malware.panelX = myData.malware.x-myData.malware.width/2
    myData.malware.panelY = myData.malware.y+myData.malware.height+40
    digit = string.len(tostring(myData.malware.lvl))
    myData.malware.txtb = display.newRoundedRect(myData.malware.x-50-(15*digit),myData.malware.y-30,70+(30*digit),70,12)
    myData.malware.txtb.strokeWidth = 5
    myData.malware.txtb:setFillColor( 0,0,0 )
    myData.malware.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.malware.txt = display.newText(myData.malware.lvl,myData.malware.x-50-(15*digit),myData.malware.y-30 ,native.systemFont, fontSize(72))
    myData.malware.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Exploit Framework
    myData.exploit = display.newImageRect( "img/exploit.png",iconSize,iconSize )
    myData.exploit.name = "Exploit Framework"
    myData.exploit.toUpgrade = "exploit"
    myData.exploit.src = "img/exploit.png"
    myData.exploit.desc = "Exploit Framework upgrades increase the effectivness of your exploits\n "
    myData.exploit.lvl = 0
    myData.exploit.cost = 0
    myData.exploit.time = 0
    myData.exploit.anchorX = 1
    myData.exploit.anchorY = 1
    myData.exploit.x, myData.exploit.y = myData.malware.x+iconSize+70, myData.av.y
    myData.exploit.panelX = myData.exploit.x-myData.exploit.width*1.5
    myData.exploit.panelY = myData.exploit.y+myData.exploit.height+40
    digit = string.len(tostring(myData.exploit.lvl))
    myData.exploit.txtb = display.newRoundedRect(myData.exploit.x-50-(15*digit),myData.exploit.y-30,70+(30*digit),70,12)
    myData.exploit.txtb.strokeWidth = 5
    myData.exploit.txtb:setFillColor( 0,0,0 )
    myData.exploit.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.exploit.txt = display.newText(myData.exploit.lvl,myData.exploit.x-50-(15*digit),myData.exploit.y-30 ,native.systemFont, fontSize(72))
    myData.exploit.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Scan
    myData.scan = display.newImageRect( "img/scan.png",iconSize,iconSize )
    myData.scan.name = "Scanner"
    myData.scan.toUpgrade = "scan"
    myData.scan.src = "img/scan.png"
    myData.scan.desc = "Scan upgrades allow you to scan through higher firewall levels\n "
    myData.scan.lvl = 0
    myData.scan.cost = 0
    myData.scan.time = 0
    myData.scan.anchorX = 1
    myData.scan.anchorY = 1
    myData.scan.x, myData.scan.y = myData.av.x+iconSize/2, myData.av.y+iconSize+50
    myData.scan.panelX = myData.scan.x
    myData.scan.panelY = myData.scan.y-myData.scan.height*2-30
    digit = string.len(tostring(myData.scan.lvl))
    myData.scan.txtb = display.newRoundedRect(myData.scan.x-50-(15*digit),myData.scan.y-30,70+(30*digit),70,12)
    myData.scan.txtb.strokeWidth = 5
    myData.scan.txtb:setFillColor( 0,0,0 )
    myData.scan.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.scan.txt = display.newText(myData.scan.lvl,myData.scan.x-50-(15*digit),myData.scan.y-30 ,native.systemFont, fontSize(72))
    myData.scan.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- cryptominer
    myData.cryptominer = display.newImageRect( "img/cryptominer.png",iconSize,iconSize )
    myData.cryptominer.name = "Cryptominer"
    myData.cryptominer.toUpgrade = "cryptominer"
    myData.cryptominer.src = "img/cryptominer.png"
    myData.cryptominer.desc = "Cryptominer upgrades give you an hourly Cryptocoins income.\nHourly Income: 1CC X lvl\nMax collectable CC: lvl x 48h\n"
    myData.cryptominer.lvl = 0
    myData.cryptominer.cost = 0
    myData.cryptominer.time = 0
    myData.cryptominer.anchorX = 1
    myData.cryptominer.anchorY = 1
    myData.cryptominer.x, myData.cryptominer.y = myData.scan.x+iconSize+100, myData.av.y+iconSize+50
    myData.cryptominer.panelX = myData.cryptominer.x-myData.cryptominer.width
    myData.cryptominer.panelY = myData.cryptominer.y-myData.cryptominer.height*2-30
    digit = string.len(tostring(myData.cryptominer.lvl))
    myData.cryptominer.txtb = display.newRoundedRect(myData.cryptominer.x-50-(15*digit),myData.cryptominer.y-30,70+(30*digit),70,12)
    myData.cryptominer.txtb.strokeWidth = 5
    myData.cryptominer.txtb:setFillColor( 0,0,0 )
    myData.cryptominer.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.cryptominer.txt = display.newText(myData.cryptominer.lvl,myData.cryptominer.x-50-(15*digit),myData.cryptominer.y-30 ,native.systemFont, fontSize(72))
    myData.cryptominer.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )


    -- Hardware Rectangle
    myData.hardwareRect = display.newImageRect( "img/upgrades_hardware.png",(iconSize*3)+300,(iconSize*2)+fontSize(200))
    myData.hardwareRect.x, myData.hardwareRect.y = myData.cpu.x+200,myData.cpu.y-10

    -- Software Rectangle
    myData.softwareRect = display.newImageRect( "img/upgrades_software.png",(iconSize*3)+300,(iconSize*2)+fontSize(200))
    myData.softwareRect.x, myData.softwareRect.y = myData.av.x+200,myData.av.y-10

    --TOP
    myData.top_backgroundUA = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_backgroundUA.anchorX = 0.5
    myData.top_backgroundUA.anchorY = 0
    myData.top_backgroundUA.x, myData.top_backgroundUA.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_backgroundUA)

    --Money
    myData.moneyTextAU = display.newText("",115,myData.top_backgroundUA.y+myData.top_backgroundUA.height/2,native.systemFont, fontSize(48))
    myData.moneyTextAU.anchorX = 0
    myData.moneyTextAU.anchorY = 0.5
    myData.moneyTextAU:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextAU = display.newText("",display.contentWidth-250,myData.top_backgroundUA.y+myData.top_backgroundUA.height/2,native.systemFont, fontSize(48))
    myData.playerTextAU.anchorX = 0.5
    myData.playerTextAU.anchorY = 0.5
    myData.playerTextAU:setFillColor( 0.9,0.9,0.9 )

    -- Back Button
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
        }
    )

    -- Info Panel - Modificare posizione in base a elemento
    sizey=display.actualContentHeight / 4.5
    myData.infoPanelUA = display.newRoundedRect( 1000, 1000, display.contentWidth/1.3, sizey-20, 12 )
    myData.infoPanelUA.anchorX = 0.5
    myData.infoPanelUA.anchorY = 0.5
    myData.infoPanelUA.strokeWidth = 5
    myData.infoPanelUA:setFillColor( 0,0,0 )
    myData.infoPanelUA:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.infoPanelUA.alpha = 0
    myData.infoTextUA = display.newText("",40,20,myData.infoPanelUA.width-60,0,native.systemFont, fontSize(52))
    myData.infoTextUA.anchorX = 0
    myData.infoTextUA.anchorY = 0
    myData.infoTextUA:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeButton2 = widget.newButton(
        {
            left = myData.infoPanelUA.width-(iconSize/1.2)-60,
            top = 20,
            width = iconSize/1.1,
            height = iconSize/1.1,
            defaultFile = "img/upgrade.png",
            onEvent = upgradeUA
        }
    )
    myData.upgradeButton2.alpha = 0

-- --	Show HUD	
 	group:insert(myData.background)
    group:insert(myData.top_backgroundUA)
 	group:insert(myData.hardwareRect)
 	group:insert(myData.softwareRect)
 	group:insert(myData.cpu)
 	group:insert(myData.cpu.txtb)
 	group:insert(myData.cpu.txt)
 	group:insert(myData.ram)
 	group:insert(myData.ram.txtb)
 	group:insert(myData.ram.txt)
 	group:insert(myData.hdd)
 	group:insert(myData.hdd.txtb)
 	group:insert(myData.hdd.txt)
 	group:insert(myData.gpu)
 	group:insert(myData.gpu.txtb)
 	group:insert(myData.gpu.txt)
 	group:insert(myData.fan)
 	group:insert(myData.fan.txtb)
 	group:insert(myData.fan.txt)
 	group:insert(myData.av)
 	group:insert(myData.av.txtb)
 	group:insert(myData.av.txt)
 	group:insert(myData.malware)
 	group:insert(myData.malware.txtb)
 	group:insert(myData.malware.txt)
 	group:insert(myData.exploit)
 	group:insert(myData.exploit.txtb)
 	group:insert(myData.exploit.txt)
    group:insert(myData.scan)
    group:insert(myData.scan.txtb)
    group:insert(myData.scan.txt)
    group:insert(myData.cryptominer)
    group:insert(myData.cryptominer.txtb)
    group:insert(myData.cryptominer.txt)
 	group:insert(myData.infoPanelUA)
 	--group:insert(myData.infoTextUA)
 	group:insert(myData.backButton)
 	--group:insert(myData.upgradeButton2)
 	group:insert(myData.moneyTextAU)
    group:insert(myData.playerTextAU)

-- --	Graphical Order
 	group:toFront()

--	Button Listeners
	myData.hdd:addEventListener("tap",showStats)
	myData.cpu:addEventListener("tap",showStats)
	myData.gpu:addEventListener("tap",showStats)
	myData.fan:addEventListener("tap",showStats)
	myData.ram:addEventListener("tap",showStats)
	myData.av:addEventListener("tap",showStats)
	myData.malware:addEventListener("tap",showStats)
	myData.exploit:addEventListener("tap",showStats)
    myData.scan:addEventListener("tap",showStats)
    myData.cryptominer:addEventListener("tap",showStats)
	myData.backButton:addEventListener("tap",goBackAttackerW)
	myData.upgradeButton2:addEventListener("tap",upgradeUA)

end

-- Upgrade Show
function upgradeAttackerScene:show(event)
	local upgradeAttackerGroup = self.view
	if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "upgrade2TutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutUpgrade2 ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "upgrade2TutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
		-- Called when the scene is still off screen (but is about to come on screen).
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
        network.request( host().."updatetask.php", "POST", nil , params )
		network.request( host().."getupgrades.php", "POST", networkListener, params )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
upgradeAttackerScene:addEventListener( "create", upgradeAttackerScene )
upgradeAttackerScene:addEventListener( "show", upgradeAttackerScene )
---------------------------------------------------------------------------------

return upgradeAttackerScene