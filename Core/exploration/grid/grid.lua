
--stateDrawing=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_cyclic+sim_drawing_itemcolors,0,0.0,-1,0,{0,0,0},nil,nil,nil)
unk,fre,ani,occ=1,2,3,4
c_unk,c_fre,c_ani,c_occ='?',' ','!','X'
sets = {}

--------------------
--INITIALIZE GRIDS--
--------------------

--real grid by scanning the world
realityGrid=function()
  unknownS,freeS,animatedS,occupiedS,realGrid={},{},{},{},{}
  sets[1]={[unk]=unknownS,[fre]=freeS,[ani]=animatedS,[occ]=occupiedS} 
  for i=1,(maxX-minX)/coef do
    realGrid[i]={} 
    for j=1,(maxY-minY)/coef do
        realGrid[i][j]=fre
    end
  end
  scanWorld()
  updateSetsRealGrid()
end

--exploration grid all unknown
explorationGrid=function()
  unknownSE,freeSE,animatedSE,occupiedSE,exploGrid={},{},{},{},{}
  sets[2]={[unk]=unknownSE,[fre]=freeSE,[ani]=animatedSE,[occ]=occupiedSE} 
  for i=1,(maxX-minX)/coef do
    exploGrid[i]={}
    for j=1,(maxY-minY)/coef do
      exploGrid[i][j]=unk
    end
  end
  updateSetsExpGrid()
end

--ground truth all unknown
explorationGridGT=function()
  exploGridGT, unknownSEGT, freeSEGT, occupiedSEGT, animatedSEGT = {},{},{},{},{}
  sets[3] = {[unk]=unknownSEGT,[fre]=freeSEGT,[ani]=animatedSEGT,[occ]=occupiedSEGT} 
  for i=1,(maxX-minX)/coef do
    exploGridGT[i] = {}
    for j=1,(maxY-minY)/coef do
      exploGridGT[i][j] = unk
    end
  end
  updateSetsExpGridGT()
end

----------------
--UPDATE GRIDS--
----------------

--exploration grid stric update
updateExplorationGrid=function(agent)
  if exploGrid then
    --local cellsToUpdate =viewDist(agent,radiusView)--/coef)
    --local cellsToUpdate =viewMasked(agent,radiusView)--/coef)
    local cellsToUpdate =bresenhamView3(agent,radiusView)
    local myPos = getPoseIJ(agent)
  	exploGrid[myPos[1]][myPos[2]] = fre
  	local cntHumans = 0
  	for i=1,#cellsToUpdate-1 do
  		if cellsToUpdate[i] ~= -1 then
  			local a, b = cellsToUpdate[i][1], cellsToUpdate[i][2]
  			exploGrid[a][b]=realGrid[a][b]
  			if realGrid[a][b] == ani then
  				cntHumans = cntHumans + 1
  			end
  		end
  	end
  	updateSetsExpGrid()
  	if proximityUpdate ~= nil then
    	proximityUpdate(cntHumans) --chain to updateGT
    end
  end
end

--ground truth stric update
updateExplorationGridGT=function()
  for i=1,(maxX-minX)/coef do
    for j=1,(maxY-minY)/coef do
      exploGridGT[i][j]=realGrid[i][j]
    end
  end
  updateSetsExpGridGT()
end

updateSetsRealGrid=function()
  updateSetsExpG(1, realGrid)
end

updateSetsExpGrid=function()
  updateSetsExpG(2, exploGrid)
end

updateSetsExpGridGT=function()
  updateSetsExpG(3,exploGridGT)
end

updateSetsExpG=function(index, expG)
  for i=1,(maxX-minX)/coef do
    for j=1,(maxY-minY)/coef do
      local key=i..'#'..j
      sets[index][unk][key] = expG[i][j] == unk
      sets[index][fre][key] = expG[i][j] == fre
      sets[index][occ][key] = expG[i][j] == occ
      sets[index][ani][key] = expG[i][j] == ani
    end
  end
end

--------------
--SCAN WORLD--
--------------

