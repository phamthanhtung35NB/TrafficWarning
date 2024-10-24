#include "Arduino.h"
#include "WiFi.h"
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include "config.h"          // Include the configuration file with sensitive data

#define rxPin 16  // Định nghĩa chân Rx của ESP32
#define txPin 17  // Định nghĩa chân Tx của ESP32

#define NAP_PIN 32  // Định nghĩa chân kiểm tra trạng thái nạp là GPIO32

// Sử dụng HardwareSerial với chân Rx và Tx đã định nghĩa
HardwareSerial mySerial(1);  // Sử dụng UART1 với Rx và Tx

// Firebase configuration
FirebaseConfig configF;
FirebaseAuth auth;
FirebaseData fbdo;  // Firebase Data object

FirebaseJson json;
String macAddress = "111";
String latitudeLongitude = "21.038859, 105.785613";

// Network credentials
const char* ssid = "abc";
const char* password = "123123123";

// ESP32 rain sensor pins
const int RAIN_SENSOR_PIN_3 = 34;  // Top sensor      D34
const int RAIN_SENSOR_PIN_2 = 39;  // Middle sensor   VN
const int RAIN_SENSOR_PIN_1 = 36;  // Bottom sensor   VP

// Function to read sensor levels and return a combined level (1-9)
int getWaterLevel() {
  int level = 0;

  // Read analog values from each sensor
  int sensor1Value = analogRead(RAIN_SENSOR_PIN_1);  // Bottom sensor
  int sensor2Value = analogRead(RAIN_SENSOR_PIN_2);  // Middle sensor
  int sensor3Value = analogRead(RAIN_SENSOR_PIN_3);  // Top sensor

  // Determine level for each sensor
  int sensor1Level = getSensorLevel(sensor1Value);
  int sensor2Level = getSensorLevel(sensor2Value);
  int sensor3Level = getSensorLevel(sensor3Value);

  Serial.print("Bottom: ");
  Serial.print(sensor1Level);
  Serial.print(" ");
  Serial.println(sensor1Value);
  Serial.print("Middle: ");
  Serial.print(sensor2Level);
  Serial.print(" ");
  Serial.println(sensor2Value);
  Serial.print("Top: ");
  Serial.print(sensor3Level);
  Serial.print(" ");
  Serial.println(sensor3Value);
  Serial.println("");

  // Combine levels into a final level (1-9)
  level = sensor1Level + sensor2Level + sensor3Level;

  return level;
}

// Helper function to determine the level for an individual sensor
int getSensorLevel(int value) {
  if (value < 1600) {
    return 2;  // Fully submerged
  } else if (value >= 1600 && value < 3000) {
    return 1;  // Partially submerged
  } else {
    return 0;  // Dry or not submerged
  }
}

void setup() {
  // Khởi động giao tiếp Serial với tốc độ baud 115200
  Serial.begin(115200);

  // Khởi động HardwareSerial với tốc độ baud 115200
  mySerial.begin(115200, SERIAL_8N1, rxPin, txPin);

  pinMode(NAP_PIN, INPUT);

  // Initialize WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  // Firebase configuration
  configF.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  configF.database_url = DATABASE_URL;
  configF.token_status_callback = tokenStatusCallback;  // Assign the callback function

  // Initialize Firebase
  Firebase.begin(&configF, &auth);
  Firebase.reconnectWiFi(true);

  // Get the MAC address of ESP32
  macAddress = WiFi.macAddress();
  Serial.println("MAC Address: " + macAddress);

  json.set("latitudeLongitude", latitudeLongitude);
}

unsigned long lastMillis = 0;
const long interval = 5000;  // 5 seconds
String other = "satLo";

void loop() {
  // Kiểm tra trạng thái nạp
  if (digitalRead(NAP_PIN) == HIGH) {
    // Nếu chân NAP_PIN ở mức HIGH, tiến hành nạp dữ liệu từ HardwareSerial
    if (mySerial.available()) {
      String receivedData = mySerial.readStringUntil('\n');  // Đọc dữ liệu từ Serial
      Serial.print("Received Data: ");
      Serial.println(receivedData);

      // Kiểm tra và xử lý chuỗi dữ liệu dựa trên ký tự đầu tiên
      if (receivedData.startsWith("L ")) {
        latitudeLongitude = receivedData.substring(2);  // Lấy giá trị tọa độ
        Serial.println("Updated Latitude and Longitude: " + latitudeLongitude);
      } else if (receivedData.startsWith("w ")) {
        String wsData = receivedData.substring(2);  // Lấy chuỗi sau 'w'
        Serial.println("WS data: " + wsData);
      } else if (receivedData.startsWith("p ")) {
        String pData = receivedData.substring(2);  // Lấy chuỗi sau 'p'
        Serial.println("P data: " + pData);
      }

      // Khởi động lại Arduino sau khi nạp xong
      ESP.restart();
    }
  } else {
    if (millis() - lastMillis >= interval) {
      lastMillis = millis();

      // Get the current water level
      int waterLevel = getWaterLevel();
      Serial.print("Water Level: ");
      Serial.println(waterLevel);

      json.set("level", waterLevel);
      json.set("other", other);

      // Push data to Firebase under the node named after the MAC address
      String path = "/devices/" + macAddress;  // Path in Firebase
      if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json)) {
        Serial.println("Data sent to Firebase successfully.");
      } else {
        Serial.println("Failed to send data to Firebase.");
        Serial.println("Reason: " + fbdo.errorReason());
      }
    }
  }
}
