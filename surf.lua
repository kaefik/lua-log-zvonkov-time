-- реализация непрерывной работы типа браузера

-- load the http module
local io = require("io")
local http = require("socket.http")
local ltn12 = require("ltn12")
local util = require("iutil")


function httpHeaderDefault()
  local  headers = {
      ["connection"] = "Keep-Alive",
      ["timeout"] = 300,
      ["User-Agent"] = "Mozilla/5.0",
    }
  return headers
end

-- получить из заголовка куки
function getCookie(headers)
  return headers["set-cookie"]
end

--  закинуть в заголовок http запроса куки
function setCookie(headers,value)
  headers["cookie"] = value
  return headers
end

function Open(url,iheader)
  -- url - урл в виде http://ya.ru
  -- iheader - заголовок http запроса
  local body = {}
  if iheader == nil then
    iheader=httpHeaderDefault()
  end
  res, code_request, head_request = http.request{
      method = "GET",
      url = url,
      sink = ltn12.sink.table(body),
      headers = iheader
    }
  body = table.concat(body)
  -- body  - содержимое страницы (string)
  -- code_request  - код ответа от сервера, если все гуд, то 200
  -- head_request  - заголовок http ответа (table)
  return  body, code_request, head_request

end

-- сохранение содержимого страницы в файл filename
function getBodyToFile(filename,url,iheader)
  -- url - урл в виде http://ya.ru
  -- iheader - заголовок http запроса
  local body = io.open(filename,"w")
  if iheader == nil then
    iheader=httpHeaderDefault()
  end
  _, code_request, head_request = http.request{
      method = "GET",
      url = url,
      sink = ltn12.sink.file(body),
      headers = iheader
    }
    -- code_request  - код ответа от сервера, если все гуд, то 200
    -- head_request  - заголовок http ответа (table)
    return  code_request, head_request
end


-------


myurl = "http://echo.msk.ru"
myurl2 = "http://lenta.ru"

getBodyToFile("newbody.txt",myurl2)
b,_,_ = Open(myurl)
-- print(b)





--
--   print("Cookie 1:",c["set-cookie"])
