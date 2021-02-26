<?php
/**
 * Charts 4 PHP
 *
 * @author Shani <support@chartphp.com> - http://www.chartphp.com
 * @version 1.2.3
 * @license: see license.txt included in package
 */
 
include("../../lib/inc/chartphp_dist.php");
include("config.php");
include("db.php");

//$stmt = $db->prepare("SELECT round(avg(webs_attack)) as webs,round(avg(apps_attack)) as apps,round(avg(dbs_attack)) as dbs,round(avg(money_attack)) as money from game_statistics order by id");
$stmt = $db->prepare("select avg(webs_attack) as webs, avg(apps_attack) as apps, avg(dbs_attack) as dbs, avg(money_attack) as money from (SELECT webs_attack,apps_attack,dbs_attack,money_attack from game_statistics order by id desc limit 10) as t");
$stmt->execute();
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
	$webs=$row['webs'];
	$apps=$row['apps'];
	$dbs=$row['dbs'];
	$money=$row['money'];
}

$p = new chartphp();
$p->title = "";
$p->data = array(array(array('Web Server', round($webs)),array('App Server', round($apps)), array('DB Server', round($dbs)), array('Money Malware', round($money))));

$p->chart_type = "pie";
$out1 = $p->render('c1');


$p = new chartphp();
$active=[];
$stmt = $db->prepare("select Hour,Active from (select id,HOUR(timestamp) as Hour,active_players as Active from game_statistics order by id desc limit 10) as t order by id asc");
$stmt->bindValue(1, $id, PDO::PARAM_INT);
$stmt->execute();
$i=0;
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
	$active[$i]=["".$row['Hour']."",$row['Active']];
	$i++;
}
$p->data = array($active);
$p->chart_type = "area";
$out_bar = $p->render('c2');


$p = new chartphp();
$p->data = array(array(array(60, 123, 1067, "Acura"), array(11, 92, 1236, "Alfa Romeo"), array(30, 200, 610, "AM General"), array(50, 23, 800, "Aston"), array(18, 17, 539, "Audi"), array(50, 89, 1026, "BMW"), array(99, 13, 864, "Bugatti")));
$p->chart_type = "bubble";
// Common Options
$out_bubble = $p->render('c3'); 

$p = new chartphp();
$webs=[];
$apps=[];
$dbs=[];
$money=[];
$stmt = $db->prepare("select * from (select HOUR(timestamp) as Hour,game_statistics.* from game_statistics order by id desc limit 10) as t order by id asc");
$stmt->bindValue(1, $id, PDO::PARAM_INT);
$stmt->execute();
$i=0;
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
	$webs[$i]=["".$row['Hour']."",$row['webs_attack']];
	$apps[$i]=["".$row['Hour']."",$row['apps_attack']];
	$dbs[$i]=["".$row['Hour']."",$row['dbs_attack']];
	$money[$i]=["".$row['Hour']."",$row['money_attack']];
	$i++;
}
$p->data = array($webs,$apps,$dbs,$money);
$p->chart_type = "area";
$out_meter = $p->render('c4'); 

$p = new chartphp();
$economy=[];
$stmt = $db->prepare("select Hour,Money from (select id,HOUR(timestamp) as Hour,global_money as Money from game_statistics order by id desc limit 10) as t order by id asc");
$stmt->bindValue(1, $id, PDO::PARAM_INT);
$stmt->execute();
$i=0;
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
	$economy[$i]=["".$row['Hour']."",$row['Money']];
	$i++;
}
$p->data = array($economy);
$p->chart_type = "area";
$out_bar_stack = $p->render('c5'); 

