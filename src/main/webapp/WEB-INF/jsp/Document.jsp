<!DOCTYPE html>
<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<html>
<head>
	<meta charset="utf-8">
	<title>Documents Migrator</title>
	
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

	<div class="container">
		<div class="row">
			<div class="span8 offset2" >
				<div class="page-header" style="font-size: 20px;">
					<strong>Migrate Documents</strong>
				</div>
				<form:form action="transformDocuments" class="form-vertical">
					<input type="submit" value="      Submit      " class="btn btn-primary btn-lg" />
				</form:form>
			</div>
		</div>
	</div>
	<div class="container">
		<div class="row">
			<div class="span8 offset2" >
				<div class="page-header" style="font-size: 20px;">
					<strong>Show logs</strong>
				</div>
				<form:form action="showLogs" class="form-vertical">
					<input type="submit" value="      Submit      " class="btn btn-primary btn-lg" />
				</form:form>
			</div>
		</div>
	</div>

</body>
</html>
