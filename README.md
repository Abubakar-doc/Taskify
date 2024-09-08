# Taskify – Streamlined Task Management Solution

🚀 **Introducing Taskify!** 🚀  
Taskify is a cross-platform task management application developed using Flutter, designed to simplify the process of assigning, managing, and tracking tasks within an organization. With seamless real-time updates, secure authentication via Firebase, and a fully-featured admin panel, Taskify ensures that both employees and admins stay organized and productive.

## 🌟 Features

### Mobile Application (Android & Web)
- **🔐 Robust Authentication**
  - Employees can apply for registration, and upon admin approval, access their assigned tasks.
  
- **📋 Task Overview**
  - View and manage tasks assigned by the admin, track progress, and stay updated on deadlines.
  
- **📱 Real-time Updates**
  - Receive instant notifications about task updates and changes directly from the admin.
  
- **💬 Chat with Admin**
  - In-app messaging feature allows employees to communicate directly with the admin for any clarifications or discussions about tasks.

- **🔧 Task Management**
  - Mark tasks as completed, manage active assignments, and ensure timely submission of all tasks.

### Admin Panel (Web-based)
- **🔹 Department Management**
  - Create and manage departments for better organization.
  
- **🔹 Member Management**
  - Approve or reject member registration requests.
  - Assign employees to specific departments based on their roles.

- **🔹 Task Management**
  - Create tasks and assign them to specific members.
  - Reallocate tasks as needed.
  - Review and evaluate completed tasks.

- **🔹 Performance & Reporting**
  - Monitor task performance and generate detailed reports to track efficiency and productivity across the organization.

## 📲 Technologies Used
- **Flutter**: Cross-platform development framework.
- **Firebase**: For secure authentication and real-time database features.
- **flutter_styled_toast**: Toast notifications for improved user experience.
- **provider**: State management for the app.
- **simple_icons**: Icon package for consistent and elegant design.
- **drop_down_search_field**: Dropdown functionality for selecting tasks, users, and departments.
- **firebase_core**: Integration with Firebase services.
- **firebase_auth**: User authentication via Firebase.
- **cloud_firestore**: Real-time database integration for task and user management.
- **multi_dropdown**: Dropdown for multi-select functionality.
- **intl**: Internationalization support for date and time formats.
- **rxdart**: Stream management and reactive programming support.
- **pdf**: Export task reports and performance evaluation into PDF format.

## 📂 Project Structure
This repository contains the following folders:

- **lib/**: Main Dart files and Flutter project structure.
- **assets/**: Contains app icons and other graphical assets.
- **firebase/**: Firebase configuration and initialization files.
- **web/**: Web-related configuration and files for Flutter web support.

## 🎬 Demo Videos
Check out the videos showcasing the mobile and web app functionalities:

### Mobile App and Web Admin Panel Demo
https://github.com/user-attachments/assets/32dc2bb1-cf1c-4f29-ac5d-6d27bca028b1

## 🔧 Installation and Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Abubakar-doc/taskify.git
   ```
   
2. Navigate to the project directory:
   ```bash
   cd taskify
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up Firebase:
   - Create a Firebase project and add your app's configuration.
   - Add the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in the appropriate folders.

5. Run the app:
   ```bash
   flutter run
   ```

---

Stay organized, stay productive with **Taskify**! 💼