--update real grid sets
scanWorld=function() --update occupied set, animated set and free set
	--set occupied and animated cells
	local humans_items_explorers = {}
	for k,v in pairs(humans) do
	 table.insert(humans_items_explorers,v)
	end
	for k,v in pairs(items) do
	 table.insert(humans_items_explorers,v)
	end
	--explorers
	for k,v in pairs(explorers) do
   table.insert(humans_items_explorers,v)
  end
  
	for k,obj in pairs(humans_items_explorers) do
		--bounding box corners coordinates into the object reference frame
		local r, bbMinX = simGetObjectFloatParameter(obj,15)
		local r, bbMaxX = simGetObjectFloatParameter(obj,18)		
		local r, bbMinY = simGetObjectFloatParameter(obj,16)
		local r, bbMaxY = simGetObjectFloatParameter(obj,19)
		local r, bbMinZ = simGetObjectFloatParameter(obj,17)
		local r, bbMaxZ = simGetObjectFloatParameter(obj,20)		
		local vMin = {bbMinX, bbMinY, bbMinZ}
		local vMax = {bbMaxX, bbMaxY, bbMaxZ}
    local width = bbMaxX-bbMinX
    local length = bbMaxY-bbMinY
    local height = bbMaxZ-bbMinZ
    
		--change the corners coordinates to the world coordinates frame
		--world frame to object frame
		--world vector coordinates = w2o * object vector coordinates
		local w2o = simGetObjectMatrix(obj,-1)
		local o2w = simGetInvertedMatrix(w2o)
		local pos = simGetObjectPosition(obj, -1)
		vMin = simMultiplyVector(w2o,vMin)
		vMax = simMultiplyVector(w2o,vMax)
		bbMinX = vMin[1]
		bbMinY = vMin[2]
		bbMinZ = vMin[3]
		bbMaxX = vMax[1]
		bbMaxY = vMax[2]
		bbMaxZ = vMax[3]

		--important change min and max
		if bbMinX > bbMaxX then
			local tmp = bbMinX
			bbMinX = bbMaxX
			bbMaxX = tmp
		end
		if bbMinY > bbMaxY then
			local tmp = bbMinY
			bbMinY = bbMaxY
			bbMaxY = tmp
		end

		--change the corner coordinates to the grid frame
		local bbMinI2, bbMinJ2 = mappingWorld2Grid(bbMinX, bbMinY)
		local bbMaxI2, bbMaxJ2 = mappingWorld2Grid(bbMaxX, bbMaxY)
		
		--condamn the cells inside the bounding box
		for a = bbMinI2, bbMaxI2 do
			for b = bbMinJ2, bbMaxJ2 do
				if string.find(simGetObjectName(obj), 'Bill#*%d*$')~=nil or string.find(simGetObjectName(obj), 'Explorer#*%d*$')~=nil then
					realGrid[a][b] = ani
				else
				  realGrid[a][b] = occ
				end
			end
		end
	end
	updateSetsRealGrid()
end

--------------
--CONVERSION--
--------------

--from string grid min-max to int grid 1-size
expGridToInt=function(exploGrid)
  local exploCopyInt = {}
  for i=1,(maxX-minX)/coef do
    exploCopyInt[i] = {}
    for j=1,(maxY-minY)/coef do
      exploCopyInt[i][j] = exploGrid[i][j]
      local res = unk
      if exploGrid[i][j] == c_unk then
        res = unk
      end
      if exploGrid[i][j] == c_fre then
        res = fre
      end
      if exploGrid[i][j] == c_ani then
        res = ani
      end
      if exploGrid[i][j] == c_occ then
        res = occ
      end
      --exploCopyString[i][j] = res
    end
  end
  return exploCopyInt
end

--from integer grid 1-size to string grid min-max
expGridToString=function(exploGrid)
  --print('GTString')
  local exploCopyString = {}
  for i= 1, (maxX-minX)/coef do
    exploCopyString[i] = {}
    for j= 1, (maxY - minY)/coef do
      exploCopyString[i][j] = exploGrid[i][j]
      local res = c_unk
      if exploGrid[i][j] == unk then
        res = c_unk
      end
      if exploGrid[i][j] == fre then
        res = c_fre
      end
      if exploGrid[i][j] == ani then
        res = c_ani
      end
      if exploGrid[i][j] == occ then
        res = c_occ
      end
      --exploCopyString[i][j] = res
    end
  end
  return exploCopyString
end

-----------
--DRAWING--
-----------

drawExploMap=function(exploGrid)  
	--simRemoveDrawingObject(stateDrawing)
	if stateDrawing == nil then	
	   stateDrawing=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_cyclic+sim_drawing_itemcolors+sim_drawing_itemtransparency+sim_drawing_backfaceculling,coef/2,0.0,-1,(maxX-minX)*(maxY-minY)*(1/(coef*coef)),{0,0,0},nil,nil,nil)
	end
	local transparency = 1 - 1/(#explorers+2)	
	local z = 0.0001
	--drawing exploration grid
	for i=1,(maxX-minX)/coef do
		for j=1,(maxY-minY)/coef do
			local c, d = mappingGrid2World(i,j)
			local f2 = {c,d}
			if exploGrid[i][j] == c_unk or exploGrid[i][j] == unk then
				simAddDrawingObjectItem(stateDrawing,{f2[1];f2[2];z;0;0;1;1;0;0;transparency})
			end
			if exploGrid[i][j] == c_fre or exploGrid[i][j] == fre then
				simAddDrawingObjectItem(stateDrawing,{f2[1];f2[2];z;0;0;1;0;1;0;transparency})
			end
			if exploGrid[i][j] == c_occ or exploGrid[i][j] == occ then
				simAddDrawingObjectItem(stateDrawing,{f2[1];f2[2];z;0;0;1;0;0;1;transparency})
			end
			if exploGrid[i][j] == c_ani or exploGrid[i][j] == ani then
				simAddDrawingObjectItem(stateDrawing,{f2[1];f2[2];z;0;0;1;0;1;1;transparency})
			end
		end
	end
end

printExploMap=function(exploGrid)
	print('\n Explo Grid')
	for j= 1, (maxY-minY)/coef do
		if j>=0 then
			str = ' '..j..': '
		else
			str = j..': '
		end
		strFin = '         '
		for i= (maxX-minX)/coef,1,-1  do
		  local c = exploGrid[i][j]
		  if exploGrid[i][j] == unk then
		    c = c_unk
		  end
		  if exploGrid[i][j] == fre then
        c = c_fre
      end
      if exploGrid[i][j] == ani then
        c = c_ani
      end
       if exploGrid[i][j] == occ then
        c = c_occ
      end
			if i>0 then
				strFin = strFin..i..':    '
			else
				strFin = strFin..i..':   '
			end
				str=str..'  |  '..c
		end
		print(str..'\n')
	end
	print(strFin)
end