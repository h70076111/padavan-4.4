<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - N2V6智能组网</title>
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
<% n2v6_status(); %>
<% login_state_hook(); %>
$j(document).ready(function() {
	init_itoggle('n2v6_enable');
	$j("#tab_n2v6_cfg, #tab_n2v6_log").click(
	function () {
		var newHash = $j(this).attr('href').toLowerCase();
		showTab(newHash);
		return false;
	});

});

</script>
<script>

var isMenuopen = 0;
function initial(){
	show_banner(2);
	show_menu(5, 17, 0);
	showINROUList();
	fill_status(ntwon_status());
	show_footer();

}

function fill_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("n2v6_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

var arrHashes = ["cfg","log"];
function showTab(curHash) {
	var obj = $('tab_n2v6_' + curHash.slice(1));
	if (obj == null || obj.style.display == 'none')
	curHash = '#cfg';
	for (var i = 0; i < arrHashes.length; i++) {
		if (curHash == ('#' + arrHashes[i])) {
			$j('#tab_ntwon_' + arrHashes[i]).parents('li').addClass('active');
			$j('#wnd_ntwon_' + arrHashes[i]).show();
		} else {
			$j('#wnd_ntwon_' + arrHashes[i]).hide();
			$j('#tab_ntwon_' + arrHashes[i]).parents('li').removeClass('active');
			}
		}
	window.location.hash = curHash;
}

function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_n2v6.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}

function done_validating(action){
	refreshpage();
}

function textarea_scripts_enabled(v){
    	inputCtrl(document.form['scripts.ntwon.conf'], v);
}

function change_ntwon_model(mflag){
	var m = document.form.ntwon_model.value;
	var Showmodel = (m >= 1 && m <= 7);


	showhide_div("ntwon_key_tr", Showmodel);
	showhide_div("ntwoni_key_td", Showmodel);
}


function clearLog(){
	var $j = jQuery.noConflict();
	$j.post('/apply.cgi', {
		'action_mode': ' ClearntwonLog ',
		'next_host': 'Advanced_n2v6.asp#log'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
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

	<input type="hidden" name="current_page" value="Advanced_n2v6.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="N2V6;LANHostConfig;General;">
	<input type="hidden" name="group_id" value="N2V6inrou;N2V6mapp">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">
	<input type="hidden" name="n2v6_routenum_x_0" value="<% nvram_get_x("N2V6inrou", "n2v6_routenum_x"); %>" readonly="1" />

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
	<h2 class="box_head round_top"><#menu5_37#></h2>
	<div class="round_bottom">
	<div>
	<ul class="nav nav-tabs" style="margin-bottom: 10px;">
	<li class="active"><a id="tab_n2v6_cfg" href="#cfg">基本设置</a></li>
	<li><a id="tab_n2v6_log" href="#log">运行日志</a></li>
	</th>
	</tr>
	<tr>
	</div>
	<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">
									<p>n2v6智能组网是一个易于配置异地组网 直连技术支持IPV6<br>
									</p>
										</div>
		<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<th><#running_status#>
	</th>
	<td colspan="4" id="n2v6_status"></td>
	</tr><td colspan="4"></td>
	<tr>
										<tr>
										<th width="30%" style="border-top: 0 none;">启用组网客户端</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="n2v6_enable_on_of">
														<input type="checkbox" id="n2v6_enable_fake" <% nvram_match_x("", "n2v6_enable", "1", "value=1 checked"); %><% nvram_match_x("", "n2v6_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="n2v6_enable" id="n2v6_enable_1" class="input" value="1" <% nvram_match_x("", "n2v6_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="n2v6_enable" id="n2v6_enable_0" class="input" value="0" <% nvram_match_x("", "n2v6_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>

										</tr>

										<tr>
										<th>本机识别码(不要改动) </th>
				<td>
					<input type="text" class="input" readonly name="n2v6_keyg" id="n2v6_keyg" style="width: 200px" value="<% nvram_get_x("","n2v6_keyg"); %>" />
				</td>

										</tr>

										<tr>
										<th>本机虚拟ip（格式 10.0.0.x）</th>
				<td>
					<input type="text" class="input" name="n2v6_xuip" id="n2v6_uxip" style="width: 200px" value="<% nvram_get_x("","n2v6_xuip"); %>" />
				</td>

										<tr>
										<th>对端面网段,虚拟ip（格式 192.168.x.0/24,10.0.0.x）</th>
				<td>
					<input type="text" class="input" name="n2v6_inlan1" id="n2v6_inlan1" style="width: 400px" value="<% nvram_get_x("","n2v6_inlan1"); %>" />
				</td>

										</tr>
										<tr>
										<th>节点地址</th>
				<td>
					<input type="text" class="input" name="n2v6_log" id="n2v6_log" style="width: 240px" value="<% nvram_get_x("","n2v6_log"); %>" />
				</td>

										</tr>
										<tr>
									
										<td colspan="4" style="border-top: 0 none;">
												<br />
												<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
											</td>
										</tr>														
	</table>
	</div>
	</div>
	</div>
	</div>
	<!-- 日志 -->
	<div id="wnd_n2v6_log" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
	<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("n2v6.log",""); %></textarea>
	</td>
	</tr>
	<tr>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.reload()" value="刷新日志" class="btn btn-primary" style="width: 200px">
	</td>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.href='ntwon.log'" value="<#CTL_onlysave#>" class="btn btn-success" style="width: 200px">
	</td>
	<td width="75%" style="text-align: right; padding-bottom: 0px;">
	<input type="button" onClick="clearLog();" value="清除日志" class="btn btn-info" style="width: 200px">
	</td>
	</tr>
	<br><td colspan="5" style="border-top: 0 none; text-align: center; padding-top: 4px;">
	<span style="color:#888;">🚫注意：日志包含 token 和 密码 等隐私信息，切勿随意分享！</span>
	</td>
	</table>
	</div>
</body>

</html>
