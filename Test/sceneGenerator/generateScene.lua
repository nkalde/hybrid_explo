package.path = package.path .. ";" .. os.getenv('PWD')..'/Test/sceneGenerator/lua-imlib2-0.1/?.lua' 
package.cpath = package.cpath .. ";" ..  os.getenv('PWD').."/Test/sceneGenerator/lua-imlib2-0.1/?.so"
--print(package.path)
local imlib2 = require("imlib2")
--local profiler = require("profiler")

--1px 1cm
loadMap=function(path)
  mName = mapName(path)
  print(mName)
  img = imlib2.image.load(path)
  wP = img:get_width()
  hP = img:get_height()
  zM = 0.5
  res = 1

  if (mName=='SFU_1200x615.png') then
    res = 0.05
  end
  if (mName=='cave_compact.png')
    or (mName=='rink.png') 
    or (mName=='simple_rooms.png') 
    or (mName=='submarine_small.png')
    or (mName=='submarine.png')
    or (mName=='table.png') then
    hM = 10
    res = hM/hP
  end
  if (mName=='mbicp.png')   or (mName=='SRI-AIC-kwing.png') then
    hM = 20
    res = hM/hP
  end
  if (mName=='autolab.png')
    or (mName=='cave.png') 
    or (mName=='cave_filled.png')
    or (mName=='hospital_section.png') 
    or (mName=='hospital.png') 
    or (mName=='space_invader.png') 
    or (mName=='ghost.png') 
    or (mName=='SFU_800x600.png') 
    or (mName=='human_outline.png')
    or (mName=='uoa_robotics_lab.png') then
      res = 0.02
  end
  
  wM = res*wP
  hM = res*hP
  p2m =res
  m2p=1/res

  --print('px :'..wP..'X'..hP)
  --print('1px = '..res..'m')
  --print('m :'..wM..'X'..hM..'X'..zM)  
  
  blackPxs()
  local handles = generate(img,p2m)
  local gHandle = setFloor()
  handles[#handles+1] = gHandle
  return handles
end

setFloor=function()
  local lhandle = {}
  for i=0,math.ceil(wM),1 do
    for j=0,math.ceil(hM),1 do
      local floor_tile = simCreatePureShape(0,bCode,{1,1,0.00000018},0,nil)
      lhandle[#lhandle+1] = floor_tile
      simSetObjectPosition(floor_tile,-1,{i-wM/2,j-hM/2,0.00000015})
    end
  end
  local gHandle = simGroupShapes(lhandle)
  simSetObjectName(gHandle,'floor')
  simSetShapeColor(gHandle,nil,0,floor_color)
  return gHandle
end

blackPxs=function()
  local pix = nil
  local key = nil
  local val = 0
  setBlackPxs={}
  for i=0,wP-1,1 do
    for j=0,hP-1,1 do
      pix = img:get_pixel(i,j)
      key = i..'#'..j
      setBlackPxs[key] = pix.red == val and pix.blue == val and pix.red == val and pix.alpha == 255
    end
  end
end

--image -> cuboids
cuboids=function()
  local lhandle = {}
  for i=0,wP-1,jump do
    for j=0,hP-1,jump do
      if blackPx(i,j) then
        local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*p2m,1},0,nil)
        lhandle[#lhandle+1] = handle
        simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2,0.5})
      end
    end
  end
  simSetShapeColor(sim_handle_all,nil,0,object_color)
  return lhandle
end

