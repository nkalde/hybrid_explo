--------------------
--INTERACTIVE COSTS--
---------------------
computeCostsI=function(robots, frontiersT, humans, frontiersC)  
  --local cMRxFH = getCostMatrixRxFH_Experiment(robots,frontiersT,humans,frontiersC, alpha, sigma)
  --local cMRxFH = getCostMatrixRxFH_Experiment_ECAI(robots,frontiersT,humans,frontiersC, alpha, sigma)
    local cMRxFH = getCostMatrixRxFH_TimeAngle2(robots,frontiersT,humans,frontiersC, evalFun)
  --printCostIMatrix(cMRxFH,robots,frontiersT,humans)
  return cMRxFH
end

getCostMatrixRxFH=function(robots,frontiersT,humans, frontiersC)
  local dRxFH = getDistanceMatrixRxFH(robots,frontiersT,humans,frontiersC)
  local pRxFH = getPenaltyMatrixRxFH(robots,frontiersT,humans,frontiersC)
  
  --normalize matrix
  dRxFH = normalizeMat(dRxFH)
  pRxFH = normalizeMat(pRxFH)
  
  local cRxFH = {}
  for i=1,#dRxFH do
    cRxFH[i] = {}
    for j=1,#dRxFH[i] do
      cRxFH[i][j] = dRxFH[i][j] + pRxFH[i][j]
    end
  end
  return cRxFH
end

