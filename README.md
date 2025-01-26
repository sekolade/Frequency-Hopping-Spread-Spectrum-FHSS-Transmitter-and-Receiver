# EE430 Term Project: Frequency-Hopping Spread Spectrum Communication System

## Project Overview
This repository contains the implementation of a Frequency-Hopping Spread Spectrum (FHSS) communication system as part of the EE430 Digital Signal Processing course at METU. The project involves the design of a transmitter and receiver system capable of generating, transmitting, receiving, and decoding FHSS signals. It covers both Part 1 and Part 2 requirements as outlined in the project description.

### Features
1. **FHSS Transmitter and Receiver**:
   - Implements 2-FSK, 4-FSK, and 8-FSK modulation schemes.
   - Supports three communication categories with different parameters (hop period, frequency separation, etc.).

2. **Noise Reduction**:
   - Employs bandpass Butterworth filters and cross-correlation techniques to reduce noise.

3. **Graphical User Interface (GUI)**:
   - User-friendly GUIs for both transmitter and receiver to input parameters and visualize results.

4. **Spectrogram Analysis**:
   - Time-frequency representation of signals using Short-Time Fourier Transform (STFT).

---

## Repository Structure
```plaintext
.
├── transmitter.m         # MATLAB script for transmitter functionality
├── transmitter.mlapp     # MATLAB GUI for transmitter
├── receiver.m            # MATLAB script for receiver functionality
├── receiver.mlapp        # MATLAB GUI for receiver
├── README.md             # Project documentation
└── figures/              # Placeholder for figures used in README and documentation
```

---

## System Requirements
- MATLAB R2022b or later
- Signal Processing Toolbox

---

## How to Run the Project

### Setting Up the Transmitter
1. Open the `transmitter.mlapp` file in MATLAB's App Designer.
2. Enter the desired text message, select modulation parameters (e.g., hop period, M-FSK, etc.), and configure spectrogram settings.
3. Generate the FHSS signal and visualize the spectrogram on the GUI.

### Setting Up the Receiver
1. Open the `receiver.mlapp` file in MATLAB's App Designer.
2. Configure the sampling rate and recording duration.
3. Record the transmitted signal, decode it, and view the spectrogram before and after noise reduction.

---

## Project Details

### 1. Frequency-Hopping Spread Spectrum (FHSS)
FHSS spreads the information signal over a wider bandwidth by rapidly changing carrier frequencies. This method offers several advantages:
- Resistance to narrowband interference.
- Difficulty in interception and jamming.
- Minimal interference with other narrowband communications.

### 2. Modulation Schemes
The project uses the following modulation schemes:
- **2-FSK:** Maps each bit to one of two frequencies.
- **4-FSK:** Maps two bits to one of four frequencies.
- **8-FSK:** Maps three bits to one of eight frequencies.

### 3. Categories of Communication
The system supports three categories:

| Category | Hop Period (s) | Modulation | Frequency Separation (Hz) | Bandwidth (Hz) | Min Data Length |
|----------|----------------|------------|----------------------------|----------------|-----------------|
| 1        | 1.0            | 2-FSK      | 100                        | 4000           | 5               |
| 2        | 0.75           | 4-FSK      | 150                        | 7000           | 20              |
| 3        | 0.50           | 8-FSK      | 200                        | 10000          | 30              |

### 4. Noise Reduction
- Bandpass Butterworth filters isolate the frequency bands of interest.
- Cross-correlation detects pilot tones for synchronization.

---

## Example Demonstrations

### Transmitter Output
- **Category 1 Example:**
  - Message: `101101`
  - Spectrogram:

    ![Transmitter Spectrogram](figures/transmitter_spectrogram.png)

### Receiver Output
- **Category 1 Example:**
  - Decoded Message: `101101`
  - Spectrograms:

    - Without Noise Reduction:
      ![Receiver Spectrogram Without Noise](figures/receiver_spectrogram_no_noise.png)
    
    - With Noise Reduction:
      ![Receiver Spectrogram With Noise](figures/receiver_spectrogram_with_noise.png)

---

## Contributing
Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.

---

## License
This project is for educational purposes only and is not licensed for commercial use.
