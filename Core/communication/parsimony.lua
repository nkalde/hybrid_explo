----------------
--NO PARSIMONY--
----------------

--sends client full knowledge
parsimonyNone_client=function(clientKnowledge, serverKnowledge)
  return mergeMaps(clientKnowledge,serverKnowledge)
end

--sends server full knowledge
parsimonyNone_server=function(serverKnowledge, clientKnowledge)
  return parsimonyNone_client(serverKnowledge,clientKnowledge)
end

--------------------
--SERVER PARSIMONY--
--------------------

--sends client substracted knowledge
parsimonyServer_server=function(serverKnowledge,clientKnowledge)  
    return diffMap(serverKnowledge, clientKnowledge)
end

--sends client full knowledge
parsimonyServer_client=function(clientKnowledge, serverKnowledge)
  return parsimonyNone_client(clientKnowledge, serverKnowledge)
end

--------------------
--CLIENT PARSIMONY--
--------------------

--sends server full knowledge
parsimonyClient_server=function(serverKnowledge,clientKnowledge)
  return mergeMaps(serverKnowledge, clientKnowledge)
end

--sends server substracted knowledge
parsimonyClient_client=function(clientKnowledge, serverKnowledge)
  return diffMap(clientKnowledge,serverKnowledge)
end

------------------
--FULL PARSIMONY--
------------------

--parsimony both sides
parsimonyBoth_server=function(serverKnowledge,clientKnowledge, senderID, readMap)
  if senderID  and senderID ~= sim_handle_self then
      if clientMaps[senderID] then
        clientMaps[senderID] = mergeMaps(clientMaps[senderID],readMap)
      else
        clientMaps[senderID] = mergeMaps(initRMap(),readMap)
      end
      local sentMap = diffMap(serverMap, clientMaps[senderID])
      clientMaps[senderID] = mergeMaps(clientMaps[senderID],sentMap)
      writeMapToClient(sim_handle_self, senderID, sentMap)
      return sentMap
  end
  return serverMap
end

parsimonyBoth_client=function(clientKnowledge, serverKnowledge)
  local sentMap = diffMap(clientKnowledge,serverKnowledge)
  serverMap = mergeMaps(serverKnowledge,clientKnowledge)
  exploGrid = mergeMaps(clientKnowledge,serverKnowledge)
  return sentMap
end

parsimonyFunctions={parsimonyNone_client, parsimonyServer_client, parsimonyClient_client, parsimonyBoth_client, parsimonyNone_server, parsimonyServer_server, parsimonyClient_client, parsimonyBoth_server}
parsimonyNames={'parsimonyNone', 'parsimonyServer', 'parsimonyClient', 'parsimonyBoth'}