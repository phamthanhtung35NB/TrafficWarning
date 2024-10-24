#include <BluetoothSerial.h>
#include <HardwareSerial.h>

BluetoothSerial SerialBT;  // Đối tượng Bluetooth Serial
HardwareSerial SerialPort(1);  // UART1 cho truyền nhận dữ liệu

// Định nghĩa chân
#define rxPin 16  // Rx của UART
#define txPin 17  // Tx của UART
#define controlPin 2  // Chân để điều khiển chế độ nhận/gửi
#define buzzerPin 4   // Chân còi


// Biến lưu chuỗi nhận và dữ liệu đã xử lý
String receivedData = "";
String latitudeLongitude = "";
String wsData = "";
String pData = "";

unsigned long previousMillis = 0;
const long interval = 3000;  // 3 giây

void setup() {
  // Khởi tạo Serial
  Serial.begin(115200);
  SerialBT.begin("ESP32_BT");  // Đặt tên Bluetooth
  Serial.println("Bluetooth Started. Waiting for connection...");

  // Cấu hình chân
  pinMode(controlPin, INPUT);  // Điều khiển nhận/gửi
  pinMode(buzzerPin, OUTPUT);  // Còi
  digitalWrite(buzzerPin, LOW);  // Tắt còi

  // Khởi tạo UART1
  SerialPort.begin(9600, SERIAL_8N1, rxPin, txPin);
}

void loop() {
  // Kiểm tra trạng thái của chân controlPin
  int controlState = digitalRead(controlPin);
  
  // Nếu controlPin ở mức LOW, nhận dữ liệu từ Bluetooth
  if (controlState == LOW) {
    if (SerialBT.available()) {
      receivedData = SerialBT.readStringUntil('\n');  // Đọc dữ liệu từ Bluetooth
      
      // Kiểm tra và xử lý chuỗi dữ liệu dựa trên ký tự đầu tiên
      if (receivedData.startsWith("L ")) {
        latitudeLongitude = receivedData.substring(2);  // Lấy giá trị tọa độ
        Serial.println("Updated Latitude and Longitude: " + latitudeLongitude);
      } else if (receivedData.startsWith("w ")) {
        wsData = receivedData.substring(2);  // Lấy chuỗi sau 'w'
        Serial.println("WS data: " + wsData);
      } else if (receivedData.startsWith("p ")) {
        pData = receivedData.substring(2);  // Lấy chuỗi sau 'p'
        Serial.println("P data: " + pData);
      }
    }
  }
  
  // Nếu controlPin ở mức HIGH, ngừng nhận và gửi dữ liệu qua UART mỗi 3 giây
  else if (controlState == HIGH) {
    unsigned long currentMillis = millis();

    // Gửi dữ liệu cứ mỗi 3 giây
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      
      // Tạo chuỗi dữ liệu để gửi
      String dataToSend = "L " + latitudeLongitude + "\n" +
                          "w " + wsData + "\n" +
                          "p " + pData + "\n";
      
      // Gửi dữ liệu qua UART
      SerialPort.print(dataToSend);
      Serial.println("Data sent: " + dataToSend);
    }

    // Kiểm tra xem có nhận được tín hiệu "ok" qua UART không
    if (SerialPort.available()) {
      String response = SerialPort.readStringUntil('\n');
      Serial.println("Response: " + response);
      
      // Nếu nhận được "ok", phát còi 3 tiếng
      if (response == "ok") {
        for (int i = 0; i < 3; i++) {
          digitalWrite(buzzerPin, HIGH);  // Bật còi
          delay(500);  // Giữ còi trong 500ms
          digitalWrite(buzzerPin, LOW);   // Tắt còi
          delay(500);  // Tắt còi trong 500ms
        }
      }
    }
  }
}
