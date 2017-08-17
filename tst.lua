
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
