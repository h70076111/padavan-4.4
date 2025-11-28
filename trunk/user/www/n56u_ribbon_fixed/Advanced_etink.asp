<!DOCTYPE html>
<!--Copyright by hiboy-->
<html>
<head>
<title><#Web_Title#> - ET异地组网</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/client_function.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script>
var $j = jQuery.noConflict();

<% etink_status(); %>
<% login_state_hook(); %>
$j(document).ready(function() {
	
	init_itoggle('etink_enable');

	$j("#tab_etink_cfg, #tab_etink_web, #tab_etink_sta, #tab_etink_log").click(
	function () {
		var newHash = $j(this).attr('href').toLowerCase();
		showTab(newHash);
		return false;
	});

});


</script>
<script>

function initial(){
	show_banner(2);
	show_menu(5,33,0);
	fill_status(etink_status());
	show_footer();
	if (!login_safe())
        		textarea_scripts_enabled(0);

}

function fill_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("etink_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

var arrHashes = ["cfg","web","sta","log"];
function showTab(curHash) {
	var obj = $('tab_etink_' + curHash.slice(1));
	if (obj == null || obj.style.display == 'none')
	curHash = '#cfg';
	for (var i = 0; i < arrHashes.length; i++) {
		if (curHash == ('#' + arrHashes[i])) {
			$j('#tab_etink_' + arrHashes[i]).parents('li').addClass('active');
			$j('#wnd_etink_' + arrHashes[i]).show();
		} else {
			$j('#wnd_etink_' + arrHashes[i]).hide();
			$j('#tab_etink_' + arrHashes[i]).parents('li').removeClass('active');
			}
		}
	window.location.hash = curHash;
}

function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_etink.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}

function  button_restartwg(){
    	var $j = jQuery.noConflict();
    	$j.post('/apply.cgi',
    	{
        		'action_mode': ' Restartwg ',
    	});
}

function done_validating(action){
	refreshpage();
}

function button_etink_web(){
	var port = '6688';
	var url = window.location.protocol + "//" + window.location.hostname + ":" + port;
	window.open(url);
}

