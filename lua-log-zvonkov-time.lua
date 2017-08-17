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
    res[i].secs = tonumber(strline[11])
  end
  return res
end

-- n = tonumber(line)   -- try to convert it to a number
--     if n == nil then
--       error(line .. " is not a valid number")
--     else
--       print(n*2)
--     end

-- получить все ключи с таблицы mtab
function getKeysTable(mtab)
  keys = {}
  strnum = 1
  for k,v in pairs(mtab) do
     keys[strnum] = k
     strnum = strnum +1
  end
  return keys
end

-- TODO: экспорт данных таблицы в файл xlsx

function getRawLogFile(begyearmonth,begday,endyearmonth,endday)
  begyearmonth = "2017-08"
  endyearmonth = "2017-08"
  begday = "14"
  endday = "15"
  suri = "http://voip.2gis.local/cisco-stat/cdr.php?s=1&t=&order=dateTimeOrigination&sens=DESC&current_page=0&posted=1&current_page=0&fromstatsmonth="..begyearmonth.."&tostatsmonth="..endyearmonth.."&Period=Day&fromday=true&fromstatsday_sday="..begday.."&fromstatsmonth_sday="..begyearmonth.."&today=true&tostatsday_sday="..endday.."&tostatsmonth_sday="..endyearmonth.. "&callingPartyNumber=&callingPartyNumbertype=2&originalCalledPartyNumber=%2B7&originalCalledPartyNumbertype=2&origDeviceName=&origDeviceNametype=1&destDeviceName=&destDeviceNametype=1&resulttype=min&image16.x=28&image16.y=8"
  suri2 = "http://voip.2gis.local/cisco-stat/export_csv.php"
	-- print(suri)

  local http=require'socket.http'
  body,c,l,h = http.request(suri)
  body,c,l,h = http.request(suri2)
  print('status line',l)
  print('body',body)

end

-- END Функции


-- начало основной программы

getRawLogFile()

resultTable =readCfgFile(nameFlog)
rawData = readLogZvonkovFile(namef)
keys = getKeysTable(resultTable)

-- фильтрация сырых данных от ненужных телефонов-источников
for k,v in pairs(rawData) do
  flag = true
  for kk,vv in pairs(resultTable) do
    -- print(v.telsource, kk)
    if v.telsource == kk then
      flag = false
    end
  end
  if flag then
    rawData[k] = nil
  end
end

-- подсчет показателей
res_sec = 25 -- продолжительность результирующего звонка
for k,v in pairs(resultTable) do
  totkol = 0          -- общее кол-во звонков
  totsec = 0          --  счетчик общей продолжительности звонков
  kolres = 0          --  счетчик кол-ва результативных звонков
  totressec = 0       --  счетчик продолжительности результативных звонков
  for kk,vv in pairs(rawData) do
    -- print(vv.telsource, k)
    if vv.telsource == k then
      totkol = totkol + 1
      totsec = totsec + vv.secs
      if vv.secs > res_sec then
        kolres = kolres + 1
        totressec = totressec + vv.secs
      end
    end
  end
  resultTable[k].totalsec = totsec
  resultTable[k].totalzv = totkol
  resultTable[k].kolresult = kolres
  resultTable[k].secresult = totressec
end

--  сохранение в файл csv
print("сохранение в файл csv...")
file = io.open ("resultTable.csv","w")
stroka = "ФИО РГ"..";".."номер телефона"..";".."ФИО МПП"..";".."общее кол-во звонков" ..";".."общая продолжительность сек"..";".."кол-во результатив. звонков"..";".."продолжит. результат. звонков".."\n"
file:write(stroka)
for k,v in pairs(resultTable) do
  stroka = v.fio_rg..";"..k..";"..v.fio_man..";"..v.totalzv ..";"..v.totalsec..";"..v.kolresult..";"..v.secresult.."\n"
  file:write(stroka)
end
file:close()

--
-- value["fio_rg"]=""            -- ФИО РГ
-- value["fio_man"]=""            -- ФИО менеджера
-- value["totalsec"]=0          --общая продолжительность звонков (в сек)
-- value["kolunik"]=0           --кол-во уникальных телефонных номеров
-- value["kolresult"]=0         --кол-во результативных звоноков
-- value["secresult"]=0          --продолжительность результативных звонков (в сек)
-- value["totalzv"]=0            -- общее кол-во звонков
-- value["planresultkolzv"]=0   --плановое кол-во результативных звоноков
-- value["kolunikresult"]=0      --кол-во уникальных результ. звонков
-- value["plankolvstrech"]=0     -- плановое количество встреч

-- printTable2Dim(resultTable)



print("END")
