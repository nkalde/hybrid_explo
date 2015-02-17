------------------------
--FRONTIERS EXTRACTION--
------------------------

--extract frontiers from exploration grid
extractFrontiers=function(exploGrid)
	local frontiersS2 = {}
	local frontiers2 = {}
	for j=1, (maxY-minY)/coef do
		for i=1, (maxX-minX)/coef do
			frontiersS2[i..'#'..j] = false
			local neighbors = neighborsFunction(i,j)
			local k=1
			if exploGrid[i][j] == ani or exploGrid[i][j] == fre then --i j (animated or free)
  			while not frontiersS2[i..'#'..j] and k <= #neighbors do
  				if neighbors[k] ~= -1 then
  					local a,b = neighbors[k][1], neighbors[k][2]
  					if (exploGrid[a][b] == unk) then --adjacent to a b (unknown)
  						frontiersS2[i..'#'..j] = true
  						frontiers2[#frontiers2+1] = {i,j}
  					end
  				end
  				k=k+1
  			end
      end
		end
	end
	return frontiers2
end

--clear frontiers of percepted robots and humans
removeRobotsHumans=function(frontiers, robots, humans)
  local frontiersMinH = frontiersMinusA(frontiers, humans)
  local frontiersMinHR = frontiersMinusA(frontiersMinH, robots)
  return frontiersMinHR
end

----------------------
--FRONTIERS GROUPING--
----------------------

--find target and components
regroupFrontiers=function(frontiers, robots, humans)
  --1 frontiers extraction
  
  --2 remove robots humans
  --local frontiers = removeRobotsHumans(frontiers, robots, humans)

  --3 extract components
  local intraDF = intraDistancesN(frontiers)  
  local lists, listsFrontiers = findComponents(frontiers, intraDF)
  
  --4 extract target
  local listTarget = minSelectionF(lists, frontiers, intraDF)
  
  return listTarget, listsFrontiers
end

--find frontiers components and chose target
findComponents=function(frontiers, intraDF)
  local set, lists, listsF = {}, {}, {}
  for i=1,#frontiers do
    if set[i] == nil then
      local index = #lists+1
      set[i] = index
      lists[index] = {}
      listsF[index] = {}
      local l = lists[index]
      local lF = listsF[index]
      table.insert(l,#l+1,i)
      table.insert(lF,#lF+1,frontiers[i])
      set, l, lF = findSameFrontier(i,set,l,intraDF,frontiers,lF)       
      lists[#lists] = l
      listsF[#listsF] = lF
    end
  end
  return lists, listsF
end

findSameFrontier=function(i,set,list,intraDF,frontiers,listF)
  local first, last = 1, 1
  while(first <= last) do
    local a = list[first]
    for b=1,#frontiers do
      if intraDF[a][b] == 0 then
        if set[b] == nil then
          list[#list+1] = b
          listF[#listF+1] = frontiers[b]
          last = last + 1
          set[b] = set[a]
        end
      end
    end
    first =  first + 1
  end
  return set, list, listF
end

frontiersMinusA =function(frontiers, AinN)
  local frontiersN = {}
  for i=1,#frontiers do
    local found = false
    local f = frontiers[i]
    local j = 1
    while j<=#AinN and not found do
      local h = AinN[j]
      local p = getPoseIJ(h)
      found = p[1] == f[1] and p[2] == f[2]
      j = j+1
    end
    if not found then
      table.insert(frontiersN,#frontiersN+1,f)
    end
  end
  return frontiersN
end

--------------------
--TARGET SELECTION--
--------------------

--first in list
firstSelectionF=function(lists, frontiers)
  local listsT = {} --easy selection first of each class -> better way to do it
  for i=1,#lists do
     listsT[i] = frontiers[lists[i][1]]
  end
  return listsT
end

--random in list
randomSelectionF=function(lists, frontiers)
  local listsT = {} --easy selection first of each class -> better way to do it
  for i=1,#lists do
     listsT[i] = frontiers[lists[i][math.random(#lists[i])]]
  end
  return listsT
end

--min in list
minSelectionF=function(lists,frontiers,intraDF)
  local listsT = {}
  for l,list in ipairs(lists) do
    local min = math.huge
    local f=-1
    --compute sum to other frontiers
    for i,a in ipairs(list) do
      local sumA = 0
      for j,b in ipairs(list) do
        sumA = sumA + intraDF[a][b]
      end
      if sumA < min then
        min = sumA
        f = a
      end
    end
    listsT[l] = frontiers[f]    
  end
  return listsT
end

-----------
--DRAWING--
-----------

drawFrontiers=function(frontiersT)
  local transparency = 1 - 1/(#explorers+2) 
  if frontiersDrawing == nil then
    frontiersDrawing=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors+sim_drawing_cyclic+sim_drawing_itemtransparency,coef/2,0.0,-1,#frontiersT,{0,0,0},nil,nil,nil)
  else
  	simRemoveDrawingObject(frontiersDrawing)
    frontiersDrawing=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors+sim_drawing_cyclic+sim_drawing_itemtransparency,coef/2,0.0,-1,#frontiersT,{0,0,0},nil,nil,nil)
  end
  local zW = 0.0001
	for i,v in ipairs(frontiersT) do
		local xW, yW = mappingGrid2World(v[1], v[2])
		simAddDrawingObjectItem(frontiersDrawing,{xW;yW;zW;0;0;1;1;1;1;transparency})
	end
end

drawFrontiersG=function(frontiersT,robots,humans)
  local a, facFrontiers = regroupFrontiers(frontiersT,robots,humans)
  local zW = 0.0001
  local transparency = 0
  if drawingFrontiers == nil then
    drawingFrontiers = simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors+sim_drawing_itemtransparency,coef/2,0.0,-1,#frontiersT,nil,nil,nil,nil)
  else
    simRemoveDrawingObject(drawingFrontiers)
    drawingFrontiers = simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors+sim_drawing_itemtransparency,coef/2,0.0,-1,#frontiersT,nil,nil,nil,nil)
  end
  
  for i,v in ipairs(facFrontiers) do
    local r,g,b = math.random(),0--[[math.random()--]],math.random()
    for i2,v2 in ipairs(v) do
      local xW, yW = mappingGrid2World(v2[1], v2[2])
      simAddDrawingObjectItem(drawingFrontiers,{xW;yW;zW;0;0;1;r;g;b;transparency})
    end
  end
end

drawFrontiersRepresent=function(frontiersT)
  local a = regroupFrontiers(frontiersT)
  local zW = 0.0001
  if drawingFrontiers == nil then
    drawingFrontiers = simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors,coef/2,0.0,-1,#a,nil,nil,nil,nil)
  else
    simRemoveDrawingObject(drawingFrontiers)
    drawingFrontiers = simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemcolors,coef/2,0.0,-1,#a,nil,nil,nil,nil)
  end
  
  for i,v in ipairs(a) do
    local r,g,b = math.random(),math.random(),math.random()
    local xW, yW = mappingGrid2World(v[1], v[2])
    simAddDrawingObjectItem(drawingFrontiers,{xW;yW;zW;0;0;1;r;g;b})
  end
end

--frontier normal vector orientation from known to unknown space
getFrontiersOrientation=function(cellsL,targets,robot)--robot in known space
  local linesN = #cellsL
  if drawOrientations == nil then
    drawOrientations=simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic+sim_drawing_itemcolors,5,0.0,-1,linesN,{0,0,0},nil,nil,nil)
  else
    simRemoveDrawingObject(drawOrientations)
    drawOrientations=simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic+sim_drawing_itemcolors,5,0.0,-1,linesN,{0,0,0},nil,nil,nil)
  end
  for i,target in ipairs(targets) do
    --getFrontierOrientation(cells,robot)
    local angle, rV = sGetFrontierOrientation(target)
    print('c ('..target[1],target[2]..')->'..angle)
    --drawing
    local xy = getPoseXY(target)
    local sx,gx = xy[1], xy[1]+rV[1]
    local sy,gy = xy[2], xy[2]+rV[2]
    simAddDrawingObjectItem(drawOrientations,{sx;sy;2;gx;gy;2;0;0;0})
  end
end

sGetFrontierOrientationSigned=function(cell)
  --select unknown neighbors
  local xy = getPoseXY(cell)
  local xyN = {}
  --print(cell[1],cell[2])
  local neighbors = neighborsFunction(cell)
  for i,n in ipairs(neighbors) do
    if n~= -1 then
      local a,b = n[1],n[2]
      if exploGrid[a][b] == unk then
        xyN[#xyN+1] = getPoseXY(n)
      end
    end
  end
  --compute resultant vector
  local rV = {0,0}
  for i,v in ipairs(xyN) do
    local vect = {v[1]-xy[1],v[2]-xy[2]}
    rV = {rV[1]+vect[1],rV[2]+vect[2]}
  end
    
  --compute vector angle
  --angle from normal Vector to World Frame
  --local angle = angleBetweenV({1,0},rV)
  local angle = signedAngleBetweenV({1,0},rV)
  
  return angle, rV
end

--[[
--frontier normal vector orientation from known to unknown space
getFrontierOrientationOldComplicated=function(cells,robot)--robot in known space

  --from IJ to XY frontiers points
  for i,c in ipairs(cells) do
    cells[i] = getPoseXY(c)
  end
  
  --print(simGetObjectName(robot))
  --from IJ to XY robot
  robot = getPoseXY(robot)
  --print(robot[1],robot[2])
  --linear regression
  local a,b,meanX,meanY = linearRegression(cells)
  
   --drawing
  local sx,gx = meanX-#cells/20, meanX+#cells/20
  local sy,gy = a+b*sx, a+b*gx
  simAddDrawingObjectItem(linearRegressionDrawing,{sx;sy;2;gx;gy;2;0;0;0})
  
  --normal vectors
  local nV1, nV2 = normalVectors(a,b)
  
  --drawing normal vectors
  sx,sy = meanX, meanY
  gx,gy = sx+nV1[1], sy+nV1[2]
  simAddDrawingObjectItem(linearRegressionDrawing,{sx;sy;2;gx;gy;2;0;0;1})
    
  gx,gy =sx+nV2[1], sy+nV2[2]
  simAddDrawingObjectItem(linearRegressionDrawing,{sx;sy;2;gx;gy;2;0;0;1})
    
  --normal vector towards unknown
  
  --vector from frontier to robot
  local fR = {robot[1]-meanX,robot[2]-meanY}
  local sp1, sp2 = dotProduct(nV1,fR),dotProduct(nV2,fR)
  local nV = nV1
  if sp1 > 0 then
    nV = nV2
  end
  
  gx,gy = sx+nV[1], sy+nV[2]
  simAddDrawingObjectItem(linearRegressionDrawing,{sx;sy;2;gx;gy;2;1;0;0})
 
  --angle from normal Vector to World Frame
  local angle = angleBetweenV({1,0},nV)
  return angle
end
--]]
