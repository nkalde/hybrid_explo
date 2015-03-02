
---------
--NORMS--
---------
distanceManhattan=function(x,y)
  return math.abs(x[1]-y[1]) + math.abs(x[2]-y[2]) 
end

distanceTchebychev=function(x,y)
  return math.max(math.abs(x[1]-y[1]),math.abs(x[2]-y[2]) )
end

distanceEuclid=function(x,y)
  return math.sqrt((y[1]-x[1])*(y[1]-x[1]) +  (y[2]-x[2])*(y[2]-x[2]))
end

--for frontiers
intraDistancesN=function(set)
  --distances AxA
  local intraDistances = {}
  local intraPoses = {}
  for i=1,#set do
    local v = set[i] 
    intraPoses[i] = getPoseIJ(v) 
  end
  
  for i=1,#intraPoses do
    intraDistances[i] = {}
    intraDistances[i][i] = 0
  end
  
  for i=1,#intraPoses do
    local v = intraPoses[i]
    for j=i+1,#intraPoses do
      intraDistances[i][j] = 0
      local intraPose = intraPoses[j]
      intraDistances[i][j] = distanceManhattan(intraPose,v)--distance[neighborsIndex](intraPose, v)
      if intraDistances[i][j] <= 1 then -- math.sqrt(2) then
        intraDistances[i][j] = 0
      end
      
    end
    for j=i+1,#set do
      intraDistances[j][i] = 0
      intraDistances[j][i] = intraDistances[i][j] 
    end
  end
  return intraDistances
end

--inter distances
interDistancesNorm=function(setA, setB)
  local interDistances = {}
  local set1, set2 = nil
  --a poses, b poses
  local aPoses, bPoses = {}, {}
  for i=1,#setA do 
    local v = setA[i]
    aPoses[i] = getPoseIJ(v) 
  end
  
  for i=1,#setB do
    local v = setB[i] 
    bPoses[i] = getPoseIJ(v) 
  end

  set1, set2 = aPoses, bPoses

  for i=1,#set1 do
    local v1 = set1[i]
    interDistances[i] = {}
    for j=1,#set2 do
      local v2 =  set2[j]
      --interDistances[i][j] = distanceFunctions[neighborsIndex](v1, v2)
      interDistances[i][j] = distanceManhattan(v1, v2)
    end
  end
  return interDistances
end

--intra distances
intraDistancesNorm=function(set)
  --distances AxA
  local intraDistances = {}
  local intraPoses = {}
  for i=1,#set do
    local v = set[i] 
    intraPoses[i] = getPoseIJ(v) 
  end
  
  for i=1,#intraPoses do
    intraDistances[i] = {}
    intraDistances[i][i] = 0
  end
  for i=1,#intraPoses do
    local v1= intraPoses[i]
    for j=1,#intraPoses do
      local v2=intraPoses[j]
      intraDistances[i][j] = 0
      if j >= i+1 then 
        intraDistances[i][j] = distanceManhattan(v,v2)--distanceFunctions[neighborsIndex](v, v2)
      end
    end
    for j=i+1,#set do
      intraDistances[j][i] = 0
      intraDistances[j][i] = intraDistances[i][j] 
    end
  end
  return intraDistances
end

--------------------------------
--GRADIENT PROPAGATED DISTANCE--
--------------------------------

--inter distances
interDistancesW=function(setA, setB)
  local interDistances = {}
  local set1, set2 = nil
  
  --a poses, b poses
  local aPoses, bPoses = {}, {}
  for i=1,#setA do
    local v = setA[i] 
    aPoses[i] = getPoseIJ(v) 
  end
  for i=1,#setB do
    local v = setB[i] 
    bPoses[i] = getPoseIJ(v) 
  end
  
  --set1 (lines) X set2 (columns) cost map
  --if #setA < #setB then
  set1, set2 = aPoses, bPoses
  --else
  --set1, set2 = bPoses, aPoses
  --end
  
  for i=1,#set1 do
    local v1 = set1[i]
    interDistances[i] = {}
    exploCloseGG()
    gradientFunction({v1},0,neighborsFunction,nil)
    for j=1,#set2 do
      local v2 = set2[j]
      local a,b = v2[1], v2[2]
      local gValue  = minValueN(a,b,neighborsFunction)
      if gValue == -1 then
        --gValue = math.huge
        gValue = 10000
      end
      interDistances[i][j] = gValue 
    end
  end
  return interDistances
end

--intra distances
intraDistancesW=function(set)
  --distances AxA
  local intraDistances = {}
  local intraPoses = {}
  for i=1,#set do
    local v = set[i] 
    intraPoses[i] = getPoseIJ(v) 
  end
  
  for i=1,#intraPoses do
    intraDistances[i] = {}
    if type(set[i]) == 'number' then
      intraDistances[i][i] = 10000--to penalize myself as an agent
    else
      intraDistances[i][i] = 0--to penalize myself as an agent  
    end
  end

  for i=1,#intraPoses do
    local v = intraPoses[i]
    exploCloseGG()
    gradientFunction({v},0,neighborsFunction,nil)
    for j=i+1,#intraPoses do
      intraDistances[i][j] = 0
      local a,b = intraPoses[j][1], intraPoses[j][2]
      local gValue  = minValueN(a,b,neighborsFunction)
      if gValue == -1 then
        --gValue = math.huge
        gValue = 10000
      end
      intraDistances[i][j] = gValue 
      intraDistances[j][i] = gValue 
    end
  end
  return intraDistances
end

distanceFunctions={distanceManhattan, distanceTchebychev, distanceEuclid}
distanceNames={'distanceManhattan', 'distanceTchebychev', 'distanceEuclid'}