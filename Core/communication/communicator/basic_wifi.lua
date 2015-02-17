--SERVER
simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,false)
simSetBooleanParameter(sim_boolparam_force_show_wireless_emission,false)
readMapFromClient=function(receiver)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,true)
	local packedMap, targetHandle = simReceiveData(0, "clientmap",receiver)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,false)
	if (packedMap) then
		unpackedMap = unpackMapAll(packedMap)
	end
	if (unpackedMap) then
		return unpackedMap, targetHandle
	else
		return nil
	end
end

readMapFromClientMonitoring=function(receiver)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,true)	
	local packedMap = simReceiveData(0, "monitoringmap", receiver)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,false)
	if (packedMap) then
		unpackedMap = unpackMapAll(packedMap)
	end
	if (unpackedMap) then
		return unpackedMap
	else
		return nil
	end
end

writeMapToClient=function(source, goal, unpackedMap)
	if not centralizedMerging then --centralized : send a merged map to the clients
		return nil
	else
		local packedMap = packMapAll(unpackedMap)
    if #packedMap ~= 0 then
		  --simSetBooleanParameter(sim_boolparam_force_show_wireless_emission,true)
      local result = simSendData(goal, 1, "servermap", packedMap,source,radiusS,3.1415,6.283,10.0*simGetSimulationTimeStep())--*#explorers*1000)
		  --simSetBooleanParameter(sim_boolparam_force_show_wireless_emission,false)
		  return result
    end
	end
end

--CLIENT
readMapFromServer=function(receiver)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,true)
	local packedMap = nil
	if not centralizedMerging then
		packedMap, senderID = simReceiveData(1, "map", receiver)
	else
		packedMap, senderID = simReceiveData(1, "servermap", receiver)
	end
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_reception,false)
	if (packedMap) then
		unpackedMap = unpackMapAll(packedMap)
	end
	if (unpackedMap) then
		return unpackedMap, senderID
	else
		return nil
	end
end

writeMapToServer=function(source, goal, unpackedMap)
	local packedMap = packMapAll(unpackedMap)
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_emission,true)
	local result = -1
  if #packedMap ~= 0 then
    if centralizedMerging then
      result = simSendData(goal, 0, "clientmap", packedMap,source,radiusC,3.1415,6.283,10.0*simGetSimulationTimeStep())--simGetSimulationTimeStep()*#explorers)
    end
    if monitoringEnabled then
      result = simSendData(goal, 0, "monitoringmap", packedMap,source,radiusC,math.pi,2*math.pi,10.0*simGetSimulationTimeStep())
    end
  end
	if not centralizedMerging then
    if #packedMap ~= 0 then 
		  result = simSendData(sim_handle_all, 1, "map", packedMap,source,radiusC)
    end
	end
	--simSetBooleanParameter(sim_boolparam_force_show_wireless_emission,false)
	
	return result
end