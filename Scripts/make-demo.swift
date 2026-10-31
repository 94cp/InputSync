// Generate an entirely fictional macOS demonstration; never captures any screen.
// Run from the repository root: swift Scripts/make-demo.swift
import AppKit
import ImageIO
import UniformTypeIdentifiers

let width = 1000, height = 680
let output = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("docs/assets")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
func color(_ hex: Int) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255)/255, green: CGFloat((hex >> 8) & 255)/255, blue: CGFloat(hex & 255)/255, alpha: 1)
}
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
    NSRect(x: x, y: CGFloat(height)-y-h, width: w, height: h)
}
func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat, _ fill: NSColor) {
    fill.setFill(); NSBezierPath(roundedRect: rect(x,y,w,h), xRadius: radius, yRadius: radius).fill()
}
func text(_ value: String, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat = 16, _ weight: NSFont.Weight = .regular, _ ink: Int = 0x25262a) {
    (value as NSString).draw(in: rect(x,y,CGFloat(width)-x-10,size*1.7), withAttributes: [.font:NSFont.systemFont(ofSize:size, weight:weight),.foregroundColor:color(ink)])
}
func lights(_ x: CGFloat, _ y: CGFloat) {
    for (i,c) in [0xff6058,0xffbd2e,0x28c840].enumerated() {box(x+CGFloat(i)*21,y,12,12,6,color(c))}
}
func cursor(_ x: CGFloat, _ y: CGFloat) {
    let p=NSBezierPath();p.move(to:NSPoint(x:x,y:CGFloat(height)-y))
    for (dx,dy) in [(0.0,24.0),(6.0,18.0),(11.0,29.0),(15.0,27.0),(10.0,16.0),(19.0,16.0)] {p.line(to:NSPoint(x:x+dx,y:CGFloat(height)-y-dy))}
    p.close();NSColor.white.setStroke();p.lineWidth=3;p.stroke();color(0x202124).setFill();p.fill()
}
let dest=CGImageDestinationCreateWithURL(output.appendingPathComponent("inputsync-demo.gif") as CFURL, UTType.gif.identifier as CFString, 100,nil)!
CGImageDestinationSetProperties(dest,[kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFLoopCount:0]] as CFDictionary)
for frame in 0..<100 {
    let t=Double(frame)/10
    let chinese=t>=1.6 && t<6.4
    let remoteChinese=t>=2.3 && t<7.1
    let menuFlash=(t>=2.3 && t<2.6)||(t>=7.1 && t<7.4)
    let keyPressed=(t>=1.6 && t<1.9)||(t>=6.4 && t<6.7)
    let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:width,pixelsHigh:height,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:bitmap)
    box(0,0,1000,680,0,color(0xe8ecf1))
    box(0,0,1000,34,0,color(0xf7f8fa))
    text("",20,4,19,.medium);text("屏幕共享",57,7,14,.semibold)
    text("文件    编辑    连接    窗口    帮助",145,7,14)
    box(720,4,58,26,7,color(0xe3e6eb));text("中/英",729,6,14,.medium)
    text(chinese ? "拼音" : "ABC",804,7,14,.medium)
    text("12:00",918,7,14)
    text("InputSync",48,53,26,.bold)
    text("本机切换，远端跟随",225,58,18,.medium,0x656d79)
    text("虚拟界面演示",822,60,13,.regular,0x7b8290)
    // Fictional Screen Sharing window and its toolbar.
    let shadow=NSShadow();shadow.shadowColor=NSColor.black.withAlphaComponent(0.16);shadow.shadowBlurRadius=20;shadow.shadowOffset=NSSize(width:0,height:-6)
    NSGraphicsContext.saveGraphicsState();shadow.set();box(48,105,904,430,13,color(0xf5f5f5));NSGraphicsContext.restoreGraphicsState()
    box(48,105,904,48,13,color(0xf0f0f1));box(48,139,904,14,0,color(0xf0f0f1))
    lights(67,123);text("屏幕共享 — 演示 Mac",374,117,16,.semibold)
    text("⌕",908,117,21)
    // Remote desktop inside the shared area.
    box(49,153,902,381,0,color(0xdce4e9))
    box(49,153,902,29,0,color(0xf7f8f9))
    text("",65,154,17);text("文本编辑",97,159,12,.semibold)
    text("文件   编辑   格式   显示   窗口   帮助",166,159,12)
    text(remoteChinese ? "拼音" : "ABC",815,159,12,.medium);text("12:00",895,159,12)
    box(177,212,646,288,9,color(0xffffff))
    box(177,212,646,36,9,color(0xf4f4f5));box(177,238,646,10,0,color(0xf4f4f5))
    lights(194,224);text("未命名",476,220,13,.medium)
    text("远端文档",207,265,13,.medium,0x858991)
    var typed=""
    if t>=3.1 && t<4.2 {
        let count=min(5,Int((t-3.1)/0.16)+1);typed=String("nihao".prefix(max(0,count)))
    } else if t>=4.2 {typed="你好"}
    if t>=7.9 {typed += "  " + String("abc".prefix(min(3,Int((t-7.9)/0.18)+1)))}
    text(typed,207,299,30)
    let stringWidth=(typed as NSString).size(withAttributes:[.font:NSFont.systemFont(ofSize:30)]).width
    if frame%10<6 {box(209+stringWidth,303,2,32,0,color(0x303238))}
    if t>=3.5 && t<4.2 {
        box(204,342,310,43,7,color(0xf2f3f5));box(212,348,87,30,5,color(0x2675df))
        text("1 你好",221,351,16,.medium,0xffffff);text("2 拟好    3 你号",314,351,16)
    }
    if menuFlash {
        box(58,182,185,143,7,color(0xf7f7f8));text("关于本机",74,194,13);text("系统设置…",74,226,13);text("最近使用的项目",74,258,13);text("睡眠",74,290,13)
        cursor(77,173)
    } else if (t>=2.0 && t<2.3)||(t>=6.8 && t<7.1) {
        let start=t<3 ? 2.0:6.8;let a=(t-start)/0.3;cursor(640-563*a,445-272*a)
    } else {cursor(640,445)}
    // Explanatory overlay outside the simulated screen.
    box(48,562,101,70,12,keyPressed ? color(0xea4938):color(0xffffff))
    text("中 / 英",63,580,23,.medium,keyPressed ? 0xffffff:0x25262a)
    let caption: String
    if t<1.6 {caption="准备切换本机输入法"}
    else if t<2.3 {caption="切换到拼音 · 等待同步"}
    else if t<3.1 {caption="短暂打开并关闭远端菜单"}
    else if t<4.2 {caption="输入 nihao · 出现中文候选"}
    else if t<6.4 {caption="确认输入：你好"}
    else if t<7.1 {caption="切回 ABC · 等待同步"}
    else if t<7.9 {caption="再次刷新远端输入状态"}
    else {caption="直接输入英文：abc"}
    text(caption,177,575,22,.semibold)
    text("示意动画 · 节奏已放慢，非实机录屏",178,610,13,.regular,0x7b8290)
    NSGraphicsContext.restoreGraphicsState()
    CGImageDestinationAddImage(dest,bitmap.cgImage!,[kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime:0.1]] as CFDictionary)
}
assert(CGImageDestinationFinalize(dest))
print(output.appendingPathComponent("inputsync-demo.gif").path)
