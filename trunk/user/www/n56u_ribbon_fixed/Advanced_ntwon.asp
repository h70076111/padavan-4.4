<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - N2V2智能组网</title>
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
<% ntwon_status(); %>
<% login_state_hook(); %>
$j(document).ready(function() {
	init_itoggle('ntwon_enable');
	$j("#tab_ntwon_cfg, #tab_ntwon_log").click(
	function () {
		var newHash = $j(this).attr('href').toLowerCase();
		showTab(newHash);
		return false;
	});

});

</script>
<script>

var m_inroulist = [<% get_nvram_list("NTWON", "NTWONinrou"); %>];
var minroulist_ifield = 4;
if(m_inroulist.length > 0){
	var m_inroulist_ifield = m_inroulist[0].length;
	for (var i = 0; i < m_inroulist.length; i++) {
		m_inroulist[i][minroulist_ifield] = i;
	}
}

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
	$("ntwon_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

var arrHashes = ["cfg","log"];
function showTab(curHash) {
	var obj = $('tab_ntwon_' + curHash.slice(1));
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
	document.form.current_page.value = "/Advanced_ntwon.asp";
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

function change_ntwon_enable(mflag){
	var m = document.form.ntwon_enable.value;
	var is_ntwon_enable = (m == "1" || m == "2") ? "重启" : "更新";
	document.form.restartntwon.value = is_ntwon_enable;

		if(m == "2"){
		showhide_div("ntwon_file_tr", 1);

		showhide_div("ntwon_ip_td", 0);
	
		showhide_div("ntwon_mapping_table", 0);
	} 
	
	if(m == "1"){	
		showhide_div("ntwon_file_tr", 0);
		
		showhide_div("ntwon_ip_td", 1);
	
		showhide_div("ntwon_mapping_table", 1);
		o_mtu = document.form.ntwon_mtu;
		
		if (o_mtu && parseInt(o_mtu.value) == 0)
			o_mtu.value = "";
			
		if (o_mtu && parseInt(o_mtu.value) > 1500)
			o_mru.value = "1500";
	}
	
}

function button_restartntwon() {
    var m = document.form.ntwon_enable.value;

    var actionMode = (m == "1" || m == "2") ? ' Restartntwon ' : ' Updatentwon ';

    change_ntwon_enable(m); 

    var $j = jQuery.noConflict(); 
    $j.post('/apply.cgi', {
        'action_mode': actionMode 
    });
}

function markrouteRULES(o, c, b) {
	document.form.group_id.value = "NTWONinrou";
	if(b == " Add "){
		if (document.form.ntwon_routenum_x_0.value >= c){
			alert("<#JS_itemlimit1#> " + c + " <#JS_itemlimit2#>");
			return false;
		}else if (document.form.ntwon_route_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.ntwon_route_x_0.focus();
			document.form.ntwon_route_x_0.select();
			return false;
		}else if(document.form.ntwon_ip_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.ntwon_ip_x_0.focus();
			document.form.ntwon_ip_x_0.select();
			return false;
		}else{
			for(i=0; i<m_inroulist.length; i++){
				if(document.form.ntwon_route_x_0.value==m_inroulist[i][1]) {
				if(document.form.ntwon_ip_x_0.value==m_inroulist[i][2]) {
					alert('<#JS_duplicate#>' + ' (' + m_inroulist[i][1] + ')' );
					document.form.ntwon_route_x_0.focus();
					document.form.ntwon_ip_x_0.select();
					return false;
					}
				}
			}
		}
	}
	pageChanged = 0;
	document.form.action_mode.value = b;
	return true;
}

function showINROUList(){
	var code = '<table width="100%" cellspacing="0" cellpadding="4" class="table table-list">';
	if(m_inroulist.length == 0)
		code +='<tr><td colspan="5" style="text-align: center;"><div class="alert alert-info"><#IPConnection_VSList_Norule#></div></td></tr>';
	else{
	    for(var i = 0; i < m_inroulist.length; i++){
		code +='<tr id="rowrl' + i + '">';
		code +='<td width="28%">&nbsp;' + m_inroulist[i][0] + '</td>';
		code +='<td width="38%">&nbsp;' + m_inroulist[i][1] + '</td>';
		code +='<td colspan="2" width="40%">' + m_inroulist[i][2] + '</td>';
		code +='<td width="50%"></td>';
		code +='<center><td width="20%" style="text-align: center;"><input type="checkbox" name="NTWONinrou_s" value="' + m_inroulist[i][minroulist_ifield] + '" onClick="changeBgColorrl(this,' + i + ');" id="check' + m_inroulist[i][minroulist_ifield] + '"></td></center>';
		
		code +='</tr>';
	    }
		code += '<tr>';
		code += '<td colspan="5">&nbsp;</td>'
		code += '<td><button class="btn btn-danger" type="submit" onclick="markrouteRULES(this, 64, \' Del \');" name="NTWONinrou"><i class="icon icon-minus icon-white"></i></button></td>';
		code += '</tr>'
	}
	code +='</table>';
	$("MrouteRULESList_Block").innerHTML = code;
}

function clearLog(){
	var $j = jQuery.noConflict();
	$j.post('/apply.cgi', {
		'action_mode': ' ClearntwonLog ',
		'next_host': 'Advanced_ntwon.asp#log'
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

	<input type="hidden" name="current_page" value="Advanced_ntwon.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="NTWON;LANHostConfig;General;">
	<input type="hidden" name="group_id" value="NTWONinrou;NTWONmapp">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">
	<input type="hidden" name="ntwon_routenum_x_0" value="<% nvram_get_x("NTWONinrou", "ntwon_routenum_x"); %>" readonly="1" />

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
	<li class="active"><a id="tab_ntwon_cfg" href="#cfg">基本设置</a></li>
	<li><a id="tab_ntwon_log" href="#log">运行日志</a></li>
	</th>
	</tr>
	<tr>
	</div>
	<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">
									<p>n2v2智能组网是一个易于配置异地组网 直连技术支持IPV6<br>
									</p>
										</div>
		<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<th><#running_status#>
	</th>
	<td colspan="4" id="ntwon_status"></td>
	</tr><td colspan="4"></td>
	<tr>
										<tr>
										<th width="30%" style="border-top: 0 none;">启用组网客户端</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="ntwon_enable_on_of">
														<input type="checkbox" id="ntwon_enable_fake" <% nvram_match_x("", "ntwon_enable", "1", "value=1 checked"); %><% nvram_match_x("", "ntwon_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="ntwon_enable" id="ntwon_enable_1" class="input" value="1" <% nvram_match_x("", "ntwon_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="ntwon_enable" id="ntwon_enable_0" class="input" value="0" <% nvram_match_x("", "ntwon_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>

										</tr>

										<tr>
										<th>本机识别码(不要改动) </th>
				<td>
					<input type="text" class="input" readonly name="ntwon_keyg" id="ntwon_keyg" style="width: 200px" value="<% nvram_get_x("","ntwon_keyg"); %>" />
				</td>

										</tr>

										<tr>
										<th>本机虚拟ip（格式 20）</th>
				<td>
					<input type="text" class="input" name="ntwon_xuip" id="ntwon_uxip" style="width: 200px" value="<% nvram_get_x("","ntwon_xuip"); %>" />
				</td>

										</tr>
										<tr>
										<th>节点地址</th>
				<td>
					<input type="text" class="input" name="ntwon_log" id="ntwon_log" style="width: 240px" value="<% nvram_get_x("","ntwon_log"); %>" />
				</td>

										</tr>
										<tr>
	</div>
	</td>
	</tr><tr id="ntwon_log_td"><td colspan="3"></td></tr>
	<table id="ntwon_subnet_table" width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
	<tr> <th colspan="4" style="background-color: #ea66a6;">子网配置 (访问远端内网设备，还需远端配置到本地网段)</th></tr>
	<tr id="row_rules_caption">
	<th width="10%"> 备注名称 </th>
	<th width="20%">远端目标网段 </th>
	<th width="20%">远端虚拟IP </th>
	<th width="5%"><center><i class="icon-th-list"></i></center></th>
	</tr>
	<tr>
	<th><input type="text" placeholder="如：家里" maxlength="128" class="span12" style="width: 100px" size="200" name="ntwon_name_x_0" value="<% nvram_get_x("", "ntwon_name_x_0"); %>"/></th>
	<th><input type="text" placeholder="192.168.2.0/24" maxlength="255" class="span12" style="width: 150px" size="200" name="ntwon_route_x_0" value="<% nvram_get_x("", "ntwon_route_x_0"); %>"/></th>
	<th><input type="text" placeholder="10.26.0.2" maxlength="255" class="span12" style="width: 150px" size="200" name="ntwon_ip_x_0" value="<% nvram_get_x("", "ntwon_ip_x_0"); %>" /></th>
	<th><button class="btn" style="max-width: 219px" type="submit" onclick="return markrouteRULES(this, 64, ' Add ');" name="markrouteRULES2" value="<#CTL_add#>" size="12"><i class="icon icon-plus"></i></button></th>
	</tr>
	<tr id="row_rules_body" >
	<td colspan="4" style="border-top: 0 none; padding: 0px;">
	<div id="MrouteRULESList_Block"></div>
	</td>
	</tr>
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
	<div id="wnd_ntwon_log" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
	<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("ntwon.log",""); %></textarea>
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
