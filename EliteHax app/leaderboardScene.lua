local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local leaderboardScene = composer.newScene()
local view = "player"
local view2 = "overall"
local view3 = "score"
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

    if (params.title~=true) then
        row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
        row.rowRectangle.strokeWidth = 0
        row.rowRectangle.anchorX=0
        row.rowRectangle.anchorY=0
        row.rowRectangle.x,row.rowRectangle.y=10,5
        row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
    end

    if ((view=="crew") or (view=="player")) then
        row.rowRank = display.newText( row, params.rank..".", 0, 0, native.systemFont, fontSize(70) )
        row.rowRank.anchorX=0.5
        row.rowRank.anchorY=0
        row.rowRank:translate(iconSize*0.35,row.contentHeight * 0.15)
        row.rowRank:setTextColor( 0, 0, 0 )

        row.rowPlayer = display.newText( row, params.user, 0, 0, native.systemFont, fontSize(65) )
        row.rowPlayer.anchorX = 0
        row.rowPlayer:translate(iconSize*0.7,row.contentHeight * 0.25)
        row.rowPlayer:setTextColor( 0, 0, 0 )
        if (params.crew ~= nil) then
            if (params.crew ~= "") then row.rowPlayer.text = row.rowPlayer.text.." ("..params.crew..")" end
        end

        if (params.score) then
            row.rowScore = display.newText( row, "Score: "..format_thousand(params.score), 0, 0, native.systemFont, fontSize(50) )
        else 
            row.rowScore = display.newText( row, "Reputation: "..format_thousand(params.reputation), 0, 0, native.systemFont, fontSize(50) )
        end
        row.rowScore.anchorX = 0
        row.rowScore:translate(iconSize*0.7,row.contentHeight * 0.6)
        row.rowScore:setTextColor( 0, 0, 0 )
    else
        local fsize=fontSize(60)
        if (params.title==true) then fsize=fontSize(60) end
        row.rowPlayer = display.newText( row, params.text, 0, 0, native.systemFont, fsize )
        row.rowPlayer.anchorX = 0.5
        row.rowPlayer:translate(myData.LBTableView.width/2,row.contentHeight * 0.35)
        if (params.title==true) then
            row.rowPlayer:setTextColor( 1, 1, 1 )
        else
            row.rowPlayer:setTextColor( 0, 0, 0 )
        end
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

local function statsLBnetworkListener( event )
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

        --Highest Attack 
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(90),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Attack Number"                        
            }
        }
        ) 
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.am_user1.." - "..format_thousand(t.am_count1)                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.am_user2.." - "..format_thousand(t.am_count2)                        
            }
        }
        )
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.am_user3.." - "..format_thousand(t.am_count3)                        
            }
        }
        )

--Highest Attack Won %
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Attack Won %"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.ap_user1.." - "..t.ap_count1.."%"
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.ap_user2.." - "..t.ap_count2.."%"
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(120),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.ap_user3.." - "..t.ap_count3.."%"
            }
        }
        )    
        --Highest Defense 
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Defense Number"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.dm_user1.." - "..format_thousand(t.dm_count1)                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.dm_user2.." - "..format_thousand(t.dm_count2)                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.dm_user3.." - "..format_thousand(t.dm_count3)                        
            }
        }
        )    

