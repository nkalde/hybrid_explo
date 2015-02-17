-------------------
--INIT NAVIGATION--
-------------------

followTrajectory=function(plan, goalHandle)
  res = initNavig(vectorGrid2World(plan), agent, goalHandle, navigationFunction)
end

initNavig = function(plan, modelHandle, goalHandle, navigationFunction)
  if #plan > 1 then
    --followingTrajectory = true
    --updateExplorationGrid(getPoseIJ(modelHandle))
    stepTrajectory = 1
    followingTrajectory = checkTrajectoryLocally(plan,stepTrajectory,getPoseIJ(modelHandle))
  end
end

--------------
--NAVIGATION--
--------------

navigateAlongNext=function(plan, modelHandle, i)
  local pos = simGetObjectPosition(modelHandle, -1)
  --local a, b = mappingWorld2Grid(pos[1],pos[2])
  local posR = getPoseIJ(modelHandle)
  followingTrajectory = checkTrajectoryLocally(plan,i,posR)
  
  --if trajectory is good and plan is not finished
  if followingTrajectory and i <= #plan then
    --next step
    local nStepX, nStepY = plan[i][1], plan[i][2]
    local gT = {nStepX, nStepY, pos[3]}
    
    --navigate
    local posBefore = pos
    navigationFunction(gT, modelHandle)
    local posAfter = simGetObjectPosition(modelHandle,-1)
    if distanceTravelledUpdate ~= nil then --monitoring enabled
      local dist = distanceEuclid(posBefore, posAfter)
      distanceTravelledUpdate(dist)
    end
    
    --update grid
    if distanceEuclid(gT, posAfter) < 0.25 then
      local c, d = mappingWorld2Grid(nStepX,nStepY)
      if updateExplorationGrid ~= nil then
        updateExplorationGrid({c, d})
      end
      stepTrajectory = i + 1
    end
  else --abort navigation
    followingTrajectory = false
    stepTrajectory = nil
  end
  --return i
end

--------------------
--CHECK TRAJECTORY--
--------------------

--check if the trajectory is still free 
checkTrajectoryLocally=function(plan, i, pos) --during navigation state
  if string.find(simGetObjectName(agent), 'Explorer#*%d*$')~=nil then --robot visibility
    scanDynamicCells(agent)
  else --all visibity
    scanDynamicCells(nil)
  end
  if i <= #plan then
    local a1, a2 = mappingWorld2Grid(plan[i][1], plan[i][2])--plan[j][1], plan[j][2]--mappingWorld2Grid(plan[j][1], plan[j][2])
    return not occupied(a1, a2) and not hindered(a1,a2)
  else
    return false
  end
end

navigationFunctions = {
  teleportTo,
  linearTo,
  linearAndAngularTo,
  SFMNew
}

navigationNames = {
  'teleportTo',
  'linearTo',
  'linearAndAngularTo',
  'SFMNew'}