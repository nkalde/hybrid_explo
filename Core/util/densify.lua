modelDir=os.getenv('PWD')..'/Core/util/models/'

densify=function(ratioHuman, numberExplorers)
  local coefTmp = coef
  coef = 1
  local positions, cnt = occupiedCells()
  local handles = {}
  local rand = ((maxX-minX)*(maxY-minY)-cnt-numberExplorers)*ratio
  
  for i=1,numberExplorers do
    simLoadModel(modelDir..'explorer.ttm')
    local handle = simGetObjectLastSelection()
    simSetObjectParent(handle,server,true)
    table.insert(handles,#handles+1,handle)
  end
  
  for i=1,rand do
    simLoadModel(modelDir..'human0_1.ttm')
    local handle = simGetObjectLastSelection()
    table.insert(handles,#handles+1,handle)
  end
  
  for i=1,#handles do
    local randI = math.random(1,maxX-minX-1)
    local randJ = math.random(1,maxY-minY-1)
    local ended = false
    while not ended do
      randI = math.random(1,maxX-minX-1)
      randJ = math.random(1,maxY-minY-1)
      ended = positions[randI..'#'..randJ] == nil
      if ended then
        positions[randI..'#'..randJ] = true
      end
    end
    local randX, randY = mappingGrid2World(randI,randJ)
    local pos = simGetObjectPosition(handles[i],-1)
    simSetObjectPosition(handles[i],-1,{randX,randY, pos[3]})
  end
  coef = coefTmp
  return handles
end

densifyUFS=function(ratioH)
  if ratioH > 0 then
    local coefTmp = coef
    coef = 1
    local positions, cntObs = occupiedCells()
    local handles = {}
    local totCells = (maxX-minX)*(maxY-minY)
    local freeCells = (totCells-cntObs)
    local nbHumansFreeSpace = math.floor(freeCells*ratioH)
    --print('freeCells/totCells',freeCells..'/'..totCells,'ratioH',ratioH,'nbHumans'..nbHumansFreeSpace)
    
    simRemoveObjectFromSelection(sim_handle_all,-1)
    simLoadModel(modelDir..'human0_1.ttm')
    table.insert(handles,#handles+1,simGetObjectSelection()[1])
    for i=2,nbHumansFreeSpace do
      simCopyPasteSelectedObjects()
      table.insert(handles,#handles+1,simGetObjectSelection()[1])
    end
    
    local nbHumans = 1
    local cellsSpan = math.floor(freeCells/nbHumansFreeSpace)
    local minI, minJ = mappingWorld2Grid(minX,minY)
    local maxI, maxJ = mappingWorld2Grid(maxX,maxY)
    local cnt=0

    --print('freecells',freeCells)
    --print('nbHumans',nbHumansFreeSpace)
    --print('minX : '..minX, 'minY : '..minY, 'maxX : '..maxX, 'maxY : '..maxY)
    --print('minI : '..minI, 'minJ : '..minJ, 'maxI : '..maxI, 'maxJ : '..maxJ)
    --print('span : '..cellsSpan)
    for i=minI, maxI do
      for j=minJ, maxJ do
        if positions[i..'#'..j] == nil and nbHumans <= nbHumansFreeSpace then
            if cnt%cellsSpan == 0 then
              positions[i..'#'..j] = true
              local x, y = mappingGrid2World(i,j)
              local pos = simGetObjectPosition(handles[nbHumans],-1)
              simSetObjectPosition(handles[nbHumans],-1,{x,y, pos[3]})
              nbHumans = nbHumans+1
            end
            cnt = cnt+1
        end
      end
    end
    coef = coefTmp
    simRemoveObjectFromSelection(sim_handle_all,-1)
    for i=nbHumans,#handles do
      simAddObjectToSelection(sim_handle_single,handles[i])
    end
    simDeleteSelectedObjects()
    simRemoveObjectFromSelection(sim_handle_all,-1)
    
    return handles
  end
  return {}
end