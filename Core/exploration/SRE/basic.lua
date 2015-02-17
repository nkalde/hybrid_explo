----------------------------
--SINGLE ROBOT EXPLORATION--
----------------------------
--SRE_strategy=function(robot, frontiers)
--SR Single Robot
--FB Frontier Based
--E Exploration

----------
--RANDOM--
----------
SRE_Random=function(agent, frontiers)
	math.randomseed(simGetFloatingParameter(sim_floatparam_rand)*10000000) -- each lua instance should start with a different and 'good' seed
  return frontiers[math.random(1,#frontiers)]
end

------------
--MIN DIST-- (gradient)
------------
SRE_MinDist=function(agent, frontiers)
	exploCloseGG()
	local agentPose = getPoseIJ(agent)
	gradientFunction({agentPose},0,neighborsFunction,{maxX,maxY})
	local min = math.huge
	local argmin = agentPose
	for i=1, #frontiers, 1 do
		if min >= gradientGrid[frontiers[i][1]][frontiers[i][2]] then
			min = gradientGrid[frontiers[i][1]][frontiers[i][2]] 
			argmin = frontiers[i]
		end
	end
	return argmin
end

------------
--MAX DIST-- (gradient)
------------
SRE_MaxDist=function(agent, frontiers)
	exploCloseGG()
	local agentPose=getPoseIJ(agent)
	gradientFunction({agentPose},0,neighborsFunction,{maxX,maxY})
	local max = -math.huge
	local argmax = agentPose
	for i=1, #frontiers, 1 do
		if max <= gradientGrid[frontiers[i][1]][frontiers[i][2]] and gradientGrid[frontiers[i][1]][frontiers[i][2]] ~= math.huge then
			max = gradientGrid[frontiers[i][1]][frontiers[i][2]] 
			argmax = frontiers[i]
		end
	end
	return argmax
end

--------------
--BEHAVIORAL--
--------------
SRE_Behavior=function(agent, frontiers)
  local agentPose = getPoseIJ(agent)
  local behavior = 'affection'
  local humanNeighbors = humansInNeighborhood(agent)
  local explo = SRFBE_Min
  local otherPos = agentPose
  if #humanNeighbors > 0 then
    if behavior == 'affection' then
      explo=SRE_FollowingHuman
      local goalHandle = humanNeighbors[1]
      otherPos = getPoseIJ(goalHandle)
    end
    if behavior == 'repulsion' then
      explo=SRFBE_Max
    end
  end
  return explo(otherPos, frontiers)
end

-----------------
--HUMANS TRACES-- (gradient)
-----------------
--towards human traces
SRE_HumanTraces=function(agent)
  local agentPose = getPoseIJ(agent)
  local neighborsR = neighborsFunction(agentPose[1], agentPose[2])
  neighborsR[#neighborsR+1] = agentPose
  for i=1,#neighborsR do
    if neighborsR[i] ~= -1 then
      if animatedSE[neighborsR[i][1]..'#'..neighborsR[i][2]] == true then
        lastSeen = neighborsR[i]
      end
    end
  end
  if lastSeen == nil then
    lastSeen = agentPose
  end
  exploCloseGG()
  gradientFunction({lastSeen},0,neighborsFunction,{maxX,maxY})
end

--frontiers near the human traces
SRE_HumanTracesMin=function(agent, frontiers)
  SRFBE_HumanTraces(agent)
  local agentPose = getPoseIJ(agent)
  local min = math.huge
  local argmin = agentPose
  for i=1, #frontiers do
    if min >= gradientGrid[frontiers[i][1]][frontiers[i][2]] then
      min = gradientGrid[frontiers[i][1]][frontiers[i][2]] 
      argmin = frontiers[i]
    end
  end
  return argmin
end

--frontiers far from the human traces
SRE_HumanTracesMax=function(agent, frontiers)
  SRFBE_HumanTraces(agent)
  local agentPose = getPoseIJ(agent)
  local max = -math.huge
  local argmax = agentPose
  for i=1, #frontiers do
    --computing gradient for each frontier is better because the agent cannot go in another disjoint place
    if max <= gradientGrid[frontiers[i][1]][frontiers[i][2]] and gradientGrid[frontiers[i][1]][frontiers[i][2]] ~= math.huge then
      max = gradientGrid[frontiers[i][1]][frontiers[i][2]] 
      argmax = frontiers[i]
    end
  end
  return argmax
end

-------------------
--FOLLOWING HUMAN--
-------------------
--the robot follows the first human in neighborhood
SRE_FollowingHuman=function(agent, frontiers)
  local humanNeighbors = humansInNeighborhood(agent)
  local agentPose = getPoseIJ(agent)
  if #humanNeighbors > 0 then
    local goalHandle = humanNeighbors[1]
    return getPoseIJ(goalHandle)
  else
    return agentPose
  end
end
