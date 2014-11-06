#!/bin/bash

APP_DIR=`pwd`
DATA_DIR=$APP_DIR/data-symbs
SYMB_NUM=`wc -l $APP_DIR/data | awk '{ print $1 }'`

cat << HEADER > $APP_DIR/index.html
<!DOCTYPE html>
<html ng-app='feedModule'>

<head>

    <meta charset="utf-8">
    <meta name="robots" content="noindex, nofollow">

    <title>WAVELLY</title>

    <!-- Core CSS - Include with every page -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="font-awesome/css/font-awesome.css" rel="stylesheet">

    <!-- Page-Level Plugin CSS - Tables -->
    <link href="css/plugins/dataTables/dataTables.bootstrap.css" rel="stylesheet">

    <!-- SB Admin CSS - Include with every page -->
    <link href="css/sb-admin.css" rel="stylesheet">

    <link rel="stylesheet" href="alertify/themes/alertify.core.css" />
    <link rel="stylesheet" href="alertify/themes/alertify.default.css" />

</head>

<body ng-controller='FeedCtrl' onload="forever()">

    <div id="wrapper">

        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".sidebar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
            </div>
        <!-- /.navbar-static-top -->
        <nav class="navbar-default navbar-static-side" role="navigation">
              <div class="sidebar-collapse">
                <ul class="nav" id="side-menu">
                    <li class="sidebar-search">
                        <a class="navbar-brand" style="font-family: Arial Black, Gadget, sans-serif;" align="center" href="#">WAVELLY</a><br><br>
                    </li> 
		       <!-- /input-group -->
                    <li>
                        <a href="#stocks"><i class="fa fa-bar-chart-o fa-fw"></i> Stocks <span class="badge">$SYMB_NUM</span></a>
                    </li>
                    <li>
			<a href="#news"><i class="fa fa-rss fa-fw"></i> News Feeds <span class="badge">8</span></a>
                    </li>
                </ul>
                <!-- /#side-menu -->
            </div>
            <!-- /.sidebar-collapse -->
        </nav>
        <!-- /.navbar-static-side -->

        <div id="page-wrapper" id="top">
            <div class="row">
		<br>
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading heading-large">
			  <span class="panel-title section-title" id="stocks"><b>Stocks </b></span>
			     <span class="section-toolbar"><a href="javascript:history.go(0)"><i class="fa fa-refresh"></i></a></span>
			       <span class="pull-right"><button id="refresh" class="btn btn-default btn-sm">Refresh Off</button></span>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>Symbol</th>
                                            <th>Company</th>
                                            <th>Rating</th>
                                            <th>Current Value</th>
                                            <th>Target Wave</th>
                                        </tr>
                                    </thead>
                                    <tbody>
HEADER

rm -f $APP_DIR/sell
touch $APP_DIR/sell

while read line; do

SYMB=`echo $line | awk '{ print $1 }'`
BUY=`echo $line | awk '{ print $2 }'`
TARGET=`echo $line | awk '{ print $3 }'`
SELL=`echo $line | awk '{ print $4 }'`

curl -sf http://finance.yahoo.com/webservice/v1/symbols/$SYMB/quote?format=json > $DATA_DIR/$SYMB

SYM_PR=`cat $DATA_DIR/$SYMB | grep price | awk -F'.' '{ print $1 }' | awk -F'"' '{ print $4 }'`
SYM_NM=`cat $DATA_DIR/$SYMB | grep '"name"' | awk -F'.' '{ print $1 }' | awk -F'"' '{ print $4 }' | sed 's/[ \t]*$//'`
SYM_SN=`cat $DATA_DIR/$SYMB | grep '"name"' | awk -F'.' '{ print $1 }' | awk -F'"' '{ print $4 }' | awk '{ print $1 }' | tr '[:upper:]' '[:lower:]'`

if [[ $SYM_PR -gt $BUY ]]; then
  if [[ $SYM_PR -lt $TARGET ]]; then
cat << BUY >> $APP_DIR/index.html
                                        <tr>
                                            <td>$SYMB</td>
                                            <td>$SYM_NM</td>
                                            <td align="center"><i class="fa fa-plus-circle fa-lg"></i> Buy</td>
                                            <td align="center">$SYM_PR</td>
                                            <td align="center">$TARGET</td>
                                        </tr>
BUY
  fi
fi

if [[ $SYM_PR -ge $TARGET ]]; then
cat << HOLD >> $APP_DIR/index.html
                                        <tr>
                                            <td>$SYMB</td>
                                            <td>$SYM_NM</td>
                                            <td align="center">&nbsp;<i class="fa fa-minus-circle fa-lg"></i> Hold</td>
                                            <td align="center">$SYM_PR</td>
                                            <td align="center">$TARGET</td>
                                        </tr>
HOLD
fi

if [[ $SYM_PR -le $BUY ]]; then
  if [[ $SYM_PR -gt $SELL ]]; then
cat << HOLDD >> $APP_DIR/index.html
                                        <tr>
                                            <td>$SYMB</td>
                                            <td>$SYM_NM</td>
                                            <td align="center">&nbsp;<i class="fa fa-minus-circle fa-lg"></i> Hold</td>
                                            <td align="center">$SYM_PR</td>
                                            <td align="center">$TARGET</td>
                                        </tr>
HOLDD
  fi
fi

if [[ $SYM_PR -le $SELL ]]; then
cat << SELL >> $APP_DIR/index.html
                                        <tr>
                                            <td>$SYMB</td>
                                            <td>$SYM_NM</td>
                                            <td align="center"><i class="fa fa-minus-stop fa-lg"></i> Sell</td>
                                            <td align="center">$SYM_PR</td>
                                            <td align="center">$TARGET</td>
                                        </tr>
