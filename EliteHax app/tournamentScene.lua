local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local tournamentScene = composer.newScene()
local updateTimer
local view = "info"
local rewView = "players"
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function onRowTouch( event )
    if (event.phase=="tap") then
        if (view=="crew") then
            local row = event.row
            local params = event.row.params
            if (params.id ~= "") and (detailsOverlay==false) then
                detailsOverlay=true
                local sceneOverlayOptions = 
                {
                    time = 200,
                    effect = "crossFade",
                    params = { 
                        id = params.id,
                    },
                    isModal = true
                }
                tapSound()
                composer.showOverlay( "crewDetailsScene", sceneOverlayOptions)
            end
        elseif (view=="player") then
            local row = event.row
            local params = event.row.params
            if (params.user ~= "") and (detailsOverlay==false) then
                detailsOverlay=true
                local sceneOverlayOptions = 
                {
                    time = 200,
                    effect = "crossFade",
                    params = { 
                        id = params.user,
                    },
                    isModal = true
                }
                tapSound()
                composer.showOverlay( "playerDetailsScene", sceneOverlayOptions)
            end
        end
    end
end


local function onRowRender( event )
    
    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    if ((view=="crew") or (view=="player")) then
        row.rowRank = display.newText( row, params.rank..".", 0, 0, native.systemFont, fontSize(70) )
        row.rowRank.anchorX=0.5
        row.rowRank.anchorY=0
        row.rowRank.x =  iconSize*0.35
        row.rowRank.y = row.contentHeight * 0.15
        row.rowRank:setTextColor( 0, 0, 0 )

        row.rowPlayer = display.newText( row, params.user, 0, 0, native.systemFont, fontSize(65) )
        row.rowPlayer.anchorX = 0
        row.rowPlayer.x =  iconSize*0.7
        row.rowPlayer.y = row.contentHeight * 0.22
        row.rowPlayer:setTextColor( 0, 0, 0 )
        if (params.crew ~= nil) then
            if (params.crew ~= "") then row.rowPlayer.text = row.rowPlayer.text.." ("..params.crew..")" end
        end

        local rankText="Money Hacked: $"
        if (params.type=="2") then
            rankText="Score Gained: "
        end

        row.rowScore = display.newText( row, rankText..format_thousand(params.score), 0, 0, native.systemFont, fontSize(55) )
        row.rowScore.anchorX = 0
        row.rowScore.x =  iconSize*0.7
        row.rowScore.y = row.contentHeight * 0.58
        row.rowScore:setTextColor( 0, 0, 0 )
    else
        local fsize=fontSize(60)
        if (params.title==true) then fsize=fontSize(62) end
        row.rowPlayer = display.newText( row, params.text, 0, 0, native.systemFont, fsize )
        row.rowPlayer.anchorX = 0.5
        row.rowPlayer.x =  myData.LBTableView.width/2
        row.rowPlayer.y = row.contentHeight * 0.3
        if (params.title==true) then
            row.rowPlayer:setTextColor( 1, 1, 1 )
        else
            row.rowPlayer:setTextColor( 0, 0, 0 )
        end
    end

end

local function onRewRowRender( event )
    
    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowPlayer = display.newText( row, params.reward, 0, 0, native.systemFont, fontSize(52) )
    row.rowPlayer.anchorX = 0
    row.rowPlayer.anchorY = 0
    row.rowPlayer.x =  fontSize(345)
    row.rowPlayer.y = row.contentHeight * 0.1
    row.rowPlayer:setTextColor( 0, 0, 0 )

    row.rowRank = display.newText( row, params.range, 0, 0, native.systemFont, fontSize(52) )
    row.rowRank.anchorX=0
    row.rowRank.anchorY=0
    row.rowRank.x =  fontSize(30)
    row.rowRank.y = row.contentHeight * 0.1
    row.rowRank:setTextColor( 0, 0, 0 )
end

