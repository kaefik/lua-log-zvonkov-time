-- версия выгрузки лога звонков на Lua

local util = require("iutil")
local surf = require("surf")

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

-- сохранение строки stroka в файл namefile
function saveToFile(namefile,stroka)
  file = io.open (namefile,"w")
  file:write(stroka)
  file:close()
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

-- получить данные из сервера
function getRawLogFile(namefile,begday,begmonth,begyear,endday,endmonth,endyear)
  begyearmonth = begyear.."-"..begmonth
  endyearmonth = endyear.."-"..endmonth
  -- begday = "14"
  -- endday = "14"
  suri = "http://voip.2gis.local/cisco-stat/cdr.php?s=1&t=&order=dateTimeOrigination&sens=DESC&current_page=0&posted=1&current_page=0&fromstatsmonth="..begyearmonth.."&tostatsmonth="..endyearmonth.."&Period=Day&fromday=true&fromstatsday_sday="..begday.."&fromstatsmonth_sday="..begyearmonth.."&today=true&tostatsday_sday="..endday.."&tostatsmonth_sday="..endyearmonth.. "&callingPartyNumber=&callingPartyNumbertype=2&originalCalledPartyNumber=%2B7&originalCalledPartyNumbertype=2&origDeviceName=&origDeviceNametype=1&destDeviceName=&destDeviceNametype=1&resulttype=min&image16.x=28&image16.y=8"
  suri2 = "http://voip.2gis.local/cisco-stat/export_csv.php"
  _,_,headers = Open(suri)
  -- printTable(headers)
  value_cookie = getCookie(headers)
  headers = setCookie(headers,value_cookie)
  h1,_,headers1 = Open(suri2,headers)
  saveToFile(namefile,h1)
end

-- END Функции


-- начало основной программы

getRawLogFile(namef,"28","08","2017","28","08","2017")

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
stroka = "ФИО РГ"..";".."номер телефона"..";".."ФИО МПП"..";".."общее кол-во звонков" ..";".."общая продолжительность сек"..";".."кол-во результатив. звонков"..";".."продолжит. результат. звонков".."\n"
for k,v in pairs(resultTable) do
  stroka = stroka..v.fio_rg..";"..k..";"..v.fio_man..";"..v.totalzv ..";"..v.totalsec..";"..v.kolresult..";"..v.secresult.."\n"
end
saveToFile("resultTable.csv",stroka)
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
