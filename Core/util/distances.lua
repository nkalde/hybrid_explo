
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
  for i,v in ipairs(set) do intraPoses[i] = getPoseIJ(v) end
  for i,v in ipairs(intraPoses) do
    intraDistances[i] = {}
    intraDistances[i][i] = 0
  end
  for i,v in ipairs(intraPoses) do
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
  for i,v in ipairs(setA) do aPoses[i] = getPoseIJ(v) end
  for i,v in ipairs(setB) do bPoses[i] = getPoseIJ(v) end

  set1, set2 = aPoses, bPoses

  for i,v1 in ipairs(set1) do
    interDistances[i] = {}
    for j,v2 in ipairs(set2) do
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
  for i,v in ipairs(set) do intraPoses[i] = getPoseIJ(v) end
  for i,v in ipairs(intraPoses) do
    intraDistances[i] = {}
    intraDistances[i][i] = 0
  end
  for i,v1 in ipairs(intraPoses) do
    for j,v2 in ipairs(intraPoses) do
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
  for i,v in ipairs(setA) do aPoses[i] = getPoseIJ(v) end
  for i,v in ipairs(setB) do bPoses[i] = getPoseIJ(v) end
  
  --set1 (lines) X set2 (columns) cost map
  --if #setA < #setB then
  set1, set2 = aPoses, bPoses
  --else
  --set1, set2 = bPoses, aPoses
  --end
  
  for i,v in ipairs(set1) do
    interDistances[i] = {}
    exploCloseGG()
    gradientFunction({v},0,neighborsFunction,nil)
    for j,v in ipairs(set2) do
      local a,b = set2[j][1], set2[j][2]
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
  for i,v in ipairs(set) do intraPoses[i] = getPoseIJ(v) end
  for i,v in ipairs(intraPoses) do
    intraDistances[i] = {}
    intraDistances[i][i] = 0
  end
  for i,v in ipairs(intraPoses) do
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
    end
    for j=i+1,#set do
      intraDistances[j][i] = 0
      intraDistances[j][i] = intraDistances[i][j] 
    end
  end
  return intraDistances
end

distanceFunctions={distanceManhattan, distanceTchebychev, distanceEuclid}
distanceNames={'distanceManhattan', 'distanceTchebychev', 'distanceEuclid'}