function clearLog(){
	var $j = jQuery.noConflict();
	$j.post('/apply.cgi', {
		'action_mode': ' CleareasytierLog ',
		'next_host': 'Advanced_etink.asp#log'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_peer(){
	var $j = jQuery.noConflict();
	$j('#btn_peer').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetpeer ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_connector(){
	var $j = jQuery.noConflict();
	$j('#btn_connector').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetconnector ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_stun(){
	var $j = jQuery.noConflict();
	$j('#btn_stun').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetstun ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_route(){
	var $j = jQuery.noConflict();
	$j('#btn_route').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetroute ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_peer_center(){
	var $j = jQuery.noConflict();
	$j('#btn_peer_center').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetpeer_center ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_vpn_portal(){
	var $j = jQuery.noConflict();
	$j('#btn_vpn_portal').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetvpn_portal ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_node(){
	var $j = jQuery.noConflict();
	$j('#btn_node').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetnode ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_proxy(){
	var $j = jQuery.noConflict();
	$j('#btn_proxy').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetproxy ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_et_status() {
	var $j = jQuery.noConflict();
	$j('#btn_status').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDetstatus ',
		'next_host': 'Advanced_etink.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_etweb(){
	var port = document.form.easytier_html_port.value;
	if (port == '')
	var port = '11210';
	var porturl =window.location.protocol + '//' + window.location.hostname + ":" + port;
	//alert(porturl);
	window.open(porturl,'easytier-web');
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
		<div class="row-fluid">
			<div class="span3"><center><div id="logo"></div></center></div>
			<div class="span9" >
				<div id="TopBanner"></div>
			</div>
		</div>
	</div>

	<div id="Loading" class="popup_bg"></div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

	<input type="hidden" name="current_page" value="Advanced_etink.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="ETINK;">
	<input type="hidden" name="group_id" value="">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">


	<div class="container-fluid">
	<div class="row-fluid">
	<div class="span3">
	<!--Sidebar content-->
	<!--=====Beginning of Main Menu=====-->
	<div class="well sidebar-nav side_nav" style="padding: 0px;">
	<ul id="mainMenu" class="clearfix"></ul>
	<ul class="clearfix">
	<li>
	<div id="subMenu" class="accordion"></div>
	</li>
	</ul>
	</div>
	</div>
	<div class="span9">
	<!--Body content-->
	<div class="row-fluid">
	<div class="span12">
	<div class="box well grad_colour_dark_blue">
	<h2 class="box_head round_top">ET组网</h2>
	<div class="round_bottom">
	<div>
	<ul class="nav nav-tabs" style="margin-bottom: 10px;">
	<li class="active"><a id="tab_etink_cfg" href="#cfg">基本设置</a></li>
	<li><a id="tab_etink_sta" href="#sta">运行状态</a></li>
	<li><a id="tab_etink_log" href="#log">运行日志</a></li>
	</th>
	</tr>
	<tr>
	</div>
	<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">
									<p>ET智能组网是一个易于配置异地组网 直连技术支持IPV6<br>
									</p>
									</div>
										<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
									<tr> <th><#running_status#></th>
                                            <td id="etink_status" colspan="3"></td>
                                        </tr><td></td><td></td><td></td>
										<tr>
										<tr>
										<th width="30%" style="border-top: 0 none;">启用组网客户端</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="etink_enable_on_of">
														<input type="checkbox" id="etink_enable_fake" <% nvram_match_x("", "etink_enable", "1", "value=1 checked"); %><% nvram_match_x("", "etink_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="etink_enable" id="etink_enable_1" class="input" value="1" <% nvram_match_x("", "etink_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="etink_enable" id="etink_enable_0" class="input" value="0" <% nvram_match_x("", "etink_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>

										</tr>

										<tr>
										<th>本机识别码(不要改动) </th>
				<td>
					<input type="text" class="input" readonly name="etink_keyg" id="etink_keyg" style="width: 200px" value="<% nvram_get_x("","etink_keyg"); %>" />
				</td>

										</tr>

										<tr>
										<th>密码(不要改动) </th>
				<td>
					<input type="password" maxlength="256" class="input" size="15" name="etink_pass" id="etink_pass" style="width: 200px" value="<% nvram_get_x("","etink_pass"); %>" />
					<button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('etink_pass')"><i class="icon-eye-close"></i></button>
				</td>

										</tr>

										<tr>
											<th>平台云注册</th>
				<td>
				<input type="button" class="btn btn-success" value="注册或登陆" onclick="window.open('https://easytier.cn/web')" size="0">
				<br>点击去注册一个帐号
											</td>
										</tr>
										<tr>
										<th>虚拟IP</th>
				<td>
					<input type="text" class="input" name="etink_xyip" id="etink_xuip" style="width: 240px" value="<% nvram_get_x("","etink_xyip"); %>" />
				</td>
										</tr>
										<tr>
										<th>节点地址</th>
				<td>
					<input type="text" class="input" name="etink_log" id="etink_log" style="width: 240px" value="<% nvram_get_x("","etink_log"); %>" />
				</td>

										</tr>
										<tr>
										<th>服务</th>
				<td>
					<input type="text" class="input" name="etink_log2" id="etink_log2" style="width: 800px" value="<% nvram_get_x("","etink_log2"); %>" />
				</td>

										</tr>
										<tr>
										<th>服务2</th>
				<td>
					<input type="text" class="input" name="etink_log3" id="etink_log3" style="width: 800px" value="<% nvram_get_x("","etink_log3"); %>" />
				</td>

										</tr>
										<tr>

										</td>
										<td colspan="4" style="border-top: 0 none;">
												<br />
												<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
												</td>
										</tr>	
    </div>
	</td>
	</tr>
	</table>
	</table>
	</div>
	<!-- 状态 -->
	<div id="wnd_etink_sta" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
		<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
			<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("easytier_cmd.log",""); %></textarea>
		</td>
	</tr>
	<tr>
		<td colspan="5" style="border-top: 0 none; text-align: center;">
			<!-- 按钮并排显示 -->
			<input class="btn btn-success" id="btn_peer" style="width:100px; margin-right: 10px;" type="button" name="et_peer" value="对等节点信息" onclick="button_et_peer()" />
			<input class="btn btn-success" id="btn_connector" style="width:100px; margin-right: 10px;" type="button" name="et_connector" value="管理连接器" onclick="button_et_connector()" />
		<input class="btn btn-success" id="btn_stun" style="width:100px; margin-right: 10px;" type="button" name="et_stun" value="STUN 测试" onclick="button_et_stun()" />
			<input class="btn btn-success" id="btn_route" style="width:100px; margin-right: 10px;" type="button" name="et_route" value="显示路由信息" onclick="button_et_route()" />
			<input class="btn btn-success" id="btn_peer_center" style="width:100px; margin-right: 10px;" type="button" name="et_peer_center" value="全局对等信息" onclick="button_et_peer_center()" />
			<input class="btn btn-success" id="btn_vpn_portal" style="width:100px; margin-right: 10px;" type="button" name="et_vpn_portal" value="WireGuard信息" onclick="button_et_vpn_portal()" />
			<input class="btn btn-success" id="btn_node" style="width:100px; margin-right: 10px;" type="button" name="et_node" value="本机核心信息" onclick="button_et_node()" />
			<input class="btn btn-success" id="btn_proxy" style="width:100px; margin-right: 10px;" type="button" name="et_proxy" value="TCP/KCP代理" onclick="button_et_proxy()" />
			<input class="btn btn-success" id="btn_status" style="width:100px; margin-right: 10px;" type="button" name="et_status" value="运行状态信息" onclick="button_et_status()" />
		</td>
	</tr>
	<tr>
		<td colspan="5" style="border-top: 0 none; text-align: center; padding-top: 5px;">
			<span style="color:#888;">🔄 点击上方按钮刷新查看</span>
		</td>
	</tr>
	</table>
	</div>

	<!-- 日志 -->
	<div id="wnd_etink_log" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
	<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("easytier.log",""); %></textarea>
	</td>
	</tr>
	<tr>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.reload()" value="刷新日志" class="btn btn-primary" style="width: 200px">
	</td>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.href='easytier.log'" value="<#CTL_onlysave#>" class="btn btn-success" style="width: 200px">
	</td>
	<td width="75%" style="text-align: right; padding-bottom: 0px;">
	<input type="button" onClick="clearLog();" value="清除日志" class="btn btn-info" style="width: 200px">
	</td>
	</tr>
	<br><td colspan="5" style="border-top: 0 none; text-align: center; padding-top: 4px;">
	<span style="color:#888;">🚫注意：日志可能包含一些隐私信息，切勿随意分享！</span>
	</td>
	</table>
	</div>

	</table>
	</div>
	
	</div>
	</div>
	</div>
	</div>
	</div>
	</form>
	<div id="footer"></div>
	</div>
</body>

</html>