--Highest Defense Won
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Defense Won %"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.dp_user1.." - "..t.dp_count1.."%"
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.dp_user2.." - "..t.dp_count2.."%"
            }
        }
        ) 
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.dp_user3.." - "..t.dp_count3.."%"
            }
        }
        ) 
        --Best Attack Ever
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Best Attack Ever"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.ba_user1.." - $"..format_thousand(t.ba_count1)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.ba_user2.." - $"..format_thousand(t.ba_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.ba_user3.." - $"..format_thousand(t.ba_count3)                        
            }
        }
        )  
        --Best Upgrades 
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Upgrade Number"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.up_user1.." - "..format_thousand(t.up_count1)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.up_user2.." - "..format_thousand(t.up_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.up_user3.." - "..format_thousand(t.up_count3)                        
            }
        }
        )  
        --Highest Money Spent
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Money Spent on Upgrades"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.ms_user1.." - $"..format_thousand(t.ms_count1)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.ms_user2.." - $"..format_thousand(t.ms_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.ms_user3.." - $"..format_thousand(t.ms_count3)                        
            }
        }
        )  
        --Highest XP
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest XP"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.xp_user1.." - "..format_thousand(t.xp_count1)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.xp_user2.." - "..format_thousand(t.xp_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.xp_user3.." - "..format_thousand(t.xp_count3)                        
            }
        }
        )  

        --Best Tournament Players
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Tournament Win - Players"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.tw_user1.." - "..format_thousand(t.tw_count1)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.tw_user2.." - "..format_thousand(t.tw_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.tw_user3.." - "..format_thousand(t.tw_count3)                        
            }
        }
        )  

        --Best Tournament Crews
        rowColor = tableColor2
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(100),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=true,
                color=tableColor2,
                text="Highest Tournament Win - Crews"                        
            }
        }
        )    
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableGold,
                text=t.ctw_crew1.." - "..format_thousand(t.ctw_count1)                        
            }  -- Include custom data in the row
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableSilver,
                text=t.ctw_crew2.." - "..format_thousand(t.ctw_count2)                        
            }
        }
        )  
        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        myData.LBTableView2:insertRow(
        {
            isCategory = isCategory,
            rowHeight = fontSize(110),
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                title=false,
                color=tableBronze,
                text=t.ctw_crew3.." - "..format_thousand(t.ctw_count3)                        
            }
        }
        )
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

        --if (t.ranks[1] == nil) then
        --    local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        --end

        if (t.musername) then
            if (string.len(t.musername)>15) then myData.playerTextLB.size = fontSize(42) end
            myData.playerTextLB.text=t.musername
            myData.moneyTextLB.text=format_thousand(t.mmoney)
        end

        if (t.prank == 0) then
            myData.myRank.text = "You are not in a Crew"
        else
            if (t.mscore) then
                myData.myRank.text = "Rank: "..t.prank.."    Score: "..format_thousand(t.mscore)
            else
                myData.myRank.text = "Rank: "..t.prank.."    Reputation: "..format_thousand(t.mreputation)
            end
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
                    reputation=t.ranks[i].reputation,     
                    id=t.ranks[i].id                        
                }  -- Include custom data in the row
            })    
        end
   end
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (event.target.id == "players") then
        tapSound()
        myData.tabBar3.alpha=1
        myData.lbRect.y=myData.tabBar3.y+myData.tabBar3.height/2-fontSize(22)
        myData.myRankRect.alpha=1
        myData.myRank.alpha=1
        myData.tabBar2.alpha=1
        myData.lbRect.height=fontSize(1100)
        myData.LBTableView.alpha=1
        myData.LBTableView2.alpha=0
        myData.LBTableView.height=fontSize(1050)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        myData.LBTableView:deleteAllRows()
        myData.tabBar2:setSelected(1)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."updatetask.php", "POST", nil , params )
        network.request( host().."getLeaderboard.php", "POST", LBNetworkListener, params )
        view = "player"
    elseif (event.target.id == "crews") then
        tapSound()
        myData.tabBar3.alpha=0
        myData.lbRect.y=myData.tabBar2.y+myData.tabBar2.height/2-fontSize(22)
        myData.myRankRect.alpha=1
        myData.myRank.alpha=1
        myData.tabBar2.alpha=1
        myData.lbRect.height=fontSize(1200)
        myData.LBTableView.alpha=1
        myData.LBTableView2.alpha=0
        myData.LBTableView.height=fontSize(1150)
        myData.LBTableView.y=myData.lbRect.y+myData.lbRect.height/2-fontSize(5)
        myData.LBTableView:deleteAllRows()
        myData.tabBar2:setSelected(1)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."updatetask.php", "POST", nil , params )
        network.request( host().."getCrewLeaderboard.php", "POST", LBNetworkListener, params )
        view = "crew"
    elseif (event.target.id == "stats") then
        tapSound()
        myData.tabBar3.alpha=0
        myData.lbRect.y=myData.tabBar.y+myData.tabBar.height/2-fontSize(22)
        myData.myRankRect.alpha=0
        myData.myRank.alpha=0
        myData.tabBar2.alpha=0
        myData.lbRect.height=fontSize(1560)
        myData.LBTableView.alpha=0
        myData.LBTableView2.alpha=1
        --myData.LBTableView.height=fontSize(1445)
        myData.LBTableView2.y=myData.lbRect.y+myData.lbRect.height/2-5
        myData.LBTableView2:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getStatsLeaderboard.php", "POST", statsLBnetworkListener, params )
        view = "stats"
    end
