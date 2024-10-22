#include <Arduino.h>

#include <WiFi.h>

#include <Firebase_ESP_Client.h>

#include <Wire.h>

#include <Adafruit_Sensor.h>

#include <Adafruit_BME280.h>

#include "time.h"

#include "addons/TokenHelper.h"

#include "addons/RTDBHelper.h"



//Enter your network credentials

const char* ssid = "YOUR_SSID";

const char* password = "YOUR_PASSWORD";



//Enter Firebase web API Key

#define API_KEY "AIzaSyCPU3dkKnnc--XM5vorDZroV_0NYxH****"



// Enter Authorized Email and Password

#define USER_EMAIL "WRITE_AUTHORIZED_EMAIL"

#define USER_PASSWORD "WRITE_AUTHORIZED_PASSWORD"



// Enter Realtime Database URL

#define DATABASE_URL "WRITE_YOUR_REALTIME_DATABASE_URL"



FirebaseData Firebase_dataObject;

FirebaseAuth authentication;

FirebaseConfig config;



String UID;



// Database main path

String database_path;



String temperature_path = "/temperature";

String humidity_path = "/humidity";

String pressure_path = "/pressure";

String time_path = "/epoch_time";



//Updated in every loop

String parent_path;



int epoch_time;

FirebaseJson json;



const char* ntpServer = "pool.ntp.org";



Adafruit_BME280 bme;

float temperature;

float humidity;

float pressure;



//send new readings every 5 minutes

unsigned long previous_time = 0;

unsigned long Delay = 300000;



//get current epoch time

unsigned long Get_Epoch_Time() {

  time_t now;

  struct tm timeinfo;

  if (!getLocalTime(&timeinfo)) {

    return (0);

  }

  time(&now);

  return now;

}



void setup() {

  Serial.begin(115200);



  if (!bme.begin(0x76)) {

    Serial.println("Could not find BME280 sensor. Check Connections!");

    while (1);

  }



  WiFi.begin(ssid, password);

  Serial.print("Connecting to WiFi ..");

  while (WiFi.status() != WL_CONNECTED) {

    Serial.print('.');

    delay(1000);

  }

  Serial.println(WiFi.localIP());

  Serial.println();



  configTime(0, 0, ntpServer);



  config.api_key = API_KEY;

  authentication.user.email = USER_EMAIL;

  authentication.user.password = USER_PASSWORD;

  config.database_url = DATABASE_URL;



  Firebase.reconnectWiFi(true);

  Firebase_dataObject.setResponseSize(4096);



  config.token_status_callback = tokenStatusCallback;

  config.max_token_generation_retry = 5;



  Firebase.begin(&config, &authentication);



  Serial.println("Getting User UID...");

  while ((authentication.token.uid) == "") {

    Serial.print('.');

    delay(1000);

  }

  UID = authentication.token.uid.c_str();

  Serial.print("User UID: ");

  Serial.println(UID);



  database_path = "/Data/" + UID + "/BME280 Readings";

}



void loop() {

  if (Firebase.ready() && (millis() - previous_time > Delay || previous_time == 0))

  {

    previous_time = millis();



    epoch_time = Get_Epoch_Time();

    Serial.print ("time: ");

    Serial.println (epoch_time);



    parent_path = database_path + "/" + String(epoch_time);



    json.set(temperature_path.c_str(), String(bme.readTemperature()));

    json.set(humidity_path.c_str(), String(bme.readHumidity()));

    json.set(pressure_path.c_str(), String(bme.readPressure() / 100.0F));

    json.set(time_path, String(epoch_time));

    Serial.printf("Set json...%s\n", Firebase.RTDB.setJSON(&Firebase_dataObject, parent_path.c_str(), &json) ? "ok" : Firebase_dataObject.errorReason().c_str());

  }

}
