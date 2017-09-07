<!DOCTYPE html>
<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<html>
	<head>
	    <meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Documents Migrator</title>
	    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	</head>
	<body>
	    <div class="spacer">
	    </div>
	    <div class="fullcenter">
	    </div>
	    <div class="spacer">
	        <div class="container">
	            <div class="row">
	                <p>
                    	<a href="/documents/" id="theBtn" class="btn btn-default login-btn-custom" ><strong>Login to Salesforce</strong></a>
	                </p>
	            </div>
	        </div>
	    </div>
	</body>
	<style>
        html,
        body,
        .container {
            height: 100%;
            font-family: 'Source Sans Pro';
        }
        .fullcenter {
            height: 70%;
            background-position: center;
		    background-image: url(/altimetrikLogo1.png);
   		    background-repeat: no-repeat;
   		    background-position: center;
            background-size: 35%;
        }
        .spacer {
            height: 15%;
            background-color: #ff5533;
            padding-top: 2%;
        }
        .btn-default:hover {
            background-color: #ff5533;
            border: solid 2px white;
            color: white;
        }
        .login-btn-custom {
            color: #ff5533;
        }
        @font-face {
            font-family: 'Source Sans Pro';
            font-style: normal;
            font-weight: 400;
            src: local('Source Sans Pro Regular'), local('SourceSansPro-Regular'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlNV_2ngZ8dMf8fLgjYEouxg.woff2) format('woff2');
            unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2212, U+2215;
        }
        #theBtn {
        	width:45%;
        	margin-left: 27%;
        }
    </style>
</html>