<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
 
</head>
<body> 
 
 

<form action="/emejis/emeupload" method="post"
enctype="multipart/form-data">
<input type="text" name="key" value='{"root":{"body":{"service":"S_PERSON","param":{"type":"1","userid":"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5","label":"---ttt---"},"function":"UPLOAD_IMGGROUP"},"header":{"id":"0ddc1d47-8051-4029-a85c-b89e9cee74d9","sender":"192.168.7.38","ack":"request","device":"手机型号:HUAWEI Y310-T10,SDK版本:10,系统版本:2.3.5","datetime":"2013-01-12 05:30:015","cid":"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5","appver":"1.0","version":"1"}}}'/>
<input type="text" name="filename " />
<input type="file" name="file" id="file"><br>
<input type="file" name="file2" id="file2"><br>
<input type="submit" name="submit" value="Submit">
</form>

</body>
</html>
 