local function playerRew( event )
    myData.TMRewNote.text="NOTE: Rewards are based on 200 players"
    myData.rewardTableView:deleteAllRows()
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="1st",
            color=tableGold,
            reward="500 Cryptocoins / 100XP"                 
        }
    })    
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="2nd",
            color=tableSilver,
            reward="400 Cryptocoins /   80XP"                 
        }
    })  
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="3rd",
            color=tableBronze,
            reward="350 Cryptocoins /   70XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="4th",
            color=color,
            reward="300 Cryptocoins /   60XP"                 
        }
    })  
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="5th",
            color=color,
            reward="250 Cryptocoins /   50XP"                 
        }
    })    
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="6th-10th",
            color=color,
            reward="200 Cryptocoins /   40XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="11th-25th",
            color=color,
            reward="100 Cryptocoins /   20XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="26th-50th",
            color=color,
            reward="  75 Cryptocoins /   15XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="51th-100th",
            color=color,
            reward="  50 Cryptocoins /   10XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="101th-200th",
            color=color,
            reward="  30 Cryptocoins /     6XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="201th-500th",
            color=color,
            reward="  20 Cryptocoins /     4XP"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="501th-1000th",
            color=color,
            reward="  10 Cryptocoins /     2XP"           
        }
    })   
end

local function crewRew( event )
    myData.TMRewNote.text="NOTE: Rewards are based on 50 Crews"
    myData.rewardTableView:deleteAllRows()
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="1st",
            color=tableGold,
            reward="1000 Cryptocoins"                 
        }
    })    
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="2nd",
            color=tableSilver,
            reward="800 Cryptocoins"                 
        }
    })  
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="3rd",
            color=tableBronze,
            reward="700 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="4th",
            color=color,
            reward="600 Cryptocoins"                 
        }
    })  
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="5th",
            color=color,
            reward="500 Cryptocoins"                 
        }
    })    
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="6th-10th",
            color=color,
            reward="400 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="11th-25th",
            color=color,
            reward="200 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="26th-50th",
            color=color,
            reward="150 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="51th-100th",
            color=color,
            reward="100 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="101th-200th",
            color=color,
            reward="  60 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor2
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="201th-500th",
            color=color,
            reward="  40 Cryptocoins"                 
        }
    })   
    rowColor = {
      default = { 0, 0, 0, 0 }
    }
    lineColor = { 
      default = { 1, 0, 0 }
    }
    local color=tableColor1
    myData.rewardTableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = iconSize/2.3,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            range="501th-1000th",
            color=color,
            reward="  20 Cryptocoins"           
        }
    })   
end

local function handleRewTabBarEvent( event )
    if (event.target.id == "players") then
        tapSound()
        playerRew()
        rewView="players"
    elseif (event.target.id == "crews") then
        tapSound()
        crewRew()
        rewView="crews"
    end
end

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

