<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<!DOCTYPE HTML>
<html>
<head>
	<title>Home</title>
	<base href="${ctx}">
	<meta name="decorator" content="default"/>
	<script type="text/javascript" src="${ctxStatic}/jQuery/jquery-1.9.1.min.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctxStatic}/bootstrap/3.2.0/css/bootstrap.min.css">
	<script type="text/javascript">
	</script>
</head>
<body>
	time：<%=request.getAttribute("time")%><br>
	name：<%=request.getAttribute("name")%><br>

</body>
</html>
