-- translated near verbatim from http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
--http://www.dreamincode.net/forums/topic/184338-lua-munkreshungarian-algorithm/page__st__15

function showMatrix(mat)
  print()
  for kRow, row in pairs(mat) do
    local line = ""
    for k, v in pairs(row) do
      line = line .. v .. " "
    end
    print(line)
  end
  print()
  return mat
end

function showArray(a)
  local line = ""
  for i=1,#a do
    local v = a[i]
    if i>1 then line = line .. ", " end
    line = line .. v
  end
  --print("{ "..line.." }")
  return a
end


function munkres(costMat)
  local function initMatrix(costMat)
    local m = {
      size = #costMat,
      cost = costMat,
      mask = {},
      rowCover = {},
      colCover = {},
      step = 1,
      Z0 = { row=0, col=0 }
    }
    
    for i=1,#costMat do
      local v = costMat[i]
      if #v ~= m.size then return nil end
      m.rowCover[i] = 0
      m.colCover[i] = 0
      m.mask[i] = {}
      for j = 1,m.size do
        m.mask[i][j] = 0
      end
    end
    return m
  end

  local steps = {
    [1] = function(m)
      local minval;
      for i = 1,m.size do
        minval = m.cost[i][1]
        for j = 2,m.size do
          if m.cost[i][j] < minval  then 
            minval = m.cost[i][j]
          end
        end

        for j = 1,m.size do
          m.cost[i][j] = m.cost[i][j] - minval
        end
      end
      m.step = 2
    end,
    
    [2] = function(m)
      for i = 1,m.size do
        for j = 1,m.size do
          if m.cost[i][j]==0 and m.colCover[j]==0 and m.rowCover[i]==0 then
            m.mask[i][j] = 1
            m.colCover[j] = 1
            m.rowCover[i] = 1
          end
        end
      end
      
      for i = 1,m.size do
        m.colCover[i] = 0
        m.rowCover[i] = 0
      end
      m.step = 3
    end,
    
    [3] = function(m)
      for i = 1,m.size do
        for j = 1,m.size do
          if m.mask[i][j] == 1 then
            m.colCover[j] = 1
          end
        end
      end
      local count = 0
      for j = 1,m.size do
        count = count + m.colCover[j]
      end
      
      if count>=m.size then 
        m.step = 7
      else
        m.step = 4
      end
    end,

    [4] = function(m)
      local function find_a_zero(m)
        for i = 1, m.size do
          for j = 1, m.size do
            if m.cost[i][j]==0 and m.colCover[j]==0 and m.rowCover[i]==0 then
              return i, j
            end
          end
        end
        return 0, 0
      end

      local function find_star_in_row(m, row)
        for j = 1, m.size do
          if m.mask[row][j]==1 then
            return j
          end
        end
        return 0
      end
      
      while true do -- this has the potential to never end
        local row, col = find_a_zero(m)
        if row==0 then
          m.step = 6
          return
        end
        
        m.mask[row][col] = 2
        local starCol = find_star_in_row(m, row)
        if starCol==0 then
          m.Z0.row = row
          m.Z0.col = col
          m.step = 5
          return
        else
          m.rowCover[row] = 1
          m.colCover[col] = 0 
        end
      end
    end,
      
    [5] = function(m)
      
      local function find_star_in_col(m, col)
        for i = 1, m.size do
          if m.mask[i][col]==1 then
            return i
          end
        end
        return 0
      end
        
      local function find_prime_in_row(m, row)
        for j = 1, m.size do
          if m.mask[row][j]==2 then
            return j
          end
        end
        return 0
      end
      
      local function convert_path(m, count, path)
        for i = 1, count do
          local pt = path[i]
          if m.mask[pt.row][pt.col] == 1 then
            m.mask[pt.row][pt.col] = 0
          else
            m.mask[pt.row][pt.col] = 1
          end
        end
      end

      local function clear_covers(m)
        for i = 1,m.size do
          m.colCover[i] = 0
          m.rowCover[i] = 0
        end
      end
      
      local function erase_primes(m)
        for i = 1, m.size do
          for j = 1, m.size do
            if m.mask[i][j]==2 then
              m.mask[i][j] = 0
            end
          end
        end
      end
        
      local count = 1
      local path = { m.Z0 }
      while true do
        local r = find_star_in_col(m, path[count].col)
        if r>0 then 
          count = count + 1
          path[count].row = r
          path[count].col = path[count-1].col
        else 
          break
        end

        local c = find_prime_in_row(m, path[count].row); 
        count = count + 1
        path[count].row = path[count-1].row
        path[count].col = c
      end
      
      convert_path(m, count, path)
      erase_primes(m)
      m.step = 3
    end,
  
    [6] = function(m)
      local function find_smallest(m)
        local minval = nil
        for i = 1, m.size do
          for j = 1, m.size do
            if m.colCover[j]==0 and m.rowCover[i]==0 then
              if minval==nil or minval > m.cost[i][j] then
                minval = m.cost[i][j]
              end
            end
          end
        end
        return minval
      end
      
      local minval = find_smallest(m)
      for i = 1, m.size do
        for j = 1, m.size do
          if m.rowCover[i]==1 then
            m.cost[i][j] = m.cost[i][j] + minval
          end
          if m.colCover[j]==0 then 
            m.cost[i][j] = m.cost[i][j] - minval
          end
        end
      end
      m.step = 4
    end,
    }
    
  local function getAssignments(m)
    local a = {}
    for i = 1,m.size do
      for j = 1,m.size do
        if m.mask[i][j] == 1 then
          a[i] = j
          break
        end
      end
    end
    return a
  end
    
  showMatrix(costMat)
  
  local mat =  initMatrix(costMat)
  if mat == nil then
    print("invalid matrix argument")
    return nil
  end
  
  local stepCount = 0
  while mat.step < 7 do
    steps[mat.step](mat)
    stepCount = stepCount + 1
    if (stepCount>100) then
      --print("stepCount = ".. stepCount)
      print("too many steps")
      return nil
    end
  end
  --print("stepCount = ".. stepCount)
  return showArray(getAssignments(mat))
end


function test()
  -- munkres( { {1,2,3,4},{2,4,6,8},{3,6,9,12},{4,8,12,16} } )
  --[[
  munkres( {
{2,2,3,7,8,1,3,4,2,5,6,9},
{1,1,2,6,7,0,2,3,2,4,5,8},
{0,1,1,5,6,1,2,3,3,4,5,7},
{1,2,0,4,5,2,1,2,4,3,4,6},
{2,3,1,4,5,2,0,1,4,2,3,6},
{3,4,2,3,4,3,1,0,5,1,2,5},
{5,6,4,0,1,6,4,3,8,2,1,2},
{6,7,5,1,0,7,5,4,9,3,2,1},
{4,5,3,2,3,4,2,1,6,0,1,4},
{5,6,4,1,2,5,3,2,7,1,0,3},
{2,1,3,7,8,2,4,5,1,6,7,9},
{0,0,0,0,0,0,0,0,0,0,0,0}
} )
  --]]
  
end

test()

