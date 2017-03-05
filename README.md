<a href='https://play.google.com/store/apps/details?id=lav.watermeter&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img width="180" alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>
## Описание
Данное устройство предназначено для сбора данных по расходу воды с импульсных счетчиков. В данном варианте для хранения данных используется сервис [thingspeak](https://thingspeak.com/). В качестве основного модуля использовалась ESP-03. Прошивка модуля собрана при помощи [online-конструктора](http://nodemcu-build.com) (модули file, gpio, net, node, tmr, uart, wifi).

## Настройка
Для настройки устройства, его необходимо перевести в соответствующий режим. Для этого необходимо зажать кнопку при подаче питания. Загоревшийся светодиод LED1 символизирует об успешном переходе в режим настройки. После этого, в списке доступных сетей должна появиться сеть ESP-???????, где вместо символов ? будет id вашего ESP. Пароль для подключения к сети "1234567890". После подключения, в браузере необходимо перейти по адресу 1.1.1.1 и ввести все необходимые настройки. По окончании настройки, необходимо нажать кнопку "Сохранить" и перезагрузить устройство. 

## Принцип работы
Каждую секунду проверяются состояния выводов, к которым подключены счетчики. Как только на выводе появляется 0 увеличиваются на 10 литров соответствующие значения. Значения на сервер передаются каждую минуту. 

![](https://github.com/LukyanovAnatoliy/WaterMeter_v2/blob/master/image/img1.jpg)
![](https://github.com/LukyanovAnatoliy/WaterMeter_v2/blob/master/image/img2.jpg)
![](https://github.com/LukyanovAnatoliy/WaterMeter_v2/blob/master/image/img3.jpg)
