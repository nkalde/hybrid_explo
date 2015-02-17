----------
--GREEDY-- (cost k = gradient distance)
----------

--'limit' steps of planification from 'start' to 'goal' using neighborhood 'neighborsF'
greedyPlan=function(start, goal)
  local actions = {}
  local startI, startJ = start[1], start[2]
  table.insert(actions,#actions+1,start)
  local goalReached = gradientGrid[startI][startJ] == 0 --Lua runtime error: attempt to index field '?' (a nil value)
  local it = 0
  while not (goalReached) and it < limit do
    startI, startJ = gradientDescentNextStepG(startI, startJ, neighborsFunction)
    goalReached = gradientGrid[startI][startJ] == 0
    it = it + 1
    table.insert(actions,#actions+1,{startI,startJ})
  end
  if #actions >= limit then
    return {}
  end 
  return actions  
end