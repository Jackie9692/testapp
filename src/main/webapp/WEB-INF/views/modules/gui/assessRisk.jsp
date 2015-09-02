<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<!DOCTYPE HTML>
<html>
<head>
	<title>Assess risk</title>
	<base href="${ctx}">
	<meta name="decorator" content="default"/>
	<script type="text/javascript" src="${ctxStatic}/jQuery/jquery-1.9.1.min.js"></script>
	<script src="${ctxStatic}/echarts/echarts-all.js"></script>
	<script type="text/javascript" src="${ctxStatic}/JSON-js-master/json2.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctxStatic}/bootstrap/3.2.0/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/tree.css">
	<link rel="stylesheet" type="text/css" href="${ctxCss}/assessRisk.css">
	<script type="text/javascript">
		var ctx = "${ctx}";
		var riskId = -1;
		var riskVersion = -1;
		var riskDetails = {};
		
		$(function(){
			riskId = $("#riskId").text();
			riskVersion = $("#riskVersion").text();
			
		    $('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
		    $('.tree').on('click', function (e) {
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
		    
		    $('.tree ul li span').on('click', function (e) {
		       	var form = document.createElement("form");
				document.body.appendChild(form);
				form.action = ctx + "/assess/initView";
				form.method = "get";
				form.appendChild(getFormInput("id", riskId));
				form.appendChild(getFormInput("version", this.getAttribute("class")));
				form.submit();
		        e.stopPropagation();
		    });
		        
		    $("#editCancelBtn").bind("click", function(){
		    	window.location.href = ctx + "/assess/initView?id=" + riskId;
		    });
		    
		    $("#editSaveBtn").bind("click", function(){
				var form = document.createElement("form");
				document.body.appendChild(form);
				form.action = ctx + "/assess/save";
				form.method = "POST";
				form.appendChild(getFormInput("id", riskId));
				form.appendChild(getFormInput("probability", riskDetails.probability));
				form.appendChild(getFormInput("impacts", JSON.stringify(riskDetails.impacts)));
				
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
							window.location.href = ctx + "/assess/initView?id=" + riskId;
						}
			     	},
			        error: function(){
			        	console.log("request fail");
			        }
				});	
		    });		    
		    
		    $("#simulateBtn").bind("click", function(){					
				var form = document.createElement("form");
				document.body.appendChild(form);
				form.action = ctx + "/assess/simulate";
				form.method = "POST";
				form.appendChild(getFormInput("id", riskId));
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
							alert("模拟成功！");
							window.location.href = ctx + "/assess/initView?id=" + riskId;
						}
			     	},
			        error: function(){
			        	console.log("request fail");
			        }
				});	
		    });	
		    
		    $("#impactsDetailDiv input").bind("change", function(){
		    	var loseMoney = this.value;
		    	var severityLevel;	    	
		    	if(!isNaN(loseMoney)){
					$.ajax({
					    	url: ctx + "/assess/severityLevel",
					    	data:{money: loseMoney},
					    	async : false,
					        type:"post",
					        dataType:"json",
					        success:function(data){
					        	severityLevel = data.severityLevel;
					     	},
					        error: function(){
					        	console.log("request fail");
					        }
					});
					$("#impactLevel_"+this.id.split("_")[1]).val(severityLevel);
					riskDetails.impacts[parseInt(this.name) -1].lossMoney = loseMoney;
					refreshContent();	    		
		    	}else{
		    		alert("检查是否为数字");
		    	}
		    });	
		    	    	    
		    $("#tempRiskProbability").bind("change", function(){
		    	var probabilityLevel;
		    	var rate = this.value;    	
		    	if(!isNaN(rate.split("%")[0])){
					$.ajax({
					    	url: ctx + "/assess/probabilityLevel",
					    	data:{rate: rate},
					    	async : false,
					        type:"post",
					        dataType:"json",
					        success:function(data){
					        	probabilityLevel = data.probabilityLevel;
					     	},
					        error: function(){
					        	console.log("request fail");
					        }
					});
					$("#tempRiskProbabilityLevel").val(probabilityLevel);
					riskDetails.probabilityLevel = probabilityLevel;
					riskDetails.probability = rate.split("%")[0]/100;
					refreshContent();	    		
		    	}else{
		    		alert("检查是否为数字");
		    	}
		    });				
			
			
			initView();
				    
		});
		
		function refreshContent(){
			drawChart();
			
			var impacts = riskDetails.impacts;
			var totalLose = 0;
			for(var i = 0; i < impacts.length; ++ i){
				totalLose += parseFloat(impacts[i].lossMoney);
			}
			$("#totalRisk").val(totalLose);
			$("#residualRisk").val(totalLose - riskDetails.reduceMoney);	
		}
		
		function initView(){
			initRiskDetailData();
			$("#currentRiskLevel").text(riskDetails.currentRiskLevel);
			$("#currentRiskScore").text(riskDetails.currentRiskScore);
			$("#probability").text(riskDetails.probability * 100);
			$("#beforeRiskScore").text(riskDetails.beforeRiskScore);
			$("#tempRiskProbability").val(riskDetails.probability * 100 + "%");
			$("#tempRiskProbabilityLevel").val(riskDetails.probabilityLevel);
			$("#currentRiskExpected").text(riskDetails.currentRiskExpected);
			var impacts = riskDetails.impacts;
			if("length" in impacts){
				for(var i = 0; i < impacts.length; ++ i){
					var id = "#impactLevel_" + impacts[i].id;
					$(id).val(impacts[i].severityLevel); 
				}
			}

			
			$("#reducedRisk").val(riskDetails.reduceMoney);
					
			refreshContent();
		}
		
		function initRiskDetailData(){
			$.ajax({
			    	url: ctx + "/assess/riskInfo",
			    	data:{id: riskId, version: riskVersion},
			    	async : false,
			        type:"post",
			        dataType:"json",
			        success:function(data){
			        	riskDetails = data;
			     	},
			        error: function(){
			        	console.log("request fail");
			        }
			});				
		}
		

		
		function getOption(){
			var legendArr = [];
			var dataArr = [];
			for(var i = 0; i < riskDetails.impacts.length; ++ i){
				legendArr.push("Impact" + (i+1));
				dataArr.push({name:"Impact" + (i+1), value: riskDetails.impacts[i].lossMoney});
			}

			var option = {
			    tooltip : {
			        trigger: 'item',
			        formatter: "{a} <br/>{b} : ¥{c} ({d}%)"
			    },
			    legend: {
			        orient : 'vertical',
			        x : 'left',
			        data:legendArr
			    },
			    toolbox: {
			        show : false,
			        feature : {
			            mark : {show: false},
			            dataView : {show: false, readOnly: false},
			            magicType : {
			                show: false, 
			                type: ['pie', 'funnel'],
			                option: {
			                    funnel: {
			                        x: '25%',
			                        width: '50%',
			                        funnelAlign: 'center',
			                        max: 1548
			                    }
			                }
			            },
			            restore : {show: false},
			            saveAsImage : {show: false}
			        }
			    },
			    calculable : true,
			    series : [
			        {
			            name:'风险结果',
			            type:'pie',
			            radius : ['50%', '70%'],
			            itemStyle : {
			                normal : {
			                    label : {
			                        show : false
			                    },
			                    labelLine : {
			                        show : false
			                    }
			                },
			                emphasis : {
			                    label : {
			                        show : false,
			                        position : 'center',
			                        textStyle : {
			                            fontSize : '30',
			                            fontWeight : 'bold'
			                        }
			                    }
			                }
			            },
			            data:dataArr
			        }
			    ]
			};
			return option;			
		}
		function drawChart(data) {
			$("#impactChart").empty();
			var impactsChart = echarts.init(document.getElementById("impactChart"));
			impactsChart.setOption(getOption(data));
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
	<div id="riskId" class="hidden">${riskId}</div>
	<div id="riskVersion" class="hidden">${riskVersion}</div>
	<header>
		<ul class="nav nav-pills nav-justified">
		  <li role="presentation" class=""><a href="${ctx}/identify/initView?id=${riskId}">风险识别</a></li>
		  <li role="presentation" class="active"><a href="${ctx}/assess/initView?id=${riskId}">风险评估</a></li>
		  <li role="presentation" class=""><a href="${ctx}/mitigate/initView?id=${riskId}">风险处理</a></li>
		  <li role="presentation" class=""><a href="${ctx}/summary/initView?id=${riskId}">风险总结</a></li>
		</ul>	
	</header>
	<section id="mainBody">
		<div id="leftNav">
			<div class="tree well">
				<ul style="margin-left:-60px">
					<li>
						<span><i class="glyphicon glyphicon-folder-open"></i> 时间轴</span>
						<ul>
							<c:forEach var="each" items="${impactsDetailEntityLi}">
								<li>
									<span class="${each.simulateVersion}"><i class="glyphicon glyphicon-time"></i>${each.updateDate}</span>
								</li>								
							</c:forEach>						
						</ul>
					</li>
				</ul>
			</div>			
		</div>
		<div id="rightPanel">
			<div id="overviewDiv">
				<div class="row">
				 <div class="col-md-3" style="border-right: 1px solid grey">
				  	<div>
				  		<div>当前风险期望(¥)</div>
				  		<div id="currentRiskExpected">-- --</div>
				  	</div>
				  </div>
				  <div class="col-md-2" style="border-right: 1px solid grey">
				  	<div>
				  		<div>当前风险等级</div>
				  		<div id="currentRiskLevel">-- --</div>
				  	</div>
				  </div>
				  <div class="col-md-2" style="border-right: 1px solid grey">
				  	<div>
				  		<div>当前风险分数</div>
				  		<div id="currentRiskScore">-- --</div>
				  	</div>				  
				  </div>
				  <div class="col-md-2" style="border-right: 1px solid grey">
				  	<div>
				  		<div>发生概率(%)</div>
				  		<div id="probability">-- --</div>
				  	</div>				  
				  </div>
				  <div class="col-md-3">
				  	<div>
				  		<div>处理前分数</div>
				  		<div id="beforeRiskScore">-- --</div>
				  	</div>				  
				  </div>				  
				</div>				  
			</div>				
			<div id="middleDiv">
				<div id="leftEchartDiv">
					<div id="impactChart"></div>
				</div>
				<div id="rightOverviewDiv">
					<div class="input-group">
					  <span class="input-group-addon" id="basic-addon1">总的风险：</span>
					  <input id="totalRisk" type="text" class="form-control" readonly aria-describedby="basic-addon1" value="-- --">
					  <span class="input-group-addon" id="basic-addon1">¥</span>
					</div>
					<div class="input-group">
					  <span class="input-group-addon" id="basic-addon1">减少风险：</span>
					  <input id="reducedRisk" type="text" class="form-control" readonly aria-describedby="basic-addon1" value="-- --">
					  <span class="input-group-addon" id="basic-addon1">¥</span>
					</div>
					<div class="input-group">
					  <span class="input-group-addon" id="basic-addon1">余留风险：</span>
					  <input id="residualRisk" type="text" class="form-control" readonly aria-describedby="basic-addon1" value="-- --">
					  <span class="input-group-addon" id="basic-addon1">¥</span>
					</div>
				</div>
			</div>
			<div id="probabilityDiv">
				<div id="leftProbablityDiv">
					<div class="input-group">
					  <span class="input-group-addon" id="basic-addon1">风险概率</span>
					  <input id="tempRiskProbability" type="text" class="form-control" aria-describedby="basic-addon1" value="-- --">
					</div>
				</div>
				<div id="rightProbablityDiv">
					<div class="input-group">
					  <span class="input-group-addon" id="basic-addon1">可能性等级</span>
					  <input id="tempRiskProbabilityLevel" type="text" class="form-control" readonly aria-describedby="basic-addon1" value="-- --">
					</div>				
				</div>
			</div>			
			<div id="impactsDetailDiv">
				<c:forEach var="eachImpact" items="${impactEnList}" varStatus="status">
					<div class="each">
						<div class="title">Impact${status.count}:</div>
						<div class="eachLeft">
							<div class="input-group">
							  <span class="input-group-addon" id="basic-addon1">损失金额：</span>
							  <input id="impact_${eachImpact.id}" name="${status.count}" type="text" class="form-control" aria-describedby="basic-addon1" value="${eachImpact.loseMoney}">
							  <span class="input-group-addon" id="basic-addon1">¥</span>
							</div>					
						</div>
						<div class="eachRight">
							<div class="input-group">
							  <span class="input-group-addon" >结果等级:</span>
							  <input id="impactLevel_${eachImpact.id}" type="text" class="form-control" readonly aria-describedby="basic-addon1" value="-- --">
							</div>					
						</div>
					</div>					
				</c:forEach>

			</div>			
			<div id="operateDiv">
			  <button id="simulateBtn" type="button"  <c:if test="${edit==false}">disabled</c:if> class="btn btn-warning">&nbsp;模拟&nbsp;</button>
			  <button id="editCancelBtn" type="button" <c:if test="${edit==false}">disabled</c:if> class="btn btn-default">取消</button>
			  <button id="editSaveBtn" type="button" <c:if test="${edit==false}">disabled</c:if> class="btn btn-primary">保存</button>
			</div>					
		</div>
	</section>
</body>
</html>