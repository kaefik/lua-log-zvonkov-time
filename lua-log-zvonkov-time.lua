-- версия выгрузки лога звонков на Lua

-- входные параметры
local namef = "Report.csv"
local nameFlog = "list-num-tel.cfg"
-- END входные параметры

-- Функции
-- структура входящих данных
function createInputDataTel ()
  local value = {}
  value["datacall"]=""  -- время и дата звонка
  value["telsource"]="" -- источник звонка (кто звонил)
  value["secs"]=0       -- продолжительность в сек
  value["teldest"]=""   -- куда звонил источник
  return value
end

  -- структура справочника телефонов менеджеров
function createDataTelMans()
   local value = {}
   value["fio_rg"]=""            -- ФИО РГ
   value["fio_man"]=""            -- ФИО менеджера
   value["totalsec"]=0          --общая продолжительность звонков (в сек)
   value["kolunik"]=0           --кол-во уникальных телефонных номеров
   value["kolresult"]=0         --кол-во результативных звоноков
   value["secresult"]=0          --продолжительность результативных звонков (в сек)
   value["totalzv"]=0            -- общее кол-во звонков
   value["planresultkolzv"]=0   --плановое кол-во результативных звоноков
   value["kolunikresult"]=0      --кол-во уникальных результ. звонков
   value["plankolvstrech"]=0     -- плановое количество встреч
   return value
end

-- TODO: сделать функцию универсальную независимо от размерности таблицы (рекурсивная)
-- распечатка в консоли содержимое таблиц
function printTable (tbl)
  for k,v in pairs(tbl) do
    print(k,v)
  end
end
-- распечатка дыумерных  массивов
function printTable2Dim (tbl)
  for k,v in pairs(tbl) do
    print(k)
    printTable(v)
  end
end

-- разделение строки str по указанному символуsimbol
function splitString(str, simbol)
  local words = {}
  for w in str:gmatch("([^"..simbol.."]*)") do
    table.insert(words, w) end
  return words
end

-- открытие файла, возвращает таблицу с номерами строк, нумерация с 1
function readFile(namef)
  local file = io.open(namef, "r")
  local strnum = 1
  local res = {}
  local strline
  strline = file:read()
  while strline ~= nil do
    res[strnum] = strline
    strline = file:read()
    strnum = strnum + 1
  end
  file:close()
  return res
end

-- чтение конфиг файла со списками телефонов
function readCfgFile (namef)
  local str = readFile(namef)
  local  res = {}
  -- local strnum = 1
  for i=1,#str do
    local strline = splitString(str[i],";")
    local numtel = strline[1]
    res[numtel] = createDataTelMans()
    res[numtel].fio_man = strline[2]
    res[numtel].fio_rg = strline[3]
    res[numtel].planresultkolzv = strline[4]
  end
  return res
end

-- чтение данных из сырого файла Report.csv
function readLogZvonkovFile (namef)
  local str = readFile(namef)
  local  res = {}
  -- local strnum = 1
  for i=1,#str do
    local strline = splitString(str[i],";")
    res[i] = createInputDataTel()
    res[i].datacall = strline[1]
    res[i].telsource = strline[2]
    res[i].teldest = strline[3]
    res[i].secs = strline[11]
  end
  return res
end

-- TODO: сделать функцию фильтрации из общего потока данных



-- END Функции


-- начало основной программы

resultTable =readCfgFile(nameFlog)
inputData = readLogZvonkovFile(namef)

for k,v in pairs(resultTable) do
  print(k)
end

print("run script...")
