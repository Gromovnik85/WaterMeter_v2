wifi.setmode(wifi.SOFTAP);

-- настройка точки доступа
local cfg={};
cfg.ssid="ESP_"..node.chipid();
cfg.pwd="1234567890";
cfg.hidden=0;
cfg.auth=wifi.AUTH_OPEN;
wifi.ap.config(cfg);

local ip_cfg = {};
ip_cfg.ip="1.1.1.1"
wifi.ap.setip(ip_cfg);

isredirected = 0;

-- запуск сервера
srv=net.createServer(net.TCP);
srv:listen(80, function(conn)
    
    local function sender(conn)
        if (isredirected == 1) then
            print("send redirect");
            conn:close();
        else
            local line=file.readline();
            if (line) then
                --print(line);
                conn:send(line);
            else
                file.close();
                conn:close();
                print("Отправлено");
            end;
        end;
    end;
    conn:on("receive", function(conn,request)
        print(request);
        if (request == nil) or (request == "") then
            return;
        end;
        _, _, method, path, vars = string.find(request, "([A-Z]+) (.*)/%??(.*) HTTP");
        if (method == "GET") then
            if (vars == nil) or (vars == "") then
                isredirected = 1;
                conn:send('<script type="text/javascript"> document.location.href="http://1.1.1.1/?'..
                        PARAM_SSID..'='..settings[PARAM_SSID]..'&'..
                        PARAM_PASSWORD..'='..settings[PARAM_PASSWORD]..'&'..
                        PARAM_API_KEY..'='..settings[PARAM_API_KEY]..'&'..
                        PARAM_COLD_FIELD_INC..'='..settings[PARAM_COLD_FIELD_INC]..'&'..
                        PARAM_COLD_FIELD_TOTAL..'='..settings[PARAM_COLD_FIELD_TOTAL]..'&'..
                        PARAM_COLD_VALUE..'='..cold_values.total..'&'..
                        PARAM_HOT_FIELD_INC..'='..settings[PARAM_HOT_FIELD_INC]..'&'..
                        PARAM_HOT_FIELD_TOTAL..'='..settings[PARAM_HOT_FIELD_TOTAL]..'&'..
                        PARAM_HOT_VALUE..'='..hot_values.total..'"; </script>');
                --'password=1234567890&api_key=test api key&channel_id=666'.. 
                --'&cold_field_incr=field2&cold_field_total=field3&cold_value=3333&hot_field_incr=field4&hot_field_total=field5&hot_value=55555"; </script>');
            else
                if (string.match(vars, "([%w_]+)=([%w_]*)")) then
                    file.open("index.html", "r");
                    isredirected = 0;
                    sender(conn);
                else
                    conn:close();
                end;
            end;
        else
            print("Сохраняем");
            -- в post запросе новые данные передаются вконце
            -- необходимо их вытащить
            
            start, _, _ = string.find(request, "\n[%w_]+=[%w_]*");
            param = string.sub(request, start + 1);
            print(param);
            cold_values.inc = 0;
            hot_values.inc = 0;
            for k, v in string.gmatch(param, "([%w_]+)=([%w_]*)") do
                if (k == PARAM_COLD_VALUE) then
                    cold_values.total = tonumber(v);
                else if (k == PARAM_HOT_VALUE) then
                        hot_values.total = tonumber(v);
                    else
                        settings[k] = v;
                    end;
                end;
            end;
            --file.close();
            write_to_file(FILE_MAIN_PARAMETERS, settings);
            write_to_file(FILE_COLD, cold_values);
            write_to_file(FILE_HOT, hot_values);
            node.restart();
        end;
    end);
    conn:on("sent", sender);
end)
