<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - 集客AC控制台</title>
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

<% gecoac_status(); %>
<% login_state_hook(); %>
$j(document).ready(function() {

	init_itoggle('gecoac_enable');
	$j("#tab_gecoac_cfg, #tab_gecoac_log").click(
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
	fill_status(gecoac_status());
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
	$("gecoac_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

var arrHashes = ["cfg","log"];
function showTab(curHash) {
	var obj = $('tab_gecoac_' + curHash.slice(1));
	if (obj == null || obj.style.display == 'none')
	curHash = '#cfg';
	for (var i = 0; i < arrHashes.length; i++) {
		if (curHash == ('#' + arrHashes[i])) {
			$j('#tab_gecoac_' + arrHashes[i]).parents('li').addClass('active');
			$j('#wnd_gecoac_' + arrHashes[i]).show();
		} else {
			$j('#wnd_gecoac_' + arrHashes[i]).hide();
			$j('#tab_gecoac_' + arrHashes[i]).parents('li').removeClass('active');
			}
		}
	window.location.hash = curHash;
}

function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_gecoac.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}


function done_validating(action){
	refreshpage();
}

function textarea_scripts_enabled(v){
    	inputCtrl(document.form['scripts.gecoac_script.sh'], v);
}

function button_restartGECOAC(){
    	var $j = jQuery.noConflict();
    	$j.post('/apply.cgi',
    	{
        		'action_mode': ' RestartGECOAC ',
    	});
}

function button_gecoac_web(){
	var port = '60650';
	var url = window.location.protocol + "//" + window.location.hostname + ":" + port;
	window.open(url);
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div id="Loading" class="popup_bg"></div>

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
		<div class="row-fluid">
			<div class="span3"><center><div id="logo"></div></center></div>
			<div class="span9" >
				<div id="TopBanner"></div>
			</div>
		</div>
	</div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

	<input type="hidden" name="current_page" value="Advanced_gecoac.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="GECOAC;LANHostConfig;General;">
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
	<h2 class="box_head round_top">集客AC控制器</h2>
	<div class="round_bottom">
	<div>
	<ul class="nav nav-tabs" style="margin-bottom: 10px;">
	<li class="active"><a id="tab_gecoac_cfg" href="#cfg">基本设置</a></li>
	<li><a id="tab_gecoac_log" href="#log">运行日志</a></li>
	</ul>
	</div>
	<div class="row-fluid">
	<div id="tabMenu" class="submenuBlock"></div>
	<div id="wnd_gecoac_cfg">
	<div class="alert alert-info" style="margin: 10px;">
	通过WEB页面方便快捷管理集客AP设备，并自动漫游移动设备<br>
	
	</div>
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<th><#running_status#>
	</th>
	<td colspan="4" id="gecoac_status"></td>
	</tr><td colspan="4"></td>
	<tr>
	<th width="30%" style="border-top: 0 none;">启用集客AC</th>
	<td style="border-top: 0 none;">
	<div class="main_itoggle">
	<div id="gecoac_enable_on_of">
		<input type="checkbox" id="gecoac_enable_fake" <% nvram_match_x("", "gecoac_enable", "1", "value=1 checked"); %><% nvram_match_x("", "gecoac_enable", "0", "value=0"); %>  />
	</div>
	</div>
	<div style="position: absolute; margin-left: -10000px;">
	<input type="radio" value="1" name="gecoac_enable" id="gecoac_enable_1" class="input" value="1" <% nvram_match_x("", "gecoac_enable", "1", "checked"); %> /><#checkbox_Yes#>
	<input type="radio" value="0" name="gecoac_enable" id="gecoac_enable_0" class="input" value="0" <% nvram_match_x("", "gecoac_enable", "0", "checked"); %> /><#checkbox_No#>
	</div>
	</td>
	<td colspan="4" style="border-top: 0 none;">
	<input class="btn btn-success" style="width:150px" type="button" name="restartJYL" value="重启" onclick="button_restartGECOAC()" />
	</td>
	</tr><td colspan="4"></td>
	<tr>
	<th width="30%" style="border-top: 0 none;">服务端口</th>
	<td style="border-top: 0 none;">
	<div class="input-append">
	<input name="gecoac_port" type="text" class="input" id="gecoac_port" placeholder="60650" onkeypress="return is_string(this,event);" value="<% nvram_get_x("","gecoac_port"); %>" size="32" maxlength="128" />
	</div>
	</td>
	</tr><td colspan="4"></td>
	<tr>
	<th width="30%" style="border-top: 0 none;">参数保存路径</th>
	<td style="border-top: 0 none;">
	<div class="input-append">
	<input name="gecoac_Save" type="text" class="input" id="gecoac_Save" placeholder="/etc/storage/gecoac" onkeypress="return is_string(this,event);" value="<% nvram_get_x("","gecoac_Save"); %>" size="32" maxlength="128" />
	</div>
	</td>
	</tr><td colspan="4"></td>	
	<tr>
	<th width="30%" style="border-top: 0 none;">程序路径</th>
	<td style="border-top: 0 none;">
	<div class="input-append">
	<input name="gecoac_bin" type="text" class="input" id="gecoac_bin" placeholder="/usr/bin/gecoac" onkeypress="return is_string(this,event);" value="<% nvram_get_x("","gecoac_bin"); %>" size="32" maxlength="128" />
	</td>
	</tr><td colspan="4"></td>	
	<tr>
	<td style="border-top: 0 none;">
	&nbsp;<input class="btn btn-success" style="" type="button" value="打开集客管理页面" onclick="button_gecoac_web()" />
	</div>
	</td>
	</tr>			
	<tr>
	<td colspan="4">
	<br />
	<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
	</td></td>
	</tr>																	
	</table>
	</div>
	</div>
	
	</div>
	<div id="wnd_gecoac_log" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
	<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("ac_gecoac.log",""); %></textarea>
	</td>
	</tr>
	<tr>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.reload()" value="刷新日志" class="btn btn-primary" style="width: 200px">
	</td>
	</tr>
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
