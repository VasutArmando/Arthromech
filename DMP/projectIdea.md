# Project Proposal: Prosthetic hand

## 1. Project Overview
 An **ESP32** serves as the primary controller and direct servomotor actuation—while an **Arduino Uno** acts as a secondary node communicating via **I2C**, complete with a hardware interrupt-driven emergency stop system.

---

## 2. System Architecture & Hardware Components

To implement this:

* **Primary Hand Controller ($1 \times$ ESP32):**
  * *Hardware:* $1 \times$ **ESP32**.
  * *Function:* Acts as the primary onboard controller, managing direct PWM generation to actuate the servomotor(s), running internal logic, and managing wireless communication protocols.
* **Secondary Controller & Safety Node ($1 \times$ Arduino Uno):**
  * *Hardware:* $1 \times$ **Arduino Uno** and $1 \times$ **Push Button** (tactile switch).
  * *Function:* Processes local sensor or command inputs and communicates with the ESP32 via I2C. The push button is wired to an external hardware interrupt pin to instantly trigger an emergency halt, overriding all operations for safety compliance.
* **Actuation Mechanism ($1 \times$ Servo):**
  * *Hardware:* $1 \times$ **MG90S servomotor**
  * *Function:* Controls the angular movement and finger tension of the prosthetic mechanism under the direction of the ESP32.
* **Voltage Level Shifting ($5\text{V}$ to $3.3\text{V}$):**
  * *Hardware:* Resistors configured as a **voltage divider** (or a dedicated logic level converter).
  * *Function:* Steps down the $5\text{V}$ I2C or serial data lines from the Arduino Uno to safe $3.3\text{V}$ logic levels required by the ESP32 GPIO pins, preventing hardware damage.
* **Wireless Communication:**
  * *Hardware:* Built-in **ESP32 Wi-Fi / Bluetooth module**.
  * *Function:* Enables remote smartphone control.