--image -> lines -> create shape
linoids=function()
  local lhandle = {}
  local cntLines = 0
  for i=0,wP-1,jump do
    local j = 0
    while j < hP do
      local size = 0
      local black = blackPx(i,j)
      while black and j < hP do
        j = j+jump
        black = blackPx(i,j)
        size = size+1
        key = i..'#'..j
      end
      if size > 0 then
        cntLines = cntLines +1
        --local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*size*p2m,1},0,nil)
        --simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2-size*p2m/2,0.5})
      end
      j = j+jump
    end
  end

  local cntCols = 0
  for j=0,hP-1,jump do
    local i = 0
    while i < wP do
      local size = 0
      local black = blackPx(i,j)
      while black and i < wP do
        i = i+jump
        black = blackPx(i,j)
        size = size+1
        key = i..'#'..j
      end
      if size > 0 then
        cntCols = cntCols+1
        --local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*size*p2m,1},0,nil)
        --simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2-size*p2m/2,0.5})
      end
      i = i+jump
    end
  end

  if cntLines <= cntCols then
    for i=0,wP-1,jump do
      local j = 0
      while j < hP do
        local size = 0
        local black = blackPx(i,j)
        while black and j < hP do
          j = j+jump
          black = blackPx(i,j)
          size = size+1
          key = i..'#'..j
        end
        if size > 0 then
          local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*size*p2m,1},0,nil)
          lhandle[#lhandle+1] = handle
          simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2-size*p2m/2,0.5})
        end
        j = j+jump
      end
    end
  else
    for j=0,hP-1,jump do
      local i = 0
      while i < wP do
        local size = 0
        local black = blackPx(i,j)
        while black and i < wP do
          i = i+jump
          black = blackPx(i,j)
          size = size+1
          key = i..'#'..j
        end
        if size > 0 then
          local handle = simCreatePureShape(0,bCode,{size*jump*p2m,jump*p2m,1},0,nil)
          lhandle[#lhandle+1] = handle
          simSetObjectPosition(handle,-1,{i*p2m-wM/2-size*p2m/2,j*p2m-hM/2,0.5})
        end
        i = i+jump
      end
    end
  end
  simSetShapeColor(sim_handle_all,nil,0,object_color)
  return lhandle
end

groupL=function(list,set)
  local lhandle = {}
  local cntLines = 0
  local cntCols = 0
  for j=0,hP-1,jump do
    local i = 0
    while i < wP do
      local key = i..'#'..j
      local size = 0
      while i < wP and set[key] == true do
        i = i+jump
        size = size+1
        key = i..'#'..j
      end
      if size > 0 then
        cntLines = cntLines + 1
        --local handle = simCreatePureShape(0,bCode,{jump*p2m*size,jump*p2m,1},0,nil)
        --simSetObjectPosition(handle,-1,{i*p2m-wM/2-size*p2m/2,j*p2m-hM/2,0.5})
        --lhandle[#lhandle+1] = handle
      end
      i = i+jump
    end
  end

  for i=0,wP-1,jump do
    local j = 0
    while j < hP do --
      local key = i..'#'..j
      local size = 0
      while j < hP and set[key] == true do
        j = j+jump
        size = size+1
        key = i..'#'..j
      end
      if size > 0 then
        cntCols = cntCols + 1
        --local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*p2m*size,1},0,nil)
        --simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2-size*p2m/2,0.5})
        --lhandle[#lhandle+1] = handle
      end
      j = j+jump
    end
  end

  if cntLines <= cntCols then
    for j=0,hP-1,jump do
      local i = 0
      while i < wP do
        local key = i..'#'..j
        local size = 0
        while i < wP and set[key] == true do
          i = i+jump
          size = size+1
          key = i..'#'..j
        end
        if size > 0 then
          local handle = simCreatePureShape(0,bCode,{jump*p2m*size,jump*p2m,1},0,nil)
          simSetObjectPosition(handle,-1,{i*p2m-wM/2-size*p2m/2,j*p2m-hM/2,0.5})
          lhandle[#lhandle+1] = handle
        end
        i = i+jump
      end
    end
  else
    for i=0,wP-1,jump do
      local j = 0
      while j < hP do --
        local key = i..'#'..j
        local size = 0
        while j < hP and set[key] == true do
          j = j+jump
          size = size+1
          key = i..'#'..j
        end
        if size > 0 then
          local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*p2m*size,1},0,nil)
          simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2-size*p2m/2,0.5})
          lhandle[#lhandle+1] = handle
        end
        j = j+jump
      end
    end
  end
  return lhandle
end

createShapes=function(list)
  local lhandle = {}
  for a=1,#list,jump do
      local i,j = list[a][1], list[a][2]
      local handle = simCreatePureShape(0,bCode,{jump*p2m,jump*p2m,1},0,nil)
      simSetObjectPosition(handle,-1,{i*p2m-wM/2,j*p2m-hM/2,0.5})
      lhandle[#lhandle+1] = handle      
  end
  return lhandle
end

--image-> components -> lines or shape
componentsLC=function()
  local lhandles = {}
  local lists, sets= findComponents()

  for i = 1,#lists,1 do
    --local lhandle = createShapes(lists[i])
    local lhandle = groupL(lists[i],sets[i])
    if #lhandle > 1 then
      local gHandle = simGroupShapes(lhandle)
      lhandles[#lhandes+1] = gHandle
      --simConvexDecompose(gHandle,1+4+32+64,{1,500,8,0},{0,1,0.5})
    end
  end
  simSetShapeColor(sim_handle_all,nil,0,object_color)
  return lhandles
end

--image -> boundaries -> components -> lines or shape
boundaries2componentsLC=function()
  local lhandles = {}
  local boundariesL, boundariesS = findBoundaries1()
  local lists,sets = findComponentsFromList(boundariesL, boundariesS)

  for i = 1,#lists,1 do
    --local lhandle = createShapes(lists[i])
    local lhandle = groupL(lists[i],sets[i])
    if #lhandle > 1 then
      local gHandle = simGroupShapes(lhandle)
      lhandles[#lhandes+1] = gHandle
    end
  end
  simSetShapeColor(sim_handle_all,nil,0,object_color)
  return lhandles
end

--img -> boundaries
findBoundaries1=function()
  local boundaries = {}
  local boundariesSet = {}
  for i=0,wP-1,1 do
    for j=0,hP-1,1 do
      if blackPx(i,j) then
        local n = neighborsF(i,j)
        local res = false
        local k = 1
        while k<= #n and not res do
          if n[k]~=-1 then
            local c,d = n[k][1], n[k][2]
            res = blackPx(i,j) and not blackPx(c,d) 
          else
            res = true
          end
          k=k+1
        end
        if res then
          local key = i..'#'..j
          boundaries[#boundaries+1] = {i,j}
          boundariesSet[key] = true
        end
      end
      
    end
  end
  return boundaries, boundariesSet
end

--find component from a set a set and a list
findComponentsFromList=function(bList,bSet)
  local sets= {}
  local set = {}
  local lists = {}
  for i=1,#bList,1 do
    local a,b = bList[i][1], bList[i][2] 
    local key = a..'#'..b
    if set[key] == nil then
      if blackPx(a,b) then
        lists[#lists+1] = {}
        sets[#sets+1] = {}
        local l = lists[#lists]
        local s = {}
        l[#l+1] = {a,b}
        set[key] = true
        set, l = findSamePixFromList(a,b,set,l,bSet)
        for m=1,#l,1 do
          local c,d = l[m][1], l[m][2]
          local key = c..'#'..d
          s[key]= true
        end
        sets[#sets] = s
      end
    end
  end
  return lists, sets
end

findSamePixFromList=function(i,j,set,list,bSet)
  local first = 1
  local last = 1
  local key = i..'#'..j
  while(first <= last) do
    local i,j = list[first][1], list[first][2]
    local n = neighborsF(i,j)
    for k=1,#n,1 do
      if n[k]~= -1 then
        local a = n[k][1]
        local b = n[k][2]
        local key = a..'#'..b
        if bSet[key] ~= nil then
          if set[key] == nil then
            --local pix2 = img:get_pixel(a,b)
            --local pix = img:get_pixel(i,j)
            --if  pix.red == pix2.red and pix.blue == pix2.blue and pix.red == pix2.red and pix.alpha == pix2.alpha then
            if blackPx(a,b) == blackPx(i,j) then
              list[#list+1] = {a,b}
              last = last + 1
              set[key] = true
            end
          end
        end
      end
    end
    first =  first + 1
  end
  return set, list
end

--find component from an image
findComponents=function()
  local set = {}
  local sets = {}
  local lists = {}
  for i=0,wP-1,1 do
    for j=0,hP-1,1 do
      local key = i..'#'..j
      if set[key] == nil then
        if blackPx(i,j) then
          lists[#lists+1] = {}
          sets[#sets+1] = {}
          local a = lists[#lists]
          local s = sets[#sets]
          a[#a+1] = {i,j}
          set[key] = true
          set, a = findSamePix(i,j,set,a)
          for m=1,#a,1 do
            local c,d = a[m][1], a[m][2]
            local key = c..'#'..d
            s[key]= true
          end
          sets[#sets] = s
        end
      end
    end
  end
  return lists, sets
end

--not recursive
findSamePix=function(i,j,set,list)
  local first = 1
  local last = 1
  local key = i..'#'..j
  while(first <= last) do
    local i,j = list[first][1], list[first][2]
    local n = neighborsF(i,j)
    for k=1,#n,1 do
      if n[k]~= -1 then
        local a = n[k][1]
        local b = n[k][2]
        local key = a..'#'..b
        if set[key] == nil then
          --local pix2 = img:get_pixel(a,b)
          --local pix = img:get_pixel(i,j)
          --if  pix.red == pix2.red and pix.blue == pix2.blue and pix.red == pix2.red and pix.alpha == pix2.alpha then
          if blackPx(a,b) == blackPx(i,j) then
            list[#list+1] = {a,b}
            last = last + 1
            set[key] = true
          end
        end
      end
    end
    first =  first + 1
  end
  return set, list
end

neighborsVN=function(i,j)
  local n1 = -1
  local n2 = -1
  local n3 = -1
  local n4 = -1
  if i>= 0 and i < wP and j-1>=0 and j-1 < hP then
    n1 = {i,j-1}
  end
  if i+1>= 0 and i+1 < wP and j>=0 and j < hP then
    n2 = {i+1,j}
  end
  if i>= 0 and i < wP and j+1>=0 and j+1< hP then
    n3 = {i,j+1}
  end
  if i-1>= 0 and i-1 < wP and j>=0 and j< hP then
    n4 = {i-1,j}
  end
  return {n1,n2,n3,n4}
end

neighborsM=function(i,j)
  local n1 = -1
  local n2 = -1
  local n3 = -1
  local n4 = -1
  local n5 = -1
  local n6 = -1
  local n7 = -1
  local n8 = -1

  if i>= 0 and i < wP and j-1>=0 and j-1 < hP then
    n1 = {i,j-1}
  end
  if i+1>= 0 and i+1 < wP and j>=0 and j < hP then
    n2 = {i+1,j}
  end
  if i>= 0 and i < wP and j+1>=0 and j+1< hP then
    n3 = {i,j+1}
  end
  if i-1>= 0 and i-1 < wP and j>=0 and j< hP then
    n4 = {i-1,j}
  end

  if i+1>= 0 and i+1 < wP and j-1>=0 and j-1 < hP then
    n5 = {i+1,j-1}
  end
  if i+1>= 0 and i+1 < wP and j+1>=0 and j+1 < hP then
    n6 = {i+1,j+1}
  end
  if i-1>= 0 and i-1 < wP and j+1>=0 and j+1< hP then
    n7 = {i-1,j+1}
  end
  if i-1>= 0 and i-1 < wP and j-1>=0 and j-1< hP then
    n8 = {i-1,j-1}
  end
  return {n1,n2,n3,n4,n5,n6,n7,n8}
end

blackPx=function(i,j)
  local key = i..'#'..j
  return setBlackPxs[key]
end

whitePx=function(i,j)
  return not blackPx(i,j)
end

mapName=function(path)
  local mName = path
  while string.find(mName,'/') ~= nil do
    a, b = string.find(mName,'/')
    mName = string.sub(mName,b+1)
  end
  return mName
end

if (simGetScriptExecutionCount()==0) then
  dofile(os.getenv('PWD')..'/Core/header.lua')
  targetDir=os.getenv('PWD')..'/Test/scenes'
  mapDir=os.getenv('PWD')..'/Test/scenes/bitmaps'
  bCode = 29+2
  jump = 1
  floor_color  = {104/255,105/255,127/255,1}
  object_color = {84/255,105/255,127/255,1}
  neighborsF=neighborsM
  generate=linoids
  
  neighborsFs={neighborsVN,neighborsM}
  neighs = {'neighborsVN', 'neighborsM'}
  functions={cuboids,linoids,componentsLC}
  funcs={'cuboids','linoids','componentsLC'}
  --cuboids(img,p2m)
  --linoids(img,p2m) --87
  --componentsLC(img,p2m)--66
  --boundaries2componentsLC(img,p2m) --69% --> 63
  --profiler.start('/Users/nkalde/Dropbox/Code/lua/log.txt')

  local fNames = {
  'SFU_1200x615.png',   --1 -- long
  'cave_compact.png',
  'rink.png',
  'simple_rooms.png',   --so
  'submarine_small.png',  --5 --not good
  'submarine.png',
  'table.png',
  'mbicp.png',
  'SRI-AIC-kwing.png',  --long
  'autolab.png',      --10
  'cave.png',
  'cave_filled.png',
  'hospital_section.png', --long
  'hospital.png',
  'space_invader.png',  --15
  'ghost.png',
  --'SFU_800x600.png',
  'human_outline.png',
  'uoa_robotics_lab.png', --18
  'high_res_obstacle_shadow.png',
'structured_small.png'
}
  --for i=1,#fNames,1 do
    i = 20
    --for j=1,#funcs,1 do
      j = 2
      --generate = funcs[j]
      --for k=1,#neighs,1 do
        k = 2 
        --neighborsF = neighs[k]
        
	print(i,j,k,fNames[i]);
	local handles = loadMap(mapDir..'/'..fNames[i])
        for m=1,#handles do
          simSetObjectSpecialProperty(handles[m],sim_objectspecialproperty_detectable_all)
        end
	
        simSaveScene(targetDir..'/'..fNames[i]..'_'..funcs[j]..'_'..neighs[k]..'.ttt')
        simRemoveObjectFromSelection(handles)
        --simLoadScene('/Users/nkalde/Dropbox/vrep_scenes/test/test_generate_copy.ttt')
      --end
    --end

  --profiler.stop()
end

if (simGetSimulationState()==sim_simulation_advancing_lastbeforestop) then
  --profiler.stop()
end
