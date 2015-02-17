readMapSignal=function(objects)  
  local packedMaps = {}
  local rMap = initRMap()
  if type(objects) == 'number' then
    objects = {objects}
  end
  for i=1,#objects do
    local signalNameI = 'map'..simGetObjectName(objects[i])
    packedMaps[i] = simGetStringSignal(signalNameI)
    if packedMaps[i] ~= nil then
      if #packedMaps[i] ~= 0 then
        local unpackedMap = unpackMapAll(packedMaps[i])
        if (unpackedMap) then
          rMap = addMap(rMap,unpackedMap)
        end
      end
    end  
  end
  return rMap
end

--object writes a string signal
writeMapSignal=function(unpackedMap,object)
  local packedMap = packMapAll(unpackedMap)
  local signalName = 'map'..simGetObjectName(object)
  simClearStringSignal(signalName)
  simSetStringSignal(signalName,packedMap)
end