const express = require("express");
const path = require("path");
var bodyParser = require("body-parser");

let server=express();  //通过express框架开启服务

server.engine(".html", require("ejs").__express);
server.set("views", path.join(__dirname, ""));
server.set("view engine", "html");
server.listen(3000);  //监听端口号3000
server.use(express.static("static"));
server.use(bodyParser.json());
server.use(bodyParser.urlencoded({extended: false}));
//server.use(express.static("public"));

server.get("/index",(req,res)=>{  //通过get方式由"/getUser"接口接收请求
    res.render("index", {locals: {title: "Welcome!"}});//发送结束
});


/* GET home page. */