local function TMInfoNetworkListener( event )
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

        if (t.username) then
            if (string.len(t.username)>15) then myData.playerTextTM.size = fontSize(42) end
            myData.playerTextTM.text=t.username
            myData.moneyTextTM.text=format_thousand(t.money)
        end

        local TMType=""
        if (t.type==0) then
            if (t.next_type==1) then
                local image = { type="image",filename="img/tournament_hack.png"}
                myData.TMDescImg.fill=image
                TMType = "Hack Tournament"
                myData.TMDescText.text="Hack Tournament leaderboard is based on the money stolen by hacking during the tournament time (1h).\nOnly the first 100 Attacks are evaluated, choose your target wisely."
            elseif (t.next_type==2) then
                TMType = "Score Tournament"
                myData.TMDescText.text="Score Tournament leaderboard is based on the score gained during the tournament time (4h).\nYou can use overclocks to complete more upgrades and you can also open your packs!"
            elseif (t.next_type==3) then
                local image = { type="image",filename="img/tournament_hackdefend.png"}
                myData.TMDescImg.fill=image
                TMType = "Hack&Defend Tournament"
                myData.TMDescText.text="Hack&Defend Tournament leaderboard is based on the difference between money stolen and money lost by hacking during the tournament time (1h).\nOnly the first 100 Attacks are evaluated, choose your target wisely."
            end
            changeImgColor(myData.TMDescImg)
            myData.TMStatusText:setFillColor(0.7,0,0)
            myData.TMStatusText.text="Not Active"
            myData.TMTimeText.text=timeText(tonumber(t.next_time))
            myData.TMTimeText.secondsLeft=tonumber(t.next_time)
        else
            if (t.type==1) then
                local image = { type="image",filename="img/tournament_hack.png"}
                myData.TMDescImg.fill=image
                TMType = "Hack Tournament"
                myData.TMDescText.text="Hack Tournament leaderboard is based on the money stolen by hacking during the tournament time (1h).\nOnly the first 100 Attacks are evaluated, choose your target wisely."
            elseif (t.type==2) then
                TMType = "Score Tournament"
                myData.TMDescText.text="Score Tournament leaderboard is based on the score gained during the tournament time (4h).\nYou can use overclocks to complete more upgrades and you can also open your packs!"
            elseif (t.type==3) then
                local image = { type="image",filename="img/tournament_hackdefend.png"}
                myData.TMDescImg.fill=image
                TMType = "Hack&Defend Tournament"
                myData.TMDescText.text="Hack&Defend Tournament leaderboard is based on the difference between money stolen and money lost by hacking during the tournament time (1h).\nOnly the first 100 Attacks are evaluated for your money stolen, choose your target wisely."
            end
            --changeImgColor(myData.TMStatusImg)
            changeImgColor(myData.TMDescImg)
            myData.TMStatusText:setFillColor(0,0.7,0)
            myData.TMStatusText.text="Active"
            local image={type="image", filename="img/tournament_time_left.png"}
            myData.TMTimeImg.fill=image
            changeImgColor(myData.TMTimeImg)
            myData.TMTimeText.text=timeText(tonumber(t.current))
            myData.TMTimeText.secondsLeft=tonumber(t.current)          
        end
        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end
        countDownTimer = timer.performWithDelay( 1000, updateTimer, 10000000 )

        if (rewView=="players") then
            playerRew()
        else
            crewRew()
        end

   end
end

