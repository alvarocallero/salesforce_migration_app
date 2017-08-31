<%@ page language="java" contentType="text/html; charset=ISO-8859-1"  pageEncoding="ISO-8859-1"%>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="utf-8">
	<title>Logs</title>
	
	<meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	
	<link href="/assets/public/css/bootstrap.min.css" rel="stylesheet">
	<link href="/assets/public/css/bootstrap-responsive.min.css" rel="stylesheet">
	<link href="/heroku.css" rel="stylesheet" type="text/css">
</head>
<body>
	<div class="navbar navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<a class="brand">Documents Migration App</a> 
			</div>
		</div>
	</div>
	<c:if test="${not empty logLst}">
		<ul>
			<c:forEach var="log" items="${logLst}">
				<li>${log}</li>
			</c:forEach>
		</ul>
	</c:if>
	<c:if test="${empty logLst}">
		Es vacia la lista...
	</c:if>

</body>
</html>