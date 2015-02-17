--robot perception on real grid
viewDist=function(agent,radiusMax)
  local posX = getPoseXY(agent)
  local posI = getPoseIJ(agent)
  local list={{posI,0}}
  local first,last=1,1
  local marked,seen = {},{}
  
  while(first<=last) do
    local cell,radius = list[first][1], list[first][2]
    local a,b = cell[1],cell[2]
    local key=a..'#'..b
    if marked[key] == nil and radius<=radiusMax then
      local neighbors = neighborsFunction(a,b)
      for i,n in ipairs(neighbors) do
        if n ~= -1 then
          local nX = getPoseXY(n)
          local a,b= n[1],n[2]
          local key=a..'#'..b
          if marked[key] == nil then
            list[#list+1] = {n,distanceFunction(posX,nX)}
            last=last+1
          end
        end
      end
    end
    seen[#seen+1] = cell
    marked[key]=true
    first=first+1
  end
  return seen
end

chamferMask2D3x3=function()
 --N E S W NE SE SW NW
 local mask2D3x3 = {1*coef, 1*coef, 1*coef, 1*coef, math.sqrt(2)*coef, math.sqrt(2)*coef, math.sqrt(2)*coef, math.sqrt(2)*coef}
 return mask2D3x3
end

applyChamferMask2D3x3=function(cell, value)
  local valN = neighborsMoore(cell[1],cell[2])
  local mask = chamferMask2D3x3()
  local applied = {}
  for i,n in ipairs(valN) do
    if n~=-1 then
      applied[#applied+1] = {n,value+mask[i]}
    end
  end
  return applied
end

bresenhamView=function(cell,radiusMax) --first ver cannot see the boundaries
  --los(2,2,6,6, function(x,y)
  --  if map[x][y] == '#' then return false end
  --  map[x][y] = 'A'
  --  return true
  --end)
  occupiedCells()
  local cInFov, cBres = viewDist(cell,radiusMax), {}
  local p = getPoseIJ(cell)

  for i,v in ipairs(cInFov) do
    if v ~= -1 then
     if los(p[1],p[2],v[1],v[2], function(i,j)
        return not occupied(i,j)
        end
      ) then
        cBres[#cBres+1] = v
      end
    end
  end
  return cBres
end

bresenhamView2=function(cell,radiusMax) --first ver cannot see the boundaries
  local mark = {}
  occupiedCells()
  local cInFov, cBres = viewDist(cell,radiusMax), {}
  local p = getPoseIJ(cell)

  for i,v in ipairs(cInFov) do
    if v ~= -1 then
      local a,b = v[1], v[2]
      local key = a..'#'..b
      if mark[key] == nil then
        local lin = line(p[1],p[2],v[1],v[2], function(i,j) return true end)
        local firstOccupied = true
        for i,v in pairs(lin) do
          local a,b = v[1], v[2]
          local key = a..'#'..b
          
          if not occupied(a,b) and firstOccupied then
            cBres[#cBres+1] = v
            mark[key] = true
          end
          if occupied (a,b) and firstOccupied then
            firstOccupied = false
            cBres[#cBres+1] = v
            mark[key] = true
          end
        end
      end
    end
  end
  return cBres
end

bresenhamView3=function(cell,radiusMax) --first ver cannot see the boundaries --less redundancy
  local mark = {}
  occupiedCells()
  local cInFov, cBres = viewDist(cell,radiusMax), {}
  local p = getPoseIJ(cell)

  for i,v in ipairs(cInFov) do
    if v ~= -1 then
      local a,b = v[1], v[2]
      local key = a..'#'..b
      if mark[key] == nil then
        local lin = line(p[1],p[2],v[1],v[2], function(i,j) return true end)
        local firstOccupied = true
        for i,v in pairs(lin) do
          local a,b = v[1], v[2]
          local key = a..'#'..b
          if firstOccupied then --mark and add visible cells until first obstacle
            if occupied (a,b) then
              firstOccupied = false
            end
            if mark[key] == nil then
              cBres[#cBres+1] = v
              mark[key] = true
            end
          else --mark other cells on the line
            mark[key] = true
          end
        end
      end
    end
  end
  return cBres
end

radiusMaskChamfer=function(cell,radiusMax)
  local posI = getPoseIJ(cell)
  local list={{posI,0}}
  local first,last=1,1
  local marked,seenVal = {},{}
  local cells = {}
  while(first<=last) do
    local cell,radius = list[first][1], list[first][2]
    local a,b = cell[1],cell[2]
    local key=a..'#'..b
    if marked[key] == nil and radius<=radiusMax then
      local neighbors = applyChamferMask2D3x3(cell,radius)
      for i,n in ipairs(neighbors) do
          list[#list+1] = n
          last=last+1            
      end
    end
    --cells[key] = {cell,radius}
    cells[#cells+1] = cell
    seenVal[#seenVal+1] = {cell,radius}
    marked[key]=true
    first=first+1
  end
  return cells
end

shadowMaskChamfer=function(cell,radiusMax)
 occupiedCells()
 --list by list
 local obstacle, free = 1, 0
 local coord = getPoseIJ(cell)
 local key = coord[1]..'#'..coord[2]
 local state,val = free,0
 local lists={}
 local mark={}
 lists[1] = {}
 lists[1][key] = {coord,val,state} --l0 init
 
 for i,listI in ipairs(lists) do
  for k,cvs in pairs(listI) do   
    local coord, value, state = cvs[1],cvs[2],cvs[3]
    if occupied(coord[1],coord[2]) then
      state = obstacle
    end
    local key = coord[1]..'#'..coord[2]
    mark[key]=true
    local neighbors = applyChamferMask2D3x3(cvs[1],cvs[2])
    for l,cv in ipairs(neighbors) do
      local coord, value = cv[1],cv[2]
      if value <= radiusMax then
        if lists[i+1] == nil then
          lists[i+1] = {}
        end
        local key = coord[1]..'#'..coord[2]
        if lists[i+1][key] == nil then
          if mark[key] == nil then
            lists[i+1][key] = {coord,value,state}
          end
        else
          local cvs=lists[i+1][key]
          lists[i+1][key] = {cvs[1],cvs[2],math.max(cvs[3],state)}
        end
      end
    end
  end
 end
 
 local seen = {}
 for i,listI in ipairs(lists) do
  for k,cvs in pairs(listI) do   
    if cvs[3] == free then
      seen[#seen+1]=cvs[1]
    end
  end
 end
 return seen
end

viewMasked=function(cell,radius)
  --local radiusMask=radiusMaskChamfer(cell,radius)
  local shadowMask=shadowMaskChamfer(cell,radius)
  return shadowMask
end

andCells=function(cellsSet1,cellsSet2)
  local andCells={}
  for k,v in pairs(cellsSet1) do
    local v2=cellsSet2[k]
    if v2 ~= nil then
      if v[2]~=v2[2] then
        andCells[#andCells+1] = v[1]
      end
    end
  end
  return andCells
  
end