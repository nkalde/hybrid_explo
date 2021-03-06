mapGrid2World = {}
mapWorld2Grid = {}

--mapping for vectors gg2w
  vectorGrid2World=function(vG)
    local vRes = {}
    for i=1, #vG, 1 do
      local vGi, vGj = mappingGrid2World(vG[i][1],vG[i][2])
      vRes[i]={vGi,vGj}
    end
    return vRes
  end

  --mapping for vectors w2gg
  vectorWorld2Grid=function(vW)
    local vRes = {}
    for i=1, #vW, 1 do
      local vWi, vWj = mappingWorld2Grid(vW[i][1],vW[i][2])
      vRes[i]={vWi,vWj}
    end
    return vRes
  end
  
  --mapping gradient grid to world coordinates
  mappingGrid2World=function(i,j)
    if mapGrid2World[i.."#"..j] == nil then
      --return minX+(i-1)*coef+coef/2, minY+(j-1)*coef+coef/2
      x = minX+(i-1)*coef+coef/2
      y = minY+(j-1)*coef+coef/2
    --print("minX minY",minX,minY)
    --print("i j",i,j,"->",x,y,"x y")
      mapGrid2World[i.."#"..j] = {x,y}
    end
    return mapGrid2World[i.."#"..j][1],mapGrid2World[i.."#"..j][2]
    --i+0.5*coef, j+0.5*coef, 
  end
  
  --mapping world coordinates to gradient grid
  mappingWorld2Grid=function(x,y)
    if mapWorld2Grid[x.."#"..y] == nil then
      local bSupX = coef
      local valX = 1
      while x-minX >= bSupX  and bSupX <= (maxX-minX)/coef do
        bSupX = bSupX + coef
        valX = valX + 1
      end
      local bSupY = coef
      local valY = 1
      while y-minY >= bSupY  and bSupY <= (maxY-minY)/coef do
        bSupY = bSupY + coef
        valY = valY + 1
      end
      mapWorld2Grid[x.."#"..y] = {math.max(math.min(valX,(maxX-minX)/coef),1), math.max(math.min(valY,(maxY-minY)/coef),1)}
    end
    return mapWorld2Grid[x.."#"..y][1],mapWorld2Grid[x.."#"..y][2]
  end

  --real world pose
  getPoseXY=function(obj)
    local pos = {0,0}
    if type(obj) == 'number' then
      pos = simGetObjectPosition(obj,-1)
      pos = {pos[1],pos[2]}
    end
    if type(obj) == 'table' then
      local a,b =obj[1],obj[2]
      local intA, decA = math.modf(a)
      local intB, decB = math.modf(b)
      if decA==0 or decB==0 then --integer
        a, b = mappingGrid2World(obj[1],obj[2])
        pos = {a,b}
      else
        pos = {a,b}
      end  
    end
    return pos
  end

  --grid pose
  getPoseIJ=function(obj)
    local pos = {0,0}
    if type(obj) == 'number' then
      pos = simGetObjectPosition(obj,-1)
      local a, b = mappingWorld2Grid(pos[1],pos[2])
      pos = {a,b}
    end
    if type(obj) == 'table' then
      local a,b = obj[1], obj[2]
      local intA, decA = math.modf(a)
      local intB, decB = math.modf(b)
      if decA==0 and decB==0 then
        pos = {a,b}
      else
        a, b = mappingWorld2Grid(a,b)
        pos = {a,b}
      end
    end
    return pos
  end