?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Charts 4 PHP | Business Dashboard Demo</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.2 -->
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="http://code.ionicframework.com/ionicons/2.0.0/css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- AdminLTE Skins. Choose a skin from the css/skins 
         folder instead of downloading all of them to reduce the load. -->
    <link href="dist/css/skins/_all-skins.min.css" rel="stylesheet" type="text/css" />
	
	<link rel="icon" type="image/png" href="http://www.chartphp.com/wp-content/uploads/favicon.png">
	
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
	
	<script src="../../lib/js/jquery.min.js"></script>
	<script src="../../lib/js/chartphp.js"></script>
	<link rel="stylesheet" href="../../lib/js/chartphp.css">

	<style>
		/* white color data labels */
		.jqplot-data-label{color:white;}
		
		.jqplot-table-legend td {
			font-size: 115%;
			padding-bottom: 0;
			padding-left: 2px;
			padding-right: 2px;
		}

		/* white color data labels */
		.jqplot-point-label{color:white;}
	</style>

  </head>
  <body class="skin-green">
    <div class="wrapper">
      
      <header class="main-header">
        <!-- Logo -->
        <a href="http://www.chartphp.com/" class="logo"><img src="http://www.chartphp.com/wp-content/uploads/logo_small_white.png" height="35" width="auto"></a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top" role="navigation">
          <!-- Sidebar toggle button-->
          <a href="#" class="sidebar-toggle" data-toggle="offcanvas" role="button">
            <span class="sr-only">Toggle navigation</span>
          </a>		  
          <!-- Navbar Right Menu -->
        </nav>
      </header>

      <!-- Left side column. contains the logo and sidebar -->
      <aside class="main-sidebar">
        <!-- sidebar: style can be found in sidebar.less -->
        <section class="sidebar">

          <!-- sidebar menu: : style can be found in sidebar.less -->
          <ul class="sidebar-menu">
            <li class="header">MAIN NAVIGATION</li>
            <li class="active treeview">
              <a href="#">
                <i class="fa fa-dashboard"></i> <span>Dashboard</span>
              </a>
            </li>
            <li><a href="http://www.chartphp.com/docs/"><i class="fa fa-book"></i> Documentation</a></li>
            <li class="treeview">
              <a href="#">
                <i class="fa fa-pie-chart"></i>
                <span>Charts</span>
                <i class="fa fa-angle-left pull-right"></i>
              </a>
              <ul class="treeview-menu">
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/funnel.php"><i class="fa fa-circle-o"></i> Funnel Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/line.php"><i class="fa fa-circle-o"></i> Line Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/bar.php"><i class="fa fa-circle-o"></i> Bar Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#basic/bar-stacked.php"><i class="fa fa-circle-o"></i> Stacked Bar Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/pie.php"><i class="fa fa-circle-o"></i> Pie Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/donut.php"><i class="fa fa-circle-o"></i> Donut Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/area.php"><i class="fa fa-circle-o"></i> Area Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#basic/meter.php"><i class="fa fa-circle-o"></i> Meter Chart</a></li>
                <li><a target="_blank" href="http://www.chartphp.com/demo/#database/bubble.php"><i class="fa fa-circle-o"></i> Bubble Chart</a></li>
              </ul>
            </li>
			<li class="header">LABELS</li>
            <li><a href="#"><i class="fa fa-circle-o text-danger"></i> Important</a></li>
            <li><a href="#"><i class="fa fa-circle-o text-warning"></i> Warning</a></li>
            <li><a href="#"><i class="fa fa-circle-o text-info"></i> Information</a></li>
          </ul>
        </section>
        <!-- /.sidebar -->
      </aside>
	  
      <!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Content Header (Page header) -->
        <section class="content-header">
          <h1>
            Dashboard
            <small>Version 2.0</small>
          </h1>
        </section>

        <!-- Main content -->
        <section class="content">

          <!-- Main row -->
          <div class="row">
            <!-- Left col -->
            <div class="col-md-6">
              <!-- MAP & BOX PANE -->
              <div class="box box-success">
                <div class="box-header with-border">
                  <h3 class="box-title">Attack Types</h3>
                  <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                    <button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                  <div class="row">
                    <div class="col-md-12 col-sm-12">
                      <div class="pad">
                        <!-- Map will be created here -->
                        		<?php echo $out1; ?>
                      </div>
                    </div><!-- /.col -->
                  </div><!-- /.row -->
                </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->
			
            <!-- Left col -->
            <div class="col-md-6">
              <!-- MAP & BOX PANE -->
              <div class="box box-warning">
                <div class="box-header with-border">
                  <h3 class="box-title">Attack Trends</h3>
                  <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                    <button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                  <div class="row">
                    <div class="col-md-12 col-sm-12">
						<div class="pad">
						<?php echo $out_meter ?>
						</div>
                  </div><!-- /.row -->
                </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->

          </div><!-- /.row -->

          <div class='row'>
		  
            <div class='col-md-6'>
              <!-- USERS LIST -->
              <div class="box box-danger">
                <div class="box-header with-border">
                  <h3 class="box-title">Active Users</h3>
                  <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                    <button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding ">
                  <div class="row">
                    <div class="col-md-12 col-sm-12">
						<div class="pad">
						<?php echo $out_bar ?>
						</div>
                    </div><!-- /.col -->				
                  </div>	
                </div><!-- /.box-body -->
              </div><!--/.box -->
            </div><!-- /.col -->
			
            <div class='col-md-6'>
              <div class="box box-default">
                <div class="box-header with-border">
                  <h3 class="box-title">Total Money</h3>
                  <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                    <button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body">
                  <div class="row">
                    <div class="col-md-12">
                      <div class="pad">
                        <?php echo $out_bar_stack ?>
                      </div>
                    </div><!-- /.col -->
                  </div><!-- /.row -->
                </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->
          </div><!-- /.row -->

		  <!--
          <div class="row">

            <div class="col-md-12">
              <!-- PRODUCT LIST 
              <div class="box box-primary">
                <div class="box-header with-border">
                  <h3 class="box-title">Recently Added Products</h3>
                  <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                    <button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
                  </div>
                </div><!-- /.box-header 
                <div class="box-body">
				
                  <div class="row">
                    <div class="col-md-12">
                      <div class="pad">
						<?php //echo $out_bubble?>
                      </div>
                    </div><!-- /.col 
                  </div><!-- /.row 
				  
                </div><!-- /.box-body 
              </div><!-- /.box 
            </div><!-- /.col 
          </div><!-- /.row 

        </section><!-- /.content 
      </div><!-- /.content-wrapper -->

      <footer class="main-footer">
        <div class="pull-right hidden-xs">
          <b>Version</b> 2.0
        </div>
        <strong>Copyright &copy; 2015 <a href="http://www.chartphp.com">Charts 4 PHP</a>,</strong> All rights reserved.
      </footer>

    </div><!-- ./wrapper -->

    <!-- Bootstrap 3.3.2 JS -->
    <script src="bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- FastClick -->
    <script src='plugins/fastclick/fastclick.min.js'></script>
    <!-- AdminLTE App -->
    <script src="dist/js/app.min.js" type="text/javascript"></script>
  </body>
</html>