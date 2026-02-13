<div align="center">
  <img src="images/icon.png" alt="Logo" width="100" height="100">

  # Miao3trike Flutter

  <p align="center">
    一个可以更改明日方舟PC版键位的小工具
    <br />
    <a href="https://github.com/Hollow-YK/ArknightsKeyTool/issues">报告 Bug</a>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Platform-Windows-blue?style=flat-square&logo=windows" alt="Platform" />
    <img src="https://img.shields.io/badge/Language-Dart-blue?style=flat-square&logo=dart" alt="Language" />
    <img src="https://img.shields.io/badge/License-GPLV3-blue?style=flat-square" alt="License" />
    <img src="https://img.shields.io/github/stars/Hollow-YK/ArknightsKeyTool?style=flat-square&logo=github&color=darkgreen" alt="Stars" />
  </p>
</div>

---

## 下载与安装

请前往[Release](https://github.com/Hollow-YK/ArknightsKeyTool/releases)下载。

## 简介

**ArknightsKeyTool** 是一个用于更改明日方舟PC版键位的小工具。

> [!Tip]
>
> **请先下载并安装明日方舟PC版并启动一次游戏。更改会在下一次启动明日方舟PC版时生效**

> [!Tip]
>
> 使用本软件设置好之后，启动明日方舟时无需启动本软件。

### 功能介绍

核心功能：

- 更改明日方舟PC版键位
- 自定义暂停键且保留ESC返回功能

其它功能：

- 自定义深色/浅色主题
- 检查更新

### 画大饼

以后有概率添加的功能，括号里是可能需要的时间
带星号的项目以目前作者水平来说难以实现
按开发者认为的优先级排序
*开发者认为的优先级是综合了功能重要性、开发者技术水平、功能开发难度后进行的综合排序，若有不同意见请自行实现这些功能。

- 支持更多预定义键位(长期)

### 使用教程

1. 保证你下载并安装了PC版明日方舟。
2. 打开本工具，若提示“未找到键盘设置”时请先正常启动一次明日方舟PC版。
3. 点击需要修改的按键右侧的“修改”按钮，在弹出的对话框中输入或选择你想要的 keyId（鹰角使用的keyId，而非键值）。
4. 修改完成后，点击底部的“保存更改”按钮。
5. 修改后的配置将在下一次启动舟PC时生效。

### 关于 keyId

<details><summary>点击查看 keyId 规则</summary>

• 数字键 0~9 → numX（例如 num0 对应 0 键）
• 字母键 A~Z → alphaX（例如 alphaF 对应 F 键）
• 功能键 → keyX
• Esc 键 → bannedEscape
上面这些已经在软件内有预定义了。

目前已知可用的功能键
• Tab 键 → keyTab
• Space 键 → keySpace

<details>

### 常见问题

<details>


Q：修改后游戏内没有生效？
A：请确认你修改后点击了“保存”。如果游戏正在运行，建议重启游戏。

Q：为什么 ESC 键是灰色的？
A：ESC 键功能特殊，为防止出现问题，作者决定将其锁定为不可使用。

Q：如何恢复默认设置？
A：本工具不直接提供恢复默认功能。

Q：暂停键为什么显示“默认”？
A：游戏原生注册表中不包含暂停键，因此首次打开时显示“默认”。但是舟PC实际上支持单独设置暂停键，所以作者添加了这一项。当你修改暂停键后，该字段才会被写入注册表，否则暂停键会像没有更改过一样与ESC绑定。',


</details>

## 开发相关

<details><summary>自行编译</summary>

### 自行编译

1. clone本仓库
2. 完成 `flutter pub get`
3. 执行 `flutter build windows --release` 进行编译

### 贡献代码

直接提pr就行

</details>

## 致谢

### 开源项目

- 使用了 [Flutter](https://github.com/flutter/flutter) 框架与很多 Flutter 的包

### 其它

- 使用Flutter进行开发
- ~~`README.md`部分照抄了我的另一个仓库的README~~
- `README.md`参考了部分开源项目
- `README.md`使用了 [shields.io](https://shields.io/) 提供的内容

### 贡献/参与者

感谢所有参与到开发/测试中的朋友们(\*´▽｀)ノノ