local function LBNetworkListener( event )
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

        if (t.ranks[1] == nil) then
            --local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        end

        if (t.musername) then
            if (string.len(t.musername)>15) then myData.playerTextTM.size = fontSize(42) end
            myData.playerTextTM.text=t.musername
            myData.moneyTextTM.text=format_thousand(t.mmoney)
        end

        local rankText="\nMoney Hacked: $"
        if (t.type=="2") then
            rankText="\nScore Gained: "
        end

        if (t.prank == 0) then
            if (t.active=="0") then
                myData.myRank.text = "You did not rank"
            else
                local hacksLeft=""
                if ((t.type=="1") or (t.type=="3")) then hacksLeft="\nHacks Left: "..t.hack_left end
                myData.myRank.text = "You are not ranking"..hacksLeft
            end
        else
            local hacksLeft=""
            if ((t.type=="1") or (t.type=="3")) then hacksLeft="      Hacks Left: "..t.hack_left end
            myData.myRank.text = "Rank: "..t.prank..hacksLeft..rankText..format_thousand(t.mscore)
        end

        for i in pairs( t.ranks ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i==1) then
                color = tableGold
            elseif (i==2) then
                color = tableSilver
            elseif (i==3) then
                color = tableBronze
            else
                if (i%2==0) then color=tableColor2 end
            end

            myData.LBTableView:insertRow(
            {
                isCategory = isCategory,
                rowHeight = fontSize(140),
                rowColor = rowColor,
                lineColor = lineColor,
                params = { 
                    rank=t.ranks[i].rank,
                    color=color,
                    crew=t.ranks[i].crew,
                    user=t.ranks[i].user,
                    score=t.ranks[i].score,   
                    id=t.ranks[i].id,
                    type=t.type                        
                }
            }
            )    
        end
   end
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (event.target.id == "players") then
        tapSound()
        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end
        myData.TMStatusImg.alpha=0
        myData.TMStatusText.alpha=0
        myData.TMTimeImg.alpha=0
        myData.TMTimeText.alpha=0
        myData.TMDescImg.alpha=0
        myData.TMDescText.alpha=0
        myData.TMRewImg.alpha=0
        myData.TMRewNote.alpha=0
        myData.rewardTableView.alpha=0
        myData.tabRewBar.alpha=0
        myData.myRankRect.alpha=1
        myData.myRank.alpha=1
        myData.lbRect.height=fontSize(1300)
        myData.LBTableView.height=fontSize(1250)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        myData.LBTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTournamentPLB.php", "POST", LBNetworkListener, params )
        view = "player"
    elseif (event.target.id == "crews") then
        tapSound()
        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end
        myData.TMStatusImg.alpha=0
        myData.TMStatusText.alpha=0
        myData.TMTimeImg.alpha=0
        myData.TMTimeText.alpha=0
        myData.TMDescImg.alpha=0
        myData.TMDescText.alpha=0
        myData.TMRewImg.alpha=0
        myData.TMRewNote.alpha=0
        myData.rewardTableView.alpha=0
        myData.tabRewBar.alpha=0
        myData.myRankRect.alpha=1
        myData.myRank.alpha=1
        myData.lbRect.height=fontSize(1300)
        myData.LBTableView.height=fontSize(1250)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        myData.LBTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTournamentCLB.php", "POST", LBNetworkListener, params )
        view = "crew"
    elseif (event.target.id == "info") then
        tapSound()
        myData.TMStatusImg.alpha=1
        myData.TMStatusText.alpha=1
        myData.TMTimeImg.alpha=1
        myData.TMTimeText.alpha=1
        myData.TMDescImg.alpha=1
        myData.TMDescText.alpha=1
        myData.TMRewImg.alpha=1
        myData.TMRewNote.alpha=1
        myData.rewardTableView.alpha=1
        myData.tabRewBar.alpha=1
        myData.LBTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTournamentInfo.php", "POST", TMInfoNetworkListener, params )
        myData.myRankRect.alpha=0
        myData.myRank.alpha=0
        myData.lbRect.height=fontSize(1580)
        myData.LBTableView.height=fontSize(1510)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        view = "info"
    end
end

updateTimer = function()
    local secondsLeft = myData.TMTimeText.secondsLeft
    if (secondsLeft >= 1) then
        secondsLeft = secondsLeft - 1
        myData.TMTimeText.text=timeText(secondsLeft)
        myData.TMTimeText.secondsLeft = secondsLeft
    else
        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTournamentInfo.php", "POST", TMInfoNetworkListener, params )        
    end
end


