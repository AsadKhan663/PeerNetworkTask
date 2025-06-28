
# 🎥 Peer Network Video Feed App

A TikTok-style video feed built with SwiftUI. This native iOS app demonstrates smooth scrolling, autoplaying videos, like gestures, and toggling between short and full video versions. Designed to simulate a social media video experience using a mock backend.

---

## ✅ Core Features

- Smooth vertical video feed with infinite scrolling and autoplay when videos are mostly visible
- Automatic pause when videos scroll out of view and retry option if a video fails to load
- Double-tap to like with heart animation, along with comment and share actions
- Toggle between short (looping) and full video versions with  controls
- Full video mode includes seek bar, play/pause functionality, and fullscreen behavior


---

## 🧱 Architectural Decisions


The app is built using **MVVM with Clean Architecture** principles to ensure clarity, scalability, and testability.

This structure separates concerns into clear, manageable layers, making the codebase easier to extend, test, and maintain. Each layer has a single responsibility, allowing for better debugging and future feature integration without breaking existing functionality.

### 🏗️ Layers Breakdown

| Layer          | Purpose                                                       |
|----------------|---------------------------------------------------------------|
| **Model**      | Defines `Video`, `Creator` structures                         |
| **ViewModel**  | Handles app state, like logic, pagination, visibility toggling|
| **UseCase**    | Executes business logic for video fetching and liking                       |
| **Repository** | Abstracts access to data source                               |
| **DataSource** | Loads data from `videos.json` and simulates network errors    |
| **View**       | SwiftUI views (`VideoFeedView`, `VideoCellView`, `VideoPlayerView`) |
| **Utilities**  | Extensions for layout, visibility, icons, etc.                |

This layered approach ensures that UI code remains clean and free from networking or data logic, making it easier to manage, test, and scale the app over time.

---

## 🚀 How to Run the App

### 🧰 Requirements
- Xcode 14 or higher
- iOS 17+
- Swift 5.7+

---

## 🛠️ Installation & Setup

Follow these steps to set up and run the project locally:

### 🧰 Requirements
1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/peer-network-video-app.git
   cd peer-network-video-app


 2. **Open the Project in Xcode**
    ```bash
     open PeerNetworkTask.xcodeproj
    

3. **Build and Run the App** 
- Choose an iOS Simulator or a connected device
- Press ⌘R or click the Run button in the toolbar



