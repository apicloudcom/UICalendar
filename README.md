# 概述

可滑动查看的日历模块（内含iOS和Android）

APICloud 的 UICalendar 模块是一个原生代码封装的日历模块。目的是为了让 APICloud 的广大开发者只需用 html+js 即可快速、高效的集成炫酷的日历到自己的 App 内。由于本模块 UI 布局界面为固定模式，不能满足日益增长的广大开发者对侧滑列表模块样式的需求。因此，广大原生模块开发者，可以参考此模块的开发方式、接口定义等开发规范，或者基于此模块开发出更多符合产品设计的新 UI 布局的模块，希望此模块能起到抛砖引玉的作用。

## 模块接口文档

<p style="color: #ccc; margin-bottom: 30px;">来自于：官方</p>

<div class="outline">

[open](#open)
[setSpecialDates](#setSpecialDates)
[cancelSpecialDates](#cancelSpecialDates)
[close](#close)
[show](#show)
[hide](#hide)
[nextMonth](#nextMonth)
[prevMonth](#prevMonth)
[nextYear](#nextYear)
[prevYear](#prevYear)
[setDate](#setDate)
[turnPage](#turnPage)

</div>

## **模块概述**

UICalendar 是一个日历选择模块；可自定义日历的样式，添加特殊日期标注，切换月份，设置指定日期；用于实现常用的日期选择，日历展示功能。**UICalendar 模块是 calendar 模块的优化版。**

注：针对单日的样式优先级序列为：

selected>setSpecialDate>specialDate>styles_specialDate>today

模块截图：

![图片说明](http://docs.apicloud.com/img/docImage/UICalendar.jpg)


## [实例widget下载地址](https://github.com/apicloudcom/UICalendar-Example/archive/master.zip)



# 模块接口

<div id="open"></div>

# **open**

打开日历

open({params}, callback(ret))

## params

multipleSelect：

- 类型：布尔类型
- 描述：（可选项）是否可以多选日期
- 默认值：false

rect：

- 类型：JSON 对象
- 描述：（可选项）模块的位置及尺寸
- 内部字段：

```js
{
    x: 0,   //（可选项）数字类型；模块左上角的 x 坐标（相对于所属的 Window 或 Frame）；默认：0
    y: 0,   //（可选项）数字类型；模块左上角的 y 坐标（相对于所属的 Window 或 Frame）；默认：0
    w: 320, //（可选项）数字类型；模块的宽度；默认：所属的 Window 或 Frame 的宽度
    h: 220  //（可选项）数字类型；模块的高度；默认：220
}
```

styles：

- 类型：JSON 对象
- 描述：（可选项）模块各部分的样式
- 内部字段：

```js
{
    bg: 'rgba(0,0,0,0)',            //（可选项）字符串类型；日历整体背景，支持 rgb、rgba、#、图片路径，要求本地路径（fs://、widget://）；默认：'rgba(0,0,0,0)'
    week: {                         //（可选项）JSON对象，星期的样式
        weekdayColor: '#3b3b3b',    //（可选项）字符串类型；平日文字的颜色，支持 rgb、rgba、#；默认：'#3b3b3b'
        weekendColor: '#a8d400',    //（可选项）字符串类型；周末文字的颜色，支持 rgb、rgba、#；默认：'#a8d400'
        size: 24                    //（可选项）数字类型；星期文字的大小；默认：24
    },
    date: {                         //（可选项）JSON对象，普通日期的样式
        color: '#3b3b3b',           //（可选项）字符串类型；普通日期文字的颜色；支持 rgb、rgba、#；默认：'#3b3b3b'
        selectedColor: '#fff',      //（可选项）字符串类型；普通日期选中后的文字颜色，支持 rgb、rgba、#；默认：'#fff'
        selectedBg: '#a8d500',      //（可选项）字符串类型；普通日期选中后的背景，支持 rgb、rgba、#，图片路径，要求本地路径（fs://、widget://）；默认：'#a8d500'
        size: 24                    //（可选项）数字类型；普通日期文字的大小；默认：24
    },
    today: {                        //（可选项）JSON对象，设备当前日期的样式
        color: '#a8d500',           //（可选项）字符串类型；当前日期的文字颜色，支持 rgb、rgba、#；默认：'#a8d500'
        bg: 'widget://'             //（可选项）字符串类型；当前日期的背景，支持 rgb、rgba、#，图片路径，要求本地路径（fs://、widget://）
    },
    specialDate: {                  //（可选项）JSON对象，需要标记的特殊日期的通用样式                  
        color: '#3b3b3b',           //（可选项）字符串类型；文字颜色，支持 rgb、rgba、#；默认：与普通日期文字颜色一致
        bg: 'widget://'             //（可选项）字符串类型；支持 rgb、rgba、#，图片路径，要求本地路径（fs://、widget://）；默认：与普通日期选中后的背景一致
    }
}
```

specialDate：

- 类型：数组
- 描述：（可选项）需要标记的特殊日期数组
- 内部字段：

```js
[{
    date: '2015-07-27'          //字符串类型；日期字符串，格式为：yyyy-MM-dd
    color: '#3b3b3b',           //（可选项）字符串类型；文字颜色，支持 rgb、rgba、#；默认：与 styles->specialDate->color 一致
    bg: 'widget://'             //（可选项）字符串类型；支持 rgb、rgba、#，图片路径，要求本地路径（fs://、widget://）；默认：与 styles->specialDate->bg 一致
}]
```

switchMode：

- 类型：字符串
- 描述：（可选项）月份的切换方式
- 默认值：'vertical'
- 取值范围：
    - vertical（上下切换）
    - horizontal（左右切换）
    - none（不支持通过手势切换月份）

fixedOn：

- 类型：字符串类型
- 描述：（可选项）模块视图添加到指定 frame 的名字（只指 frame，传 window 无效）
- 默认：模块依附于当前 window

fixed：

- 类型：布尔
- 描述：（可选项）模块是否随所属 window 或 frame 滚动
- 默认值：true（不随之滚动）

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    eventType: 'show',          //字符串类型；交互事件类型
                                //取值范围：
                                //show（日历显示）
                                //switch（水平或垂直切换月份）
                                //special（点击特殊日期）
                                //normal（点击普通日期）
                                //cancelNormal（取消点击普通日期）
                                //cancelSpecial（取消点击特殊日期）
                                                                                                
	year: 2015,                 //数字类型；当前选择的年份
	month: 7,                   //数字类型；当前选择的月份
	day: 27                     //数字类型；当前选择的日期
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.open({
	rect: {
		x: 30,
		y: api.frameHeight / 2 - 170,
		w: api.frameWidth - 60,
		h: 340
	},
	styles: {
		bg: 'rgba(0,0,0,0)',
		week: {
			weekdayColor: '#3b3b3b',
			weekendColor: '#a8d400',
			size: 12
		},
		date: {
			color: '#3b3b3b',
			selectedColor: '#fff',
			selectedBg: '#a8d500',
			size: 12
		},
		today: {
			color: 'rgb(230,46,37)',
			bg: ''
		},
		specialDate: {
			color: '#a8d500',
			bg: 'widget://image/a.png'
		}
	},
	specialDate: [{
		date: '2015-06-01'
	}],
	switchMode: 'vertical',
	fixedOn: api.frameName,
	fixed: false
}, function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="setSpecialDates"></div>

# **setSpecialDates**

设置特殊日期

setSpecialDates({params})

## params

specialDates：

- 类型：数组
- 描述：需要标记的特殊日期数组，格式为：yyyy-MM-dd
- 内部字段：

```js
[{
    date: '2015-07-27'          //字符串类型；日期字符串，格式为：yyyy-MM-dd
    color: '#3b3b3b',           //（可选项）字符串类型；文字颜色，支持 rgb、rgba、#；默认：与 styles->specialDate->color 一致
    bg: 'widget://'             //（可选项）字符串类型；支持 rgb、rgba、#，图片路径，要求本地路径（fs://、widget://）；默认：与 styles->specialDate->bg 一致
}]
```
## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.setSpecialDates({
	specialDates: [{
		date: '2015-12-07',
		color: '#abckde',
		bg: '#ff0000'
	}, {
		date: '2015-12-08',
		color: '#abckde',
		bg: '#ff0000'
	}]
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="cancelSpecialDates"></div>

# **cancelSpecialDates**

取消已设置的特殊日期状态

cancelSpecialDates({params})

## params

specialDates：

- 类型：数组
- 描述：需要取消的特殊日期组成的数组，格式为：yyyy-MM-dd

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.cancelSpecialDates({
	specialDates: ['2015-12-08', '2015-12-07']
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="close"></div>

# **close**

关闭日历

close()

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.close();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="show"></div>

# **show**

显示日历

show()

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.show();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="hide"></div>

# **hide**

隐藏日历

hide()

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.hide();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="nextMonth"></div>

# **nextMonth**

显示下个月

nextMonth(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
	year: '2015',          //数字类型；当前显示的年份
	month: '8'             //数字类型；当前显示的月份
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.nextMonth(function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="prevMonth"></div>

# **prevMonth**

显示上个月

prevMonth(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    year: '2015',          //数字类型；当前显示的年份
    month: '6'             //数字类型；当前显示的月份
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.prevMonth(function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="nextYear"></div>

# **nextYear**

显示下一年

nextYear(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    year: '2016',          //数字类型；当前显示的年份
    month: '6'             //数字类型；当前显示的月份
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.nextYear(function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="prevYear"></div>

# **prevYear**

显示上一年

prevYear(callback(ret, err))

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    year: '2014',          //数字类型；当前显示的年份
    month: '6'             //数字类型；当前显示的月份
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.prevYear(function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="setDate"></div>

# **setDate**

设置选中日期（不支持日期多选模式）

setDate({params}, callback(ret))

## params

date：

- 类型：字符串
- 描述：（可选项）选中日期，格式为：yyyy-MM-dd
- 默认值：当前日期

ignoreSelected：

- 类型：布尔
- 描述：（可选项）选中日期是否忽略选中日期样式（open -> styles -> date -> selectedColor、selectedBg）
- 默认值：false

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    status: true        //布尔型；true||false
}
```

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.setDate({
	date: '2015-08-08',
	ignoreSelected: false
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="turnPage"></div>

# **turnPage**

翻到指定的页

turnPage({params})

## params

date：

- 类型：字符串
- 描述：选中日期，格式为：yyyy-MM

## 示例代码

```js
var UICalendar = api.require('UICalendar');
UICalendar.turnPage({
	date: '2015-08'
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本