--with new angle heuristic
getCostMatrixRxFH_TimeAngle2=function(robots,frontiersT,humans,frontiersC, alpha, sigma)  
  --distance matrix
  local dRxFH = getDistanceMatrixRxFH(robots,frontiersT,humans,frontiersC)
  dRxFH = normalizeMat(dRxFH)
  ---[[
  local fh =  {}
  for i=1,#frontiersT do
    fh[#fh+1]= frontiersT[i]
  end
  for i=1,#humans do
    fh[#fh+1]= humans[i]
  end
  
  --time matrix
  local pRxFH = getPenaltyMatrixRxFH_TimeAngle2(robots,frontiersT,humans,frontiersC,sigma)
  pRxFH = normalizeMat(pRxFH)
  --printInterAngles(pRxFH,robots,fh)
  
  --parameterized cost matrix
  local cRxFH = {}
  for i=1,#dRxFH do
    cRxFH[i] = {}
    for j=1,#dRxFH[i] do
      cRxFH[i][j] = alpha * dRxFH[i][j] + (1-alpha) * pRxFH[i][j]
    end
  end
  --printInterAngles(cRxFH,robots,fh)
  return cRxFH
end

getCostMatrixRxFH_Experiment_ECAI=function(robots,frontiersT,humans,frontiersC, alpha, sigma)  
  --distance matrix
  local dRxFH = getDistanceMatrixRxFH(robots,frontiersT,humans,frontiersC)
  dRxFH = normalizeMat(dRxFH)
  ---[[
  local fh =  {}
  for i=1,#frontiersT do
    fh[#fh+1]= frontiersT[i]
  end
   for i=1,#humans do
    fh[#fh+1]= humans[i]
  end
  --printInterDistances(dRxFH,robots,fh)
  --]]
  
  --time matrix
  local pRxFH = getPenaltyMatrixRxFH_Experiment_ECAI(robots,frontiersT,humans,frontiersC,sigma)
  pRxFH = normalizeMat(pRxFH)
  --printInterAngles(pRxFH,robots,fh)
  
  --parameterized cost matrix
  local cRxFH = {}
  for i=1,#dRxFH do
    cRxFH[i] = {}
    for j=1,#dRxFH[i] do
      cRxFH[i][j] = alpha * dRxFH[i][j] + (1-alpha) * pRxFH[i][j]
    end
  end
  --printInterAngles(cRxFH,robots,fh)
  return cRxFH
end

getCostMatrixRxFH_Experiment=function(robots,frontiersT,humans,frontiersC, alpha, sigma)  
  --distance matrix
  local dRxFH = getDistanceMatrixRxFH(robots,frontiersT,humans,frontiersC)
  
  --penalty matrix
  local pRxFH = getPenaltyMatrixRxFH_Experiment(robots,frontiersT,humans,frontiersC,sigma)

  --normalize matrix
  dRxFH = normalizeMat(dRxFH)
  pRxFH = normalizeMat(pRxFH)
  
  --parameterized cost matrix
  local cRxFH = {}
  for i=1,#dRxFH do
    cRxFH[i] = {}
    for j=1,#dRxFH[i] do
      cRxFH[i][j] = alpha * dRxFH[i][j] + (1-alpha) * pRxFH[i][j]
    end
  end
  return cRxFH
end

getDistanceMatrixRxFH=function(robots,frontiersT,humans,frontiersC)
  --distances RxH
  local interRxH = interDistancesW(robots,humans)
  --interDistancesNorm(robots,humans)
  
  --distances RxF
  local interRxF = interDistancesW(robots,frontiersT)
  --interDistancesNorm(robots,frontiersT)
  
  --distancesRxFH
  local interRxFH = {}
  for i=1,#robots do
    interRxFH[i] = {}
    for j=1,#frontiersT do
      interRxFH[i][j] = interRxF[i][j]
    end
    for j=1,#humans do
      interRxFH[i][j+#frontiersT] = interRxH[i][j] 
    end
  end
  return interRxFH
end

getAngleMatrixRxFH=function(robots,frontiersT,humans,frontiersC)
  --angles RxH
  local interRxH = interAngles(robots,humans)
  
  --angles RxF
  local interRxF = interAngles(robots,frontiersT)
  
  --anglesRxFH
  local interRxFH = {}
  for i=1,#robots do
    interRxFH[i] = {}
    for j=1,#frontiersT do
      interRxFH[i][j] = interRxF[i][j]
    end
    for j=1,#humans do
      interRxFH[i][j+#frontiersT] = interRxH[i][j] 
    end
  end
  return interRxFH
end

getAngleMatrixRxFH2=function(robots,frontiersT,humans,frontiersC)
  --angles RxH
  local interRxH = interAngles2(robots,humans)
  
  --angles RxF
  local interRxF = interAngles2(robots,frontiersT)
  
  --anglesRxFH
  local interRxFH = {}
  for i=1,#robots do
    interRxFH[i] = {}
    for j=1,#frontiersT do
      interRxFH[i][j] = interRxF[i][j]
    end
    for j=1,#humans do
      interRxFH[i][j+#frontiersT] = interRxH[i][j] 
    end
  end
  return interRxFH
end

getPenaltyMatrixRxFH=function(robots,frontiersT,humans,frontiersC)
  --penaltyAs(robots,usualRVel)
  penaltyAs(robots,1)
  penaltyAs(humans,1)
  penaltyAs(frontiersT,1)
  local pMRxFH = {}
  
  local pVR = getPenaltyVector(robots)
  local pVH = getPenaltyVector(humans)
  local pVF = getPenaltyVector(frontiersT)
  
  local pMR = transposePenalties(getPenaltyMatrix(pVR,#humans+#frontiersT))
  local pMH = getPenaltyMatrix(pVH,#robots)
  local pMF = getPenaltyMatrix(pVF,#robots)
  
  --print('MR',#pMR..'x'..#pMR[1])
  --print('MH',#pMH..'x'..#pMH[1])
  --print('MF',#pMF..'x'..#pMF[1])
  
  --local alpha, beta, gamma = -1,-1,1
  --local alpha, beta, gamma = 0,-1,1
  local alpha, beta, gamma = 0,0,0
  for i=1,#robots do
    pMRxFH[i] = {}
    for j=1,#frontiersT do
      pMRxFH[i][j] = alpha*pMR[i][j] + beta*pMF[i][j]
    end
    for j=1,#humans do
      pMRxFH[i][j+#frontiersT] = alpha*pMR[i][j+#frontiersT] + gamma*pMH[i][j] 
    end
  end
  return pMRxFH
end

getPenaltyMatrixRxFH_Experiment=function(robots,frontiersT,humans,frontiersC, sigma)
  penaltyAs(humans,1)
  penaltyAs(frontiersT,1)
  local pVH = getPenaltyVector(humans)
  local pVF = getPenaltyVector(frontiersT)
  local pMH = getPenaltyMatrix(pVH,#robots)
  local pMF = getPenaltyMatrix(pVF,#robots)
  --pMH = normalizeMat(pMH)
  --pMF = normalizeMat(pMF)
  local pMRxFH = {}
  for i=1,#robots do
    pMRxFH[i] = {}
    for j=1,#frontiersT do
      pMRxFH[i][j] = sigma*pMF[i][j]
    end
    for j=1,#humans do
      pMRxFH[i][j+#frontiersT] = (1-sigma)*pMH[i][j] 
    end
  end
  return pMRxFH
end

getPenaltyMatrixRxFH_Experiment_ECAI=function(robots,frontiersT,humans,frontiersC, sigma)
  penaltyAs(humans,1)
  penaltyAs(frontiersT,1)
  local pVH = getPenaltyVector(humans)
  local pVF = getPenaltyVector(frontiersT)
  local pMH = getPenaltyMatrix(pVH,#robots)
  local pMF = getPenaltyMatrix(pVF,#robots)
  
  --time matrix
  local tRxFH = {}
  for i=1,#robots do
    tRxFH[i] = {}
    for j=1,#frontiersT do
      tRxFH[i][j] = pMF[i][j]
    end
    for j=1,#humans do
      tRxFH[i][j+#frontiersT] = pMH[i][j] 
    end
  end
  tRxFH = normalizeMat(tRxFH)
  
  --angle matrix
  local aRxFH = getAngleMatrixRxFH(robots,frontiersT,humans,frontiersC)
  aRxFH = normalizeMat(aRxFH)
 
  --time and angle matrix 
  local pMRxFH = {}
  for i=1,#robots do
    pMRxFH[i] = {}
    for j=1,#frontiersT do
      pMRxFH[i][j] = sigma*(tRxFH[i][j] +aRxFH[i][j])
    end
    for j=1,#humans do
      pMRxFH[i][j+#frontiersT] = (1-sigma)*(tRxFH[i][j+#frontiersT] + aRxFH[i][j+#frontiersT])
    end
  end
  return pMRxFH
end

getPenaltyMatrixRxFH_TimeAngle2=function(robots,frontiersT,humans,frontiersC, sigma)
  penaltyAs(humans,1)
  penaltyAs(frontiersT,1)
  local pVH = getPenaltyVector(humans)
  local pVF = getPenaltyVector(frontiersT)
  local pMH = getPenaltyMatrix(pVH,#robots)
  local pMF = getPenaltyMatrix(pVF,#robots)
  
  --time matrix
  local tRxFH = {}
  for i=1,#robots do
    tRxFH[i] = {}
    for j=1,#frontiersT do
      tRxFH[i][j] = pMF[i][j]
    end
    for j=1,#humans do
      tRxFH[i][j+#frontiersT] = pMH[i][j] 
    end
  end
  tRxFH = normalizeMat(tRxFH)
  
  --angle matrix
  local aRxFH = getAngleMatrixRxFH2(robots,frontiersT,humans,frontiersC)
  aRxFH = normalizeMat(aRxFH)
 
  --time and angle matrix 
  local pMRxFH = {}
  for i=1,#robots do
    pMRxFH[i] = {}
    for j=1,#frontiersT do
      pMRxFH[i][j] = sigma*(tRxFH[i][j] +aRxFH[i][j])
    end
    for j=1,#humans do
      pMRxFH[i][j+#frontiersT] = (1-sigma)*(tRxFH[i][j+#frontiersT] + aRxFH[i][j+#frontiersT])
    end
  end
  return pMRxFH
end

-------------
--PENALTIES--
-------------

penaltyA=function(a,usualVel) --compute penalty for entity a
  local incrementPenalty = simGetSimulationTimeStep() --* usualVel
  local poseA = getPoseIJ(a)
  local nameA = '('..poseA[1]..','..poseA[2]..')' --human and robot case
  if type(a) == 'number' then --frontier case
      nameA = simGetObjectName(a)
  end
  local pA = penaltiesAs[nameA]
  if pA == nil then --not present
    penaltiesAs[nameA] = {poseA,0}
  else --present
    if pA[1][1] == poseA[1] and pA[1][2] == poseA[2] then --same pose
      pA[2] = pA[2] + incrementPenalty
    else
      pA = {poseA,0}
    end
    penaltiesAs[nameA] = pA
  end
end

penaltyAs=function(aSet,usualVel) --compute penalties for a_set
  if penaltiesAs == nil then
    penaltiesAs = {}
  end
  for i=1,#aSet do
    penaltyA(aSet[i],usualVel)
  end
end

getPenaltyVector=function(setA) --get a_set penalty vector
  local penaltyVector = {}
  for i=1,#setA do
    local v = setA[i]
    local key = ''
    if type(v) == 'table' then
        key = '('..v[1]..','..v[2]..')' --frontier case
    end
    if type(v) == 'number' then    --human and robot case
      key = simGetObjectName(v)
    end
    local val = penaltiesAs[key]
    penaltyVector[key] = val
  end
  return penaltyVector
end

--size lines of penaltyVector
getPenaltyMatrix=function(penaltyVector,size) --vector put in lines
  local penaltyMatrix = {}
  local pV = {}
  for k,v in pairs(penaltyVector) do 
    pV[#pV+1] = v[2]
 end
  for i = 1,size do
    penaltyMatrix[i] = pV
  end
  return penaltyMatrix
end

----------
--ANGLES--
----------

--inter angle capA, capB
interAngles=function(setA, setB)
  local interAngles = {}
  local set1, set2 = nil
  --a poses, b poses
  local aAngles, bAngles = {}, {}
  local radToDeg = 180/math.pi
  for i=1,#setA do 
    aAngles[i] = getOrientation(setA[i])*radToDeg 
  end
  for i=1,#setB do 
    bAngles[i] = getOrientation(setB[i])*radToDeg 
  end

  set1, set2 = aAngles, bAngles

  for i=1,#set1 do
    local v1=set1[i]
    interAngles[i] = {}
    for j=1,#set2 do
      local v2=set2[j]
      local sourceA, targetA = aAngles[i], bAngles[j]
      local a = absoluteDiffAngle(sourceA,targetA)
      interAngles[i][j] = a
    end
  end
  return interAngles
end

--angle from start orientation to target and from target to target orientation
--inter angle 2 abs(capA-capAToB), abs(capAToB-capB)
interAngles2=function(setA, setB)
  local interAngles = {}
  local set1, set2 = nil
  --a poses, b poses
  local aAngles, bAngles = {}, {}
  for i=1,#setA do 
    aAngles[i] = math.deg(getOrientation(setA[i])) 
  end
  for i=1,#setB do 
    bAngles[i] = math.deg(getOrientation(setB[i])) 
  end
  
  set1, set2 = aAngles, bAngles

  for i=1,#set1 do
    local v1 = set1[i]
    interAngles[i] = {}
    for j=1,#set2 do
      local v2 = set2[j]      
      local sourceA, targetA = aAngles[i], bAngles[j]
      local sourceToTargetA = angleFromAToB(setA[i],setB[j])
      local a = absoluteDiffAngle(sourceA,sourceToTargetA)
      local b = absoluteDiffAngle(sourceToTargetA,targetA)
      --local a = absoluteDiffAngle(sourceA,targetA)
      interAngles[i][j] = a + b
    end
  end
  return interAngles
end

getOrientation=function(a)
  if type(a)=='number' then
    return simGetObjectOrientation(a,-1)[3]
  else
    local angle = sGetFrontierOrientationSigned(a) 
    --print(angle)
    return angle
  end
end
-------------
--transpose--
-------------
transposeInterDistances=function(distancesM)
  return transpose(distancesM)
end

transposePenalties=function(penaltiesM)
 return transpose(penaltiesM)
end

------------
--PRINTING--
------------

printIntraDistances=function(matDist,set)
  print('\n###########################')
  print('###Intra Distance Matrix###')
  print('###########################\n')
  local strEnd = '\t'
  for k, v in ipairs(matDist) do
      for i=1, #v do
        strEnd = strEnd..'\t'..i
      end
      break
  end
  print(strEnd)
    for i,v in ipairs(matDist) do
    if i <= #set then
      local str = ''
      if type(set[i]) == 'number' then
        str = simGetObjectName(set[i])
      end
      if type(set[i]) == 'table' then
        str = '('..set[i][1]..','..set[i][2]..')'
      end
      for j=1,#v do
        str = str..'\t'..v[j]      
      end
      print(str)
    end
  end
end

printInterDistances=function(matDist,setA,setB)
  print('\n###########################')
  print('###Inter Distance Matrix###')
  print('###########################\n')
  local strEnd = '\t'
  for i, v in ipairs(setB) do
    if type(v) == 'number' then
      strEnd = strEnd..'\t'..simGetObjectName(v)
    end
    if type(v) == 'table' then
      strEnd = strEnd..'\t'..'('..v[1]..','..v[2]..')'
    end      
  end
  print(strEnd)
  ---[[
  for i,v in ipairs(matDist) do
    local str = ''
    local val = setA[i]
    if type(val) == 'number' then
      str = simGetObjectName(val)
    end
    if type(val) == 'table' then
      str = '('..val[1]..','..val[2]..')'
    end
    for j,v2 in ipairs(v) do
      str = str..'\t'..string.format('%.3f',v2)--v2      
    end
    print(str)
  end
  --]]
end

printInterAngles=function(matAngle,setA,setB)
  print('\n###########################')
  print('###Inter  Angle   Matrix###')
  print('###########################\n')
  local strEnd = '\t'
  for i, v in ipairs(setB) do
    if type(v) == 'number' then
      strEnd = strEnd..'\t'..simGetObjectName(v)
    end
    if type(v) == 'table' then
      strEnd = strEnd..'\t'..'('..v[1]..','..v[2]..')'
    end      
  end
  print(strEnd)
  ---[[
  for i,v in ipairs(matAngle) do
    local str = ''
    local val = setA[i]
    if type(val) == 'number' then
      str = simGetObjectName(val)
    end
    if type(val) == 'table' then
      str = '('..val[1]..','..val[2]..')'
    end
    for j,v2 in ipairs(v) do
      str = str..'\t'..string.format('%.6f',v2)--v2      
    end
    print(str)
  end
  --]]
end

printCostIMatrix=function(costMatrix,robots,frontiers,humans)
  print('\n###################')
  print('###Costs I Matrix###')
  print('###################\n')
  local strEnd = '\t'
  for k, v in ipairs(costMatrix) do
      for i=1, #v do
        local val = ''
        if i<=#frontiers then
          val = '('..frontiers[i][1]..','..frontiers[i][2]..')'
        else
          val = simGetObjectName(humans[i-#frontiers])
        end
        strEnd = strEnd..'\t'..val
      end
      break
  end
  print(strEnd)
  
  for k,v in pairs(costMatrix) do
    if k <= #robots then
      local str = simGetObjectName(robots[k])
      for i=1,#v do
        str = str..'\t'..string.format('%.3f',v[i])--math.floor(v[i])      
      end
      print(str)
    end
  end
end

printPenaltiesAs=function() --print all penalties
  local str = ''
  for k,v in pairs(penaltiesAs) do
    str = str ..'\n'.. k .. ' -> ('.. v[2] ..')' 
  end
  print(str)
  str = nil
end

printPenaltyV=function(penaltyVector) --print penalty vector
  local str = ''
  for k,v in pairs(penaltyVector) do
    str = str ..'\n'.. k .. ' -> ('.. v[2] ..')' 
  end
  print(str)
  str = nil
end

printPenaltyM=function(penaltyMatrix, set) --print penalty matrix
  local str, strEnd = '', ''
  for k,v in pairs(set) do
    local key = ''
    if type(v) == 'table' then
        key = '('..v[1]..','..v[2]..')' --frontier case
    end
    if type(v) == 'number' then    --human and robot case
      key = simGetObjectName(v)
    end
    strEnd = strEnd..'\t'..key
  end
  print(strEnd)
  
  for i,v in ipairs(penaltyMatrix) do
    for i2,v2 in ipairs(v) do
      str = str..'\t'..math.floor(v2) 
    end
    str=str..'\n'
  end
  print(str)
  str = nil
end