SELL

echo "$SYMB" >> $APP_DIR/sell
fi

done < $APP_DIR/data

cat << 'MIDDLE' >> $APP_DIR/index.html
                                    </tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
    </div>
    <ul class="list-group">
       <li class="list-group-item">
          <b>Rating Indicators:</b>  &nbsp;&nbsp; Sell <i class="fa fa-minus-stop fa-lg"></i> &nbsp;&nbsp; | &nbsp;&nbsp; Hold  <i class="fa fa-minus-circle fa-lg"></i> &nbsp;&nbsp; | &nbsp;&nbsp; Buy <i class="fa fa-plus-circle fa-lg"></i>
			   <span class="pull-right">
                            <button class="btn btn-default btn-sm" data-toggle="modal" data-target="#myModal">
                                Disclaimer
                            </button>
                            <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                            <h4 class="modal-title" id="myModalLabel">Disclaimer</h4>
                                        </div>
                                        <div class="modal-body">
					  <p> Stock recommendations and comments presented on THIS APP are solely those of the analysts and experts quoted. They do not represent the opinions of THIS APP on whether to buy, sell or hold shares of a particular stock.  They're only recommedations.<br><br>

Investors should be cautious about any and all stock recommendations and should consider the source of any advice on stock selection. Various factors, including personal or corporate ownership, may influence or factor into an expert's stock analysis or opinion.<br><br>

All investors are advised to conduct their own independent research into individual stocks before making a purchase decision. In addition, investors are advised that past stock performance is no guarantee of future price appreciation.<br></p>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                    <!-- /.modal-content -->
                                </div>
                                <!-- /.modal-dialog -->
                            </div>
			   </span><br><br>
       </li>
    </ul>

<br><br>
                <div class="col-lg-12" id="news">
                    <div class="panel panel-default">
                        <div class="panel-heading heading-large">
                          <span class="panel-title section-title"><b>News </b></span>
                             <span class="section-toolbar"><a href="javascript:history.go(0)"><i class="fa fa-refresh"></i></a></span><br><br>
		  <div ng-repeat="feed in feeds | orderBy:'title'">
		        <p><span ng-repeat="item in feed.entries">
        		<a href="{{item.link}}" target="_blank">{{item.title}}</a><br />
		        </span></p>
		  </div>
		        </div>
		     </div>
		<span class="pull-right"><a href="#top">Back to top</a></span>
		</div>
		<br><br>
                <center><h10>&copy; 2014 Wavelly, Timothy Marcinowski</h10></center><br>

    <!-- Core Scripts - Include with every page -->
    <script src="js/jquery-1.10.2.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/plugins/metisMenu/jquery.metisMenu.js"></script>

    <!-- Page-Level Plugin Scripts - Tables -->
    <script src="js/plugins/dataTables/jquery.dataTables.js"></script>
    <script src="js/plugins/dataTables/dataTables.bootstrap.js"></script>

    <!-- SB Admin Scripts - Include with every page -->
    <script src="js/sb-admin.js"></script>

    <script src="alertify/src/alertify.js"></script>

    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.9/angular.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.9/angular-resource.min.js"></script>
    <script src="js/feeds.js"></script>

    <!-- Page-Level Demo Scripts - Tables - Use for reference -->
    <script>
    $(document).ready(function() {
        $('#dataTables-example').dataTable();
    });
    </script>

<script type="text/javascript">
    var checkeventcount = 1,prevTarget;
    $('.modal').on('show.bs.modal', function (e) {
        if(typeof prevTarget == 'undefined' || (checkeventcount==1 && e.target!=prevTarget))
        {  
          prevTarget = e.target;
          checkeventcount++;
          e.preventDefault();
          $(e.target).appendTo('body').modal('show');
        }
        else if(e.target==prevTarget && checkeventcount==2)
        {
          checkeventcount--;
        }
     });
</script>

<script type="text/javascript">
// Auto refresh section 
var int=self.setInterval(function(){refresh()},60000);

$(document).ready(function() {
  
  var hashTag = window.location.href.split('#')
  if (hashTag[1] == 'reload') {
     $('#refresh').addClass('refresh-on').html('Refresh On');  
  }
  
  $('#refresh').on('click', function() { 
    $(this).toggleClass('refresh-on'); 
    if ($(this).hasClass('refresh-on'))
      $(this).html('Refresh On');
    else 
      $(this).html('Refresh Off');
  });
                  
});

// Left bar hightlight active link
function refresh() {
  if ($('#refresh').hasClass('refresh-on')) {
    location.hash = 'reload';
    window.location.reload();
  } else
      location.hash = '';
}

    $(function() {
        $("li#sidenav-resources").addClass("active");
    });
</script>

<script type="text/javascript">
function reset () {
  alertify.set({
     labels : {
       ok     : "OK",
       cancel : "Cancel"
  },
       delay : 5000,
       buttonReverse : false,
       buttonFocus   : "ok"
  });
}

var audio = new Audio('pop.mp3');
MIDDLE

ALERT_NUM=`wc -l $APP_DIR/sell | awk '{ print $1 }'`

if [[ $ALERT_NUM != 0 ]]; then
cat << ALERT >> $APP_DIR/index.html
function forever() {
  reset();
  audio.play();
  alertify.log("<span class='label label-danger'>$ALERT_NUM</span>  &nbsp;&nbsp; Stocks are at <b>SELL</b>", "", 0);
  return false;
}
ALERT
fi

cat << 'FOOTER' >> $APP_DIR/index.html
</script>

</body>

</html>
FOOTER

rm -f sell
