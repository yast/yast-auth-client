


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>yast-nfs-server/CONTRIBUTING.md at master · yast/yast-nfs-server · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="https://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <meta property="og:image" content="https://github.global.ssl.fastly.net/images/modules/logos_page/Octocat.png">
    <meta name="hostname" content="github-fe129-cp1-prd.iad.github.net">
    <meta name="ruby" content="ruby 2.1.0p0-github-tcmalloc (60139581e1) [x86_64-linux]">
    <link rel="assets" href="https://github.global.ssl.fastly.net/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035/">
    <link rel="xhr-socket" href="/_sockets" />
    


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="5DCDF27C:4A2B:3E42D9D:52D624C5" name="octolytics-dimension-request_id" />
    

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="6FF9qlV4OW1KhCrf2EX/t7MCe1QYj7yijuNiKzk4x5U=" name="csrf-token" />

    <link href="https://github.global.ssl.fastly.net/assets/github-a30b99c54670bd78528a6229b341e1baae15ec17.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://github.global.ssl.fastly.net/assets/github2-d731afd4f624c99a4b19ad69f3083cd6d02b81d5.css" media="all" rel="stylesheet" type="text/css" />
    


      <script src="https://github.global.ssl.fastly.net/assets/frameworks-e075736093c12b6b7444888c0c54d072c23c2a9a.js" type="text/javascript"></script>
      <script src="https://github.global.ssl.fastly.net/assets/github-9223cff931d1ee57f0b581d6f07f25540d269318.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="8582c1c7e638ffd356f2007e95d87ab3">

        <link data-pjax-transient rel='permalink' href='/yast/yast-nfs-server/blob/d3cc773c06c6d7739597dedced709effeced2eed/CONTRIBUTING.md'>
  <meta property="og:title" content="yast-nfs-server"/>
  <meta property="og:type" content="githubog:gitrepository"/>
  <meta property="og:url" content="https://github.com/yast/yast-nfs-server"/>
  <meta property="og:image" content="https://github.global.ssl.fastly.net/images/gravatars/gravatar-user-420.png"/>
  <meta property="og:site_name" content="GitHub"/>
  <meta property="og:description" content="yast-nfs-server - YaST module nfs-server"/>

  <meta name="description" content="yast-nfs-server - YaST module nfs-server" />

  <meta content="909990" name="octolytics-dimension-user_id" /><meta content="yast" name="octolytics-dimension-user_login" /><meta content="4368162" name="octolytics-dimension-repository_id" /><meta content="yast/yast-nfs-server" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="4368162" name="octolytics-dimension-repository_network_root_id" /><meta content="yast/yast-nfs-server" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/yast/yast-nfs-server/commits/master.atom" rel="alternate" title="Recent Commits to yast-nfs-server:master" type="application/atom+xml" />

  </head>


  <body class="logged_out  env-production  vis-public page-blob">
    <div class="wrapper">
      
      
      
      


      
      <div class="header header-logged-out">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions">
        <a class="button primary" href="/join">Sign up</a>
      <a class="button signin" href="/login?return_to=%2Fyast%2Fyast-nfs-server%2Fblob%2Fmaster%2FCONTRIBUTING.md">Sign in</a>
    </div>

    <div class="command-bar js-command-bar  in-repository">

      <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
        <li class="features"><a href="/features">Features</a></li>
          <li class="enterprise"><a href="https://enterprise.github.com/">Enterprise</a></li>
          <li class="blog"><a href="/blog">Blog</a></li>
      </ul>
        <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    
      data-repo="yast/yast-nfs-server"
      data-branch="master"
      data-sha="56a2e3dc25f6769a6bf7d6568385a83fbcefd56a"
  >

    <input type="hidden" name="nwo" value="yast/yast-nfs-server" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="octicon help tooltipped downwards" title="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
    </div>

  </div>
