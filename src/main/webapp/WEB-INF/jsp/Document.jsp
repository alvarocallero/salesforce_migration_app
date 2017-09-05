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
	    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	    <script src="/sweetalert.min.js"></script>
	    <link rel="stylesheet" type="text/css" href="/sweetalert.css">
	</head>
	<body>
	    <div class="container">
	        <div class="row">
	            <!--Begin logo-->
	            <div class="col-md-7 no-float logo-main ">
	            </div>
	            <!--end logo-->
	            <!--begin begin-->
	            <div class="col-md-5 no-float begin-shadow begin-main">
	                <p class="title">
	                    Document Migrator
	                </p>
	                <hr>
	                <div class="welcomeText">
		                <p class="instructions">
		                	Welcome! Click over 'Start migration' button to start the Migration of the documents
		                </p>
	                </div>
	                <p class="begin-section" id="dataFields">
	                    <form:form action="transformDocuments" class="form-vertical begin-form">
	                    	<div class="formDiv">
		                    	Org user name: <br/><input type = "text" name="orgUserName"  id="orgUserName"><br/><br/>
		                    	Org password: <br/><input type = "password" name="orgPassword"  id="orgPassword"><br/><br/>
		                    	Org security token: <br/><input type = "password" name="orgSecurityToken"  id="orgSecurityToken"><br/><br/><br/>
		                        <input type="submit" onclick="SetButtonStatus(event)" value="Start migration" name="submitBtn" class="button" id="submitBtn" />
	                        </div>
	                    </form:form>
	                </p>
	            </div>
	            <!--end begin-->
	        </div>
	    </div>
	    <!--  SHOW LOGS
	    <div class="container">
	        <div class="row">
	            <div class="span8 offset2">
	                <div class="page-header" style="font-size: 20px;">
	                    <strong>Show logs</strong>
	                </div>
	                <form:form action="showLogs" class="form-vertical">
	                    <input type="submit" value="      Submit      "
	                        class="btn btn-primary btn-lg" />
	                </form:form>
	            </div>
	        </div>
	    </div>-->
	</body>
	<style>
        @font-face {
            font-family: 'Source Sans Pro';
            font-style: normal;
            font-weight: 400;
            src: local('Source Sans Pro Regular'), local('SourceSansPro-Regular'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlNV_2ngZ8dMf8fLgjYEouxg.woff2) format('woff2');
            unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2212, U+2215;
        }
        html, body, .container {
            height: 100%;
            font-family: 'Source Sans Pro';
        }
        .container {
            display: table;
            width: 100%;
            margin-top: 0px;
            padding: 0px 0 0 0;
            box-sizing: border-box;
        }
        .row {
            height: 100%;
            display: table-row;
        }
        .row .no-float {
            display: table-cell;
            float: none;
        }
        .instructions {
            color: white;
            margin: 0 10px 0 10px
        }
        .title {
            color: white;
            font-size: 32px;
            padding-top: 35%;
            margin: 0 10px 0 10px
        }
        .begin-form {
            margin: 0 10px 0 10px;
            width: 100%;
            color: #ffa500;
        }
        .begin-shadow {
            box-shadow: -5px 0px 22px #888888;
        }
        .begin-section {
            padding-top: 25px;
        }
        .button:hover {
            background-color: white;
            color: #ff5533;
            border:1px solid #999;
        }
        .begin-main {
            background-color: #ff5533;
        }
        .logo-main {
            background-size: 62%;
		    background-image: url(/altimetrikLogo1.png);
		    background-repeat: no-repeat;
		    background-position: center;
        }
        .formDiv {
        	color: white;
        }
        input[name=orgUserName],input[name=orgPassword],input[name=orgSecurityToken],input[name=submitBtn]
		{
			width: 45%;
			height: 35px;
		    color: black;
		    padding: 14px 20px;
		    margin: 4px 0;
		    border: none;
		    border-radius: 4px;
		    font-size: medium;
		    box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
		}
		input[name=submitBtn]
		{
			box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
		    background: linear-gradient(rgb(255, 255, 255) 5%, rgb(246, 246, 246) 100%) rgb(255, 255, 255);
		    border-radius: 6px;
		    border: 1px solid rgb(220, 220, 220);
		    display: inline-block;
		    cursor: pointer;
		    color: rgb(102, 102, 102);
		    font-family: Arial;
		    font-size: 15px;
		    padding: 6px 24px;
		    text-decoration: none;
		    text-shadow: rgb(255, 255, 255) 0px 1px 0px;
		    font-family:Verdana;
		    color: black;
		}
		.welcomeText {
			font-size: large;
		}
		
    </style>
	<script>
		function SetButtonStatus(event) {
			var orgUserName = document.getElementById('orgUserName').value;
			var orgPassword = document.getElementById('orgPassword').value;
			var orgSecurityToken = document.getElementById('orgSecurityToken').value;
			if (orgUserName.trim() == '' || orgPassword.trim() == '' || orgSecurityToken.trim() == '') {
				swal({
					  title: "Atención",
					  text: "Se deben rellenar todos los campos para ejecutar la migración",
					  type: "warning",
					  confirmButtonColor: "#ff5533",
					  animation: "slide-from-top",
					  allowOutsideClick: true,
				});
				event.preventDefault();
			}
		}
	</script>
</html>