end

local function handleTabBarEvent2( event )
    if (event.target.id == "overall") then
        myData.LBTableView:deleteAllRows()
        tapSound()
        view2="overall"
        if (view=="player") then
            if (view3=="score") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."updatetask.php", "POST", nil , params )
                network.request( host().."getLeaderboard.php", "POST", LBNetworkListener, params )
            elseif (view3=="reputation") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."getRepLeaderboard.php", "POST", LBNetworkListener, params )
            end
        elseif (view=="crew") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getCrewLeaderboard.php", "POST", LBNetworkListener, params )
        end
    elseif (event.target.id == "monthly") then
        myData.LBTableView:deleteAllRows()
        tapSound()
        view2="monthly"
        if (view=="player") then
            if (view3=="score") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."updatetask.php", "POST", nil , params )
                network.request( host().."getMonthlyLeaderboard.php", "POST", LBNetworkListener, params )
            elseif (view3=="reputation") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."getMonthlyRepLeaderboard.php", "POST", LBNetworkListener, params )
            end
        else
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getMonthlyCrewLeaderboard.php", "POST", LBNetworkListener, params )
        end
    elseif (event.target.id == "weekly") then
        myData.LBTableView:deleteAllRows()
        tapSound()
        view2="weekly"
        if (view=="player") then
            if (view3=="score") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."updatetask.php", "POST", nil , params )
                network.request( host().."getWeeklyLeaderboard.php", "POST", LBNetworkListener, params )
            elseif (view3=="reputation") then
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."getWeeklyRepLeaderboard.php", "POST", LBNetworkListener, params )
            end
        else
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getWeeklyCrewLeaderboard.php", "POST", LBNetworkListener, params )
        end
    end
end

local function handleTabBarEvent3( event )
    if (event.target.id == "score") then
        myData.LBTableView:deleteAllRows()
        tapSound()
        view3="score"
        if (view2=="overall") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getLeaderboard.php", "POST", LBNetworkListener, params )
        elseif (view2=="monthly") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getMonthlyLeaderboard.php", "POST", LBNetworkListener, params )
        elseif (view2=="weekly") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."updatetask.php", "POST", nil , params )
            network.request( host().."getWeeklyLeaderboard.php", "POST", LBNetworkListener, params )
        end
    elseif (event.target.id == "reputation") then
        myData.LBTableView:deleteAllRows()
        tapSound()
        view3="reputation"
        if (view2=="overall") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getRepLeaderboard.php", "POST", LBNetworkListener, params )
        elseif (view2=="monthly") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getMonthlyRepLeaderboard.php", "POST", LBNetworkListener, params )
        elseif (view2=="weekly") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getWeeklyRepLeaderboard.php", "POST", LBNetworkListener, params )
        end
    end
end

local goBack = function(event)
    backSound()
    composer.removeScene( "leaderboardScene" )
    composer.gotoScene("homeScene", {effect = "fade", time = 300})
end

