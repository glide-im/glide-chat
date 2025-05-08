# glide chat

适配的平台：Android/iOS， Web/Windows/macOS

本项目需要依赖 [Glide Dart SDK](https://github.com/glide-im/glide_dart_sdk) 请将该仓库克隆到本项目同级目录下
才能正常使用，DartDK 包含即时通讯协议及基本的功能，例如协议，状态维护等。

### 运行

运行前先初始化 Realm 数据库

**Command**

```shell
dart run realm install
dart run realm generate
```

**入口**

不同平台需要使用不同的入口文件

- Windows/macOS
  - main_desktop.dart
- Android/iOS
  - main.dart
- Web
  - main_web.dart
