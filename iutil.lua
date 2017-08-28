-- модуль общих полезных функций  от Сайфутдинов И. Г.
-- e-mail: ilnursoft@gmail.comments

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

function myprint()
  print("Hello")
end
-- END


--  РАБОТА СО СТРОКАМИ
-- разделение строки str по указанному символуsimbol
function splitString(str, simbol)
  local words = {}
  for w in str:gmatch("([^"..simbol.."]*)") do
    table.insert(words, w) end
  return words
end
--  END РАБОТА СО СТРОКАМИ