function goBackLeaderboard(event)
    if (tutOverlay==false) then
        backSound()
        if (detailsOverlay==true) then
            detailsOverlay=false
            composer.hideOverlay( "fade",0 )
        else
            composer.removeScene( "leaderboardScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 300})
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function leaderboardScene:create(event)
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
    myData.moneyTextLB = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextLB.anchorX = 0
    myData.moneyTextLB.anchorY = 0.5
    myData.moneyTextLB:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextLB = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextLB.anchorX = 0.5
    myData.playerTextLB.anchorY = 0.5
    myData.playerTextLB:setFillColor( 0.9,0.9,0.9 )

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
        sheetContentHeight = 120
    }
    local tabBarSheet = graphics.newImageSheet( tabBarColor, options )

    local tabButtons = {
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Players",
            id = "players",
            selected = true,
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
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Stats",
            id = "stats",
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

    local tabButtons2 = {
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Overall",
            id = "overall",
            selected = true,
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent2
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Monthly",
            id = "monthly",
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent2
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Weekly",
            id = "weekly",
            size = fontSize(60),
            labelYOffset = -fontSize(20),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent2
        }
    }
 
    -- Create the widget
    myData.tabBar2 = widget.newTabBar(
        {
            sheet = tabBarSheet,
            top = myData.tabBar.y+fontSize(40),
            left = 20,
            width = display.contentWidth-40,
            height = 120,
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 160,
            buttons = tabButtons2
        }
    )

    local tabButtons3 = {
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Score",
            id = "score",
            selected = true,
            size = fontSize(55),
            labelYOffset = -fontSize(25),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent3,
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Reputation",
            id = "reputation",
            size = fontSize(55),
            labelYOffset = -fontSize(25),
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent3
        }
    }
 
    -- Create the widget
    myData.tabBar3 = widget.newTabBar(
        {
            sheet = tabBarSheet,
            top = myData.tabBar2.y+fontSize(40),
            left = 20,
            width = display.contentWidth-40,
            height = 120,
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 160,
            buttons = tabButtons3
        }
    )

    myData.lbRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1100) )
    myData.lbRect.anchorX = 0.5
    myData.lbRect.anchorY = 0
    myData.lbRect.x, myData.lbRect.y = display.contentWidth/2,myData.tabBar3.y+myData.tabBar3.height/2-fontSize(22)
    changeImgColor(myData.lbRect)

    myData.LBTableView = widget.newTableView(
        {
            left = 40,
            top = myData.lbRect.y+fontSize(20),
            height = fontSize(1050),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true,
        }
    )

    myData.LBTableView2 = widget.newTableView(
        {
            left = 40,
            top = myData.lbRect.y+fontSize(20),
            height = fontSize(1495),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true,
        }
    )
    myData.LBTableView2.alpha=0

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
    })

    --My Rank Rectangle
    myData.myRankRect = display.newImageRect( "img/leaderboard_details_rect.png",display.contentWidth-20,fontSize(280) )
    myData.myRankRect.anchorX = 0.5
    myData.myRankRect.anchorY = 0
    myData.myRankRect.x, myData.myRankRect.y = display.contentWidth/2,myData.lbRect.y+myData.lbRect.height-10
    changeImgColor(myData.myRankRect)

    --My Rank
    myData.myRank = display.newText("",display.contentWidth/2,myData.myRankRect.y+fontSize(100) ,native.systemFont, fontSize(64))
    myData.myRank.anchorX = 0.5
    myData.myRank.anchorY = 0
    myData.myRank:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextLB)
    group:insert(myData.playerTextLB)
    group:insert(myData.lbRect)
    group:insert(myData.backButton)
    group:insert(myData.LBTableView)
    group:insert(myData.LBTableView2)
    group:insert(myData.myRankRect)
    group:insert(myData.myRank)
    group:insert(myData.tabBar)
    group:insert(myData.tabBar2)
    group:insert(myData.tabBar3)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function leaderboardScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "leaderboardTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutLeaderboard ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "leaderboardTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."updatetask.php", "POST", nil , params )
        network.request( host().."getLeaderboard.php", "POST", LBNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
leaderboardScene:addEventListener( "create", leaderboardScene )
leaderboardScene:addEventListener( "show", leaderboardScene )
---------------------------------------------------------------------------------

return leaderboardScene