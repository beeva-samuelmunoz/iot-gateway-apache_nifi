--[[
AUTHOR: Samuel M.H. <samuel.munoz@beeva.com>
DESCRIPTION: Lua script for NodeMCU.
 - Connect the ESP8266 chip to an access point.
 - Create a MQTT client.
 - Publish temperature/humidity
 - Subscribe to operate LED light.
]]

-- Thing
THING_ID = node.chipid()

-- Sensors
LED_PIN = 2 --D2/GPIO4

-- DHT11
DHT11_PIN = 1  -- D1/GPIO5
DHT11_PERIOD = 10*1000-- milliseconds

-- WiFi
AP = "IOT-GW-01" --Name of the access point to connect
PASSWORD =  "IOT-PASS-01" --Password for the access point

-- MQTT
MQTT_BROKER_IP = ""  -- Will be taken from the gateway IP
MQTT_BROKER_PORT = 1883
MQTT_TOPIC = THING_ID
MQTT_CLIENT = ""
