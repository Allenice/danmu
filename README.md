弹幕网站示例
===
基于nodejs+socket.io+mongodb的弹幕视频网站示例

安装
===
- 请先安装以下软件，并配置好环境变量
 - mongodb
 - ffmpeg

- 设置ffmpeg的执行路径和数据库
  ```coffeescript
    # settings.coffee
    module.exports = {
      cookieSecret: 'socket.io',
      db: 'danmu',
      host: 'localhost',
      ffmpegPath: 'E:\\ffmpeg\\bin\\ffmpeg.exe'
    }
  ```
 - 请把ffmpeg放到项目的同一个磁盘分区

- 安装依赖库
 ```coffeescript
    # 在项目的根目录下执行
    npm install
 ```

运行
===
- 启动app
 ```
    node app.js
 ```
- 先访问以下地址安装数据库
 ```
 http://localhost:3000/install
 ```
- 访问
 ```
 http://localhost:3000/
 ```
