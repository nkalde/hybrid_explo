if (simGetScriptExecutionCount()==0) then
		package.path=package.path..';'..os.getenv('HOME')..'/Dropbox/Code/luaN/Evaluation/profiling/?.lua'
	
	--display
	displayOn = false
	if displayOn then
		console = simAuxiliaryConsoleOpen("Aux Console", 500, 0x10)
		oldprint = print
		print = function(...)
		simAuxiliaryConsolePrint(console, ...)
		end
	end

	argmax=function(args,fun)
		max = -math.huge
		j = 0
		for i=1,#args,1 do
			ev = fun(args[i])
			if max < ev then
				max = ev
				argj = args[i]
				j = i
			end
		end
		return argj, j, max
	end

	-- Function to compute the cos(phi, k)
	cosPhiIK=function(nIKx, nIKy, eIx, eIy)
		return -1 * dotProduct2D(nIKx, nIKy, eIx, eIy)
	end



	-- Function to compute g
	g=function(x)
		if (x >= 0) then
			return x
		else
			return 0
		end
	end

	-- Function to compute the diameter of the bounding box
	boundingBoxDiameter=function(object)
		if (string.find(simGetObjectName(object),'Bill')) then
			maxBoundingBoxDiameter = 0.4
		else 
			--ret, minX = simGetObjectFloatParameter(object, 15)
			--ret, minY = simGetObjectFloatParameter(object, 16)
			--ret, maxX = simGetObjectFloatParameter(object, 18)
			--ret, maxY = simGetObjectFloatParameter(object, 19)
			--dX = maxX - minX
			--dY = maxY - minY
			--maxBoundingBoxDiameter = math.min(dX,dY)
			maxBoundingBoxDiameter = 0.1
		end
		return maxBoundingBoxDiameter
	end

	-- Function to compute the distance between the center of two objects
	distanceObjectCenters=function(object1, object2)
		local c1=simGetObjectPosition(object1, -1)
		local c2=simGetObjectPosition(object2, -1)
		return distanceEuclid(c1,c2)
	end

	--Function to compute the closest distance between object 1 and object 2 --pb here
	distanceObjectMin=function(object1, object2)
		ret, dist = simCheckDistance(object1, object2, 0)
		if ret == 1 then
			return dist[7], {dist[1]-dist[4], dist[2]-dist[5], dist[3]-dist[6]}
		else
			return 0, {0,0,0}
		end
	end

	-- Function computing the vector from object1 to object2 -> from 2 to 1
	normalizedVector=function(object1, object2)
		--c1x, c1y = centerBoundingBox(object1)
		--c2x, c2y = centerBoundingBox(object2)
		--nvx = c2x - c1x
		--nvy = c2y - c1y
		--norm = distancePoints(c1x,c1y,c2x,c2y)
		ret, dist = simCheckDistance(object1, object2, 0)
		if ret == 1 then
			nvx = dist[1]-dist[4]
			nvy = dist[2]-dist[5]
			nvz = dist[3]-dist[6]
			norm = dist[7]
		else
			nvx = 0
			nvy = 0
			nvz = 0
			norm = 0
		end
		if norm ~= 0 then
			nvx = nvx/norm
			nvy = nvy/norm
			nvz = nvz/norm
		end
		return nvx, nvy, nvz
	end

	function table.copy(t)
	  local t2 = {}
	  for k,v in pairs(t) do
	    t2[k] = v
	  end
	  return t2
	end

	sortDistance=function(a,b)
		ret, dist = simCheckDistance(object, a, 0)
		if ret == 1 then
			dA = dist[7]
		else
			dA = 0
		end
		ret, dist = simCheckDistance(object, b, 0)
		if ret == 1 then
			dB = dist[7]
		else
			dB = 0
		end
		return dA < dB
	end

  function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
  end
  
	objectsSet=function()
		local object = simGetObjectAssociatedWithScript(sim_handle_self)
		simAddObjectToSelection(sim_handle_all,-1)
		local modelObjects = simGetObjectSelection()
		while modelObjects == nil do
  		simRemoveObjectFromSelection(sim_handle_all,-1)
  		modelObjects=simGetObjectSelection()
	  end
	  simRemoveObjectFromSelection(sim_handle_all,-1)
		local objects={}
		local humans={}
		local items={}
		local explorers={}
		local floor = nil
		local server = nil
		for i=1,#modelObjects,1 do
			local objectI = modelObjects[i]
			local typeI=simGetObjectType(objectI)
			local nameI=simGetObjectName(objectI)
			--floor
			if string.find(nameI, "floor$")~=nil  then --'floor'
				floor=modelObjects[i]
			end
			--humans
			if string.find(nameI, 'Bill#*%d*$')~=nil and object~=objectI then
			   --[[
  		  local base = simGetObjectHandle(string.gsub(nameI,'Bill','Bill_base'))
        if base ~= -1 then
          objectI =  base
        end
        --]]
				table.insert(humans, objectI)
				table.insert(objects, objectI)
      end
			--items
			if string.find(nameI, 'Obj')~=nil or string.find(nameI, 'Cuboid')~=nil then
				table.insert(items, objectI)
				table.insert(objects, objectI)
			end
			if string.find(nameI, "Server$")~=nil  then --'floor'
				server=modelObjects[i]
			end
			if string.find(nameI, 'Explorer#*%d*$')~=nil and object~=objectI then
        table.insert(explorers, objectI)
        table.insert(objects, objectI)
      end
		end
		return object, objects, humans, items, floor, server, explorers
	end
end