function goBackTournament(event)
    if (detailsOverlay==true) then
        detailsOverlay=false
        backSound()
        composer.hideOverlay( "fade",0 )
    else
        if (countDownTimer) then
        timer.cancel(countDownTimer)
        end
        backSound()
        composer.removeScene( "tournamentScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 300})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function tournamentScene:create(event)
    group = self.view

    loginInfo = localToken()
    detailsOverlay = false

    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextTM = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextTM.anchorX = 0
    myData.moneyTextTM.anchorY = 0.5
    myData.moneyTextTM:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextTM = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextTM.anchorX = 0.5
    myData.playerTextTM.anchorY = 0.5
    myData.playerTextTM:setFillColor( 0.9,0.9,0.9 )

    -- Configure the tab buttons to appear within the bar
    local options = {
        frames =
        {
            { x=4, y=0, width=24, height=120 },
            { x=32, y=0, width=40, height=120 },
            { x=72, y=0, width=40, height=120 },
            { x=112, y=0, width=40, height=120 },
            { x=152, y=0, width=328, height=120 },
            { x=480, y=0, width=328, height=120 }
        },
        sheetContentWidth = 812,
        sheetContentHeight = fontSize(120)
    }
    local tabBarSheet = graphics.newImageSheet( tabBarColor, options )

    local tabButtons = {
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Info",
            id = "info",
            selected = true,
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Players",
            id = "players",
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Crews",
            id = "crews",
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent
        }
    }
 
    -- Create the widget
    myData.tabBar = widget.newTabBar(
        {
            sheet = tabBarSheet,
            top = myData.top_background.y+myData.top_background.height,
            left = 20,
            width = display.contentWidth-40,
            height = 120,
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 160,
            buttons = tabButtons
        }
    )

    myData.lbRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1300) )
    myData.lbRect.anchorX = 0.5
    myData.lbRect.anchorY = 0
    myData.lbRect.x, myData.lbRect.y = display.contentWidth/2,myData.tabBar.y+myData.tabBar.height/2-fontSize(22)
    changeImgColor(myData.lbRect)

    myData.LBTableView = widget.newTableView(
        {
            left = 40,
            top = myData.lbRect.y+fontSize(20),
            height = fontSize(1250),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )

    --Tournament Info
    myData.TMStatusImg = display.newImageRect( buttonColor400,400,fontSize(100) )
    myData.TMStatusImg.anchorX = 0.5
    myData.TMStatusImg.anchorY = 0
    myData.TMStatusImg.x, myData.TMStatusImg.y = display.contentWidth/2,myData.lbRect.y+fontSize(30)
    myData.TMStatusText = display.newText("",display.contentWidth/2,myData.TMStatusImg.y+myData.TMStatusImg.height/2,native.systemFont, fontSize(70))
    myData.TMStatusText.anchorX = 0.5
    myData.TMStatusText.anchorY = 0.5
    myData.TMStatusText:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    --Tournament Time
    myData.TMTimeImg = display.newImageRect( "img/tournament_time_next.png",600,fontSize(180) )
    myData.TMTimeImg.anchorX = 0.5
    myData.TMTimeImg.anchorY = 0
    myData.TMTimeImg.x, myData.TMTimeImg.y = display.contentWidth/2,myData.TMStatusImg.y+myData.TMStatusImg.height+fontSize(10)
    changeImgColor(myData.TMTimeImg)
    myData.TMTimeText = display.newText("",display.contentWidth/2,myData.TMTimeImg.y+myData.TMTimeImg.height/2+fontSize(20),native.systemFont, fontSize(70))
    myData.TMTimeText.anchorX = 0.5
    myData.TMTimeText.anchorY = 0.5
    myData.TMTimeText:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    --Tournament Description
    myData.TMDescImg = display.newImageRect( "img/tournament_score.png",1000,fontSize(550) )
    myData.TMDescImg.anchorX = 0.5
    myData.TMDescImg.anchorY = 0
    myData.TMDescImg.x, myData.TMDescImg.y = display.contentWidth/2,myData.TMTimeImg.y+myData.TMTimeImg.height
    changeImgColor(myData.TMDescImg)
    myData.TMDescText = display.newText("",myData.TMDescImg.x-myData.TMDescImg.width/2+50,myData.TMDescImg.y+fontSize(110),920,0,native.systemFont, fontSize(50))
    myData.TMDescText.anchorX = 0
    myData.TMDescText.anchorY = 0
    myData.TMDescText:setFillColor( textColor1[1],textColor1[2],textColor1[3] )    

    --Tournament Rewards
    myData.TMRewImg = display.newImageRect( "img/tournament_rewards.png",1000,fontSize(600) )
    myData.TMRewImg.anchorX = 0.5
    myData.TMRewImg.anchorY = 0
    myData.TMRewImg.x, myData.TMRewImg.y = display.contentWidth/2,myData.TMDescImg.y+myData.TMDescImg.height
    changeImgColor(myData.TMRewImg)

    myData.TMRewNote = display.newText("NOTE: Rewards are based on 200 players", display.contentWidth/2+50,myData.TMRewImg.y+fontSize(100),myData.TMRewImg.width-50,0,native.systemFont, fontSize(45) )
    myData.TMRewNote.anchorX = 0.5
    myData.TMRewNote.anchorY = 0
    myData.TMRewNote:setFillColor( 1,1,1 )  

    local tabRewButtons = {
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Players",
            id = "players",
            selected = true,
            size = fontSize(60),
            labelYOffset = 0,
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleRewTabBarEvent
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Crews",
            id = "crews",
            size = fontSize(60),
            labelYOffset = 0,
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleRewTabBarEvent
        }
    }

        local options2 = {
        frames =
        {
            { x=4, y=0, width=24, height=120 },
            { x=32, y=0, width=40, height=120 },
            { x=72, y=0, width=40, height=120 },
            { x=112, y=0, width=40, height=120 },
            { x=152, y=0, width=328, height=120 },
            { x=480, y=0, width=328, height=120 }
        },
        sheetContentWidth = 812,
        sheetContentHeight = fontSize(100)
    }
    local tabBarSheet2 = graphics.newImageSheet( tabBarColor, options2 )
 
    -- Create the widget
    myData.tabRewBar = widget.newTabBar(
        {
            sheet = tabBarSheet2,
            top = myData.TMRewImg.y+fontSize(150),
            left = myData.TMRewImg.x-myData.TMRewImg.width/2+20,
            width = myData.TMRewImg.width-40,
            height = fontSize(60),
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 160,
            buttons = tabRewButtons
        }
    )

    myData.rewardTableView = widget.newTableView(
        {
            left = 70,
            top = myData.tabRewBar.y+myData.tabRewBar.height/2-20,
            height = fontSize(320),
            width = display.contentWidth-140,
            onRowRender = onRewRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )


    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBackTournament
    })

    --My Rank Rectangle
    myData.myRankRect = display.newImageRect( "img/leaderboard_details_rect.png",display.contentWidth-20,fontSize(280) )
    myData.myRankRect.anchorX = 0.5
    myData.myRankRect.anchorY = 0
    myData.myRankRect.x, myData.myRankRect.y = display.contentWidth/2,myData.lbRect.y+myData.lbRect.height-10
    changeImgColor(myData.myRankRect)

    --My Rank
    myData.myRank = display.newText("",display.contentWidth/2,myData.myRankRect.y+fontSize(164) ,native.systemFont, fontSize(64))
    myData.myRank.anchorX = 0.5
    myData.myRank.anchorY = 0.5
    myData.myRank:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextTM)
    group:insert(myData.playerTextTM)
    group:insert(myData.lbRect)
    group:insert(myData.backButton)
    group:insert(myData.LBTableView)
    group:insert(myData.TMStatusImg)
    group:insert(myData.TMStatusText)
    group:insert(myData.TMTimeImg)
    group:insert(myData.TMTimeText)
    group:insert(myData.TMDescImg)
    group:insert(myData.TMDescText)
    group:insert(myData.TMRewImg)
    group:insert(myData.tabRewBar)
    group:insert(myData.TMRewNote)
    group:insert(myData.rewardTableView)
    group:insert(myData.myRankRect)
    group:insert(myData.myRank)
    group:insert(myData.tabBar)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackTournament)
end

-- Home Show
function tournamentScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        myData.myRankRect.alpha=0
        myData.myRank.alpha=0
        myData.lbRect.height=fontSize(1580)
        myData.LBTableView.height=fontSize(1510)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTournamentInfo.php", "POST", TMInfoNetworkListener, params )
        local tutCompleted = loadsave.loadTable( "tournamentTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutTournament ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "tournamentTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
tournamentScene:addEventListener( "create", tournamentScene )
tournamentScene:addEventListener( "show", tournamentScene )
---------------------------------------------------------------------------------

return tournamentScene