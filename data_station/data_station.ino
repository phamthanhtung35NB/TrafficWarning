#include "Arduino.h"
#include "WiFi.h"
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include "config.h"  // Include the configuration file with sensitive data

#include <Wire.h>
#include <Adafruit_BMP085.h>



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

// Tạo đối tượng cho cảm biến BMP180
Adafruit_BMP085 bmp;

// Biến để lưu áp suất ban đầu (khi không ở trong nước)
float initialPressure = 0;
const float waterDensity = 997;  // mật độ nước (kg/m^3)
const float gravity = 9.81;      // gia tốc trọng trường (m/s^2)

unsigned long lastMillis = 0;
const long interval = 5000;  // 5 seconds
String other = "satLo";

float depthInCm = 0.0;
int level = 0;

#define rxPin 16  // Định nghĩa chân Rx của ESP32
#define txPin 17  // Định nghĩa chân Tx của ESP32

#define NAP_PIN 32  // Định nghĩa chân kiểm tra trạng thái nạp là GPIO32

// ESP32 rain sensor pins
const int RAIN_SENSOR_PIN_3 = 34;     // Top sensor      D34
const int RAIN_SENSOR_PIN_NGAP = 39;  // ngập   VN
const int RAIN_SENSOR_PIN_MUA = 36;   // mưa   VP

bool getRain() {
  // Read analog values from each sensor
  int Value = analogRead(RAIN_SENSOR_PIN_MUA);
  if (Value < 3000) {
    return true;
  } else {
    return false;
  }
}
bool getNgap() {
  // Read analog values from each sensor
  int Value = analogRead(RAIN_SENSOR_PIN_NGAP);
  if (Value < 3000) {
    return true;
  } else {
    return false;
  }
}

// Function to read sensor levels and return a combined level (1-9)
void getWaterLevel() {
  if (getNgap() == true) {
    // Đọc áp suất hiện tại từ cảm biến
    float currentPressure = bmp.readPressure();

    // Tính sự chênh lệch áp suất (áp suất trong nước lớn hơn)
    float pressureDifference = currentPressure - initialPressure;

    // Tính toán độ sâu nước dựa trên sự chênh lệch áp suất
    // Công thức: độ sâu (m) = áp suất chênh lệch (Pa) / (mật độ nước * gia tốc trọng trường)
    float depth = pressureDifference / (waterDensity * gravity);

    // Đổi đơn vị độ sâu từ mét sang cm
    depthInCm = depth * 100;

    // In kết quả độ sâu ra màn hình serial với 4 chữ số sau dấu phẩy
    Serial.print("Áp suất ban đầu (Pa): ");
    Serial.println(initialPressure);
    Serial.print("Áp suất hiện tại (Pa): ");
    Serial.println(currentPressure);
    Serial.print("Chênh lệch áp suất (Pa): ");
    Serial.println(pressureDifference);
    Serial.print("Độ sâu nước (cm): ");
    Serial.println(depthInCm, 4);  // In ra với 4 chữ số sau dấu phẩy

    // Delay 1 giây trước khi đọc lần tiếp theo
    delay(1000);

    if (depthInCm > 30) {
      level = 3;
    } else if (depthInCm > 20) {
      level = 2;
    } else {
      level = 1;
    }
  } else {
    level = 0;
    return;
  }
}

bool initWifi() {
  // Initialize WiFi
  WiFi.begin(ssid, password);

  unsigned long wifiTimeout = millis() + 10000;  // Giới hạn thời gian 10 giây
  while (WiFi.status() != WL_CONNECTED && millis() < wifiTimeout) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Connected to WiFi");
    return true;
  } else {
    Serial.println("Failed to connect to WiFi");
    return false;
  }
}
void initBmp() {
  // Khởi tạo I2C (nếu cần thiết) với ESP32
  Wire.begin(21, 22); // SDA = 21, SCL = 22 (đây là mặc định, có thể không cần)

  // Kiểm tra kết nối cảm biến BMP180
  if (!bmp.begin()) {
    Serial.println("Không tìm thấy cảm biến BMP180!");
    while (1) {
      Serial.println("Không tìm thấy cảm biến BMP180!");  // In thông báo lỗi liên tục
      delay(1000);                                        // Đợi 1 giây trước khi in lại
    }
  }

  // Lấy áp suất hiện tại khi cảm biến chưa nhúng vào nước
  initialPressure = bmp.readPressure();
  Serial.print("Áp suất ban đầu (Pa): ");
  Serial.println(initialPressure);

  delay(1000);
}
void initFirebase() {
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
void setup() {
  // Khởi động giao tiếp Serial với tốc độ baud 115200
  Serial.begin(115200);

  // Khởi động HardwareSerial với tốc độ baud 115200
  mySerial.begin(115200, SERIAL_8N1, rxPin, txPin);

  pinMode(NAP_PIN, INPUT);
  // Khởi động kết nối wifi
  if (initWifi()) {
    //khởi động firebase
    initFirebase();
    // Khởi động cảm biến áp suất
    initBmp();
  }
}
//mưa, ngập, mức độ cảnh báo, độ cao của nước
void pushData(bool mua, bool ngap, int waterLevel, int Cm) {
  if (!Firebase.ready()) {
    Serial.println("Firebase is not ready!");
    return;
  }
  json.set("mua", mua);
  json.set("level", waterLevel);
  json.set("ngap", ngap);
  json.set("waterDepth", Cm);
  // Push data to Firebase under the node named after the MAC address
  String path = "/devices/" + macAddress;  // Path in Firebase
  if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json)) {
    Serial.println("Data sent to Firebase successfully.");
  } else {
    Serial.println("Failed to send data to Firebase.");
    Serial.println("Reason: " + fbdo.errorReason());
  }
}
// void pushData() {
//   json.set("level", waterLevel);
//   json.set("other", other);
//   // Push data to Firebase under the node named after the MAC address
//   String path = "/devices/" + macAddress;  // Path in Firebase
//   if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json)) {
//     Serial.println("Data sent to Firebase successfully.");
//   } else {
//     Serial.println("Failed to send data to Firebase.");
//     Serial.println("Reason: " + fbdo.errorReason());
//   }
// }
void loop() {
  // Kiểm tra trạng thái nạp
  if (digitalRead(NAP_PIN) == LOW) {
    if (millis() - lastMillis >= interval) {
      lastMillis = millis();
      depthInCm = 0;
      getWaterLevel();
      pushData(getRain(), getNgap(), level, depthInCm);
    }
  } else {
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
  }
}
