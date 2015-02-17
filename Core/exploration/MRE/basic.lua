dofile(os.getenv('PWD')..'/Core/exploration/MRE/hungarianMethod.lua')

---------------------------
--MULTI ROBOT EXPLORATION--
---------------------------
--MRE_strategy=function(robots, frontiers)
--MR MULTI Robot
--FB Frontier Based
--E Exploration

----------
--RANDOM--
----------

MRE_Random=function(robots, frontiers, humans, frontiersL)
  local costs = computeC({robots[#robots]}, frontiers, humans, frontiersL)
  local assignments = {}
  for explorer, frontiersC in ipairs(costs) do
    assignments[explorer] = math.random(1,#frontiersC)
  end
  return assignments
end

MRE_Random_dec=function(robots, frontiers, humans, frontiersL)
  local costs = computeC({robots[#robots]}, frontiers, humans, frontiersL)
  local assignments = {}
  for i=1,#robots do assignments[i] = 0 end
  assignments[#robots] = math.random(1,#costs[1]) 
  return assignments
end

-----------
--MINDIST--
-----------

MRE_MinDist=function(robots, frontiers, humans, frontiersL)
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local assignments = {}
  for explorer, frontiersC in ipairs(costs) do
    --compute min dist, all min dist tasks, random selection between all min dist tasks
    local aMin, min = min(frontiersC)
    local minFrontiers = eq(frontiersC, min)
    assignments[explorer] = minFrontiers[math.random(1,#minFrontiers)] 
  end
  return assignments
end

MRE_MinDist_dec=function(robots, frontiers, humans, frontiersL)
  local costs = computeC({robots[#robots]}, frontiers, humans, frontiersL)
  local assignments = {}
  for i=1,#robots do assignments[i] = 0 end
  local frontiersC = costs[#costs]
  --compute min dist, all min dist tasks, random selection between all min dist tasks
  local aMin, min = min(frontiersC)
  --print(min)
  local minFrontiers = eq(frontiersC, min)
  assignments[#robots] = minFrontiers[math.random(1,#minFrontiers)] 
  return assignments
end

----------
--GREEDY--
----------

MRE_Greedy=function(robots, frontiers, humans, frontiersL)
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local tasksE, robotsE, assignments, cnt = {}, {}, {}, 0
  
  while cnt ~= #costs do --#robots
    local explorerI, frontierJ, min = nil, nil, math.huge
    for i,costI in ipairs(costs) do
      if robotsE[i] == nil then
        for j,costIJ in ipairs(costI) do
          if tasksE[j] == nil then
            if min >= costIJ then
              explorerI, frontierJ, min = i, j, costIJ
            end
          end
        end
      end
    end
    tasksE[frontierJ] = explorerI
    robotsE[explorerI] = frontierJ
    cnt = cnt + 1 
    assignments[explorerI] = frontierJ
    if cnt%#costs[#costs] == 0 then --all tasks assigned but robots available
      tasksE = {}
    end
  end
  return assignments
end

MRE_Greedy_dec=function(robots, frontiers, humans, frontiersL)
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local tasksE, robotsE, assignments, cnt, stop = {}, {}, {}, 0, false
  for i=1,#robots do assignments[i] = 0 end
  
  while cnt ~= #costs and stop == false do --#robots and current robot not assigned yet
    local explorerI, frontierJ, min = nil, nil, math.huge
    for i,costI in ipairs(costs) do
      if robotsE[i] == nil then
        for j,costIJ in ipairs(costI) do
          if tasksE[j] == nil then
            if min >= costIJ then
              explorerI, frontierJ, min = i, j, costIJ
            end
          end
        end
      end
    end
    stop = explorerI == #costs --#robots
    tasksE[frontierJ] = explorerI
    robotsE[explorerI] = frontierJ
    cnt = cnt + 1 
    assignments[explorerI] = frontierJ
    if cnt%#costs[#costs] == 0 then --all tasks assigned but robots available
      tasksE = {}
    end
  end
  return assignments
end

----------
--MINPOS--
----------

MRE_MinPos=function(robots, frontiers, humans, frontiersL)
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local assignments, positions, nCosts = {}, {}, {}
  
  --compute positions of robot i
  for i,cI in ipairs(costs) do
    positions[i] = {}
    for j,cIJ in ipairs(cI) do --to task j
      local cnt = 0
      for k,cK in ipairs(costs) do --relative to other robots k
        local cKJ = cK[j]
        if cKJ < cIJ then
          cnt = cnt + 1
        end
      end
      positions[i][j] = cnt
    end
  end
  
  --compute assignments
  for i,positionsI in ipairs(positions) do
    --find min position
    local aMin, min = min(positionsI)
    
    --find other min position tasks
    local equalityFrontiers = eq(positionsI, min)
    
    --equality resolution min cost
    local aMin, min = nil, math.huge
    for j,eqf in ipairs(equalityFrontiers) do
      local val = costs[i][eqf]
      if min >= val then
        aMin, min = j, val
      end
    end
    assignments[i] = equalityFrontiers[aMin]
  end

  return assignments
end

MRE_MinPos_dec=function(robots, frontiers, humans, frontiersL) --dec
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local assignments, positions, nCosts = {}, {}, {}
  for i=1,#robots do assignments[i] = 0 end
  
  --compute positions of robot i
  for i,cI in ipairs(costs) do
    positions[i] = {}
    for j,cIJ in ipairs(cI) do --to task j
      local cnt = 0
      for k,cK in ipairs(costs) do --relative to other robots k
        local cKJ = cK[j]
        if cKJ < cIJ then
          cnt = cnt + 1
        end
      end
      positions[i][j] = cnt
    end
  end
   
  --compute assignment
  --find min position
  local i = #costs --#robots
  local positionsI = positions[i] --#robots
  local aMin, min = min(positionsI)
    
  --find other min position tasks
  local equalityFrontiers = eq(positionsI, min)
    
  --equality resolution min cost
  local aMin, min = nil, math.huge
  for j,eqf in ipairs(equalityFrontiers) do
    local val = costs[i][eqf]
    if min >= val then
      aMin, min = j, val
    end
  end
  assignments[i] = equalityFrontiers[aMin] --#robots
    
  return assignments
end

--------------------
--HUNGARIAN METHOD--(todo verify)
--------------------

--a b c d workers
--p q r s jobs
MRE_HungarianMethod=function(robots, frontiers, humans, frontiersL)
  local costs = computeC(robots, frontiers, humans, frontiersL)
  local maxSide = math.max(#costs,#costs[#costs])
  local assignments = {}
  for i=1,#robots do assignments[i] = 0 end
  --search max value
  local ki, kj, max = maxMat(costs)
  
  --replace math.huge by max value
  costs = replaceMat(costs, math.huge, max*max+1)
  printCostMatrix(costs,robots)
  
  --create a square matrix by padding max values
  local nCosts = {}
  for i=1,maxSide do
    nCosts[i] = {}
    for j=1,maxSide do
      if i<=#costs and j<=#costs[i] then
        nCosts[i][j] = costs[i][j]
      else
        nCosts[i][j] = max*max+1
      end
    end
  end

  -- input matrix : workers (lines) X jobs (columns)
  local res = munkres(nCosts)
  if res ~= nil then
    for i=1,#robots do
      if res[i] <= #costs[#costs] then
        assignments[i] = res[i]
      else
        assignments[i] = math.random(1,#costs[#costs])
      end
    end 
  end
  return assignments
end
