--my global space
local mime=require("mime")
local composer = require( "composer" )
local loadsave = require( "loadsave" )
local notifications = require( "plugin.notifications" )
local json = require ("json")
local openssl = require("plugin.openssl")
local crypto = require( "crypto" )
local cipher = openssl.get_cipher("aes-256-cbc")
local M = {}

function base64Decode(data)
	local len = data:len()
	local t = {}
	for i=1,len,384 do
		local n = math.min(384, len+1-i)
		if n > 0 then
			local s = data:sub(i, i+n-1)
			local dec, _ = mime.unb64(s)
			t[#t+1] = dec
		end
	end
	return table.concat(t)
end

--GitHub Note: this is where you point to the version specific API:
function host()
  return "https://app.elitehax.it/v3.0.7/"
end

function appVersion()
  return "v3.0.7 (2018/10/21)"
end

function base64Encode(data)
	local len = data:len()
	local t = {}
	for i=1,len,384 do
		local n = math.min(384, len+1-i)
		if n > 0 then
			local s = data:sub(i, i+n-1)
			local enc, _ = mime.b64(s)
			t[#t+1] = enc
		end
	end
	return table.concat(t)
end

function string.urlEncode( str )
   if ( str ) then
      str = string.gsub( str, "\n", "\r\n" )
      str = string.gsub( str, "([^%w ])",
         function (c) return string.format( "%%%02X", string.byte(c) ) end )
      str = string.gsub( str, " ", "+" )
   end
   return str
end

function format_thousand(v)
	--local s = string.format("%d", math.floor(v))
  s=v
	local pos = string.len(s) % 3
	if pos == 0 then pos = 3 end
	return string.sub(s, 1, pos)
		.. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
		.. string.sub(string.format("%.0f", v - math.floor(v)), 2)
end

function isIpAddress(ip)
   if not ip then return false end
   local a,b,c,d=ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
   a=tonumber(a)
   b=tonumber(b)
   c=tonumber(c)
   d=tonumber(d)
   if not a or not b or not c or not d then return false end
   if a<0 or 255<a then return false end
   if b<0 or 255<b then return false end
   if c<0 or 255<c then return false end
   if d<0 or 255<d then return false end
   return true
end

local function closeApp( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
          native.requestExit()
        else
          os.exit() 
      end
    end
end

local function closeAppQ( event )
    if ( event.action == "clicked" ) then
      local i = event.index
      if ( i == 1 ) then
        if  system.getInfo("platformName")=="Android" then
          native.requestExit()
        else
          os.exit() 
        end
      elseif ( i == 2 ) then
          --    
      end
        
    end
end

local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

--Nonce to mitigate Replay Attacks
function generateNonce()
    local nonce = randomString(64)
    local jsonRequest = {["nonce"] = nonce, ["timestamp"] = os.time()}
    jsonRequest = json.encode(jsonRequest)
    local encryptedDataTemp = base64Encode(cipher:encrypt(jsonRequest,crypto.digest( crypto.md5, base64Encode(system.getInfo("deviceID")))))
    --GitHub Note: here you have to put your encryption key used for nonce
    local encryptedData = base64Encode(cipher:encrypt(encryptedDataTemp,"XXX"))
    return encryptedData
end

function localToken()
  loginInfo = loadsave.loadTable( "loginStatus.json" )  
  if (loginInfo == nil) then
    local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, closeApp )
  else
    return loginInfo
  end
end

local function onKeyEvent( event )
    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
    if (event.phase == "up") then
        local platformName = system.getInfo( "platformName" )
        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
          local currScene = composer.getSceneName( "current" )
          if (currScene == "homeScene") then
            if (detailsOverlay==true) then
                detailsOverlay=false
                composer.hideOverlay( "fade",0 )
            elseif (chatOpen == 1) then closeGC() 
            elseif (chatOpen == 0) then
                local alert = native.showAlert( "EliteHax", "Are you sure you want to close the app?", { "Yes", "No" }, closeAppQ )
            end
          elseif (currScene == "c2cManageScene") then
              goBackC2C()
          elseif (currScene == "researchScene") then
              goBackRC()
          elseif (currScene == "upgradeScene") then
              goBackUpgrade()
          elseif (currScene == "tournamentScene") then
              goBackTournament()
          elseif (currScene == "achievementScene") then
              goBackAchievement()
          elseif (currScene == "upgradeAttackerScene") then
              goBackAttackerW()
          elseif (currScene == "terminalScene") then
              if (scanOverlay==true) then
                goBackScan()
              elseif (addTargetOverlay==true) then
                goBackAddEdit()
              elseif (targetListOverlay==true) then
                closeTL()
              else
                goBackTerminal()
              end       
          elseif (currScene == "messageScene") then
              if (msgOverlay == true) then
                closePC()
              else
                goBackMessages()
              end
          elseif (currScene == "taskScene") then
              goBackTasks()
          elseif (currScene == "logScene") then
              goBackLogs()
          elseif (currScene == "offerScene") then
              goBackItems()
          elseif (currScene == "skillTreeScene") then
              goBackST()
          elseif (currScene == "crewShopScene") then
              goBackCrewShop()
          elseif (currScene == "playerScene") then
              goBackPlayer()
          elseif (currScene == "playerNotificationScene") then
              goBackPlayerNotifications()
          elseif (currScene == "supporterScene") then
              goBackPlayerSupporter()
          elseif (currScene == "crewScene") and (loaded == true) then
              goBackCrew()
          elseif (currScene == "leaderboardScene") then
              goBackLeaderboard()
          elseif (currScene == "missionScene") then
              goBackMission()
          elseif (currScene == "crewSettingScene") then
              goBackCrewSettings()
          elseif (currScene == "myCrewMembersScene") then
              goBackCrewM()
          elseif (currScene == "myCrewRequestsScene") then
              goBackCrewR()
          elseif (currScene == "newCrewScene") then
              goBackNewCrew()
          elseif (currScene == "tutorialScene") then
              goBackTutorial()
          elseif (currScene == "statisticsScene") then
              goBackPlayerStat()
          elseif (currScene == "playerSettingScene") then
              goBackPlayerSettings()
          elseif(currScene == "defendDatacenterScene") then
              goBackCrew()
          elseif(currScene == "datacenterScene") then
              goBackRegion()
          elseif(currScene == "regionScene") then
              goBackmap()
          elseif(currScene == "mapScene") then
              goBackCrew()     
          elseif(currScene == "myDatacenterScene") then
              goBackCrew()
          elseif(currScene == "crewLogsScene") then
              goBackCrewLogs()
          elseif (currScene == "hackMapScene") then
              if (scanOverlay == true) then
                closePCD()
              else
                goBackHackMap()
              end
          elseif (currScene == "hackScene") then
              goBackHack()
          end   
          return true
        end
    else
      return true
    end
    end
    return false
end
-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )

local function myUnhandledErrorListener( event )
 
    local iHandledTheError = true
    print(event.errorMessage)
    
    return iHandledTheError
end
 
Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

function topPadding()
  if (display.actualContentHeight == display.contentHeight) then
    return 0
  else
    return ((display.contentHeight-display.actualContentHeight)/2)+5
  end
end

function fontSize(font)
  return math.round(font*display.actualContentHeight/display.contentHeight)
end

function maskScaleFactor()
  local curScale=display.actualContentHeight/display.actualContentWidth
  local normalScale=1920/1080
  local newScale=1
  if ((curScale>1.33) and (curScale<1.34)) then
    newScale=curScale/normalScale
  end
  return newScale
end

function timeText(seconds)
  local timeLeft = 0
  if (seconds < 0) then 
    timeLeft = "Finished" 
  else
    local minutes = math.floor( seconds / 60 )
    local hours = 0
    if (minutes>59) then 
        hours=minutes/60
        minutes = minutes % 60
    end
    local seconds = seconds % 60
    if (hours>=1) then timeLeft = string.format( "%01d:%02d:%02d", hours, minutes, seconds )
    else timeLeft = string.format( "%01d:%02d", minutes, seconds ) end
  end
  return timeLeft
end

function makeTimeStamp( dateString )
  local pattern = "(%d+)%-(%d+)%-(%d+) (%d+)%:(%d+)%:([%d%.]+)"
  local year, month, day, hour, minute, seconds = dateString:match(pattern)
  local now = os.time()
  local diff= os.difftime(now, os.time(os.date("!*t", now)))
  local timestamp = os.time(
       { year=year, month=month, day=day, hour=hour, min=minute, sec=seconds+diff+3600 }
    ) 
  return os.date("%Y-%m-%d %H:%M:%S",timestamp)
end

function quicksortA(t, sortname, start, endi)
  start, endi = start or 1, endi or #t
  sortname = sortname or 1
  if(endi - start < 1) then return t end
  local pivot = start
  for i = start + 1, endi do
    if  t[i][sortname] <= t[pivot][sortname] then
      local temp = t[pivot + 1]
      t[pivot + 1] = t[pivot]
      if(i == pivot + 1) then
        t[pivot] = temp
      else
        t[pivot] = t[i]
        t[i] = temp
      end
      pivot = pivot + 1
    end
  end
  t = quicksortA(t, sortname, start, pivot - 1)
  return quicksortA(t, sortname, pivot + 1, endi)
end

function quicksortD(t, sortname, start, endi)
  start, endi = start or 1, endi or #t
  sortname = sortname or 1
  if(endi - start < 1) then return t end
  local pivot = start
  for i = start + 1, endi do
    if  t[i][sortname] >= t[pivot][sortname] then
      local temp = t[pivot + 1]
      t[pivot + 1] = t[pivot]
      if(i == pivot + 1) then
        t[pivot] = temp
      else
        t[pivot] = t[i]
        t[i] = temp
      end
      pivot = pivot + 1
    end
  end
  t = quicksortD(t, sortname, start, pivot - 1)
  return quicksortD(t, sortname, pivot + 1, endi)
end

--GitHub Note: appMode="test" will print all debug info, appMode="prod" will disable the print function to avoid printing debug info on the final app
--REMEMBER TO CHANGE THIS!!!
local appMode = "test"
 
if appMode == "prod" then
     oldPrint = print
     print = function() end
end

function changeImgColor(imgObj)
    if (skinColor ~= "green") then
      if ((system.getInfo( "gpuSupportsHighPrecisionFragmentShaders" ) == false ) or (skinColor=="silver") or (skinColor=="aqua")) then
        imgObj.fill.effect="filter.monotone"
        imgObj.fill.effect.r,imgObj.fill.effect.g,imgObj.fill.effect.b=skinTone.r,skinTone.g,skinTone.b
        --imgObj.fill.effect.r,imgObj.fill.effect.g,imgObj.fill.effect.b=0.5,0.97,0.98
      else
        imgObj.fill.effect="filter.hue"
        imgObj.fill.effect.angle=angleColor
      end
    end
end

--Color Definition
function applySkin(skin)
  if (skin=="green") then
      tableColor1=tableGreen1
      tableColor2=tableGreen2
      tableColor3=tableGreen3
      textColor1=textGreen1
      textColor2=textGreen2
      strokeColor1=strokeGreen1
      angleColor=angleGreen
      buttonColor1080=buttonGreen1080
      buttonColor400=buttonGreen400
      stepperColor=stepperGreen
      sliderColor=sliderGreen
      tabBarColor=tabBarGreen
      progressColor=progressGreen
      checkboxColor=checkboxGreen
      refreshColor=refreshGreen
      skillColor=skillGreen
      skinTone=greenTone
  end
  if (skin=="blue") then
      tableColor1=tableBlue1
      tableColor2=tableBlue2
      tableColor3=tableBlue3
      textColor1=textBlue1
      textColor2=textBlue2
      strokeColor1=strokeBlue1
      angleColor=angleBlue
      buttonColor1080=buttonBlue1080
      buttonColor400=buttonBlue400
      stepperColor=stepperBlue
      sliderColor=sliderBlue
      tabBarColor=tabBarBlue
      progressColor=progressBlue
      checkboxColor=checkboxBlue
      refreshColor=refreshBlue
      skillColor=skillBlue
      skinTone=blueTone
  end
  if (skin=="red") then
      tableColor1=tableRed1
      tableColor2=tableRed2
      tableColor3=tableRed3
      textColor1=textRed1
      textColor2=textRed2
      strokeColor1=strokeRed1
      angleColor=angleRed
      buttonColor1080=buttonRed1080
      buttonColor400=buttonRed400
      stepperColor=stepperRed
      sliderColor=sliderRed
      tabBarColor=tabBarRed
      progressColor=progressRed
      checkboxColor=checkboxRed
      refreshColor=refreshRed
      skillColor=skillRed
      skinTone=redTone
  end
  if (skin=="yellow") then
      tableColor1=tableYellow1
      tableColor2=tableYellow2
      tableColor3=tableYellow3
      textColor1=textYellow1
      textColor2=textYellow2
      strokeColor1=strokeYellow1
      angleColor=angleYellow
      buttonColor1080=buttonYellow1080
      buttonColor400=buttonYellow400
      stepperColor=stepperYellow
      sliderColor=sliderYellow
      tabBarColor=tabBarYellow
      progressColor=progressYellow
      checkboxColor=checkboxYellow
      refreshColor=refreshYellow
      skillColor=skillYellow
      skinTone=yellowTone
  end
  if (skin=="purple") then
      tableColor1=tablePurple1
      tableColor2=tablePurple2
      tableColor3=tablePurple3
      textColor1=textPurple1
      textColor2=textPurple2
      strokeColor1=strokePurple1
      angleColor=anglePurple
      buttonColor1080=buttonPurple1080
      buttonColor400=buttonPurple400
      stepperColor=stepperPurple
      sliderColor=sliderPurple
      tabBarColor=tabBarPurple
      progressColor=progressPurple
      checkboxColor=checkboxPurple
      refreshColor=refreshPurple
      skillColor=skillPurple
      skinTone=purpleTone
  end
  if (skin=="orange") then
      tableColor1=tableOrange1
      tableColor2=tableOrange2
      tableColor3=tableOrange3
      textColor1=textOrange1
      textColor2=textOrange2
      strokeColor1=strokeOrange1
      angleColor=angleOrange
      buttonColor1080=buttonOrange1080
      buttonColor400=buttonOrange400
      stepperColor=stepperOrange
      sliderColor=sliderOrange
      tabBarColor=tabBarOrange
      progressColor=progressOrange
      checkboxColor=checkboxOrange
      refreshColor=refreshOrange
      skillColor=skillOrange
      skinTone=orangeTone
  end
  if (skin=="silver") then
      tableColor1=tableSilver1
      tableColor2=tableSilver2
      tableColor3=tableSilver3
      textColor1=textSilver1
      textColor2=textSilver2
      strokeColor1=strokeSilver1
      angleColor=angleSilver
      buttonColor1080=buttonSilver1080
      buttonColor400=buttonSilver400
      stepperColor=stepperSilver
      sliderColor=sliderSilver
      tabBarColor=tabBarSilver
      progressColor=progressSilver
      checkboxColor=checkboxSilver
      refreshColor=refreshSilver
      skillColor=skillSilver
      skinTone=silverTone
  end
  if (skin=="aqua") then
      tableColor1=tableAqua1
      tableColor2=tableAqua2
      tableColor3=tableAqua3
      textColor1=textAqua1
      textColor2=textAqua2
      strokeColor1=strokeAqua1
      angleColor=angleAqua
      buttonColor1080=buttonAqua1080
      buttonColor400=buttonAqua400
      stepperColor=stepperAqua
      sliderColor=sliderAqua
      tabBarColor=tabBarAqua
      progressColor=progressAqua
      checkboxColor=checkboxAqua
      refreshColor=refreshAqua
      skillColor=skillAqua
      skinTone=aquaTone
  end
end

skin="green"
tableGold={ default = { 0.8, 0.6, 0, 0.9 }, over={ 0.8, 0.6, 0, 0.9 } }
tableSilver={ default = { 0.63, 0.63, 0.63, 0.9 }, over={ 0.63, 0.63, 0.63, 0.9 } }
tableBronze={ default = { 0.58, 0.35, 0.31, 0.9 }, over={ 0.58, 0.35, 0.31, 0.9 } }
tableGreen1={ default = { 0.15, 0.59, 0.17, 0.9 }, over = { 0.15, 0.59, 0.17, 0.9 } }
tableGreen2={ default = { 0.15, 0.49, 0.17, 0.9 }, over = { 0.15, 0.49, 0.17, 0.9 } }
tableGreen3={ default = { 0.15, 0.29, 0.17, 0.9 }, over = { 0.15, 0.29, 0.17, 0.9 } }
greenTone={r=0,g=0.5,b=0}
angleGreen=0
buttonGreen1080="img/button_1080.png"
buttonGreen400="img/button_400.png"
stepperGreen="img/crew_wallet_stepper_green.png"
sliderGreen="img/widget-slider_green.png"
tabBarGreen="img/widget-tabbar-sheet.png"
progressGreen="img/widget-progress-view.png"
checkboxGreen="img/global_search.png"
refreshGreen="img/refresh.png"
skillGreen="img/+skill.png"
tableBlue1={ default = { 0.0, 0.29, 0.5, 0.9 }, over = { 0, 0.29, 0.5, 0.9 } }
tableBlue2={ default = { 0.0, 0.29, 0.4, 0.9 }, over = { 0, 0.29, 0.4, 0.9 } }
tableBlue3={ default = { 0.0, 0.29, 0.3, 0.9 }, over = { 0, 0.29, 0.3, 0.9 } }
blueTone={r=0,g=0.3,b=0.5}
angleBlue=275
buttonBlue1080="img/button_1080_blue.png"
buttonBlue400="img/button_400_blue.png"
stepperBlue="img/crew_wallet_stepper_blue.png"
sliderBlue="img/widget-slider_blue.png"
tabBarBlue="img/widget-tabbar-sheet_blue.png"
progressBlue="img/widget-progress-view_blue.png"
checkboxBlue="img/global_search_blue.png"
refreshBlue="img/refresh_blue.png"
skillBlue="img/+skill_blue.png"
tableRed1={ default = { 0.69, 0.17, 0.15, 0.9 }, over = { 0.69, 0.17, 0.15, 0.9 } }
tableRed2={ default = { 0.59, 0.17, 0.15, 0.9 }, over = { 0.59, 0.17, 0.15, 0.9 } }
tableRed3={ default = { 0.29, 0.17, 0.15, 0.9 }, over = { 0.29, 0.17, 0.15, 0.9 } }
redTone={r=0.5,g=0,b=0}
angleRed=115
buttonRed1080="img/button_1080_red.png"
buttonRed400="img/button_400_red.png"
stepperRed="img/crew_wallet_stepper_red.png"
sliderRed="img/widget-slider_red.png"
tabBarRed="img/widget-tabbar-sheet_red.png"
progressRed="img/widget-progress-view_red.png"
checkboxRed="img/global_search_red.png"
refreshRed="img/refresh_red.png"
skillRed="img/+skill_red.png"
tableYellow1={ default = { 0.80, 0.80, 0.20, 0.9 }, over = { 0.80, 0.80, 0.20, 0.9 } }
tableYellow2={ default = { 0.70, 0.70, 0.20, 0.9 }, over = { 0.70, 0.70, 0.20, 0.9 } }
tableYellow3={ default = { 0.40, 0.40, 0.20, 0.9 }, over = { 0.40, 0.40, 0.20, 0.9 } }
yellowTone={r=0.5,g=0.5,b=0}
angleYellow=60
buttonYellow1080="img/button_1080_yellow.png"
buttonYellow400="img/button_400_yellow.png"
stepperYellow="img/crew_wallet_stepper_yellow.png"
sliderYellow="img/widget-slider_yellow.png"
tabBarYellow="img/widget-tabbar-sheet_yellow.png"
progressYellow="img/widget-progress-view_yellow.png"
checkboxYellow="img/global_search_yellow.png"
refreshYellow="img/refresh_yellow.png"
skillYellow="img/+skill_yellow.png"
tablePurple1={ default = { 0.64, 0.28, 0.64, 0.9 }, over = { 0.64, 0.28, 0.64, 0.9 } }
tablePurple2={ default = { 0.54, 0.28, 0.54, 0.9 }, over = { 0.54, 0.28, 0.54, 0.9 } }
tablePurple3={ default = { 0.44, 0.28, 0.44, 0.9 }, over = { 0.44, 0.28, 0.44, 0.9 } }
purpleTone={r=0.33,g=0,b=0.5}
anglePurple=200
buttonPurple1080="img/button_1080_purple.png"
buttonPurple400="img/button_400_purple.png"
stepperPurple="img/crew_wallet_stepper_purple.png"
sliderPurple="img/widget-slider_purple.png"
tabBarPurple="img/widget-tabbar-sheet_purple.png"
progressPurple="img/widget-progress-view_purple.png"
checkboxPurple="img/global_search_purple.png"
refreshPurple="img/refresh_purple.png"
skillPurple="img/+skill_purple.png"
tableOrange1={ default = { 0.8, 0.4, 0.0, 0.9 }, over = { 0.8, 0.4, 0.0, 0.9 } }
tableOrange2={ default = { 0.7, 0.3, 0.0, 0.9 }, over = { 0.7, 0.3, 0.0, 0.9 } }
tableOrange3={ default = { 0.6, 0.2, 0.0, 0.9 }, over = { 0.6, 0.2, 0.0, 0.9 } }
orangeTone={r=0.5,g=0.25,b=0}
angleOrange=90
buttonOrange1080="img/button_1080_orange.png"
buttonOrange400="img/button_400_orange.png"
stepperOrange="img/crew_wallet_stepper_orange.png"
sliderOrange="img/widget-slider_orange.png"
tabBarOrange="img/widget-tabbar-sheet_orange.png"
progressOrange="img/widget-progress-view_orange.png"
checkboxOrange="img/global_search_orange.png"
refreshOrange="img/refresh_orange.png"
skillOrange="img/+skill_orange.png"
tableSilver1={ default = { 0.66, 0.66, 0.66, 0.9 }, over = { 0.66, 0.66, 0.66, 0.9 } }
tableSilver2={ default = { 0.55, 0.55, 0.55, 0.9 }, over = { 0.55, 0.55, 0.55, 0.9 } }
tableSilver3={ default = { 0.45, 0.45, 0.45, 0.9 }, over = { 0.45, 0.45, 0.45, 0.9 } }
silverTone={r=0.66,g=0.66,b=0.66}
angleSilver=90
buttonSilver1080="img/button_1080_silver.png"
buttonSilver400="img/button_400_silver.png"
stepperSilver="img/crew_wallet_stepper_silver.png"
sliderSilver="img/widget-slider_silver.png"
tabBarSilver="img/widget-tabbar-sheet_silver.png"
progressSilver="img/widget-progress-view_silver.png"
checkboxSilver="img/global_search_silver.png"
refreshSilver="img/refresh_silver.png"
skillSilver="img/+skill_silver.png"
tableAqua1={ default = { 0.08, 0.78, 0.72, 0.9 }, over = { 0.08, 0.78, 0.72, 0.9 } }
tableAqua2={ default = { 0.08, 0.68, 0.62, 0.9 }, over = { 0.08, 0.68, 0.62, 0.9 } }
tableAqua3={ default = { 0, 0.58, 0.52, 0.9 }, over = { 0, 0.58, 0.62, 0.9 } }
aquaTone={r=0.08,g=0.78,b=0.72}
angleAqua=90
buttonAqua1080="img/button_1080_aqua.png"
buttonAqua400="img/button_400_aqua.png"
stepperAqua="img/crew_wallet_stepper_aqua.png"
sliderAqua="img/widget-slider_aqua.png"
tabBarAqua="img/widget-tabbar-sheet_aqua.png"
progressAqua="img/widget-progress-view_aqua.png"
checkboxAqua="img/global_search_aqua.png"
refreshAqua="img/refresh_aqua.png"
skillAqua="img/+skill_aqua.png"
tableGold={ default = { 0.8, 0.6, 0, 0.9, 0.9 }, over={ 0.8, 0.6, 0, 0.9, 0.9 } }
tableSilver={ default = { 0.63, 0.63, 0.63, 0.9 }, over={0.63, 0.63, 0.63, 0.9 } }
tableBronze={ default = { 0.58, 0.35, 0.31, 0.9 }, over={ 0.58, 0.35, 0.31, 0.9 } }
textGreen1={0,0.7,0}
textBlue1={0,0.29,0.5}
textRed1={0.7,0,0}
textYellow1={0.8,0.8,0.2}
textPurple1={0.64,0.28,0.64}
textOrange1={0.8,0.4,0}
textSilver1={0.66,0.66,0.66}
textAqua1={0.08,0.78,0.72}
textGreen2={0,0.5,0}
textBlue2={0,0.29,0.3}
textRed2={0.5,0,0}
textYellow2={0.7,0.7,0.2}
textPurple2={0.44,0.28,0.44}
textOrange2={0.7,0.3,0}
textSilver2={0.55,0.55,0.55}
textAqua2={0.08,0.68,0.62}
strokeGreen1={0,0.7,0}
strokeBlue1={0,0.29,0.5}
strokeRed1={0.7,0,0}
strokeYellow1={0.8,0.8,0.2}
strokePurple1={0.64,0.28,0.64}
strokeOrange1={0.8,0.4,0}
strokeSilver1={0.66,0.66,0.66}
strokeAqua1={0.08,0.78,0.72}

applySkin("green")

--Notifications
function setNewNotifications( event )
    if (notificationGlobal) then 
        notifications.cancelNotification(notificationGlobal) 
        notificationGlobal=nil
    end
    if (notificationGlobalResearch) then 
        notifications.cancelNotification(notificationGlobalResearch) 
        notificationGlobalResearch=nil
    end
    notifications.cancelNotification()
    print("Previous Notifications Canceled")
    local tempNotificationActive = loadsave.loadTable( "localNotificationStatus.json" )
    if ((tempNotificationActive.task~=nil) and (os.difftime(tempNotificationActive.taskTime,os.time())>0)) then
        print("Setting New Task Notifications: "..json.prettify(tempNotificationActive.task).."\n"..tempNotificationActive.taskTime)
        notificationGlobal=notifications.scheduleNotification(tempNotificationActive.task,{alert="All your tasks are now finished!"})
    end
    if ((tempNotificationActive.research~=nil) and (os.difftime(tempNotificationActive.researchTime,os.time())>0)) then
        print("Setting New Research Notifications: "..json.prettify(tempNotificationActive.research).."\n"..tempNotificationActive.researchTime)
        notificationGlobalResearch=notifications.scheduleNotification(tempNotificationActive.research,{alert="Your research is finished!"})
    end
end

-- Listen for notifications
local function onNotification( event )
  if ((event.type=="local") and (event.applicationState=="active")) then
    if (event.alert=="All your tasks are now finished!") then
      notifications.cancelNotification()
      notificationActive.task=nil
      notificationActive.taskTime=nil
      notificationGlobal=nil
    elseif (event.alert=="Your research is finished!") then
      notifications.cancelNotification()
      notificationActive.research=nil
      notificationActive.researchTime=nil
      notificationGlobalResearch=nil
    end
    notifications.cancelNotification()
    loadsave.saveTable( notificationActive, "localNotificationStatus.json" )
    if ( event.alert ) then
        local alert = native.showAlert( "EliteHax", event.alert, { "Close" } )
    end
    setNewNotifications()
  end
end
Runtime:addEventListener( "notification", onNotification )

notificationGlobal=nil
notificationGlobalResearch=nil
taskNotificationActive=true
researchNotificationActive=true
notificationText=""

return M