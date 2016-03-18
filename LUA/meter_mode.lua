-- если параметры подключения не заданы, то часто мигаем
if (settings[PARAM_SSID] == nil) or (settings[PARAM_SSID] == "") then
    tmr.alarm(0, 500, tmr.ALARM_AUTO, function() 
        if (gpio.read(LED_GPIO) == 0) then
            led_off();
        else
            led_on();
        end;
    end) 
    return;
end;

-- подключаемся к wifi точке 
wifi.setmode(wifi.STATION);
wifi.sta.config(settings[PARAM_SSID], settings[PARAM_PASSWORD]);
wifi.sta.autoconnect(1);
wifi.sta.connect();

cold_state = 0;
hot_state = 0;
--каждую секунду проверяем состояние выходов
tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()

    if (gpio.read(LED_GPIO) == 0) then
        led_off();
    else
        led_on();
    end;

    -- холодная вода
    if ((gpio.read(COLD_GPIO) == 0) and (cold_state == 1)) then
        cold_values.inc = cold_values.inc + INC_VALUE;
        cold_values.total = cold_values.total + INC_VALUE;
        print("cold="..table_to_str(cold_values));
        write_to_file(FILE_COLD, cold_values);
    end;
    cold_state = gpio.read(COLD_GPIO);

    -- горячая вода
    if ((gpio.read(HOT_GPIO) == 0) and (hot_state == 1)) then
        hot_values.inc = hot_values.inc + INC_VALUE;
        hot_values.total = hot_values.total + INC_VALUE;
        print("hot="..table_to_str(hot_values));
        write_to_file(FILE_HOT, hot_values);
    end;
    hot_state = gpio.read(HOT_GPIO);

    --print(wifi.sta.getip());
end)

-- каждую минуту отправляем данные
tmr.alarm(2, 60000, 1, function()
    -- если нет подключения, выходим
    if (wifi.sta.status() ~= 5) then
        return;
    end;
    -- отправляем данные если произошли какие-либо изменения 
    if (tonumber(cold_values.inc) > 0) or (tonumber(hot_values.inc) > 0) then
        conn = net.createConnection(net.TCP, 0)
        conn:on("receive", function(con, receive)

            --print(receive);
        
            cold_values.inc = 0;
            write_to_file(FILE_COLD, cold_values);

            hot_values.inc = 0;
            write_to_file(FILE_HOT, hot_values);

            con:close();
        
        end)
        conn:on("connection", function(c)
            local param_str = "";
            if (tonumber(cold_values.inc) > 0) then
                param_str = "&"..settings[PARAM_COLD_FIELD_INC].."="..tostring(cold_values.inc).."&"..
                                 settings[PARAM_COLD_FIELD_TOTAL].."="..tostring(cold_values.total);
            end;
            if (tonumber(hot_values.inc) > 0) then
                param_str = param_str.."&"..
                            settings[PARAM_HOT_FIELD_INC].."="..tostring(hot_values.inc).."&"..
                            settings[PARAM_HOT_FIELD_TOTAL].."="..tostring(hot_values.total);
            end;
            
            print("GET /update?key="..settings[PARAM_API_KEY]..param_str);
            
            c:send("GET /update?key="..settings[PARAM_API_KEY]..param_str
                .." HTTP/1.1\r\n"
                .."Host: api.thingspeak.com\r\n"
                .."Connection: keep-alive\r\n"
                .."Accept: */*\r\n"
                .."\r\n");
        end)
        conn:connect(80,"api.thingspeak.com");
    end;
end)