</div>


      


          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">


  <li>
    <a href="/login?return_to=%2Fyast%2Fyast-nfs-server"
    class="minibutton with-count js-toggler-target star-button tooltipped upwards"
    title="You must be signed in to use this feature" rel="nofollow">
    <span class="octicon octicon-star"></span>Star
  </a>

    <a class="social-count js-social-count" href="/yast/yast-nfs-server/stargazers">
      1
    </a>

  </li>

    <li>
      <a href="/login?return_to=%2Fyast%2Fyast-nfs-server"
        class="minibutton with-count js-toggler-target fork-button tooltipped upwards"
        title="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-git-branch"></span>Fork
      </a>
      <a href="/yast/yast-nfs-server/network" class="social-count">
        3
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author">
            <a href="/yast" class="url fn" itemprop="url" rel="author"><span itemprop="title">yast</span></a>
          </span>
          <span class="repohead-name-divider">/</span>
          <strong><a href="/yast/yast-nfs-server" class="js-current-repository js-repo-home-link">yast-nfs-server</a></strong>

          <span class="page-context-loader">
            <img alt="Octocat-spinner-32" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">
      

      <div class="repository-with-sidebar repo-container  ">

        <div class="repository-sidebar">
            

<div class="sunken-menu vertical-right repo-nav js-repo-nav js-repository-container-pjax js-octicon-loaders">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped leftwards" title="Code">
        <a href="/yast/yast-nfs-server" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-gotokey="c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /yast/yast-nfs-server">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped leftwards" title="Issues">
          <a href="/yast/yast-nfs-server/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-gotokey="i" data-selected-links="repo_issues /yast/yast-nfs-server/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>0</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped leftwards" title="Pull Requests">
        <a href="/yast/yast-nfs-server/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-gotokey="p" data-selected-links="repo_pulls /yast/yast-nfs-server/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>0</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped leftwards" title="Pulse">
        <a href="/yast/yast-nfs-server/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /yast/yast-nfs-server/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Graphs">
        <a href="/yast/yast-nfs-server/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /yast/yast-nfs-server/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Network">
        <a href="/yast/yast-nfs-server/network" aria-label="Network" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-selected-links="repo_network /yast/yast-nfs-server/network">
          <span class="octicon octicon-git-branch"></span> <span class="full-word">Network</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

            <div class="only-with-full-nav">
              

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/yast/yast-nfs-server.git" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/yast/yast-nfs-server.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/yast/yast-nfs-server" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/yast/yast-nfs-server" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <span class="octicon help tooltipped upwards" title="Get help on which URL is right for you.">
    <a href="https://help.github.com/articles/which-remote-url-should-i-use">
    <span class="octicon octicon-question"></span>
    </a>
  </span>
</p>



              <a href="/yast/yast-nfs-server/archive/master.zip"
                 class="minibutton sidebar-button"
                 title="Download this repository as a zip file"
                 rel="nofollow">
                <span class="octicon octicon-cloud-download"></span>
                Download ZIP
              </a>
            </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:c4ff14f6ad6466af8cc61f496c361c8c -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<a href="/yast/yast-nfs-server/find/master" data-pjax data-hotkey="t" class="js-show-file-finder" style="display:none">Show File Finder</a>

<div class="file-navigation">
  

