computeCostsIROS=function(robots, frontiersT, humans, frontiersC)  
  local cMRxFH = getCostMatrixRxFH_IROS(robots,frontiersT,humans,frontiersC,evalFun)
  return cMRxFH
end

getCostMatrixRxFH_IROS=function(robots,frontiersT,humans,frontiersC,evalFun)  
  --distance matrix
  local dRxFHR, dHxF, dRxF = getDistanceMatrixRxFH_IROS(robots,frontiersT,humans,frontiersC)
  
  --penalty matrix
  local pRxFHR, pHxF, pRxF = getPenaltyMatrixRxFH_IROS(robots,frontiersT,humans,frontiersC)
  
  --human empathy different assumptions  
  local fHxF = getEmpathyHxF_IROS(dHxF,pHxF,1)
  
  --robot empathy --cooperative
  local fRxF = getEmpathyHxF_IROS(dRxF,pRxF,1)
  
  --parameterized cost matrix
  local cRxFHR = {}
  for i=1,#dRxFHR do
    cRxFHR[i] = {}
    for j=1,#frontiersT do
      cRxFHR[i][j] = dRxFHR[i][j] + pRxFHR[i][j]
    end
    for j=1,#humans do
      cRxFHR[i][j+#frontiersT] = dRxFHR[i][j+#frontiersT] + pRxFHR[i][j+#frontiersT] + fHxF[j]
    end
    for j=1,#robots do
      cRxFHR[i][j+#frontiersT+#humans] = dRxFHR[i][j+#frontiersT+#humans] + pRxFHR[i][j+#frontiersT+#humans] + fRxF[j]
    end
  end
  return cRxFHR
end

getEmpathyHxF_IROS=function(distAxF,penAxF, evalFun)  
  --cost matrix
  local cAxF = {}
  for i=1,#distAxF do
    cAxF[i] = {}
    for j=1,#distAxF[1] do
       cAxF[i][j] = distAxF[i][j] + penAxF[i][j]
    end
  end
  
  --evaluation
  local fAxF = {}
  local id
  for i=1,#cAxF do
    if evalFun == 1 then --"min" then
      id, fAxF[i] = min(cAxF[i])
    end
    if evalFun == 2 then --"max" then
      id, fAxF[i] = max(cAxF[i])
    end
    if evalFun == 3 then --"avg" then
      id, fAxF[i] = avg(cAxF[i])
    end
  end
  
  return fAxF
end

getDistanceMatrixRxFH_IROS=function(robots,frontiersT,humans,frontiersC)
  --DISTANCES
  local robots_humans = tableConcat(robots,humans)
  
  --distances
  --local interRxF = interDistancesWave(robots,frontiersT)
  --local interHxF = interDistancesWave(humans,frontiersT) --merge
  local interRHxF = interDistancesWave(robots_humans,frontiersT)
  local interRxH = interDistancesLocal(robots,humans)
  local intraRxR = intraDistancesLocal(robots)
  
  
  --distancesRxFH
  local interRxFHR = {}
  local interHxF = {}
  local interRxF = {}
  
  for i=1,#robots do
    interRxFHR[i] = {}
    interRxF[i] = {}  
    for j=1,#frontiersT do
      local interRHxFij = interRHxF[i][j] 
      interRxFHR[i][j] = interRHxFij 
      interRxF[i][j] = interRHxFij
    end
    for j=1,#humans do
      interRxFHR[i][j+#frontiersT] = interRxH[i][j] 
    end
    for j=1,#robots do
      interRxFHR[i][j+#frontiersT+#humans] = intraRxR[i][j] 
    end
  end
  
  for i=1,#humans do
   interHxF[i] = {}
    for j=1,#frontiersT do
      interHxF[i][j] = interRHxF[i+#robots][j]
    end
  end
  
  return interRxFHR, interHxF, interRxF
end

getPenaltyMatrixRxFH_IROS=function(robots,frontiersT,humans,frontiersC, sigma)
  --PENALTIES
  local robots_humans = tableConcat(robots,humans)
  
  --velocity
  --local pVRxF = interVelocities(robots,frontiersT)--0 matrix
  --local pVHxF = interVelocities(robots,frontiersT)--0 matrix merge
  local pVRxH = interVelocities(robots,humans)
  local pVRxR = intraVelocities(robots)
  
  --velocity diffenre matrix
  local vRxFHR = {}
  for i=1,#robots do
    vRxFHR[i] = {}
    for j=1,#frontiersT do
      vRxFHR[i][j] = 0
    end
    for j=1,#humans do
      vRxFHR[i][j+#frontiersT] = pVRxH[i][j] 
    end
    for j=1,#robots do
      vRxFHR[i][j+#frontiersT+#humans] = pVRxR[i][j] 
    end
  end
  
  --re-orientation angles
  local aRHxF = interAngles2(robots_humans,frontiersT)
  --local aRxF = interAngles2(robots,frontiersT)
  --local aHxF = interAngles2(humans,frontiersT)--merge
  local aRxH = interAngles2(robots,humans)
  local aRxR = intraAngles2(robots)
 
  --angle matrix
  local aRxFHR = {}
  for i=1,#robots do
    aRxFHR[i] = {}
    for j=1,#frontiersT do
      aRxFHR[i][j] = aRHxF[i][j]
    end
    for j=1,#humans do
      aRxFHR[i][j+#frontiersT] = aRxH[i][j] 
    end
    for j=1,#robots do
      aRxFHR[i][j+#frontiersT+#humans] = aRxR[i][j] 
    end
  end
  
  --velocity and angle matrix
  local pMRxFHR = {}
  local pMRxF = {}
  for i=1,#robots do
    pMRxFHR[i] = {}
    pMRxF[i] = {}
    for j=1,#frontiersT do
      local pMRxFHRij = vRxFHR[i][j] +aRxFHR[i][j]
      pMRxFHR[i][j] = pMRxFHRij 
      pMRxF[i][j] = pMRxFHRij
    end
    for j=1,#humans do
      pMRxFHR[i][j+#frontiersT] = vRxFHR[i][j+#frontiersT] + aRxFHR[i][j+#frontiersT]
    end
    for j=1,#robots do
      pMRxFHR[i][j+#frontiersT+#humans] = vRxFHR[i][j+#frontiersT+#humans] + aRxFHR[i][j+#frontiersT+#humans]
    end
  end
  
  local pMHxF = {}
  for i=1,#humans do
    pMHxF[i] = {}
    for j=1,#frontiersT do
      pMHxF[i][j] = aRHxF[i][j] --+ vHxF[i][j] --0
    end
  end
  
  return pMRxFHR, pMHxF, pMRxF
end

--velocity difference from agent A (follower) to agent B (guide)
interVelocities=function(setA, setB)
  local interVels = {}
  --a poses, b poses
  local aVelocities, bVelocities = {}, {}
  for i=1,#setA do --linear velocity of the agent
    local v = setA[i]
    if type(v) == 'number' then 
      aVelocities[i] = simGetObjectVelocity(v)
    else
      aVelocities[i] = {0,0,0}
    end  
  end 
  
  for i=1,#setB do --linear velocity of the human
    local v=setB[i]
    if type(v) == 'number' then 
      bVelocities[i] = simGetObjectVelocity(v) 
    else  
      bVelocities[i] = {0,0,0}
    end
  end
  
  for i=1,#aVelocities do
    local v1 = aVelocities[i]
    interVels[i] = {}
    for j=1,#bVelocities do
      local v2 = bVelocities[j]
      local sourceA, targetA = v1, v2
      local diffX = sourceA[1]-targetA[1]
      local diffY = sourceA[2]-targetA[2]
      local diff = math.sqrt(diffX*diffX,diffY*diffY)
      interVels[i][j] = diff
    end
  end
  return interVels
end

--velocity difference from agent A (follower) to agent B (guide)
intraVelocities=function(setA)
  local intraVels = {}
  local aVelocities = {}
  --a poses, b poses
  for i=1,#setA do --linear velocity of the agent
    local v = setA[i]
    if type(v) == 'number' then 
      aVelocities[i] = simGetObjectVelocity(v)
    else
      aVelocities[i] = {0,0,0}
    end
    intraVels[i] = {}
    intraVels[i][i] = 2 -- to penalize myself as an agent
  end 
  
  for i=1,#setA do
    for j=i+1,#setA do
      local sourceA, targetA = aVelocities[i], aVelocities[j]
      local diffX = sourceA[1]-targetA[1]
      local diffY = sourceA[2]-targetA[2]
      local diff = math.sqrt(diffX*diffX,diffY*diffY)
      intraVels[i][j] = diff
      intraVels[j][i] = diff
    end
  end
  return intraVels
end

--angle from start orientation to target and from target to target orientation
--inter angle 2 abs(capA-capAToB), abs(capAToB-capB)
intraAngles2=function(setA)
  local intraAngles = {}
  --a poses, b poses
  local aAngles = {}
  for i=1,#setA do
    local v = setA[i] 
    aAngles[i] = math.deg(getOrientation(v)) 
    intraAngles[i] = {}
    intraAngles[i][i] = 360 --to penalize myself as an agent
  end
  
  for i=1,#setA do
    for j=i+1,#setA do      
      local source, target = aAngles[i], aAngles[j]
      
      local sourceToTarget = angleFromAToB(setA[i],setA[j])
      local a = absoluteDiffAngle(source,sourceToTarget)
      local b = absoluteDiffAngle(sourceToTarget,target)
      intraAngles[i][j] = a + b
      
      local targetToSource = angleFromAToB(setA[j],setA[i])
      local c = absoluteDiffAngle(target,targetToSource)
      local d = absoluteDiffAngle(targetToSource,source)
      
      
      intraAngles[j][i] = c+d--360 - (a + b)
    end
  end
  return intraAngles
end

--inter distances
interDistancesLocal=function(setA, setB)
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
      interDistances[i][j] = distanceFunction(v1, v2)
    end
  end
  return interDistances
end

--intra distances
intraDistancesLocal=function(set)
  --distances AxA
  local intraDistances = {}
  local intraPoses = {}
  for i=1,#set do
    local v = set[i] 
    intraPoses[i] = getPoseIJ(v) 
  end
  
  for i=1,#intraPoses do
    intraDistances[i] = {}
    intraDistances[i][i] = 10000
  end
  for i=1,#intraPoses do
    local v1= intraPoses[i]
    for j=1,#intraPoses do
      local v2=intraPoses[j]
      intraDistances[i][j] = 0
      if j >= i+1 then 
        intraDistances[i][j] = distanceFunction(v1, v2)
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
interDistancesWave=function(setA, setB)
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
  if #setA < #setB then
    set1, set2 = aPoses, bPoses
  else
    set1, set2 = bPoses, aPoses
  end
  
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
  if #setA < #setB then 
    return interDistances
  else
    return transpose(interDistances)
  end
end

--intra distances
intraDistancesWave=function(set)
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