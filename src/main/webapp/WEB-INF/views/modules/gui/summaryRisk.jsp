<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<!DOCTYPE HTML>
<html>
<head>
	<title>Summary risk</title>
	<base href="${ctx}">
	<meta name="decorator" content="default"/>
	<script type="text/javascript" src="${ctxStatic}/jQuery/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="${ctxStatic}/d3/d3.min.js"></script>
	<script type="text/javascript" src="${ctxJs}/CControl.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctxStatic}/bootstrap/3.2.0/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/summaryRisk.css">
	<script type="text/javascript">
		var ctx = "${ctx}";
		var riskId = -1;
		var riskDetailClass = {};
		
		$(function(){
			riskId = $("#riskId").text();

		    /*获取risk信息  */
			$.ajax({
		    	url: ctx + "/summary/riskInfo",
		    	data:{id: riskId},
		    	async : false,
		        type:"post",
		        dataType:"json",
		        success:function(data){
					var edit = data.edit;
					var schema = data.schema;
					var riskName = data.riskName;
					var priOrg = data.priOrg;
					var secOrg = data.secOrg;
					var riskCate = data.riskCate;
					var activity = data.activity;
					var drivers = data.drivers;
					var impacts = data.impacts;
					var responses = data.responses;
					var controls = 	data.controls;	
					var policies = data.policies;
					riskDetailClass = new RiskDetailClass(edit, schema, riskName, priOrg, secOrg, riskCate, activity, drivers, impacts, responses, controls, policies);	
					riskDetailClass.refreshContent();	        		
		     	},
		        error: function(){
		        	console.log("request fail");
		        }
			});	
				    
		});		
		
	</script>
</head>
<body>
	<div id="riskId" class="hidden">${riskId}</div>
	<header>
		<ul class="nav nav-pills nav-justified">
		  <li role="presentation" class=""><a href="${ctx}/identify/initView?id=${riskId}">风险识别</a></li>
		  <li role="presentation" class=""><a href="${ctx}/assess/initView?id=${riskId}">风险评估</a></li>
		  <li role="presentation" class=""><a href="${ctx}/mitigate/initView?id=${riskId}">风险处理</a></li>
		  <li role="presentation" class="active"><a href="${ctx}/summary/initView?id=${riskId}">风险总结</a></li>
		</ul>	
	</header>
	<section id="mainBody">
		<div id="rightPanel">
			<div id="svgContainer" class="drawBoard">
			</div>				
		</div>
	</section>

</body>
</html>