<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    role="button" aria-label="Switch branches or tags" tabindex="0">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax>

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-remove-close js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/Code-11/CONTRIBUTING.md"
                 data-name="Code-11"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="Code-11">Code-11</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/Code-11-SP1/CONTRIBUTING.md"
                 data-name="Code-11-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="Code-11-SP1">Code-11-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/REFACTORING-10_3/CONTRIBUTING.md"
                 data-name="REFACTORING-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="REFACTORING-10_3">REFACTORING-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10/CONTRIBUTING.md"
                 data-name="SLE-10"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10">SLE-10</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10-SP1/CONTRIBUTING.md"
                 data-name="SLE-10-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10-SP1">SLE-10-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10-SP1-Features/CONTRIBUTING.md"
                 data-name="SLE-10-SP1-Features"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10-SP1-Features">SLE-10-SP1-Features</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10-SP2/CONTRIBUTING.md"
                 data-name="SLE-10-SP2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10-SP2">SLE-10-SP2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10-SP3/CONTRIBUTING.md"
                 data-name="SLE-10-SP3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10-SP3">SLE-10-SP3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/SLE-10-SP4/CONTRIBUTING.md"
                 data-name="SLE-10-SP4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="SLE-10-SP4">SLE-10-SP4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/limal_removal/CONTRIBUTING.md"
                 data-name="limal_removal"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="limal_removal">limal_removal</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/master/CONTRIBUTING.md"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-9_3/CONTRIBUTING.md"
                 data-name="openSUSE-9_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-9_3">openSUSE-9_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-10_0/CONTRIBUTING.md"
                 data-name="openSUSE-10_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-10_0">openSUSE-10_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-10_1/CONTRIBUTING.md"
                 data-name="openSUSE-10_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-10_1">openSUSE-10_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-10_2/CONTRIBUTING.md"
                 data-name="openSUSE-10_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-10_2">openSUSE-10_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-10_3/CONTRIBUTING.md"
                 data-name="openSUSE-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-10_3">openSUSE-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-11_0/CONTRIBUTING.md"
                 data-name="openSUSE-11_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-11_0">openSUSE-11_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-11_2/CONTRIBUTING.md"
                 data-name="openSUSE-11_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-11_2">openSUSE-11_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-11_3/CONTRIBUTING.md"
                 data-name="openSUSE-11_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-11_3">openSUSE-11_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-11_4/CONTRIBUTING.md"
                 data-name="openSUSE-11_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-11_4">openSUSE-11_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-12_1/CONTRIBUTING.md"
                 data-name="openSUSE-12_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-12_1">openSUSE-12_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/openSUSE-13_1/CONTRIBUTING.md"
                 data-name="openSUSE-13_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="openSUSE-13_1">openSUSE-13_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/remove_spec_in/CONTRIBUTING.md"
                 data-name="remove_spec_in"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="remove_spec_in">remove_spec_in</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/blob/screenshot-locally/CONTRIBUTING.md"
                 data-name="screenshot-locally"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="screenshot-locally">screenshot-locally</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/openSUSE-10_3/2_15_5/CONTRIBUTING.md"
                 data-name="yast-nfs-server/openSUSE-10_3/2_15_5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/openSUSE-10_3/2_15_5">yast-nfs-server/openSUSE-10_3/2_15_5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/openSUSE-9_3/GM/CONTRIBUTING.md"
                 data-name="yast-nfs-server/openSUSE-9_3/GM"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/openSUSE-9_3/GM">yast-nfs-server/openSUSE-9_3/GM</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP2/2_13_10/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP2/2_13_10"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP2/2_13_10">yast-nfs-server/SLE-10-SP2/2_13_10</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP1/2_13_8/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP1/2_13_8"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP1/2_13_8">yast-nfs-server/SLE-10-SP1/2_13_8</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP1/2_13_7/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP1/2_13_7"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP1/2_13_7">yast-nfs-server/SLE-10-SP1/2_13_7</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP1/2_13_6/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP1/2_13_6"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP1/2_13_6">yast-nfs-server/SLE-10-SP1/2_13_6</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP1/2_13_5/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP1/2_13_5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP1/2_13_5">yast-nfs-server/SLE-10-SP1/2_13_5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/SLE-10-SP1/2_13_4/CONTRIBUTING.md"
                 data-name="yast-nfs-server/SLE-10-SP1/2_13_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/SLE-10-SP1/2_13_4">yast-nfs-server/SLE-10-SP1/2_13_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_21_3/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_21_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_21_3">yast-nfs-server/2_21_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_21_2/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_21_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_21_2">yast-nfs-server/2_21_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_21_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_21_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_21_1">yast-nfs-server/2_21_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_21_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_21_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_21_0">yast-nfs-server/2_21_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_18_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_18_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_18_1">yast-nfs-server/2_18_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_18_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_18_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_18_0">yast-nfs-server/2_18_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_7/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_7"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_7">yast-nfs-server/2_17_7</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_6/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_6"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_6">yast-nfs-server/2_17_6</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_5/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_5">yast-nfs-server/2_17_5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_3/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_3">yast-nfs-server/2_17_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_2/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_2">yast-nfs-server/2_17_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_1">yast-nfs-server/2_17_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_17_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_17_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_17_0">yast-nfs-server/2_17_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_16_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_16_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_16_1">yast-nfs-server/2_16_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_16_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_16_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_16_0">yast-nfs-server/2_16_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_5/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_5">yast-nfs-server/2_15_5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_4/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_4">yast-nfs-server/2_15_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_3/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_3">yast-nfs-server/2_15_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_2/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_2">yast-nfs-server/2_15_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_1">yast-nfs-server/2_15_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_15_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_15_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_15_0">yast-nfs-server/2_15_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_14_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_14_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_14_0">yast-nfs-server/2_14_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_13_3/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_13_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_13_3">yast-nfs-server/2_13_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_13_2/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_13_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_13_2">yast-nfs-server/2_13_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_13_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_13_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_13_1">yast-nfs-server/2_13_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_13_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_13_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_13_0">yast-nfs-server/2_13_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_12_1/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_12_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_12_1">yast-nfs-server/2_12_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_12_0/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_12_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_12_0">yast-nfs-server/2_12_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_11_5/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_11_5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_11_5">yast-nfs-server/2_11_5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_11_4/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_11_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_11_4">yast-nfs-server/2_11_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/yast-nfs-server/2_11_3/CONTRIBUTING.md"
                 data-name="yast-nfs-server/2_11_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="yast-nfs-server/2_11_3">yast-nfs-server/2_11_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-12_1/CONTRIBUTING.md"
                 data-name="svn/openSUSE-12_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-12_1">svn/openSUSE-12_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-11_4/CONTRIBUTING.md"
                 data-name="svn/openSUSE-11_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-11_4">svn/openSUSE-11_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-11_3/CONTRIBUTING.md"
                 data-name="svn/openSUSE-11_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-11_3">svn/openSUSE-11_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-11_2/CONTRIBUTING.md"
                 data-name="svn/openSUSE-11_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-11_2">svn/openSUSE-11_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-11_0/CONTRIBUTING.md"
                 data-name="svn/openSUSE-11_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-11_0">svn/openSUSE-11_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-10_3/CONTRIBUTING.md"
                 data-name="svn/openSUSE-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-10_3">svn/openSUSE-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-10_2/CONTRIBUTING.md"
                 data-name="svn/openSUSE-10_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-10_2">svn/openSUSE-10_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-10_1/CONTRIBUTING.md"
                 data-name="svn/openSUSE-10_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-10_1">svn/openSUSE-10_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-10_0/CONTRIBUTING.md"
                 data-name="svn/openSUSE-10_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-10_0">svn/openSUSE-10_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/openSUSE-9_3/CONTRIBUTING.md"
                 data-name="svn/openSUSE-9_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/openSUSE-9_3">svn/openSUSE-9_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/master/CONTRIBUTING.md"
                 data-name="svn/master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/master">svn/master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10-SP4/CONTRIBUTING.md"
                 data-name="svn/SLE-10-SP4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10-SP4">svn/SLE-10-SP4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10-SP3/CONTRIBUTING.md"
                 data-name="svn/SLE-10-SP3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10-SP3">svn/SLE-10-SP3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10-SP2/CONTRIBUTING.md"
                 data-name="svn/SLE-10-SP2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10-SP2">svn/SLE-10-SP2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10-SP1-Features/CONTRIBUTING.md"
                 data-name="svn/SLE-10-SP1-Features"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10-SP1-Features">svn/SLE-10-SP1-Features</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10-SP1/CONTRIBUTING.md"
                 data-name="svn/SLE-10-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10-SP1">svn/SLE-10-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/SLE-10/CONTRIBUTING.md"
                 data-name="svn/SLE-10"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/SLE-10">svn/SLE-10</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/REFACTORING-10_3/CONTRIBUTING.md"
                 data-name="svn/REFACTORING-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/REFACTORING-10_3">svn/REFACTORING-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/Code-11-SP1/CONTRIBUTING.md"
                 data-name="svn/Code-11-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/Code-11-SP1">svn/Code-11-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/svn/Code-11/CONTRIBUTING.md"
                 data-name="svn/Code-11"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="svn/Code-11">svn/Code-11</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/hello-ruby/CONTRIBUTING.md"
                 data-name="hello-ruby"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="hello-ruby">hello-ruby</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/good-bye-ycp/CONTRIBUTING.md"
                 data-name="good-bye-ycp"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="good-bye-ycp">good-bye-ycp</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-12_1/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-12_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-12_1">broken/svn/openSUSE-12_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-11_4/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-11_4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-11_4">broken/svn/openSUSE-11_4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-11_3/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-11_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-11_3">broken/svn/openSUSE-11_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-11_2/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-11_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-11_2">broken/svn/openSUSE-11_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-11_0/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-11_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-11_0">broken/svn/openSUSE-11_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-10_3/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-10_3">broken/svn/openSUSE-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-10_2/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-10_2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-10_2">broken/svn/openSUSE-10_2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-10_1/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-10_1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-10_1">broken/svn/openSUSE-10_1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-10_0/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-10_0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-10_0">broken/svn/openSUSE-10_0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/openSUSE-9_3/CONTRIBUTING.md"
                 data-name="broken/svn/openSUSE-9_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/openSUSE-9_3">broken/svn/openSUSE-9_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/master/CONTRIBUTING.md"
                 data-name="broken/svn/master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/master">broken/svn/master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10-SP4/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10-SP4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10-SP4">broken/svn/SLE-10-SP4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10-SP3/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10-SP3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10-SP3">broken/svn/SLE-10-SP3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10-SP2/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10-SP2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10-SP2">broken/svn/SLE-10-SP2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10-SP1-Features/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10-SP1-Features"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10-SP1-Features">broken/svn/SLE-10-SP1-Features</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10-SP1/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10-SP1">broken/svn/SLE-10-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/SLE-10/CONTRIBUTING.md"
                 data-name="broken/svn/SLE-10"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/SLE-10">broken/svn/SLE-10</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/REFACTORING-10_3/CONTRIBUTING.md"
                 data-name="broken/svn/REFACTORING-10_3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/REFACTORING-10_3">broken/svn/REFACTORING-10_3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/Code-11-SP1/CONTRIBUTING.md"
                 data-name="broken/svn/Code-11-SP1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/Code-11-SP1">broken/svn/Code-11-SP1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/yast/yast-nfs-server/tree/broken/svn/Code-11/CONTRIBUTING.md"
                 data-name="broken/svn/Code-11"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="broken/svn/Code-11">broken/svn/Code-11</a>
            </div> <!-- /.select-menu-item -->
        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/yast/yast-nfs-server" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">yast-nfs-server</span></a></span></span><span class="separator"> / </span><strong class="final-path">CONTRIBUTING.md</strong> <span class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="CONTRIBUTING.md" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>



  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://2.gravatar.com/avatar/ebe96461709771a430da9c7c58f9ae5f?d=https%3A%2F%2Fidenticons.github.com%2Ffb945b3067434474ba269b604525ca02.png&amp;r=x&amp;s=140" width="24" />
    <span class="author"><a href="/dmajda" rel="author">dmajda</a></span>
    <time class="js-relative-date" datetime="2013-11-04T07:06:33-08:00" title="2013-11-04 07:06:33">November 04, 2013</time>
    <div class="commit-title">
        <a href="/yast/yast-nfs-server/commit/b5d30cd3b9f2a3db932e17bc164d43b4a371ce8a" class="message" data-pjax="true" title="Add CONTRIBUTING.md

