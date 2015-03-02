--------
--LRTA-- (real cost k= euclidean, heuristic h= euclidean or gradient)
--------
he={}

lrtaStar=function(start, goal)
  local startI, startJ, goalI, goalJ = start[1], start[2], goal[1], goal[2]
  local actions = {}
  return lrtaS({startI,startJ,0},{goalI,goalJ,0},actions,0)
end

--LRTA* path planning
lrtaS=function(s0,sG,actions,depth)
	if (k(s0,sG)>coef) and (depth < limit) then
		heuristicFunction(s0,sG,actions)
		bNeighbor, bIndex, min =trial(s0,sG,actions)
 		s1 = s0
 		if bNeighbor ~= nil then
	 		s1 = {bNeighbor[1],bNeighbor[2],0}
	 	end
 		actions[#actions+1]=s0 --modify this bIndex to a grid position
 		s0 = s1
 		lrtaS(s0,sG,actions,depth+1)
 	end
 	return actions
end

trial=function(s0,sG,actions)
	--print('\n#########################')
	--print('\ns0 ('..s0[1]..', '..s0[2]..')')
	bNeighbor, bIndex, min= aMin(s0,neighborsFunction,sG,actions)
	--print('\nindex '..index..' min '..min)
	he[formatPosition(s0,sG)]= math.max(heuristicFunction(s0,sG),min)
	return bNeighbor, bIndex
end

aMin=function(s0,neighborsFunction,sG,actions)
	local min = math.huge
	local neighbors, neighbors2 =  neighborsFunction(s0[1],s0[2])
	local j=-1
	local argj = nil
	for i=1,#neighbors do
	  ev = eval(s0,neighbors[i],sG,actions, neighbors2[i])
		if min > ev then
			min = ev
			argj = neighbors[i]
			j = i
		end
	end
	return argj, j, min
end

eval=function(s0,neighbor,sG,actions,neighborP)
	local nS = neighbor --nextState
	if nS == - 1 then
	   return 1 + heuristicFunction(neighborP,sG)
	else
	   return  1 + heuristicFunction(nS,sG)
  end
end

--------------
--HEURISTICS--
--------------

hEuclidNoUpdate=function(nS,sG)
	local s = formatPosition(nS, sG)
	if not he[s] then --not seen
		nSI, nSJ = nS[1],nS[2]
		if not insideGrid(nS[1],nS[2]) or occupied(nS[1],nS[2]) then
			he[s]=math.huge
		else
			he[s]=k(nS,sG)
		end
	end
	return he[s]
end

hEuclidUpdate=function(nS,sG)
	local s = formatPosition(nS, sG)	
  nSI, nSJ = nS[1],nS[2]
  if not insideGrid(nS[1],nS[2]) or occupied(nS[1],nS[2]) then
  	he[s]=math.huge
  else
  	he[s]=k(nS,sG)
  end
	return he[s]
end

hGradientNoUpdate=function(nS,sG)
	local s = formatPosition(nS,sG)
	if not he[s] then -- not seen
		if not insideGrid(nS[1],nS[2]) then
      he[s] = math.huge
    else
			local nSI, nSJ = nS[1],nS[2]
			he[s]=gradientGrid[nSI][nSJ]
    end
	end
	return he[s]
end

hGradientUpdate=function(nS,sG)
	local s = formatPosition(nS, sG)
	nSI, nSJ = nS[1],nS[2]
	if not insideGrid(nSI, nSJ) then
    he[s]=math.huge
  else
  	if not he[s] then --not seen
  			he[s]=gradientGrid[nSI][nSJ]
  	else --seen
  		if he[s]~=gradientGrid[nSI][nSJ] then --seen but updated
  			he[s]=gradientGrid[nSI][nSJ]
  		else --seen but not updated
  		end
  	end
  end
	return he[s]
end

k=function(s0, nS)
	return distanceEuclid(s0, nS)
end

formatPosition=function(s,g)
	local s = s[1]..','..s[2]..'-'..g[1]..','..g[2]
	return s
end