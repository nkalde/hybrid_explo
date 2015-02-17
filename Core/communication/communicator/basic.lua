dofile(os.getenv('PWD')..'/Core/communication/communicator/basic_signal.lua')
dofile(os.getenv('PWD')..'/Core/communication/communicator/basic_tube.lua')
dofile(os.getenv('PWD')..'/Core/communication/communicator/basic_wifi.lua')

------------------
--basic_wifi.lua--
------------------
--radiusC radius diffusion client
--radiusS radius diffusion server
--radiusM radius diffusion client for visualization
--centralizedMerging merging maps on server or locally

--------------------
--INITIALIZING MAP--
--------------------

initRMap=function()
	local rMap = {}
	for i=1,(maxX-minX)/coef do
		rMap[i]= {}
		for j=1,(maxX-minX)/coef do
			rMap[i][j] = 1
		end
	end
	return rMap
end

----------------
--UPDATING MAP--
----------------

mergeMaps=function(mapT_1, mapT)
  if mapT_1 == nil then
	end
	if mapT == nil then
		return mapT_1, {}
	end
	local mergedMapAll = {}
	for i=1,#mapT_1 do
		mergedMapAll[i] = {}
		for j=1,#mapT_1[i] do
			local cT_1 = mapT_1[i][j]
			local cT = mapT[i][j]
			mergedMapAll[i][j] = cT_1
			if cT==fre or cT==ani or cT==occ then --full transition
				mergedMapAll[i][j] = cT
			end
			if cT==unk then 
				mergedMapAll[i][j] = cT_1 --'?' no return to unknown
			end
			if cT_1==ani and cT==fre then --keep human traces ????
				mergedMapAll[i][j] = cT_1
			end
		end
	end
	return mergedMapAll
end

--a/b map known in a and unknown in b
diffMap=function(a,b)
	local dMap = {}
	if b == nil then
		for i=1,#a do
			dMap[i] = {}
			for j=1,#a[i] do
				dMap[i][j] = a[i][j]
			end
		end
		return dMap
	else
		for i=1,#a do
			dMap[i] = {}
			for j=1,#a[i] do
				dMap[i][j] = 1
				local cA = a[i][j]
				local cB = b[i][j]
				if cA ~= unk and cB == unk then --compute and store differences
					dMap[i][j] = cA
				end
			end
		end
		return dMap
	end
end

--a+b map known in a and b (t, t+1)
addMap=function(a,b)
	local mergedMaps = {}
	for i=1,#a do
		mergedMaps[i] = {}
		for j=1,#a[i] do
			mergedMaps[i][j] = a[i][j]
			local cA = a[i][j]
			local cB = a[i][j]
			if b ~= nil then
			 cB = b[i][j]     
      end
      mergedMaps[i][j] = math.max(cA,cB)
--      if cA==unk or cB==unk then --one unknown
--        mergedMaps[i][j] = math.max(cA,cB)
--      end
--      if cA~=unk and cB~=unk then --no unknown take the new one
----        local rand = math.random(0,1) --or random
----        if rand == 0 then
----          mergedMaps[i][j] = cB
----        else
----          mergedMaps[i][j] = cA
----        end     
--         mergedMaps[i][j] = cB
--      end
	 end
	end
	return mergedMaps
end

----------------
--PACKING DATA--
----------------

packMapAll=function(mapAll)	
	--select the known cells into a list
	local knownList = {}
	for i=1,#mapAll do
	 for j=1,#mapAll[i] do
	   local val = mapAll[i][j]
	   if val ~= 1 then
      knownList[#knownList+1] = i
      knownList[#knownList+1] = j
      knownList[#knownList+1] = val
	   end
	 end
	end
	--pack the known cells list
	return simPackInts(knownList)
end

packMapAll2=function(mapAll) 
  --select the known cells into a list
  local knownList = {}
  for i=1,#mapAll do
   for j=1,#mapAll[i] do
     local val = mapAll[i][j]
      knownList[#knownList+1] = i
      knownList[#knownList+1] = j
      knownList[#knownList+1] = val
   end
  end
  --pack the known cells list
  return simPackInts(knownList)
end

unpackMapAll=function(data)
  local unpackedInts = simUnpackInts(data)
  local unpackedMap = initRMap()
  for i=1, #unpackedInts,3 do
    local a,b,val = unpackedInts[i], unpackedInts[i+1], unpackedInts[i+2]
    unpackedMap[a][b] = val
  end
  return unpackedMap
  --[[
	local unpackedInts = simUnpackInts(data)
	local unpackedMapAll = {}
	for i=1,(maxX-minX)/coef do
		unpackedMapAll[i] = {}
		for j=1,(maxX-minX)/coef do
			unpackedMapAll[i][j] = unpackedInts[(i-1)*(maxX-minX)/coef+j]
		end
	end
	return unpackedMapAll
--]]
end

merges = {[true] = 'centralized',[false] = 'decentralized'}
