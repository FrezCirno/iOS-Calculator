# iOS应用开发练习2 - 计算器

> Author 谭梓煊 (1853434)

> Github [UIKit版](https://github.com/FrezCirno/ios-calc-uikit.git) [SwiftUI版](https://github.com/FrezCirno/ios-calc-swiftui.git)

[TOC]

## 一、概述

    使用UIKit和SwiftUI分别开发一个计算器应用程序。具体要求如下：

1. 使用UIKit开发计算器

    - [x] 使用MVC架构进行计算器开发，代码中需要包括Model、View、Controller的部分

    - [x] 使用AutoLayout，使得计算器能够在不同的iPhone和iPad上正常显示

    - [x] 通过测试的设备(由小到大): iPod touch(7th), iPhone 8 SE, iPad(8th)

2. 使用SwiftUI开发计算器

    - [x] 使用MVVM架构进行计算器开发

    - [x] 计算器能够在不同的iPhone和iPad上正常显示
    
    - [x] 通过测试的设备(由小到大): iPod touch(7th), iPhone 8 SE, iPad(8th)

3. 奖励部分（选做）

    - [x] 计算器支持多步计算（需要支持运算符优先级、小括弧等）

    - [x] 支持的运算符: 加&正<kbd>+</kbd>, 减&负<kbd>-</kbd>, 乘<kbd>*</kbd>, 除<kbd>/</kbd>, 乘方<kbd>^</kbd>, 取模<kbd>%</kbd>, 开根号<kbd>√</kbd>

    - [x] 支持小括弧<kbd>(</kbd><kbd>)</kbd>

    - [x] 支持运算符优先级


## 二、代码实现

### 1. 计算器核心逻辑

计算器的核心逻辑位于`Core.swift`文件中, 主要包括一个`eval(_ : String) throws -> Double`函数, 用于求解一个字符串表达式. **两个版本的计算器的核心求解器完全一样**.

#### 1.1 算法

`eval`函数内部实现了经典的基于栈的表达式求解算法, 支持运算符优先级和小括号

使用了两个栈: 一个操作数栈`opnd: [Double]` + 一个操作符栈`optr: [Optr]`

- while 运算符栈不空

    - 每次从输入字符串中读取一个字符

    - 如果是数字, 则调用`Scanner`类的`scanDouble`方法解析一个数字, 读取指针后移

    - 否则是运算符, 首先调用`dispatch`函数判断运算符类型, 某些多义运算符, 如减号和负号, 根据前一个字符的类型来区别

        - 判断运算符栈顶的运算符和当前运算符的优先级 (通过查表法)

        - 如果当前运算符优先级较高: 将当前运算符压栈

        - 如果栈顶运算符优先级较高: 从操作数栈中弹出一或两个操作数, 从运算符栈中弹出一个运算符, 进行运算后压回

        - 否则: 从运算符栈中弹出一个运算符

- 则操作数栈所剩的数字为最终结果

为方便处理, 在算法开始时, 向运算符栈中和表达式末尾都添加一个`=`.

#### 1.2 错误处理

程序定义了三种错误, 分别为算术错误、语法错误和输入错误.

- 算数错误包括除以0, 对0取模, 对负数开根号等;

- 语法错误表示输入表达式中运算符的顺序不正确等;

- 输入错误表示输入表达式中有未知字符.

```swift
enum CalcError: Error {
    case ArithmeticError(detail: String)
    case SyntaxError(detail: String)
    case InputError(detail: String)
}
```

### 2. UI 设计 (UIKit 版)

- UIKit 版的计算器 UI 完全使用 StoryBoard 绘制

| 类型      | 数量 |
| --------- | ---- |
| button    | 23   |
| stackView | 7    |
| label     | 1    |

- 每行`button`使用一个水平`stackView`包裹, 所有`button`行使用一个竖直`stackView`包裹, 最终与`label`并列.

### 3. UI 设计 (SwiftUI 版)

- SwiftUI 版的计算器 UI 与 UIKit 版大体相同, 不同之处在于 SwiftUI 版完全使用代码定义, 在一些细节上比 UIKit 版更加精致

| 类型   | 数量 |
| ------ | ---- |
| Text   | 24   |
| Button | 23   |
| HStack | 7    |
| Spacer | 3    |
| VStack | 2    |
| Color  | 1    |
| ZStack | 1    |

## 三、运行截图

### 1. UIKit 版

| 设备 | 表达式                                              | 结果                                                |
|---- |--------------------------------------------------- | --------------------------------------------------- |
| iPod touch(7th) |<img src="./images/uikit/ipod1.png" width="300" /> | <img src="./images/uikit/ipod1r.png" width="300" /> |
| iPod touch(7th) |<img src="./images/uikit/ipod2.png" width="300" />  | <img src="./images/uikit/ipod2r.png" width="300" /> |
| iPod touch(7th) |<img src="./images/uikit/ipod3.png" width="300" />  | <img src="./images/uikit/ipod3r.png" width="300" /> |
| iPhone 12 Pro Max |<img src="./images/uikit/iphone1.png" width="300" />  | <img src="./images/uikit/iphone1r.png" width="300" /> |
| iPhone 12 Pro Max |<img src="./images/uikit/iphone2.png" width="300" />  | <img src="./images/uikit/iphone2r.png" width="300" /> |
| iPhone 12 Pro Max |<img src="./images/uikit/iphone3.png" width="300" />  | <img src="./images/uikit/iphone3r.png" width="300" /> |
| iPad(8th) |<img src="./images/uikit/ipad1.png" width="300" />  | <img src="./images/uikit/ipad1r.png" width="300" /> |
| iPad(8th) |<img src="./images/uikit/ipad2.png" width="300" />  | <img src="./images/uikit/ipad2r.png" width="300" /> |
| iPad(8th) |<img src="./images/uikit/ipad3.png" width="300" />  | <img src="./images/uikit/ipad3r.png" width="300" /> |

### 2. SwiftUI 版

| 设备 | 表达式                                              | 结果                                                |
|---- |--------------------------------------------------- | --------------------------------------------------- |
| iPod touch(7th) |<img src="./images/swiftui/ipod1.png" width="300" /> | <img src="./images/swiftui/ipod1r.png" width="300" /> |
| iPod touch(7th) |<img src="./images/swiftui/ipod2.png" width="300" />  | <img src="./images/swiftui/ipod2r.png" width="300" /> |
| iPod touch(7th) |<img src="./images/swiftui/ipod3.png" width="300" />  | <img src="./images/swiftui/ipod3r.png" width="300" /> |
| iPhone SE(2nd) |<img src="./images/swiftui/iphone1.png" width="300" />  | <img src="./images/swiftui/iphone1r.png" width="300" /> |
| iPhone SE(2nd) |<img src="./images/swiftui/iphone2.png" width="300" />  | <img src="./images/swiftui/iphone2r.png" width="300" /> |
| iPhone SE(2nd) |<img src="./images/swiftui/iphone3.png" width="300" />  | <img src="./images/swiftui/iphone3r.png" width="300" /> |
| iPhone 8 Plus |<img src="./images/swiftui/ipad1.png" width="300" />  | <img src="./images/swiftui/ipad1r.png" width="300" /> |
| iPhone 8 Plus |<img src="./images/swiftui/ipad2.png" width="300" />  | <img src="./images/swiftui/ipad2r.png" width="300" /> |
| iPhone 8 Plus |<img src="./images/swiftui/ipad3.png" width="300" />  | <img src="./images/swiftui/ipad3r.png" width="300" /> |








