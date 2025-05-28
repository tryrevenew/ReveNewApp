# ReveNew – iOS Client Application

**ReveNew** is an open-source client application designed to seamlessly connect with your ReveNew backend server to track directly from your device all purchases happening across all your apps.

---

## 🚀 Getting Started

Follow these steps to quickly set up your ReveNew client application:

### 1. Server-side Setup

Ensure you've completed the [Server-Side Implementation](#) of ReveNew.

### 2. Create a Firebase Project (if you didn't do it while setting up the Server-Side)

- Navigate to the [Firebase Console](https://console.firebase.google.com/).
- Create a new Firebase project named **ReveNew**.
- Under **Authentication → Sign-in Methods**, enable **Apple Sign-in**.

### 3. Client-side Setup

Clone this repository:

```bash
git clone https://github.com/yourusername/ReveNew-iOS-Client.git
```
- Add your Firebase GoogleService-Info.plist file to the root of your cloned project directory.

### 4. Network Configuration

Open ReveNewApp.swift and configure your network details:

```bash
NetworkConfiguration.shared.configure(host: "your_server_host", port: your_server_port)
```
Replace your_server_host and your_server_port with your deployed server’s actual host and port.

📱 Usage

After completing the setup steps, build and run the application in Xcode:
  -	Open ReveNew.xcodeproj in Xcode.
  -	Select your preferred iOS simulator or a physical device.
  -	Click Run (⌘R) to launch the app.

 
⸻

🤝 Contributing

We encourage community contributions! To contribute:
  -	Fork this repository.
  -	Create a new feature branch: git checkout -b feature/your-feature-name.
  -	Commit your changes and submit a pull request clearly describing your additions or fixes.

⸻

📄 License

This project is open-source and available under the MIT License.