See:

  * https://github.com/blog/1184-contributing-guidelines
  * http://lists.opensuse.org/yast-devel/2013-10/msg00052.html">Add CONTRIBUTING.md</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong> contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img height="24" src="https://2.gravatar.com/avatar/ebe96461709771a430da9c7c58f9ae5f?d=https%3A%2F%2Fidenticons.github.com%2Ffb945b3067434474ba269b604525ca02.png&amp;r=x&amp;s=140" width="24" />
            <a href="/dmajda">dmajda</a>
          </li>
      </ul>
    </div>
  </div>

<div id="files" class="bubble">
  <div class="file">
    <div class="meta">
      <div class="info">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">file</span>
          <span>88 lines (63 sloc)</span>
        <span>3.526 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled tooltipped leftwards" href="#"
                 title="You must be signed in to make or propose changes">Edit</a>
          <a href="/yast/yast-nfs-server/raw/master/CONTRIBUTING.md" class="button minibutton " id="raw-url">Raw</a>
            <a href="/yast/yast-nfs-server/blame/master/CONTRIBUTING.md" class="button minibutton ">Blame</a>
          <a href="/yast/yast-nfs-server/commits/master/CONTRIBUTING.md" class="button minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
          <a class="minibutton danger disabled empty-icon tooltipped leftwards" href="#"
             title="You must be signed in to make or propose changes">
          Delete
        </a>
      </div><!-- /.actions -->

    </div>
      
  <div id="readme" class="blob instapaper_body">
    <article class="markdown-body entry-content" itemprop="mainContentOfPage"><h1>
