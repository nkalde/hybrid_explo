openTube=function(size)
	local tubeHandle = simTubeOpen(0,'map',size,false)
	return tubeHandle
end

readMap=function(tubeHandle)
	local packedMap = simTubeRead(tubeHandle, false)
	if (packedMap) then
		unpackedMap = unpackMapAll(packedMap)
	end
	if (unpackedMap) then
		return unpackedMap
	else
		return nil
	end
end

writeMap=function(tubeHandle, unpackedMap)
	local packedMap = packMapAll(unpackedMap)
	local result = simTubeWrite(tubeHandle, packedMap)
	return result
end

closeTube=function(tubeHandle)
	local result = simTubeClose(tubeHandle)
	return result
end