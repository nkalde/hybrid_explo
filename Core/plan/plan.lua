
gradientGrid={}	--grid for real world or exploration

------------
--PLANNING--
------------

planTrajectory=function(goal, gradientGridInit)
	if type(goal) == 'number' or type(goal) == 'table' and (type(agent) == 'number' or type(agent) == 'table') then
		local goalI, goalJ
		if type(goal) == 'number' then
			local goalPos = simGetObjectPosition(goal, -1)
			local goalX, goalY = goalPos[1], goalPos[2]
			goalI, goalJ = mappingWorld2Grid(goalX,goalY)
		end
		if type(goal) == 'table' then
			goalI, goalJ = goal[1], goal[2]
		end
		local startI, startJ
		if type(agent) == 'number' then
			local startPos = simGetObjectPosition(agent, -1)
			local startX, startY = startPos[1], startPos[2]
			startI, startJ = mappingWorld2Grid(startX,startY)
		end
		if type(agent) == 'table' then
			startI, startJ = agent[1], agent[2]
		end
		if insideGrid(goalI, goalJ) and insideGrid(startI,startJ) then
			--compute gradient
			gradientGridInit()
			gradientFunction({{goalI,goalJ}},0,neighborsFunction,{startI, startJ})
			plan = planningFunction({startI,startJ}, {goalI,goalJ}, limit, neighborsFunction)
			drawTrajectory(plan)
			return plan
		end	
		return {}
	end
	return {}
end

-----------
--DRAWING--
-----------

drawTrajectory=function(plan)
  local actions = vectorGrid2World(plan)
  if drawingT == nil then
    drawingT = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1,#actions, {0,0,0}, nil, nil, nil)
  else
    simRemoveDrawingObject(drawingT)
    drawingT = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1,#actions, {0,0,0}, nil, nil, nil)
  end
  if #actions >= 2 then
    for i=2,#actions+1 do
      if i <=#actions then 
        local a1 = actions[i-1]
        local a2 = actions[i]
        simAddDrawingObjectItem(drawingT, {a1[1],a1[2],2,a2[1],a2[2],2})
      else
        local a1 = actions[#actions]
        simAddDrawingObjectItem(drawingT, {a1[1],a1[2],2,a1[1],a1[2],2})
      end
    end
  end
end


--planification basic parameters
planningFunctions = {
  greedyPlan
  ,lrtaStar
  --,dStarLite
  --,lpaStar
}

planningNames = {
  'greedyPlan'
  ,'lrtaStar'
  --,'dStarLite'
  --,'lpaStar'
 
}  
  
heuristicFunctions = {
  hEuclidNoUpdate
  ,hEuclidUpdate
  ,hGradientNoUpdate
  ,hGradientUpdate
}

heuristicNames = {
  'hEuclidNoUpdate'
  ,'hEuclidUpdate'
  ,'hGradientNoUpdate'
  ,'hGradientUpdate'
}
