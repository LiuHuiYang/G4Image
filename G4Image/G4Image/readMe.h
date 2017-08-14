/*
    Author: Mark Liu
    E-mail: liuhuiyang2009@163.com
    部署地址: https://github.com/LiuHuiYang/G4Image
 
 > 详细说明
    
    1.当前版本是V2.0 是对1.2.1中使用MRC以及不匹配iOS8.0以上版本进行适配。
    
    2.当前socket通信是支持前后台的，如果需要不支持后台，在shUdpSocket这个类中增加通知来监听系统的程序是否进入前台或后台进行关闭与打开socket。
 
 修改日志:
    V2.0 
        全部重新设计数据库
        使用ARC机制全部重写代码
        更改按钮图片
 
    V2.0.1
        更改通用设置界面为个性化设置界面
        修复音乐不能播放的bug
 
    V2.0.2 
        取消窗帘的解析数据 -> 解决总是不断切换 open && close的标题

    V2.1.0
        修改设备的图标及大小
        修改LED的控制方式
        修改空调的控制方式
        修改App中的UI的部分细节
 
    V2.1.1 
        修复iPad中空调控制面板关闭后，其余设备的数据同步问题。
    V2.1.2 
        修改出现空调控制面板的方式为长按
 
    =============发布说明=====================
 
 调试ID: Mark.G4Image
 
 开发者账号:
    Username: Smart-hdl
    Password: appl@@MaxSep16
 
 发布 证书是： SH G4Image
 
 发布 Bundle ID 是：com.SmartHome.G4Image

    检测代码是否使用了IDFA：
        grep -r advertisingIdentifier .  // 最后这个点不要忘记了
 
 测试图片： https://image.baidu.com/search/detail?ct=503316480&z=3&ipn=d&word=家居摄影图片&step_word=&hs=0&pn=278&spn=0&di=43675242050&pi=0&rn=1&tn=baiduimagedetail&is=0%2C0&istype=2&ie=utf-8&oe=utf-8&in=&cl=2&lm=-1&st=-1&cs=1471743946%2C436153727&os=889003505%2C588814333&simid=4167560949%2C534311626&adpicid=0&lpn=0&ln=1983&fr=&fmq=1494574823262_R&fm=result&ic=0&s=undefined&se=&sme=&tab=0&width=0&height=0&face=undefined&ist=&jit=&cg=&bdtype=0&oriquery=&objurl=http%3A%2F%2Fpic36.nipic.com%2F20131214%2F13935674_175856656106_2.jpg&fromurl=ippr_z2C%24qAzdH3FAzdH3Fooo_z%26e3Bgtrtv_z%26e3Bv54AzdH3Fzi7wgptAzdH3F89n8ldn_z%26e3Bip4s&gsm=f0&rpstart=0&rpnum=0
 

 测试使用的参数
 demokit
    普通灯泡: SubNetID : 1  DeviceID:   223
    LED :    SubNetID : 1  DeviceID:   224
    AC :     SubNetID : 1  DeviceID:   222
    Music:   SubNetID: 1   DeviceID: 2  221
 ceo:
    窗帘:               1             248  / 2open - 1cose
    AC: 1 - 52
    led: 1 - 167
 */
