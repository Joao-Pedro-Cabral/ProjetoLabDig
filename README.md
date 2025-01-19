# Magic Piano

Welcome to the Magic Piano project! This repository contains the implementation of a touchless piano system inspired by the Genius game. The project integrates FPGA-based logic, ESP32 microcontroller, and a digital twin to create a unique musical experience.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Hardware Requirements](#hardware-requirements)
- [Software Requirements](#software-requirements)
- [Architecture](#architecture)
- [Setup and Usage](#setup-and-usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The Magic Piano is a touchless instrument allowing users to play music by interacting with virtual keys. This is achieved through:
- Distance sensors to detect "key presses."
- A digital twin interface that replicates the piano on a computer screen.
- MQTT communication for real-time synchronization between the physical and digital components.

The project merges the functionality of the Genius Musical project with new features developed in the Digital Laboratory course.

## Features

1. **Touchless Interaction**:
   - Play virtual keys using an ultrasonic distance sensor.
2. **Dual Representation**:
   - Physical and digital twin representations for enhanced interaction.
3. **Game Modes**:
   - Single-player and multiplayer modes.
   - Adjustable difficulty levels.
4. **Real-time Feedback**:
   - LEDs and servomotor-controlled flags indicate victory or defeat.
5. **Audible Notes**:
   - Each virtual key triggers a specific musical note on the buzzer.
6. **Dynamic Visuals**:
   - A Python-based GUI using Pygame reflects the game state.

## Hardware Requirements

- 1 x FPGA Board (DE0-CV recommended)
- 1 x ESP32 microcontroller
- 1 x Ultrasonic distance sensor (HC-SR04)
- 2 x Servomotors
- 1 x Buzzer (5V passive)
- Miscellaneous: Resistors, cables, power supply

## Software Requirements

- **FPGA Tools**:
  - Intel Quartus Prime
  - ModelSim
- **Microcontroller Tools**:
  - Arduino IDE for ESP32 programming
- **Python Environment**:
  - Python 3.x
  - Pygame library
  - MQTT library (`paho-mqtt`)

## Architecture

The system architecture includes:
1. **Control Unit**:
   - Implements the game logic on the FPGA using VHDL.
2. **Data Flow Unit**:
   - Handles sensor input, serial communication, and PWM signals for the servos and buzzer.
3. **ESP32 Module**:
   - Bridges the physical system with the digital twin via MQTT.
4. **Digital Twin**:
   - Python-based interface displaying the piano and game status.

## Setup and Usage

### 1. Hardware Assembly
- Connect the components to the FPGA as per the pinout table in the report.
- Integrate the ESP32 and sensor with the FPGA for communication.

### 2. FPGA Programming
- Compile the VHDL code in Quartus Prime.
- Load the compiled program onto the FPGA using a USB-Blaster.

### 3. ESP32 Configuration
- Flash the ESP32 with the provided Arduino code.
- Ensure it connects to an MQTT broker.

### 4. Python Digital Twin
- Install the required Python libraries using `pip`.
  ```bash
  pip install pygame paho-mqtt
  ```
- Run the GUI with:
  ```bash
  python main.py
  ```

### 5. Gameplay
- Power on the system and follow the game instructions via the GUI or physical interface.
- Adjust game settings such as mode and difficulty through the GUI.

## Contributing
Contributions are welcome! Please fork the repository, create a feature branch, and submit a pull request.

---

Enjoy making music with the Magic Piano! 🎵
