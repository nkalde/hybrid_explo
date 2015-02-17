-------------
--NEIGHBORS--
-------------
neighborsMoore=function(i,j)
  if type(i) == 'table' then
    j=i[2]
    i=i[1]
  end
  local nE2 = -1
  local nW2 = -1
  local nN2 = -1
  local nS2 = -1
  local nNE2 = -1
  local nSE2 = -1
  local nSW2 = -1
  local nNW2 = -1
  local bsupX = (maxX-minX)/coef 
  local bsupY = (maxY-minY)/coef
  if i==nil or j ==nil then
   --print(simGetObjectName(agent))
   --print(i,j)
  end
  if i>=1 and i<=bsupX and j>=1 and j<=bsupY then 
    if i+1 > 1 and i+1 <= bsupX then    
      nE2 = {i+1,j}
    end
    if i-1 >= 1 and i-1 < bsupX then
      nW2 = {i-1,j}
    end
    if j+1 > 1 and j+1 <= bsupY then
      nN2 = {i,j+1}
    end
    if j-1 >= 1 and j-1 < bsupY then
      nS2 = {i,j-1}
    end
    --
    if (i+1 > 1) and (i+1 <= bsupX) and (j+1 > 1) and (j+1 <= bsupY) then
      nNE2 = {i+1,j+1}
    end
    if (i+1 > 1) and (i+1 <= bsupX) and (j-1 >= 1) and (j-1 < bsupY) then
      nSE2 = {i+1,j-1}
    end
    if (i-1 >= 1) and (i-1 < bsupX) and (j-1 >= 1) and (j-1 < bsupY) then
      nSW2 = {i-1,j-1}
    end
    if (i-1 >= 1) and (i-1 < bsupX) and (j+1 > 1) and (j+1 <= bsupY) then
      nNW2 = {i-1,j+1}
    end
  end 
  --local ret2 = {nN2, nNE2, nE2, nSE2, nS2, nSW2, nW2, nNW2}
  local ret2 = {nN2, nE2, nS2, nW2, nNE2, nSE2, nSW2, nNW2}
  local ret3 = {{i,j+1},{i+1,j},{i,j-1},{i-1,j},{i+1,j+1},{i+1,j-1},{i-1,j-1},{i-1,j+1}}
  local ret4 = {{0,1},{1,0},{0,-1},{-1,0},{1,1},{1,-1},{-1,-1},{-1,1}}
  
  return ret2, ret3, ret4
end

neighborsVonNeumann=function(i,j)
  if type(i) == 'table' then
    j=i[2]
    i=i[1]
  end
  local nE2 = -1
  local nW2 = -1
  local nN2 = -1
  local nS2 = -1
  local bsupX = (maxX-minX)/coef 
  local bsupY = (maxY-minY)/coef
  if i>=1 and i<=bsupX and j>=1 and j<=bsupY then 
    if i+1 > 1 and i+1 <= bsupX then    
      nE2 = {i+1,j}
    end
    if i-1 >= 1 and i-1 < bsupX then
      nW2 = {i-1,j}
    end
    if j+1 > 1 and j+1 <= bsupY then
      nN2 = {i,j+1}
    end
    if j-1 >= 1 and j-1 < bsupY then
      nS2 = {i,j-1}
    end
  end 
  local ret2 = {nN2, nE2, nS2, nW2}
  local ret3 = {{i,j+1},{i+1,j},{i,j-1},{i-1,j}}
  local ret4 = {{0,1},{1,0},{0,-1},{-1,0}}
  return ret2, ret3, ret4
end

printNeighbors=function(i,j, neighborsF)
  local ret = neighborsF(i,j)
  local str = '['
  for i=1,#ret,1 do
    if (ret[i] ~= -1) then
      str=str..' ('..ret[i][1]..','..ret[i][2]..') '
    else
      str=str..' nil '
    end
  end
  str = str..']'
  print(str)
end

neighborsFunctions = {neighborsVonNeumann, neighborsMoore}
neighborsNames = {'neighborsVonNeumann', 'neighborsMoore'}