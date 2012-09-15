<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>QAC - QuickAutoComplete</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="QuickAutoComplete - JS for making typing intuitive on web">
    <meta name="author" content="Mayank Singhal">

    <!-- Le styles -->
    <link href="css/bootstrap.css" rel="stylesheet">
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/qac.css">
    <link href="css/bootstrap-responsive.css" rel="stylesheet">

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Le fav and touch icons -->
    <link rel="shortcut icon" href="/favicon.ico">
  </head>

  <body>

    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner hanging">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="#">QuickAutoComplete</a>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li class="active"><a href="#">Demo</a></li>
              <li><a href="http://blog.brotherboard.com">Blog</a></li>
              <li><a href="http://brotherboard.com">WebHome</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
    	<div class="row">
    		<div class="span4">
    			<h1>QuickAutoComplete</h1>
          <p>Very-early pre-alpha zero-tests version</p>
          
          <dt><a href="https://github.com/mayanksinghal/qac">GITHUB</a></dt>
          <dd>For source code, issues, pull requests and more</dd>

          <dt>BLOGPOST</dt>
          <dd>For meta, comments, pats and slaps</dd>

          <dt>THANKS</dt>
          <dd>
            <a href="http://jquery.com">jQuery</a>,
            <a href="http://bevis.me/jquery-caret-position-getter">jquery.caretposition</a>,
            <a href="https://github.com/loopj/jquery-tokeninput">jquery.tokeninput</a>,
            <a href="http://code.google.com/p/jcaret/">jquery.caret</a> and
            <a href="http://twitter.github.com/bootstrap/">Twitter Bootstrap</a>
          </dd>

          <dt>LINCENSE (For Now)</dt>
          <dd>
            <a rel="license"
                href="http://creativecommons.org/licenses/by/3.0/deed.en_US">
                  <img alt="Creative Commons License"
                      style="border-width:0"
                      src="http://i.creativecommons.org/l/by/3.0/88x31.png" />
            </a><br />
            <span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">QAC</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://brotherboard.com" property="cc:attributionName" rel="cc:attributionURL">Mayank Singhal</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/deed.en_US">Creative Commons Attribution 3.0 Unported License</a>.
          </dd>
    		</div>
    		<div class="span4">
    			<div class="well">
					<form>
						<legend>Try it here!</legend>
						<textarea name="" id="tryarea"></textarea>
						<div class="hint">
							<small>Try typing "arrival"</small>
						</div>
					</form>
					
    			</div>
    		</div>
    		<div class="span4">
    			<div class="well">
            <div class="log">
    				  <table class="table table-condensed table-bordered">
  						  <caption>Dictionary Log</caption>
  						  <tbody></tbody>
					    </table>
            </div>
    			</div>
				
    		</div>
    	</div>
    </div> <!-- /container -->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script> -->
    <script src="js/jquery-1.8.0.js"></script>
    <script type="text/javascript" src="js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/assets/closure-library/closure/goog/base.js"></script>
    <script type="text/javascript">
    	goog.require('goog.structs.Trie');
    </script>
    <script type="text/javascript" src="js/jquery.caret.1.02.min.js"></script>
    <script type="text/javascript" src="js/jquery.caretposition.js"></script>
    <script type="text/javascript" src="js/bin/qac.js"></script>
  </body>
</html>
