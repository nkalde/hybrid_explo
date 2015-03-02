-------------------
--INIT NAVIGATION--
-------------------

followTrajectory=function(plan, goalHandle)
  res = initNavig(vectorGrid2World(plan), agent, goalHandle, navigationFunction)
end

initNavig = function(plan, modelHandle, goalHandle, navigationFunction)
    if #plan > 1 then
      stepTrajectory = 1
      followingTrajectory = true--it is the best choice at this point --checkTrajectoryLocally(plan,stepTrajectory)
    end
end

--------------
--NAVIGATION--
--------------

navigateAlongNext=function(plan, modelHandle, i)
  local pos = simGetObjectPosition(modelHandle, -1)
  followingTrajectory = checkTrajectoryLocally(plan,i)
  
  --if trajectory is still good and plan is not finished
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
    if distanceEuclid(gT, posAfter) < coef/2 then
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
checkTrajectoryLocally=function(plan, i) --during navigation state
  if string.find(simGetObjectName(agent), 'Explorer#*%d*$')~=nil then --robot visibility
    scanDynamicCells(agent)
  else --all visibity
    scanDynamicCells(nil)
  end
  if i <= #plan then
    local a1, a2 = mappingWorld2Grid(plan[i][1], plan[i][2])
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