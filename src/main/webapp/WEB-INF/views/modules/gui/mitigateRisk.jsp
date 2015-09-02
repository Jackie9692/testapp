<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<!DOCTYPE HTML>
<html>
<head>
	<title>Mitigate risk</title>
	<base href="${ctx}">
	<meta name="decorator" content="default"/>
	<script type="text/javascript" src="${ctxStatic}/jQuery/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="${ctxStatic}/d3/d3.min.js"></script>
	<script type="text/javascript" src="${ctxStatic}/JSON-js-master/json2.js"></script>
	<script type="text/javascript" src="${ctxJs}/CControl.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctxStatic}/bootstrap/3.2.0/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/tree.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/mitigateRisk.css">
	<script type="text/javascript">
		var ctx = "${ctx}";
		var riskId = -1;
		var riskRelativeInfo = {};
		
		$(function(){
			riskId = $("#riskId").text();
			
		    $("#editCancelBtn").bind("click", function(){
		    	window.location.href = ctx + "/mitigate/initView?id=" + riskId;
		    });
		    
		    $("#editSaveBtn").bind("click", function(){
		    	var rows = riskRelativeInfo.responseLength + riskRelativeInfo.policyLength + riskRelativeInfo.controlLength;
				var colums = riskRelativeInfo.driverLength + riskRelativeInfo.impactLength;
				var checkInputs = $("th.checkTh input");
				var relationArr = [];
				for(var i=0;i<rows;++i){
					var tempDriver = "";
					var tempImpact = "";
					for(var j=0;j<colums;++j){
						if(j<riskRelativeInfo.driverLength){
							if($(checkInputs[i*colums + j]).prop("checked") == true){
								tempDriver = tempDriver + $(checkInputs[i*colums + j]).val() + ",";
							}						
						}else{
							if($(checkInputs[i*colums + j]).prop("checked") == true){
								tempImpact = tempImpact + $(checkInputs[i*colums + j]).val() + ",";
							}						
						}
					}
					relationArr.push(tempDriver);
					relationArr.push(tempImpact);
				}		    	
		    
				var form = document.createElement("form");
				document.body.appendChild(form);
				form.action = ctx + "/mitigate/save";
				form.method = "POST";
				form.appendChild(getFormInput("id", riskId));
				form.appendChild(getFormInput("relationArr", JSON.stringify(relationArr)));
				var url = $(form).attr("action");
				var data = $(form).serialize();
				$.ajax({
			    	url: url,
			    	data: data,
			    	async : false,
			        type:"post",
			        dataType:"json",
			        success:function(data){
						if(data.success == true){
							alert("保存成功！");
							window.location.href = ctx + "/mitigate/initView?id=" + riskId;
						}
			     	},
			        error: function(){
			        	console.log("request fail");
			        }
				});	
		    });		
		    		    		    		    
		    /*获取risk信息  */
			$.ajax({
		    	url: ctx + "/mitigate/riskInfo",
		    	data:{id: riskId},
		    	async : false,
		        type:"post",
		        dataType:"json",
		        success:function(data){ 
		             riskRelativeInfo = data;		
		     	},
		        error: function(){
		        	console.log("request fail");
		        }
			});	
			refreshContent();	    
		});	
		
		function refreshContent(){
			var rows = riskRelativeInfo.responseLength + riskRelativeInfo.policyLength + riskRelativeInfo.controlLength;
			var colums = riskRelativeInfo.driverLength + riskRelativeInfo.impactLength;
			var checkInputs = $("th.checkTh input");
			for(var i=0;i<rows;++i){
				for(var j=0;j<colums;++j){
					if(riskRelativeInfo.relationArr[i][j] == 1){
						$(checkInputs[i*colums + j]).attr("checked","checked");
					}
				}
			}
			
		}	
		function getFormInput(name, value){
	    	var input = document.createElement("input");
			input.type = "hidden";
			input.value =value;
			input.name = name;
			return input;
	    }		
	</script>
</head>
<body>
	<footer class="hidden">
		<a id="testBtn" style="float: right; margin-right: 300px" class="btn btn-primary">Test</a>
	</footer>
	<div id="riskId" class="hidden">${riskId}</div>
	<header>
		<ul class="nav nav-pills nav-justified">
		  <li role="presentation" class=""><a href="${ctx}/identify/initView?id=${riskId}">风险识别</a></li>
		  <li role="presentation" class=""><a href="${ctx}/assess/initView?id=${riskId}">风险评估</a></li>
		  <li role="presentation" class="active"><a href="${ctx}/mitigate/initView?id=${riskId}">风险处理</a></li>
		  <li role="presentation" class=""><a href="${ctx}/summary/initView?id=${riskId}">风险总结</a></li>
		</ul>	
	</header>
	<section id="mainBody">
		<div id="rightPanel">
			<div class="drawBoard">
				<table class="table table-condensed">
				      <caption></caption>
				      <thead>
				        <tr>
				          <th></th>
				          <c:forEach var="eachDriver" items="${driverEnList}">
				          	<th>${eachDriver.comment}</th>
				          </c:forEach>
				          <c:forEach var="eachImpact" items="${impactEnList}">
				          	<th>${eachImpact.comment}</th>
				          </c:forEach>				          
				        </tr>
				      </thead>
				      <tbody>
				      	<c:forEach var="responseEach" items="${responseEnListDetailEntity}">
					        <tr>
					          <th scope="row">${responseEach.name}</th>
					          <c:forEach var="eachDriver" items="${driverEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachDriver.id}"></th>
					          </c:forEach>
					          <c:forEach var="eachImpact" items="${impactEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachImpact.id}"></th>
					          </c:forEach>
					        </tr>				      	
				      	</c:forEach>
				      	<c:forEach var="policyEach" items="${policyEnListDetailEntity}">
					        <tr>
					          <th scope="row">${policyEach.name}</th>
					          <c:forEach var="eachDriver" items="${driverEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachDriver.id}"></th>
					          </c:forEach>
					          <c:forEach var="eachImpact" items="${impactEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachImpact.id}"></th>
					          </c:forEach>
					        </tr>				      	
				      	</c:forEach>
				      	<c:forEach var="controlEach" items="${controlEnListDetailEntity}">
					        <tr>
					          <th scope="row">${controlEach.name}</th>
					          <c:forEach var="eachDriver" items="${driverEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachDriver.id}"></th>
					          </c:forEach>
					          <c:forEach var="eachImpact" items="${impactEnList}">
					          	<th class="checkTh"><input type="checkbox"  value="${eachImpact.id}"></th>
					          </c:forEach>
					        </tr>				      	
				      	</c:forEach>				      	
				      </tbody>
				  </table>				
			</div>
			<div id="editDiv">
			  <button id="editCancelBtn" type="button" class="btn btn-default">取消</button>
			  <button id="editSaveBtn" type="button" class="btn btn-primary">保存</button>
			</div>					
		</div>
	</section>

</body>
</html>