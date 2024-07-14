# todo_app

An WIP android app for tasks using Flutter and Firebase.

Demo: https://simonaskalpokas.github.io/todo_app/

## Development Milestones
- [x] Checked tasks
- [x] Timed tasks
- [x] Repeating tasks
- [ ] Amounted tasks
- [x] Subtasks/folders/lists
- [x] Main page
- [x] Moving/reordering tasks
- [ ] Notifications
- [x] Categories
- [ ] Filtering system
- [ ] [Nice UI](https://todo-app-git-ui-task-card-expand-simonaskalpokas1.vercel.app)
- [ ] Different users
- [ ] Custom backend
- [ ] E2E tests

## Quick Start

Install [Flutter](https://flutter.dev/).

Clone and run the repo:
```console
git clone https://github.com/SimonasKalpokas1/todo_app.git
cd todo_app
flutter run
```

## Debug setup on an android device on WSL

A little outdated but still great tutorial [here](https://halimsamy.com/wsl-for-developers-connect-usb-devices).

Required command **usbipd** can be installed with `winget install usbipd`.
1. Run in Command Prompt/Powershell:
    1. `usbipd list` to find needed device,
    2. `usbipd attach --wsl --busid {BUSID}`.
2. On wsl run `sudo adb start-server`.
3. Allow access in the popup on the android device.
4. Run `flutter devices` or `adb devices` to make sure the device is connected.
