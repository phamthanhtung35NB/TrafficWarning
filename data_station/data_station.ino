#include "Arduino.h"
#include "WiFi.h"
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include "config.h"  // Include the configuration file with sensitive data

// Initialize Firebase variables using values from config.h
FirebaseConfig configF;
FirebaseAuth auth;
FirebaseData fbdo; // Declare FirebaseData object

// Replace with your network credentials
const char* ssid = "abc";
const char* password = "123123123";

void setup() {
  // Serial port for debugging purposes
  Serial.begin(115200);
  
  // Initialize WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
// Firebase configuration
 Serial.println("------------------------");
   Serial.println(API_KEY);           // API_KEY from config.h
   Serial.println(USER_EMAIL);        // USER_EMAIL from config.h
   Serial.println(USER_PASSWORD);  // USER_PASSWORD from config.h
   Serial.println(DATABASE_URL);
  // Firebase configuration
  configF.api_key = API_KEY;           // API_KEY from config.h
  auth.user.email = USER_EMAIL;        // USER_EMAIL from config.h
  auth.user.password = USER_PASSWORD;  // USER_PASSWORD from config.h
  configF.database_url = DATABASE_URL; // DATABASE_URL from config.h
  
  // Assign the callback function for the long running token generation task
  configF.token_status_callback = tokenStatusCallback;

  // Initialize Firebase
  Firebase.begin(&configF, &auth);
  Firebase.reconnectWiFi(true);
}

unsigned long lastMillis = 0;
const long interval = 100; // 5 seconds

void loop() {
  // Check if 5 seconds have passed
  if (millis() - lastMillis >= interval) {
    lastMillis = millis();

    // Read data from Realtime Database
    if (Firebase.ready()) {
      if (Firebase.RTDB.getJSON(&fbdo, "/")) {
        FirebaseJson& json = fbdo.jsonObject(); // Retrieve the JSON object
        
        FirebaseJsonData jsonData;
        
        // Get the value of "s1"
        json.get(jsonData, "s1/latitudeLongitude");
        if (jsonData.success) {
          Serial.print("s1 Latitude, Longitude: ");
          Serial.println(jsonData.stringValue);
        }

        json.get(jsonData, "s1/level");
        if (jsonData.success) {
          Serial.print("s1 Level: ");
          Serial.println(jsonData.intValue);
        }

        json.get(jsonData, "s1/other");
        if (jsonData.success) {
          Serial.print("s1 Other: ");
          Serial.println(jsonData.stringValue);
        }

        // Get the value of "s2"
        // json.get(jsonData, "s2/latitudeLongitude");
        // if (jsonData.success) {
        //   Serial.print("s2 Latitude, Longitude: ");
        //   Serial.println(jsonData.stringValue);
        // }

        // json.get(jsonData, "s2/level");
        // if (jsonData.success) {
        //   Serial.print("s2 Level: ");
        //   Serial.println(jsonData.intValue);
        // }

        // json.get(jsonData, "s2/other");
        // if (jsonData.success) {
        //   Serial.print("s2 Other: ");
        //   Serial.println(jsonData.stringValue);
        // }

        // Get the value of "sum"
        json.get(jsonData, "sum");
        if (jsonData.success) {
          Serial.print("Sum: ");
          Serial.println(jsonData.intValue);
        }
      } else {
        Serial.println(fbdo.errorReason());
      }
    }
  }
}
