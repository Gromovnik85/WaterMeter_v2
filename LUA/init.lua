LED_GPIO = 5; -- GPIO14
BUTTON_GPIO = 0; -- GPIO16
COLD_GPIO = 6; -- GPIO12 
HOT_GPIO = 7; -- GPIO13

node.setcpufreq(node.CPU80MHZ);

INC_VALUE = 10; -- инкрементирующее значение в литрах

PARAM_SSID = "ssid";
PARAM_PASSWORD = "password";
PARAM_API_KEY = "api_key";
PARAM_COLD_FIELD_INC = "cold_field_incr";
PARAM_COLD_FIELD_TOTAL = "cold_field_total";
PARAM_COLD_VALUE = "cold_value";
PARAM_HOT_FIELD_INC = "hot_field_incr";
PARAM_HOT_FIELD_TOTAL = "hot_field_total";
PARAM_HOT_VALUE = "hot_value";

FILE_MAIN_PARAMETERS = "main_parameters";
FILE_COLD = "cold";
FILE_HOT = "hot";

settings = {};
cold_values = {};
hot_values = {};

-- настройка GPIO
gpio.mode(COLD_GPIO, gpio.INPUT, gpio.PULLUP)
gpio.mode(HOT_GPIO, gpio.INPUT, gpio.PULLUP)
gpio.mode(LED_GPIO, gpio.OUTPUT)
gpio.mode(BUTTON_GPIO, gpio.INPUT, gpio.PULLUP);

-- включение светодиода
function led_on()
    gpio.write(LED_GPIO, gpio.LOW);
end;

-- отключение светодиода  
function led_off()
    gpio.write(LED_GPIO, gpio.HIGH);
end;

function val_to_str ( v )
    return ((v == nil) or (v == "")) and '""' or '"'..v..'"'
end;

-- перевод таблицы в строку 
function table_to_str(tbl)
    local result = {}
    for k, v in pairs(tbl) do
        table.insert( result, k .. "=" .. val_to_str( v ) )
    end
    return "{" .. table.concat( result, "," ) .. "}"
end;

-- сохранение таблицы в файл 
function write_to_file(fileName, tbl)
    file.open(fileName, "w+");
    file.write(table_to_str(tbl));
    file.flush();
    file.close();
end;

-- чтение данных из файла
function read_from_file(fileName)
    if (file.open(fileName, "r")) then
        str = file.read();
        file.close();
        if (str == nil) or (str == "") then
            return {};
        else
            return loadstring("return "..str)();
        end;
    else 
        return {}
    end;
end;

settings = read_from_file(FILE_MAIN_PARAMETERS);
cold_values = read_from_file(FILE_COLD);
hot_values = read_from_file(FILE_HOT);

-- зададим начальные значения если ничего не задано
if (cold_values.total == nil) then
    cold_values.inc = 0;
    cold_values.total = 0;
end;

if (hot_values.total == nil) then
    hot_values.inc = 0;
    hot_values.total = 0;
end;

if (settings[PARAM_SSID] == nil) then
    settings[PARAM_SSID] = "";
    settings[PARAM_PASSWORD] = "";
    settings[PARAM_API_KEY] = "";
    settings[PARAM_COLD_FIELD_INC] = "";
    settings[PARAM_COLD_FIELD_TOTAL] = "";
    settings[PARAM_HOT_FIELD_INC] = "";
    settings[PARAM_HOT_FIELD_TOTAL] = "";
end;

led_off();

-- задержка 2 секунды, чтобы успеть нажать на кнопку
tmr.delay(2000000); 

-- проверяем состояние вывода с кнопкой
if (gpio.read(BUTTON_GPIO) == 0) then 
    -- если нажата кнопка, то запускаем веб-сервер
    led_on();
    dofile("setup_mode.lua");
else -- в противном случае передачу данных
    dofile("meter_mode.lua");
end;
