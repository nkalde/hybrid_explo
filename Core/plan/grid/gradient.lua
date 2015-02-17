---------------------------
--SUBSETS FOR PROPAGATION--
---------------------------

  -------------------------
  --FULL GRID PROPAGATION--
  -------------------------
  
  --the grid is ready for a gradient propagation
  fullGG=function()
  	gridOfCells()
  	occupiedCells()
  end
  
  ---------------------------
  --CLOSE WORLD PROPAGATION--
  ---------------------------
  
  --gradient grid disables propagation in the unknown space (close world assumption)
  exploCloseGG=function()
  	fullGG()
  	markUnknownAsOccupied()
  end
  
  --builds upon fullGG
  markUnknownAsOccupied=function() --new one builds on basicGridForGradient
    if exploGrid then
      for i=1,(maxX-minX)/coef do
        for j=1,(maxY-minY)/coef do
          if unknownSE[i..'#'..j] == true then 
            occupiedSet[i..'#'..j] = true     --unknown is occupied
            gradientGrid[i][j] = -math.huge       --no gradient propagation 
          end
        end
      end
    end
  end
  
  --------------------------
  --OPEN WORLD PROPAGATION--
  --------------------------
  
  --gradient grid enables propagation in the unknown space (open world assumption)
  exploOpenGG=function()
  	fullGG()
  	markUnknownAsFree()
  end
  
  --builds upon fullGG
  markUnknownAsFree=function()
    if exploGrid then
      for i=1,(maxX-minX)/coef do
        for j=1,(maxY-minY)/coef do
          if unknownSE[i..'#'..j] == true then
            occupiedSet[i..'#'..j] = nil    --unknown is free
            gradientGrid[i][j] = math.huge        --gradient propagation
          end
        end
      end
    end
  end
  
  ------------------------
  --GRADIENT PROPAGATION-- (recursive)
  ------------------------
  
  --set target to empty tab {}
  gradient=function(todoCells, val, neighborsF, target)
  	local flags = {}
  	if #todoCells ~= 0 then
  		local newTodo = {}
  		local nbTodo = #todoCells
  		local flags = {} --flags for doubles
  		for i = 1, nbTodo, 1 do
  			local curI, curJ = todoCells[i][1],todoCells[i][2]
  			--set value of gradient
  			if gradientGrid[curI][curJ] == math.huge then
  				gradientGrid[curI][curJ] = val
  			end
  			--add neighbors to the end todoCells
  			local neighbors = neighborsF(curI,curJ)
  			for k=1,#neighbors,1 do
  	 			if (neighbors[k] ~= -1) then --neighbor exists
  					local nI, nJ = neighbors[k][1], neighbors[k][2]
  					if (gradientGrid[nI][nJ] ~= val-1 and gradientGrid[nI][nJ] ~= val) then --not previous neighbor
  						if (gradientGrid[nI][nJ] == math.huge) then --not set or obstacle
  							if not occupied(nI,nJ) then
  								if not flags[nI..','..nJ] then
  									table.insert(newTodo,#newTodo+1,{nI,nJ})
  									flags[nI..','..nJ] = true
  							   	end
  							end
  						end
  					end			
  				end
  			end
  			--remove todoCells from the list
  			todoCells[i] = nil
  		end
  		--remove flags
  		for i = 1,#newTodo,1 do
  			flags[newTodo[i][1]..','..newTodo[i][2]]=nil
  		end
  		todoCells = nil
  		flags = nil
  		gradient(newTodo,val+1, neighborsF, target) --no target before
  		for i = 1, #newTodo, 1 do
  			newTodo[i][1] = nil
  			newTodo[i][2] = nil
  			newTodo[i] = nil
  		end
  		newTodo = nil
  	end
  end
  
  gradientMooreSqrt2=function(todoCells, val, neighborsF, target)
  	--[[
  	if val == 0 then
  		tmp = {todoCells[#todoCells],val}
  		todoCells[#todoCells] = tmp
  	end
  	--]]
  	if val == 0 then --modif for list of cells
      tmp = {}
      for i=1,#todoCells do
        local tmp_i = {todoCells[i],val}
        todoCells[i] = tmp_i
      end
      
    end
  	local flags = {}
  	if #todoCells ~= 0 then
  		local newTodo = {}
  		local nbTodo = #todoCells
  		local flags = {} --flags for doubles
  		for i = 1, nbTodo, 1 do
  			local curI, curJ = todoCells[i][1][1],todoCells[i][1][2]
  			local val = todoCells[i][2]
  			--set value of gradient
  			if gradientGrid[curI][curJ] == math.huge then --correction for moore neighboorhood error to correct Lua runtime error: gradient.lua:151: attempt to index field '?' (a nil value)
  				gradientGrid[curI][curJ] = val
  			end
  			--add neighbors to the end todoCells
  			local neighbors = neighborsF(curI,curJ)
  			for k=1,#neighbors,1 do
  	 			if (neighbors[k] ~= -1) then --neighbor exists
  					local nI, nJ = neighbors[k][1], neighbors[k][2]
  					if (gradientGrid[nI][nJ] ~= val-1 and gradientGrid[nI][nJ] ~= val and gradientGrid[nI][nJ] ~= val-math.sqrt(2)) then --not previous neighbor
  						if (gradientGrid[nI][nJ] == math.huge) then --not set or obstacle
  							if not occupied(nI,nJ) then
  								if not flags[nI..','..nJ] then
  									if k > 4 then
  										inc = 7
  									else
  										inc = 5
  									end
  									table.insert(newTodo,#newTodo+1,{{nI,nJ},val+inc})
  									flags[nI..','..nJ] = true
  							   	end
  							end
  						end
  					end			
  				end
  			end
  			--remove todoCells from the list
  			todoCells[i] = nil
  		end
  		--remove flags
  		for i = 1,#newTodo,1 do
  			flags[newTodo[i][1][1]..','..newTodo[i][1][2]]=nil
  		end
  		todoCells = nil
  		flags = nil
  		gradientMooreSqrt2(newTodo, val+1, neighborsF, target)
  		for i = 1, #newTodo, 1 do
  			newTodo[i][1] = nil
  			newTodo[i][2] = nil
  			newTodo[i] = nil
  		end
  		newTodo = nil
  	end
  end
  
  minValueN=function(i,j, neighborsF) --pb here for planif on exploration grid
  	local neighbors = neighborsF(i,j)
  	local min = math.huge
  	local argmin = -1
  	for k=1,#neighbors do
   		if (neighbors[k] ~= -1) then
  			if gradientGrid[neighbors[k][1]][neighbors[k][2]] < min and gradientGrid[neighbors[k][1]][neighbors[k][2]] ~= -math.huge then ---math.huge values for unset unknown cells
  				min = gradientGrid[neighbors[k][1]][neighbors[k][2]]
  				argmin = k
  			end
  		end
  	end
  	if min == math.huge then
  		return -1, argmin
  	else
  		return min, argmin
  	end
  end
  
  --gradient descent from grid cells
  gradientDescentNextStepG=function(i,j, neighborsF) --pb here for planification on exploration grid
  	local neighbors = neighborsF(i,j)
  	local min, argmin = minValueN(i,j, neighborsF)
  	local nextI, nextJ = i, j --do not move but sometimes problem while moving
  	if min ~= -1 then
  		nextI, nextJ = neighbors[argmin][1], neighbors[argmin][2]
  	end
  	return nextI, nextJ
  end
  
  -----------
  --DRAWING--
  -----------
  
  printGradient=function()
    print('\n')
    for j= 1, (maxY-minY)/coef do
      if j>=0 then
        str = ' '..j..': '
      else
        str = j..': '
      end
      strFin = '         '
      for i= (maxX-minX)/coef, 1, -1 do
        if i>0 then
          strFin = strFin..i..':    '
        else
          strFin = strFin..i..':   '
        end
        if gradientGrid[i][j] ~= math.huge and gradientGrid[i][j] ~= -math.huge then
          if gradientGrid[i][j]>=10 then
            str=str..'  | '..gradientGrid[i][j]
          else
            str=str..'  |  '..gradientGrid[i][j]    
          end
        else
          str=str..'  |  '..'N'
        end
      end
      print(str..'\n')
      str = nil
    end
    print(strFin)
  end
  
  drawGradient=function()
    if gradientDrawing == nil then
      gradientDrawing=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_cyclic+sim_drawing_itemcolors,coef/2,0.0,-1,(maxX-minX)*(maxX-minX)*(1/(coef*coef)),{0,0,0},nil,nil,nil)
    end
    --drawing exploration grid
    local max = -math.huge
    for i=1,#gradientGrid do
      for j=1,#gradientGrid[i]  do
        local val = gradientGrid[i][j]
        if max <= val and val ~= math.huge then
          max = val
        end
      end
    end
    for i=1,(maxX-minX)/coef do
      for j=1,(maxY-minY)/coef do
        local c, d = mappingGrid2World(i,j)
        local f2 = {c,d}
        local val = gradientGrid[i][j]
        if val == math.huge then
          val = max
        end
        simAddDrawingObjectItem(gradientDrawing,{f2[1];f2[2];0--[[val/max--]];0;0;1;val/max;val/max;val/max})
      end
    end
  end
  
  gradientFunctions = {gradientMooreSqrt2, gradient}
  gradientNames = {'gradientMooreSqrt2', 'gradient'}