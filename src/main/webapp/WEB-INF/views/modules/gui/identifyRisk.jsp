<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<!DOCTYPE HTML>
<html>
<head>
	<title>Identify risk</title>
	<base href="${ctx}">
	<meta name="decorator" content="default"/>
	<script type="text/javascript" src="${ctxStatic}/jQuery/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="${ctxStatic}/d3/d3.min.js"></script>
	<script type="text/javascript" src="${ctxStatic}/JSON-js-master/json2.js"></script>
	<script type="text/javascript" src="${ctxJs}/CControl.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctxStatic}/bootstrap/3.2.0/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/tree.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/identifyRisk.css">
	<script type="text/javascript">
		var ctx = "${ctx}";
		var riskId = -1;
		var riskDetailClass = {};
		
		$(function(){
			riskId = $("#riskId").text();
		    $('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
		    $('.tree li.parent_li > span').on('click', function (e) {
		        var children = $(this).parent('li.parent_li').find(' > ul > li');
		        if (children.is(":visible")) {
		            children.hide('fast');
		            $(this).attr('title', 'Expand this branch').find(' > i').addClass('glyphicon-plus-sign').removeClass('glyphicon-minus-sign');
		        } else {
		            children.show('fast');
		            $(this).attr('title', 'Collapse this branch').find(' > i').addClass('glyphicon-minus-sign').removeClass('glyphicon-plus-sign');
		        }
		        e.stopPropagation();
		    });
		    
/* 		    $(".nav li").bind("click", function(){
		    	$(".nav li").removeClass("active");
		    	$(this).addClass("active");
		    }); */
		    
		    $('.tree ul li ul li.parent_li > span').click();//折叠目录
		    
		    $("#testBtn").bind("click", function(){
		    	riskDetailClass.refreshContent();
		    	
		    });

		    $("#editCancelBtn").bind("click", function(){
		    	window.location.href = ctx + "/identify/initView?id=" + riskId;
		    });
		    
		    $("#editSaveBtn").bind("click", function(){
				var form = document.createElement("form");
				document.body.appendChild(form);
				form.action = ctx + "/identify/save";
				form.method = "POST";
				form.appendChild(getFormInput("riskName", JSON.stringify(riskDetailClass.riskName)));
				if(riskDetailClass.priOrg)
					form.appendChild(getFormInput("pirOrgId", riskDetailClass.priOrg.id));
				if(riskDetailClass.secOrg)
					form.appendChild(getFormInput("secOrgId", riskDetailClass.secOrg.id));
				if(riskDetailClass.riskCate)
					form.appendChild(getFormInput("riskCateId", riskDetailClass.riskCate.id));
				if(riskDetailClass.activity)
					form.appendChild(getFormInput("activityId", riskDetailClass.activity.id));
				form.appendChild(getFormInput("drivers", JSON.stringify(riskDetailClass.drivers)));
				form.appendChild(getFormInput("impacts", JSON.stringify(riskDetailClass.impacts)));
				
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
							alert("修改成功！");
							window.location.href = ctx + "/identify/initView?id=" + riskId;
						}
			     	},
			        error: function(){
			        	console.log("request fail");
			        }
				});	
		    });
		    
		    
		    function getFormInput(name, value){
		    	var input = document.createElement("input");
				input.type = "hidden";
				input.value =value;
				input.name = name;
				return input;
		    }
		    		    		    
		    /*获取risk信息  */
			$.ajax({
		    	url: ctx + "/identify/riskInfo",
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
					var responses = [{id: 1, text:"response1"},{id: 2, text:"response2"}];
					var controls = [{id: 1, text:"control1"},{id: 2, text:"control2"}];
					var policies = [{id: 1, text:"policies1"},{id: 2, text:"policies2"}];

					riskDetailClass = new RiskDetailClass(edit, schema, riskName, priOrg, secOrg, riskCate, activity, drivers, impacts, responses, controls, policies);	
					riskDetailClass.refreshContent();	        		
		     	},
		        error: function(){
		        	console.log("request fail");
		        }
			});	
				    
		});
		
		/*拖拽函数 */
		function allowDrop(ev){
			ev.preventDefault();
		}
		
		function drag(ev){
			ev.dataTransfer.setData("id",ev.target.id);
			ev.dataTransfer.setData("type",ev.target.getAttribute("type"));
			ev.dataTransfer.setData("content",ev.target.textContent);
		}
		
		function drop(ev){
			ev.preventDefault();
			var id=ev.dataTransfer.getData("id");
			var type=ev.dataTransfer.getData("type");
			var content=ev.dataTransfer.getData("content");
			riskDetailClass.addProperty({type:type, id:id, text:content});
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
		  <li role="presentation" class="active"><a href="${ctx}/identify/initView?id=${riskId}">风险识别</a></li>
		  <li role="presentation" class=""><a href="${ctx}/assess/initView?id=${riskId}">风险评估</a></li>
		  <li role="presentation" class=""><a href="${ctx}/mitigate/initView?id=${riskId}">风险处理</a></li>
		  <li role="presentation" class=""><a href="${ctx}/summary/initView?id=${riskId}">风险总结</a></li>
		</ul>	
	</header>
	<section id="mainBody">
		<div id="leftNav">
			<div class="tree well">
				<ul style="margin-left:-60px">
					<li>
						<span><i class="glyphicon glyphicon-folder-open"></i> Root</span>
						<ul>
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i>一级组织</span>
								<ul>
									<c:forEach var="eachPriOrg" items="${organizationParentList}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachPriOrg.id}" type="priOrg"><i class="glyphicon glyphicon-leaf"></i>${eachPriOrg.name}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i> 二级组织</span>
								<ul>
									<c:forEach var="eachSecOrg" items="${organizationSonlist}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachSecOrg.id}" type="secOrg"><i class="glyphicon glyphicon-leaf"></i>${eachSecOrg.name}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i> 风险类目</span>
								<ul>
									<c:forEach var="eachRiskCate" items="${riskCategoryList}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachRiskCate.id}" type="riskCate"><i class="glyphicon glyphicon-leaf"></i>${eachRiskCate.name}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>							
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i> 活动类目</span>
								<ul>
									<c:forEach var="eachActivityCate" items="${activityCategorylist}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachActivityCate.id}" type="activity"><i class="glyphicon glyphicon-leaf"></i>${eachActivityCate.name}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i> 驱动因素</span>
								<ul>
									<c:forEach var="eachDriver" items="${driverCategoryList}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachDriver.id}" type="drivers"><i class="glyphicon glyphicon-leaf"></i>${eachDriver.text}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>
							<li>
								<span><i class="glyphicon glyphicon-minus-sign"></i> 风险结果</span>
								<ul>
									<c:forEach var="eachImpact" items="${impactCategoryList}">
										<li>
											<span draggable="true" ondragstart="drag(event)" id="${eachImpact.id}" type="impacts"><i class="glyphicon glyphicon-leaf"></i>${eachImpact.text}</span>
										</li>									
									</c:forEach>
								</ul>
							</li>																					
						</ul>
					</li>
				</ul>
			</div>			
		</div>
		<div id="rightPanel">
			<div id="svgContainer" class="drawBoard" ondrop="drop(event)" ondragover="allowDrop(event)">
			</div>
			<div id="editDiv">
			  <button id="editCancelBtn" type="button" class="btn btn-default">取消</button>
			  <button id="editSaveBtn" type="button" class="btn btn-primary">保存</button>
			</div>					
		</div>
	</section>

</body>
</html>