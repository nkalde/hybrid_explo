dofile(os.getenv('PWD')..'/Core/exploration/costs/interactive_h.lua')
dofile(os.getenv('PWD')..'/Core/exploration/costs/interactive_update.lua')

---------
--COSTS--
----------

--robots, frontiers (target), humans, frontiersL (components)
computeCosts=function(robots, frontiers, humans, frontiersL)
  return costMatrixFrontierComponent(robots, frontiers, frontiersL)
end

--Gradient propagation from a frontier target
costMatrixFrontierTarget=function(explorers, frontiers)
  local costs = {}
  
  --explorers poses
  local explorerPoses = {}
  for i=1,#explorers do
    local pose = getPoseIJ(explorers[i])
    explorerPoses[i] = pose
  end
  
  --explorers (lines) X frontiers (columns) cost map
  for i=1,#frontiers do
    local frontier = frontiers[i]
    exploCloseGG()
    gradientFunction({frontier},0,neighborsFunction,nil)
    for k,v in pairs(explorerPoses) do
      if costs[k] == nil then
        costs[k] = {}
      end
      local a,b = explorerPoses[k][1], explorerPoses[k][2]
      local gValue  = minValueN(a,b,neighborsFunction)
      if gValue == -1 then
        gValue = math.huge
      end
      costs[k][i] = gValue 
    end
  end
  --printCostMatrix(costs)
  return costs
end

--Gradient propagation from a frontier set
costMatrixFrontierComponent=function(explorers, frontiers, frontiersL)
  local costs = {}
  
  --explorers poses
  local explorerPoses = {}
  for i=1,#explorers do
    local pose = getPoseIJ(explorers[i])
    explorerPoses[i] = pose
  end
  
  --explorers (lines) X frontiers (columns) cost map
  for i=1,#frontiersL do
    local frontier = frontiersL[i]
    exploCloseGG()
    gradientFunction(frontier,0,neighborsFunction,nil)
    for explorer,pose in pairs(explorerPoses) do
      if costs[explorer] == nil then
        costs[explorer] = {}
      end
      local gValue  = minValueN(pose[1],pose[2],neighborsFunction)
      if gValue == -1 then
        gValue = math.huge
      end
      costs[explorer][i] = gValue 
    end
  end
  --printCostMatrix(costs, robots)
  return costs
end

------------
--PRINTING--
------------
printCostMatrix=function(costMatrix, robots)
  print('\n##################')
  print('###Costs Matrix###')
  print('##################\n')
  local strEnd = '\t'
  for k, v in ipairs(costMatrix) do
      for i=1, #v do
        strEnd = strEnd..'\t'..i
      end
      break
  end
  print(strEnd)
  
  for k,v in pairs(costMatrix) do
    if k <= #robots then
      local str = simGetObjectName(robots[k])
      for i=1,#v do
        str = str..'\t'..math.floor(v[i])      
      end
      print(str)
    end
  end
end