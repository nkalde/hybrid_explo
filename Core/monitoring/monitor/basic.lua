
--requires explorationGrid and explorationGridGT
--unknown, occupied, animated, free, S, SE, SEGT
--------------
--MONITORING--
--------------

  -------------------
  --INIT MONITORING--
  -------------------
  monitoringInit=function()
    if monitoringEnabled then
      explorationGridGT()
      distanceTravelledInit()
      explorationTimeInit()
      frontierAffsInit()
      interactionAffsInit()
      proximityInit()
    end
  end
  
  -- travelled distance
  -- update when a trajectory is followed
  -- init distance traveled
  distanceTravelledInit=function()
    distanceTravelled = 0
  end
  
  -- covering time
  -- init covering time
  explorationTimeInit=function()
    explorationTime =  0
    initTime = os.clock()
  end
  
  -- frontiers assignments
  -- number of frontiers assignments
  frontierAffsInit=function()
    frontierAffs = 0
  end
  
  
  -- interactions assignments
  interactionAffsInit=function()
    interactionAffs = 0
  end
  
  -- proximity indicator
  -- counts the number of times a robot was next to a person
  proximityInit=function()
    proximity = 0
  end
  
  ---------------------
  --UPDATE MONITORING--
  ---------------------
  
  -- update distance travelled
  distanceTravelledUpdate=function(dist)
    if monitoringEnabled then
      distanceTravelled = distanceTravelled + dist
    end
  end
  
  -- update frontier assignments
  frontierAffsUpdate=function(cnt)
    if monitoringEnabled then
      frontierAffs = frontierAffs + cnt
    end
  end
  
  -- update covering time
  explorationTimeUpdate=function()
    if monitoringEnabled then
      explorationTime = explorationTime + (os.clock() - initTime)
      initTime = os.clock()
    end
  end
  
  -- update interactons assignments
  interactionAffsUpdate=function(cnt)
    if monitoringEnabled then
      interactionAffs = interactionAffs + cnt
    end
  end
  
  -- update proximity indicator
  proximityUpdate=function(cnt)
    if monitoringEnabled then
      proximity= proximity+cnt
      updateExplorationGridGT()
    end
  end
  
  ------------------
  --END MONITORING--
  ------------------
  
  --get monitored information
  monitoringEnd=function()
    if monitoringEnabled then
      print('\n###################')
      print('#MONITORING RESULTS#')
      print('####################\n') 
      local comE = getCompletenessExploration()
      local corE = getCorrectnessExploration()
      local dT = getDistanceTravelled()
      --local eT = getExplorationTime()
      local eT = getExplorationTime2()  
      local fA = getFrontierAffs()
      local iA = getInteractionAffs()
      local pI = getProximity()
      print('Completeness :'..comE)
      print('Correctness :'..corE)
      print('Distance travelled :'..dT)
      print('Exploration Time :'..eT)
      print('Frontiers Affectations :'..fA)
      print('Interaction Affectations :'..iA)
      print('Proximity Indicator :'..pI)
      print('\n####################\n')
    end
  end
  
  --write monitored information to file
  monitoringEndToFile=function()
    --local date = os.date('%x-%H', os.time())
    --date = string.gsub(date,'/','_')
    local scene = simGetStringParameter(sim_stringparam_scene_path_and_name)
    local path, file, extension = string.match(scene, "(.-)([^//]-([^%.]+))$")
    local comE = getCompletenessExploration()
    local corE = getCorrectnessExploration()
    local dT = getDistanceTravelled()
    local eT = getExplorationTime2()
    local fA = getFrontierAffs()
    local iA = getInteractionAffs()
    local pI = getProximity()
  
    --new file writing
    local nbR = simGetScriptSimulationParameter(baseScript,'numberExplorers')
    local densityH = simGetScriptSimulationParameter(baseScript,'ratio')
    densityH=string.format("%.1f",densityH)
    local exploR = simGetScriptSimulationParameter(baseScript,'explorationFunction')
    local alpha = simGetScriptSimulationParameter(baseScript,'alpha')
    local sigma = simGetScriptSimulationParameter(baseScript,'sigma')
    local cnt = simGetStringParameter(sim_stringparam_app_arg7)
     if cnt == '' then --default value
      cnt = '0'
    end
    cnt = tonumber(cnt)
    --local date = os.date('%x', os.time())
    --date = string.gsub(date,'/','_')
    local date = os.date('%m_%d_%y', os.time())
    local exploName = explorationNames[exploR]
    local fileName = file..'_nbr'..nbR..'_den'..densityH..'_ass'..exploName..'_'..date..'.txt'
    local filePathName = os.getenv('PWD').."/Core/monitoring/data/"..fileName
    print(filePathName)
    local opt = "a"
    local f = io.open(filePathName,opt)
    local str = agentName..'\t'..comE..'\t'..corE..'\t'..dT..'\t'..eT..'\t'..fA..'\t'..iA..'\t'..pI..'\t'..alpha..'\t'..sigma..'\t'..cnt..'\n'
    f:write(str)
    f:close()   
  end

  -- exploration is complete ?
  getCompletenessExploration=function()
  	local cntT = 0
  	local cntE = 0
  	--compare exploration grid to real grid
  	--change to min max values
  	for k,v in pairs(unknownS) do
  		if (unknownS[k] == unknownSE[k]) then
  			cntE = cntE +  1
  		end
  		cntT = cntT + 1
  	end
  	return cntE/cntT
  	end
  
  -- exploration is correct ?
  getCorrectnessExploration=function()
  	local cntT = 0
  	local cntR = 0
  	for k,v in pairs(unknownSEGT) do
  		if unknownSE[k] == true then
  		else
  			if (unknownSEGT[k] == unknownSE[k] and
  				occupiedSEGT[k] == occupiedSE[k] and
  				animatedSEGT[k] == animatedSE[k] and
  				freeSEGT[k] == freeSE[k]) then
  				cntR = cntR + 1
  			end
  			cntT = cntT + 1
  		end
  	end
  	return cntR/cntT
  end

  -- distance travelled
  getDistanceTravelled=function()
  	return distanceTravelled
  end
  
  -- covering time
  getExplorationTime=function()
  	explorationTimeUpdate()
  	return explorationTime
  end
  
  getExplorationTime2=function()
    return simGetSimulationTime()
  end
 
  -- number of frontier targets
  getFrontierAffs=function()
  	return frontierAffs
  end

  -- number of interaction targets
  getInteractionAffs=function()
    return interactionAffs
  end

  -- proximity indicator
  getProximity=function()
  	return proximity
  end

  monitorings = {[true] = 'enabled',[false] = 'disabled'}