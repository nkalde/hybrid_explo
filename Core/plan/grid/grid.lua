-------------
--INIT GRID--
-------------

--sets all cells to infinity gradient propagation
gridOfCells=function()
  --delete last grid
  if #gradientGrid ~= 0 then
    for i=1,(maxX-minX)/coef do
      for j=1,(maxY-minY)/coef do
        gradientGrid[i][j] = nil
      end
      gradientGrid[i] = nil
    end
    gradientGrid = nil
  end
  --create new grid 2
  gradientGrid = {}
  for i=1,(maxX-minX)/coef do
    gradientGrid[i] = {}
    for j=1,(maxY-minY)/coef do 
      gradientGrid[i][j] = math.huge
    end
  end
end

---------------
--UPDATE GRID--
---------------

updateOccupiedSet=function(objects)
  local cnt=0
  for k,obj in pairs(objects) do
      --bounding box corners coordinates into the object reference frame
      local r, bbMinX = simGetObjectFloatParameter(obj,15)
      local r, bbMaxX = simGetObjectFloatParameter(obj,18)    
      local r, bbMinY = simGetObjectFloatParameter(obj,16)
      local r, bbMaxY = simGetObjectFloatParameter(obj,19)
      local r, bbMinZ = simGetObjectFloatParameter(obj,17)
      local r, bbMaxZ = simGetObjectFloatParameter(obj,20)    
      local vMin = {bbMinX, bbMinY, bbMinZ}
      local vMax = {bbMaxX, bbMaxY, bbMaxZ}
  
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
          occupiedSet[a..'#'..b] = true
          cnt = cnt+1
        end
      end
    end
    return cnt
end

--dilate
dilate = 0.2
dilateHuman=function(object)
  local posX = getPoseXY(object)
  local posI = getPoseIJ(object)
  local list={{posI,0}}
  local first,last=1,1
  local marked,dilation = {},{}
  while(first<=last) do
    local cell,radius = list[first][1], list[first][2]
    local a,b = cell[1],cell[2]
    local key=a..'#'..b
    if marked[key] == nil and radius <= dilate then
      local neighbors = neighborsFunction(a,b)
      for i,n in ipairs(neighbors) do
        if n ~= -1 then
          local nX = getPoseXY(n)
          local a,b= n[1],n[2]
          local key=a..'#'..b
          if marked[key] == nil then
            list[#list+1] = {n,distanceEuclid(posX,nX)}
            last=last+1
          end
        end
      end
    end
    dilation[#dilation+1] = cell
    marked[key]=true
    first=first+1
  end
  return dilation
end

--dilate human cells
dilateDynamicSet=function(objects)
  hinderedSet = {}
  for k, obj in pairs(objects) do
    print(simGetObjectName(obj))
    local dilateSet = dilateHuman(obj)
    for i, cell in ipairs(dilateSet) do
      local a, b = cell[1], cell[2]
      hinderedSet[a..'#'..b] = true
    end
  end
end

--set occupied set to all items, humans (in) and explorers (in)
occupiedCells=function()
  occupiedSet = {}
  --update occupiedSet with static items
  local cntS = scanStaticCells()
  --update occupiedSet with dynamic items in visibility
  local cntD = 0
  if string.find(simGetObjectName(agent), 'Explorer#*%d*$')~=nil then --in robot visibility
    cntD = scanDynamicCells(agent)
  else
    cntD = scanDynamicCells(nil)
  end
  return occupiedSet, cntS+cntD
end

scanStaticCells=function()
  local static_items= {}
  --add items
  for k,v in pairs(items) do
   table.insert(static_items,v)
  end
  local cnt = updateOccupiedSet(static_items)
  return cnt
end

scanDynamicCells=function(agent) --during navigation dynamic items
  --add dynamic content
  local dynamic_items = {}
  local human_items = {}
  if pos~=nil then --in robot visibility
    --explorers
    if explorersInNeighborhood ~= nil then
      local expIN = explorersInNeighborhood(agent)
      for k,v in pairs(expIN) do
        if v ~= agent then
          table.insert(dynamic_items,v)
        end
      end
    end
    --humans
    if humansInNeighborhood ~= nil then
      local humIN = humansInNeighborhood(agent)
      for k,v in pairs(humIN) do
        table.insert(dynamic_items,v)
        table.insert(human_items,v)
      end
    end
  else --in all map
    for k,v in pairs(explorers) do
      if v ~= agent then
        table.insert(dynamic_items,v)
      end
    end
    for k,v in pairs(humans) do
      table.insert(dynamic_items,v)
      table.insert(human_items,v)
    end
  end
  
  dilateDynamicSet(human_items)
  local cnt = updateOccupiedSet(dynamic_items)
  return cnt
end

--------------
--CHECK CELL--
--------------

--check if cell i,j is inside the grid
insideGrid=function(i,j)
  return i<=(maxX-minX)/coef and i>=1 and j<=(maxY-minY)/coef and j>=1
  --i<maxX and i>=minX and j<maxY and j>=minY
end

--check if the cell is occupied bounding box condamned
occupied=function(i,j)
  return occupiedSet[i..'#'..j] ~= nil
end

hindered=function(i,j)
  return hinderedSet[i..'#'..j] ~= nil
end
