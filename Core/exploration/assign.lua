---------------
--ASSIGNMENTS--
---------------

assignFrontiers=function(frontiers, agents)
  --update exploration grid
  local explorerPoseXY = getPoseXY(agent)
  local explorerPoseIJ = getPoseIJ(agent)
  updateExplorationGrid(agent)
   
  --costs matrix
  computeC = computeCostsI
  --computeC = computeCosts
  
  --robots set
  local robotsInN = explorersInNeighborhood(agent)
  table.insert(robotsInN,#robotsInN+1,agent)
  
  --humans set
  local humansInN = humansInNeighborhood(agent)
  local agentsN = robotsInN
  
  --frontiers set (targets, components)
  local frontiersTargets, frontiersComponents = regroupFrontiers(frontiers,robotsInN,humansInN)
  
  if #frontiersTargets == 0 then -- no frontiers
    return explorerPoseIJ
  else  -- frontiers
    if explorationIndex <= 7 then --SRE
      return explorationFunction(agent,frontiersTargets)
    else  --MRE
      local assignments = explorationFunction(agentsN,frontiersTargets,humansInN,frontiersComponents)
      --printAssignments(assignments, agentsN, frontiersTargets, humansInN)
      local iAssignment = assignments[#agentsN]
      if iAssignment == 0 then
        return explorerPoseIJ
      end
      if iAssignment <= #frontiersTargets then
        if frontierAffsUpdate then
          frontierAffsUpdate(1)
        end
        return frontiersTargets[iAssignment]      
      else
        if interactionAffsUpdate then
          interactionAffsUpdate(1)
        end
        return humansInN[iAssignment-#frontiersTargets]  
      end    
    end
  end
end

--move to another file
--different strategies based on human poses
humansInNeighborhood=function(agent) --check into visibility distance
  --humanPoses on the grid
  local pos = getPoseXY(agent)
  local humanPoses = {}
  for i=1,#humans do
    local humanHandle = humans[i]
    local position = simGetObjectPosition(humanHandle,-1)
    humanPoses[#humanPoses+1] = {position[1], position[2]}
  end
  --humanPoses = vectorWorld2Grid(humanPoses)
  local humanNeighbors = {}
  for i,v in ipairs(humanPoses) do
    if distanceFunction(pos,v) < radiusView then--/coef then
      humanNeighbors[#humanNeighbors+1] = humans[i]
    end
  end
  return humanNeighbors
end

explorersInNeighborhood=function(agent)
  --humanPoses on the grid
  local pos = getPoseXY(agent)
  local explorerPoses = {}
  for i=1,#explorers do
    local explorerHandle = explorers[i]
    local position = simGetObjectPosition(explorerHandle,-1)
    explorerPoses[#explorerPoses+1] = {position[1], position[2]}
  end
  --explorerPoses = vectorWorld2Grid(explorerPoses)
  local explorerNeighbors = {}
  for i,v in ipairs(explorerPoses) do
    if distanceFunction(pos,v) < radiusView then--/coef then 
      explorerNeighbors[#explorerNeighbors+1] = explorers[i]
    end
  end
  return explorerNeighbors
end

------------
--PRINTING--
------------

printAssignments=function(assignments, robots, frontiers, humans)
  if #assignments ~= 0 then
    print('\n#################')
    print('###Assignments###')
    print('#################\n')
    for k,v in ipairs(assignments) do
      if v > #frontiers and v <= #frontiers + #humans then
        local human = humans[v-#frontiers]
        v = simGetObjectName(human)
        --simAddObjectToSelection({human})
        --simRemoveObjectFromSelection(sim_handle_all)
      end
      if k < #robots then
        print(simGetObjectName(explorers[k])..'\t->'..v)
      end
      if k == #robots then
        print(agentName..'\t->'..v)
      end
    end
  end
end

explorationFunctions = { 
  SRE_Random,
  SRE_FollowingHuman,
  SRE_HumanTracesMin,
  SRE_HumanTracesMax,
  SRE_MinDist,
  SRE_MaxDist,
  SRE_Behavior,
  MRE_MinDist_dec,
  MRE_MinPos_dec,
  MRE_Greedy_dec,
  MRE_Random_dec,
  MRE_HungarianMethod
}

explorationNames = {
  'SRE_Random',
  'SRE_FollowingHuman',
  'SRE_HumanTracesMin',
  'SRE_HumanTracesMax',
  'SRE_MinDist',
  'SRE_MaxDist',
  'SRE_Behavior', --7
  'MRE_MinDist_dec',
  'MRE_MinPos_dec',
  'MRE_Greedy_dec',
  'MRE_Random_dec',
  'MRE_HungarianMethod'
}
