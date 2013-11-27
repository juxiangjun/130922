<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script type="text/javascript">
	function loaddata() {
		var key= document.getElementById("key").value;
		
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "/emejis/eme/?key="+key, false);
		xmlhttp.send();
		document.getElementById("myDiv").innerHTML = xmlhttp.responseText;

	}
</script>
</head>
<body> 
 

			<textarea id="key" cols="50" rows="10" name="key" ></textarea>

           <button type="button" onclick="loaddata()"> 测试</button>

	   
	<div id="myDiv"></div>

</body>
</html>