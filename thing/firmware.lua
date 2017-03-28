--[[
AUTHOR: Samuel M.H. <samuel.munoz@beeva.com>
DESCRIPTION: Lua script for NodeMCU.
 - Connect the ESP8266 chip to an access point.
 - Create a MQTT client.
 - Publish temperature/humidity
 - Subscribe to operate LED light.
]]

require "config" -- CONFIGURATION


-- Aux functions

-- Sensor DHT11
function read_temp()
  status, temp, humi, temp_dec, humi_dec = dht.read(DHT11_PIN)
  if status == dht.OK then
    print("[DHT11] Temperature: "..temp.."ºC  /  Humidity: "..humi.."%")
    MQTT_CLIENT:publish(MQTT_TOPIC.."/temperature", temp, 0, 0,
      function(client) print("[MQTT] Publish") end
    )
    MQTT_CLIENT:publish(MQTT_TOPIC.."/humidity", humi, 0 ,0,
      function(client) print("[MQTT] Publish") end
    )
  elseif status == dht.ERROR_CHECKSUM then
    print("[DHT11] ERROR_CHECKSUM")
  elseif status == dht.ERROR_TIMEOUT then
    print("[DHT11] TIMEOUT")
  end
end

-- Actuator LED
function mqtt_led(client, topic, message)
  print("[MQTT] Topic: "..topic.."    Message: "..message)
  if message == "1" then
    print("[LED] On")
    gpio.write(LED_PIN, gpio.HIGH)
  elseif message == "0" then
    print("[LED] Off")
    gpio.write(LED_PIN, gpio.LOW)
  end
end


-- Main logic
function mqtt_connected(client)
  print("[MQTT] Connected")
  TIMER = tmr.create():alarm(DHT11_PERIOD, tmr.ALARM_AUTO, read_temp)
  MQTT_CLIENT:subscribe(MQTT_TOPIC.."/LED", 0,
    function(client) print("[MQTT] Subscribed") end
  )
end

function mqtt_disconnected(client, reason)
  print("[MQTT] Disconnected: "..reason)
  tmr:unregister(TIMER)
  tmr.create():alarm(30000, tmr.ALARM_SINGLE, mqtt_connect)
end

function mqtt_connect()
  MQTT_CLIENT:connect(MQTT_BROKER_IP, MQTT_BROKER_PORT, 0,1,
    mqtt_connected, mqtt_disconnected
  )
end

function launch_program()
  MQTT_CLIENT = mqtt.Client(THING_ID, 120)
  MQTT_CLIENT:on("message", mqtt_led)
  mqtt_connect()
end


-- WiFi events
function print_ip()
  addr, nm, MQTT_BROKER_IP = wifi.sta.getip()
  print("[WIFI] GOTIP: "..addr)
  launch_program()
end

wifi.setmode(wifi.STATION)
wifi.sta.eventMonReg(wifi.STA_GOTIP, print_ip)
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("[WIFI] IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("[WIFI] CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("[WIFI] WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("[WIFI] NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("[WIFI] CONNECT_FAIL") end)


---
--- Run
---

print("[NODE] Thing Id: "..THING_ID)

-- Intialize pins
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.mode(DHT11_PIN, gpio.INPUT)

-- Launch WiFi
wifi.sta.eventMonStart()
wifi.sta.config(AP, PASSWORD)
