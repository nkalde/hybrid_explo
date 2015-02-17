dofile(os.getenv('PWD')..'/Core/navigation/navigator/SFMImpl.lua')

------------
--TELEPORT--
------------

--teleportation to coordinates
teleportTo=function(gT,modelHandle) 
  simSetObjectPosition(modelHandle,-1,gT)
end

---------------
--TRANSLATE--
---------------

--position update towards target
linearTo=function(gT, modelHandle)
  local a=simGetObjectPosition(modelHandle,-1)
  local b=gT
  local abL=distanceEuclid(b,a)
  if abL > 0 then
    local d=simGetSimulationTimeStep()*nominalVelocity
    local k=d/abL
    local ab={b[1]-a[1],b[2]-a[2]}
    a = {a[1]+k*ab[1],a[2]+k*ab[2],a[3]}
    simSetObjectPosition(modelHandle,-1,a)
  end
end

----------
--ROTATE--
----------

--orientation update towards target
angularTo=function(gT, modelHandle)
  local a=simGetObjectPosition(modelHandle,-1)
  local b=gT
  local ab={(b[1]-a[1]),(b[2]-a[2])}
  local orientation = math.atan2(ab[2],ab[1])
  simSetObjectOrientation(modelHandle,-1,{0,0,orientation})
end

------------------------
--TRANSLATE AND ROTATE--
------------------------

--position and orientation update towards target
linearAndAngularTo=function(gT, modelHandle) 
  angularTo(gT,modelHandle)
  linearTo(gT,modelHandle)
end