<a name="yast-contribution-guidelines" class="anchor" href="#yast-contribution-guidelines"><span class="octicon octicon-link"></span></a>YaST Contribution Guidelines</h1>

<p>YaST is an open source project and as such it welcomes all kinds of
contributions. If you decide to contribute, please follow these guidelines to
ensure the process is effective and pleasant both for you and YaST maintainers.</p>

<p>There are two main forms of contribution: reporting bugs and performing code
changes.</p>

<h2>
<a name="bug-reports" class="anchor" href="#bug-reports"><span class="octicon octicon-link"></span></a>Bug Reports</h2>

<p>If you find a problem, please report it either using
<a href="https://bugzilla.novell.com/enter_bug.cgi?format=guided&amp;product=openSUSE+Factory&amp;component=YaST2">Bugzilla</a>
or <a href="/yast/yast-nfs-server/issues">GitHub issues</a>. (For Bugzilla, use the <a href="https://secure-www.novell.com/selfreg/jsp/createSimpleAccount.jsp">simplified
registration</a>
if you don't have an account yet.)</p>

<p>If you find a problem, please report it either using
<a href="https://bugzilla.novell.com/">Bugzilla</a> or GitHub issues. We can't guarantee
that every bug will be fixed, but we'll try.</p>

<p>When creating a bug report, please follow our <a href="http://en.opensuse.org/openSUSE:Report_a_YaST_bug">bug reporting
guidelines</a>.</p>

<h2>
<a name="code-changes" class="anchor" href="#code-changes"><span class="octicon octicon-link"></span></a>Code Changes</h2>

<p>We welcome all kinds of code contributions, from simple bug fixes to significant
refactorings and implementation of new features. However, before making any
non-trivial contribution, get in touch with us first — this can prevent wasted
effort on both sides. Also, have a look at our <a href="http://en.opensuse.org/openSUSE:YaST_development">development
documentation</a>.</p>

<p>To send us your code change, use GitHub pull requests. The workflow is as
follows:</p>

<ol>
<li><p>Fork the project.</p></li>
<li><p>Create a topic branch based on <code>master</code>.</p></li>
<li><p>Implement your change, including tests (if possible). Make sure you adhere
 to the <a href="https://github.com/SUSE/style-guides/blob/master/Ruby.md">Ruby style
 guide</a>.</p></li>
<li><p>Make sure your change didn't break anything by building the RPM package
 (<code>rake osc:build</code>). The build process includes running the full testsuite.</p></li>
<li><p>Publish the branch and create a pull request.</p></li>
<li><p>YaST developers will review your change and possibly point out issues.
 Adapt the code under their guidance until they are all resolved.</p></li>
<li><p>Finally, the pull request will get merged or rejected.</p></li>
</ol><p>See also <a href="https://help.github.com/articles/fork-a-repo">GitHub's guide on
contributing</a>.</p>

<p>If you want to do multiple unrelated changes, use separate branches and pull
requests.</p>

<p>Do not change the <code>VERSION</code> and <code>*.changes</code> files as this could lead to
conflicts.</p>

<h3>
<a name="commits" class="anchor" href="#commits"><span class="octicon octicon-link"></span></a>Commits</h3>

<p>Each commit in the pull request should do only one thing, which is clearly
described by its commit message. Especially avoid mixing formatting changes and
functional changes into one commit. When writing commit messages, adhere to
<a href="http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html">widely used
conventions</a>.</p>

<p>If your commit is related to a bug in Buzgilla or an issue on GitHub, make sure
you mention it in the commit message for cross-reference. Use format like
bnc#775814 or gh#yast/yast-foo#42. See also <a href="https://help.github.com/articles/github-flavored-markdown#references">GitHub
autolinking</a>
and <a href="http://en.opensuse.org/openSUSE:Packaging_Patches_guidelines#Current_set_of_abbreviations">openSUSE abbreviation
reference</a>.</p>

<h2>
<a name="additional-information" class="anchor" href="#additional-information"><span class="octicon octicon-link"></span></a>Additional Information</h2>

<p>If you have any question, feel free to ask at the <a href="http://lists.opensuse.org/yast-devel/">development mailing
list</a> or at the
<a href="http://webchat.freenode.net/?channels=%23yast">#yast</a> IRC channel on freenode.
We'll do our best to provide a timely and accurate answer.</p></article>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2014 <span title="0.03265s from github-fe129-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/yast/yast-nfs-server/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-remove-close close ajax-error-dismiss"></a>
      Something went wrong with that request. Please try again.
    </div>

  </body>
</html>

