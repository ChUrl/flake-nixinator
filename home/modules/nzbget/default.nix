{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.nzbget;
in {
  options.modules.nzbget = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nzbget
    ];

    home.file.".nzbget".text = ''
      # Configuration file for NZBGet


      ##############################################################################
      ### PATHS                                                                  ###

      # Root directory for all tasks.
      #
      # On POSIX you can use "~" as alias for home directory (e.g. "~/downloads").
      # On Windows use absolute paths (e.g. "C:\Downloads").
      MainDir=${cfg.mainDir}

      # Destination directory for downloaded files.
      #
      # If you want to distinguish between partially downloaded files and
      # completed downloads, use also option <InterDir>.
      DestDir=${cfg.mainDir}/dst

      # Directory to store intermediate files.
      #
      # If this option is set (not empty) the files are downloaded into
      # this directory first. After successful download of nzb-file (possibly
      # after par-repair) the files are moved to destination directory
      # (option <DestDir>). If download or unpack fail the files remain in
      # intermediate directory.
      #
      # Using of intermediate directory can significantly improve unpack
      # performance if you can put intermediate directory (option <InterDir>)
      # and destination directory (option <DestDir>) on separate physical
      # hard drives.
      #
      # NOTE: If the option <InterDir> is set to empty value the downloaded
      # files are put directly to destination directory (option <DestDir>).
      InterDir=${cfg.mainDir}/inter

      # Directory for incoming nzb-files.
      #
      # If a new nzb-file is added to queue via web-interface or RPC-API, it
      # is saved into this directory and then processed by extension
      # scripts (option <Extensions>).
      #
      # This directory is also monitored for new nzb-files. If a new file
      # is found it is added to download queue. The directory can have
      # sub-directories. A nzb-file queued from a subdirectory is automatically
      # assigned to category with sub-directory-name.
      NzbDir=${cfg.mainDir}/nzb

      # Directory to store program state.
      #
      # This directory is used to save download queue, history, information
      # about fetched RSS feeds, statistics, etc.
      QueueDir=${cfg.mainDir}/queue

      # Directory to store temporary files.
      TempDir=${cfg.mainDir}/tmp

      # Directory with web-interface files.
      #
      # Example: /usr/local/share/nzbget/webui.
      #
      # NOTE: To disable web-interface set the option to an empty value.
      # This however doesn't disable the built-in web-server completely because
      # it is also used to serve JSON-/XML-RPC requests.
      WebDir=${pkgs.nzbget}/share/nzbget/webui

      # Directory with post-processing and other scripts.
      #
      # This option may contain multiple directories separated with commas or semicolons.
      #
      # NOTE: For information on writing scripts visit http://nzbget.net/extension-scripts.
      ScriptDir=${cfg.mainDir}/scripts

      # Lock-file for daemon-mode, POSIX only.
      #
      # When started in daemon mode the program creates the lock file and
      # writes process-id (PID) into it. That info can be used in shell
      # scripts. If the lock file can not be created or the lock to the file
      # can not be acquired the daemon terminates, preventing unintentional
      # starting of multiple daemons.
      #
      # Set to empty value to disable the creating of the lock-file and the
      # check for another running instance (not recommended).
      LockFile=${cfg.mainDir}/nzbget.lock

      # Where to store log file, if it needs to be created.
      #
      # NOTE: See also option <WriteLog>.
      LogFile=${cfg.mainDir}/nzbget.log

      # Configuration file template.
      #
      # Put the path to the example configuration file which comes with
      # NZBGet. Web-interface needs this file to read option descriptions.
      #
      # Do not put here your actual configuration file (typically stored
      # in your home directory or in /etc/nzbget.conf) but instead the unchanged
      # example configuration file (typically installed to
      # /usr/local/share/nzbget/nzbget.conf).
      #
      # Example: /usr/local/share/nzbget/nzbget.conf.
      ConfigTemplate=${pkgs.nzbget}/share/nzbget/nzbget.conf

      # Required directories.
      #
      # List of destination directories to be waited for on program start. Directories
      # must be separated with commas or semicolons.
      #
      # The list of directories is checked on program start. The program waits
      # until all directories become available before starting download or
      # post-processing. This is useful if the download destination is configured
      # on network or external drives, which may require some time to mount on boot.
      #
      # NOTE: Only directories used in option <InterDir> and option <DestDir>
      # (global or per-category) can be waited. Other directories, such as
      # option <TempDir>, option <NzbDir> and option <QueueDir> must be
      # available on program start.
      RequiredDir=

      # Certificate store file or directory.
      #
      # Certificate store contains root certificates used for server certificate
      # verification when connecting to servers with encryption (TLS/SSL). This
      # includes communication with news-servers for article downloading and
      # with web-servers (via https) for fetching of rss feeds and nzb-files.
      #
      # The option can point either to one big file containing all root
      # certificates or to a directory containing certificate files, in PEM format.
      #
      # Example: /etc/ssl/certs/ca-certificates.crt.
      #
      # NOTE: Certificate verification must be enabled separately via option <CertCheck>.
      #
      # NOTE: For more details visit http://nzbget.net/certificate-verification.
      CertStore=

      ##############################################################################
      ### NEWS-SERVERS                                                           ###

      # This section defines which servers NZBGet should connect to.
      #
      # The servers should be numbered subsequently without holes.
      # For example if you configure three servers you should name them as Server1,
      # Server2 and Server3. If you need to delete Server2 later you should also
      # change the name of Server3 to Server2. Otherwise it will not be properly
      # read from the config file. Server number doesn't affect its priority (level).

      # Use this news server (yes, no).
      #
      # Set to "no" to disable the server on program start. Servers can be activated
      # later via scheduler tasks or manually via web-interface.
      #
      # NOTE: Download is not possible when all servers on level 0 are disabled. Servers
      # on higher levels are used only if at least one server on level 0 was tried.
      Server1.Active=yes

      # Name of news server.
      #
      # The name is used in UI and for logging. It can be any string, you
      # may even leave it empty.
      Server1.Name=Eweka

      # Level (priority) of news server (0-99).
      #
      # The servers are ordered by their level. NZBGet first tries to download
      # an article from one (any) of level-0-servers. If that server fails,
      # NZBGet tries all other level-0-servers. If all servers fail, it proceeds
      # with the level-1-servers, etc.
      #
      # Put your major download servers at level 0 and your fill servers at
      # levels 1, 2, etc..
      #
      # Several servers with the same level may be defined, they have
      # the same priority.
      Server1.Level=0

      # This is an optional non-reliable server (yes, no).
      #
      # Marking server as optional tells NZBGet to ignore this server if a
      # connection to this server cannot be established. Normally NZBGet
      # doesn't try upper-level servers before all servers on current level
      # were tried. If a connection to server fails NZBGet waits until the
      # server becomes available (it may try others from current level at this
      # time). This is usually what you want to avoid exhausting of
      # (costly) upper level servers if one of main servers is temporary
      # unavailable. However, for less reliable servers you may prefer to ignore
      # connection errors and go on with higher-level servers instead.
      Server1.Optional=no

      # Group of news server (0-99).
      #
      # If you have multiple accounts with same conditions (retention, etc.)
      # on the same news server, set the same group (greater than 0) for all
      # of them. If download fails on one news server, NZBGet does not try
      # other servers from the same group.
      #
      # Value "0" means no group defined (default).
      Server1.Group=0

      # Host name of news server.
      Server1.Host=news.eweka.nl

      # Port to connect to (1-65535).
      Server1.Port=563

      # User name to use for authentication.
      # TODO: User File
      Server1.Username=

      # Password to use for authentication.
      # TODO: PW File
      Server1.Password=

      # Server requires "Join Group"-command (yes, no).
      Server1.JoinGroup=no

      # Encrypted server connection (TLS/SSL) (yes, no).
      #
      # NOTE: By changing this option you should also change the option <ServerX.Port>
      # accordingly because unsecure and encrypted connections use different ports.
      Server1.Encryption=yes

      # Cipher to use for encrypted server connection.
      #
      # By default (when the option is empty) the underlying encryption library
      # chooses the cipher automatically. To achieve the best performance
      # however you can manually select a faster cipher.
      #
      # See http://nzbget.net/choosing-cipher for details.
      #
      # NOTE: You may get a TLS handshake error if the news server does
      # not support the chosen cipher. You can also get an error "Could not
      # select cipher for TLS" if the cipher string is not valid.
      Server1.Cipher=

      # Maximum number of simultaneous connections to this server (0-999).
      Server1.Connections=20

      # Server retention time (days).
      #
      # How long the articles are stored on the news server. The articles
      # whose age exceed the defined server retention time are not tried on
      # this news server, the articles are instead considered failed on this
      # news server.
      #
      # Value "0" disables retention check.
      Server1.Retention=0

      # IP protocol version (auto, ipv4, ipv6).
      Server1.IpVersion=auto

      # User comments on this server.
      #
      # Any text you want to save along with the server definition. For your convenience
      # or for usage in custom extension scripts.
      Server1.Notes=

      # Second server, on level 0.

      #Server2.Level=0
      #Server2.Host=my2.newsserver.com
      #Server2.Port=119
      #Server2.Username=me
      #Server2.Password=mypass
      #Server2.JoinGroup=yes
      #Server2.Connections=4

      # Third server, on level 1.

      #Server3.Level=1
      #Server3.Host=fills.newsserver.com
      #Server3.Port=119
      #Server3.Username=me2
      #Server3.Password=mypass2
      #Server3.JoinGroup=yes
      #Server3.Connections=1


      ##############################################################################
      ### SECURITY                                                               ###

      # IP on which NZBGet server listen and which clients use to contact NZBGet.
      #
      # It could be a dns-hostname (e. g. "mypc") or an IP address (e. g. "192.168.1.2" or
      # "127.0.0.1").
      #
      # Your computer may have multiple network interfaces and therefore multiple IP
      # addresses. If you want NZBGet to listen to all interfaces and be available from
      # all IP-addresses use value "0.0.0.0".
      #
      # NOTE: When you start NZBGet as client (to send remote commands to NZBGet server) and
      # the option <ControlIP> is set to "0.0.0.0" the client will use IP "127.0.0.1".
      #
      # NOTE: If you set the option to "127.0.0.1" you will be able to connect to NZBGet
      # only from the computer running NZBGet. This restriction applies to web-interface too.
      #
      # NOTE: NZBGet also supports listening on Unix domain sockets instead of TCP/IP
      # sockets. To activate this mode set option <ControlIP> to a local path
      # (e. g. "ControlIP=/var/sock").
      ControlIP=0.0.0.0

      # Port which NZBGet server and remote client use (1-65535).
      #
      # NOTE: The communication via this port is not encrypted. For encrypted
      # communication see option <SecurePort>.
      ControlPort=6789

      # User name which NZBGet server and remote client use.
      #
      # Set to empty value to disable user name check (check only password).
      #
      # NOTE: This option was added in NZBGet 11. Older versions used predefined
      # not changeable user name "nzbget". Third-party tools or web-sites written
      # for older NZBGet versions may not have an option to define user name. In
      # this case you should set option <ControlUsername> to the default value
      # "nzbget" or use empty value.
      ControlUsername=nzbget

      # Password which NZBGet server and remote client use.
      #
      # Set to empty value to disable authorization request.
      ControlPassword=nzbgeteweka

      # User name for restricted access.
      #
      # The restricted user can control the program with a few restrictions.
      # They have access to the web-interface and can see most of the program
      # settings. They however, can not change program settings, view security
      # related options or options provided by extension scripts.
      #
      # Use this user to connect to NZBGet from other programs and web-sites.
      #
      # In terms of RPC-API the user:
      # - cannot use method "saveconfig";
      # - methods "config" and "saveconfig" return string "***" for
      #   options those content is protected from the user.
      #
      # Set to empty value to disable restricted user.
      #
      # NOTE: Don't forget to change default username/password of the control
      # user (options <ControlUsername> and <ControlPassword>).
      RestrictedUsername=

      # Password for restricted access.
      #
      # Set to empty value to disable password check.
      RestrictedPassword=

      # User name to add downloads via RPC-API.
      #
      # Use the AddUsername/AddPassword to give other programs or web-services
      # access to NZBGet with only two permissions:
      # - add new downloads using RPC-method "append";
      # - check program version using RPC-method "version".
      #
      # In a case the program/web-service needs more rights use the restricted
      # user instead (options <RestrictedUsername> and <RestrictedPassword>).
      #
      # Set to empty value to disable add-user.
      #
      # NOTE: Don't forget to change default username/password of the control
      # user (options <ControlUsername> and <ControlPassword>).
      AddUsername=

      # Password for user with add downloads access.
      #
      # Set to empty value to disable password check.
      AddPassword=

      # Authenticate using web-form (yes, no).
      #
      # The preferred and default way to authenticate in web-interface is using
      # HTTP authentication. Web-browsers show a special dialog to enter username
      # and password which they then send back to NZBGet. Sometimes browser plugins
      # aided at storing and filling of passwords do not work properly with browser's
      # built-in dialog. To help with such tools NZBGet provide an alternative
      # authentication mechanism via web form.
      FormAuth=no

      # Secure control of NZBGet server (yes, no).
      #
      # Activate the option if you want to access NZBGet built-in web-server
      # via HTTPS (web-interface and RPC). You should also provide certificate
      # and key files, see option <SecureCert> and option <SecureKey>.
      SecureControl=no

      # Port which NZBGet server and remote client use for encrypted
      # communication (1-65535).
      SecurePort=6791

      # Full path to certificate file for encrypted communication.
      #
      # In case of Let's Encrypt: full path to fullchain.pem.
      SecureCert=

      # Full path to key file for encrypted communication.
      #
      # In case of Let's Encrypt: full path to privkey.pem.
      SecureKey=

      # IP-addresses allowed to connect without authorization.
      #
      # List of privileged IPs for easy access to NZBGet built-in web-server
      # (web-interface and RPC). The connected clients have full unrestricted access.
      #
      # Separate entries with commas or semicolons. Use wildcard characters
      # * and ? for pattern matching.
      #
      # Example: 127.0.0.1, 192.168.178.*
      #
      # NOTE: Do not use this option if the program works behind another
      # web-server because all requests will have the address of this server.
      AuthorizedIP=

      # TLS certificate verification (yes, no).
      #
      # When connecting to a news server (for downloading) or a web server
      # (for fetching of rss feeds and nzb-files) the authenticity of the server
      # should be validated using server security certificate. If the check
      # fails that means the connection cannot be trusted and must be closed
      # with an error message explaining the security issue.
      #
      # Sometimes servers are improperly configured and the certificate verification
      # fails even if there is no hacker attack in place. In that case you should
      # inform the server owner about the issue. If you still need to connect to
      # servers with invalid certificates you can disable the certificate verification
      # but you should know that your connection is insecure and you might be
      # connecting to attacker's server without your awareness.
      #
      # NOTE: Certificate verification requires a list of trusted root certificates,
      # which must be configured using option <CertStore>.
      #
      # NOTE: For more details visit http://nzbget.net/certificate-verification.
      CertCheck=no

      # Automatically check for new releases (none, stable, testing).
      #
      #  None    - do not show notifcations;
      #  Stable  - show notifications about new stable releases;
      #  Testing - show notifications about new stable and testing releases.
      UpdateCheck=stable

      # User name for daemon-mode, POSIX only.
      #
      # Set the user that the daemon normally runs at (POSIX in daemon-mode only).
      # Set MainDir with an absolute path to be sure where it will write.
      # This allows NZBGet daemon to be launched in rc.local (at boot), and
      # download items as a specific user id.
      #
      # NOTE: This option has effect only if the program was started from
      # root-account, otherwise it is ignored and the daemon runs under
      # current user id.
      DaemonUsername=root

      # Specify default umask, POSIX only (000-1000).
      #
      # UMask determines the settings of a mask that controls how file permissions
      # are set for newly created files and directories. Please note that UMask
      # doesn't set file permissions directly, it merely filters out certain
      # permissions. It also has very different effect from command "chmod", which
      # you shouldn't confuse UMask with. Please read
      # http://en.wikipedia.org/wiki/Umask for details.
      #
      # The value should be written in octal form (the same as for "umask" shell
      # command).
      # Empty value or value "1000" disables the setting of umask-mode; current
      # umask-mode (set via shell) is used in this case.
      UMask=1000


      ##############################################################################
      ### CATEGORIES                                                             ###

      # This section defines categories available in web-interface.

      # Category name.
      #
      # Each nzb-file can be assigned to a category.
      # Category name is passed to post-processing script and can be used by it
      # to perform category specific processing.
      Category1.Name=Movies

      # Destination directory for this category.
      #
      # If this option is empty, then the default destination directory
      # (option <DestDir>) is used. In this case if the option <AppendCategoryDir>
      # is active, the program creates a subdirectory with category name within
      # destination directory.
      Category1.DestDir=

      # Unpack downloaded nzb-files (yes, no).
      #
      # For more information see global option <Unpack>.
      Category1.Unpack=yes

      # List of extension scripts for this category.
      #
      # For more information see global option <Extensions>.
      Category1.Extensions=

      # List of aliases.
      #
      # When a nzb-file is added from URL, RSS or RPC the category name
      # is usually supplied by nzb-site or by application accessing
      # NZBGet. Using Aliases you can match their categories with your owns.
      #
      # Separate aliases with commas or semicolons. Use wildcard characters
      # * and ? for pattern matching.
      #
      # Example: TV - HD, TV - SD, TV*
      Category1.Aliases=

      Category2.Name=Series
      Category3.Name=Music
      Category4.Name=Software


      ##############################################################################
      ### RSS FEEDS                                                              ###

      # Name of RSS Feed.
      #
      # The name is used in UI and for logging. It can be any string.
      #Feed1.Name=my feed

      # Address (URL) of RSS Feed.
      #
      # Example: https://myindexer.com/api?apikey=3544646bfd1c535a9654645609800901&t=search&q=game.
      #Feed1.URL=

      # Filter rules for items.
      #
      # Use filter to ignore unwanted items in the feed. In its simplest version
      # the filter is a space separated list of words which must be present in
      # the item title.
      #
      # Example: linux debian dvd.
      #
      # MORE INFO:
      # NOTE: This is a short documentation, for more information visit
      # http://nzbget.net/rss.
      #
      # Feed filter consists of rules - one rule per line. Each rule defines
      # a search string and a command, which must be performed if the search
      # string matches. There are five kinds of rule-commands: Accept,
      # Reject, Require, Options, Comment.
      #
      # NOTE: Since options in the configuration file can not span multiple
      # lines, the lines (rules) must be separated with %-character (percent).
      #
      # Definition of a rule:
      #  [A:|A(options):|R:|Q:|O(options):|#] search-string
      #
      #  A - declares Accept-rule. Rules are accept-rules by default, the
      #      "A:" can be omitted. If the feed item matches to the rule the
      #      item is considered good and no further rules are checked.
      #  R - declares Reject-rule. If the feed item matches to the rule the
      #      item is considered bad and no further rules are checked.
      #  Q - declares Require-rule. If the feed item DOES NOT match to the rule
      #      the item is considered bad and no further rules are checked.
      #  O - declares Options-rule. If the feed item matches to the rule the
      #      options declared in the rule are set for the item. The item is
      #      neither accepted nor rejected via this rule but can be accepted
      #      later by one of Accept-rules. In this case the item will have its
      #      options already set (unless the Accept-rule overrides them).
      #  # - lines starting with # are considered comments and are ignored. You
      #      can use comments to explain complex rules or to temporary disable
      #      rules for debugging.
      #
      # Options allow to set properties on nzb-file. It's a comma-separated
      # list of property names with their values.
      #
      # Definition of an option:
      #  name:value
      #
      # Options can be defined using long option names or short names:
      #  category (cat, c)    - set category name, value is a string;
      #  pause (p)            - add nzb in paused or unpaused state, possible
      #                         values are: yes (y), no (n);
      #  priority (pr, r)     - set priority, value is a signed integer number;
      #  priority+ (pr+, r+)  - increase priority, value is a signed integer number;
      #  dupescore (ds, s)    - set duplicate score, value is a signed integer number;
      #  dupescore+ (ds+, s+) - increase duplicate score, value is a signed integer number;
      #  dupekey (dk, k)      - set duplicate key, value is a string;
      #  dupekey+ (dk+, k+)   - add to duplicate key, value is a string;
      #  dupemode (dm, m)     - set duplicate check mode, possible values
      #                         are: score (s), all (a), force (f);
      #  rageid				- generate duplicate key using this rageid
      #                         (integer number) and season/episode numbers;
      #  series				- generate duplicate key using series identifier
      #                         (any unique string) and season/episode numbers.
      #
      # Examples of option definitions:
      #  Accept(category:my series, pause:yes, priority:100): my show 1080p;
      #  Options(c:my series, p:y, r:100): 1080p;
      #  Options(s:1000): 1080p;
      #  Options(k+:1080p): 1080p;
      #  Options(dupemode:force): BluRay.
      #
      # Rule-options override values set in feed-options.
      #
      # The search-string is similar to used in search engines. It consists of
      # search terms separated with spaces. Every term is checked for a feed
      # item and if they all succeed the rule is considered matching.
      #
      # Definition of a term:
      #  [+|-][field:][command]param
      #
      #  +       - declares a positive term. Terms are positive by default,
      #            the "+" can be omitted;
      #  -       - declares a negative term. If the term succeeds the feed
      #            item is ignored;
      #  field   - field to which apply the term. If not specified
      #            the default field "title" is used;
      #  command - a special character defining how to interpret the
      #            parameter (followed after the command):
      #            @  - search for string "param". This is default command,
      #                 the "@" can be omitted;
      #            $  - "param" defines a regular expression (using POSIX Extended
      #                 Regular Expressions syntax);
      #            =  - equal;
      #            <  - less than;
      #            <= - equal or less than;
      #            >  - greater than;
      #            >= - equal or greater than;
      #  param   - parameter for command.
      #
      # Commands @ and $ are for use with text fields (title, filename, category,
      # link, description, dupekey). Commands =, <, <=, > and >= are for use
      # with numeric fields (size, age, imdbid, rageid, season, episode, priority,
      # dupescore).
      #
      # Only fields title, filename and age are always present. The availability of
      # other fields depend on rss feed provider.
      #
      # Any newznab attribute (encoded as "newznab:attr" in the RSS feed) can
      # be used as search field with prefix "attr-", for example "attr-genre".
      #
      # Text search (Command @) supports wildcard characters * (matches
      # any number of any characters), ? (matches any one character)
      # and # (matches one digit).
      # Text search is by default performed against words (word-search mode): the
      # field content is separated into words and then each word is checked
      # against pattern. If the search pattern starts and ends with * (star)
      # the search is performed against the whole field content
      # (substring-search mode). If the search pattern contains word separator
      # characters (except * and ?) the search is performed on the whole
      # field (the word-search would be obviously never successful in this
      # case). Word separators are: !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~.
      #
      # Field "size" can have suffixes "K" or "KB" for kilobytes, "M" or "MB"
      # for megabytes and "G" or "GB" for gigabytes. Field "age" can have
      # suffixes "m" for minutes, "h" for hours and "d" for days. If suffix
      # is not specified default is days.
      #
      # Examples (the trailing ; or . is not part of filter):
      # 1) A: s01* -category:anime;
      # 2) my show WEB-DL;
      # 3) *my?show* WEB-DL size:<1.8GB age:>2h;
      # 4) R: size:>9GB;
      # 5) Q: HDTV.
      #
      # NOTE: This is a short documentation, for more information visit
      # http://nzbget.net/rss.
      #Feed1.Filter=

      # How often to check for new items (minutes).
      #
      # Value "0" disables the automatic check of this feed.
      #Feed1.Interval=15

      # Treat all items on first fetch as backlog (yes, no).
      #
      #  yes - when the feed is fetched for the very first time (or after
      #        changing of URL or filter) all existing items are ignored (marked
      #        as backlog). The items found on subsequent fetches are processed;
      #  no  - all items are processed even on first fetch (or after
      #        changing of URL or filter).
      #Feed1.Backlog=yes

      # Add nzb-files as paused (yes, no).
      #Feed1.PauseNzb=no

      # Category for added nzb-files.
      #
      # NOTE: Feed providers may include category name within response when nzb-file
      # is downloaded. If you want to use the providers category leave the option empty.
      #Feed1.Category=

      # Priority for added nzb-files (number).
      #
      # Priority can be any integer value. The web-interface however operates
      # with only six predefined priorities: -100 (very low priority), -50
      # (low priority), 0 (normal priority, default), 50 (high priority),
      # 100 (very high priority) and 900 (force priority). Downloads with
      # priorities equal to or greater than 900 are downloaded and
      # post-processed even if the program is in paused state (force mode).
      #Feed1.Priority=0

      # List of rss feed extension scripts to execute for rss content.
      #
      # The scripts in the list must be separated with commas or semicolons. All
      # scripts must be stored in directory set by option <ScriptDir> and
      # paths relative to <ScriptDir> must be entered here.
      #
      # NOTE: For developer documentation visit http://nzbget.net/extension-scripts.
      #Feed1.Extensions=


      ##############################################################################
      ### INCOMING NZBS                                                          ###

      # Create subdirectory with category-name in destination-directory (yes, no).
      AppendCategoryDir=yes

      # How often incoming-directory (option <NzbDir>) must be checked for new
      # nzb-files (seconds).
      #
      # Value "0" disables the check.
      #
      # NOTE: nzb-files are processed by extension scripts. See option <Extensions>.
      NzbDirInterval=5

      # How old nzb-file should at least be for it to be loaded to queue (seconds).
      #
      # NZBGet checks if nzb-file was not modified in last few seconds, defined by
      # this option. That safety interval prevents the loading of files, which
      # were not yet completely saved to disk, for example if they are still being
      # downloaded in web-browser.
      NzbDirFileAge=60

      # Check for duplicate titles (yes, no).
      #
      # If this option is enabled the program checks by adding of a new nzb-file:
      # 1) if history contains the same title (see below) with success status
      #    the nzb-file is not added to queue;
      # 2) if download queue already contains the same title the nzb-file is
      #    added to queue for backup (if the first file fails);
      # 3) if nzb-file contains duplicate entries. This helps to find errors
      #    in bad nzb-files.
      #
      # "Same title" means the nzb file name is same or the duplicate key is
      # same. Duplicate keys are set by fetching from RSS feeds using title
      # identifier fields provided by RSS provider (imdbid or rageid/season/episode).
      #
      # If duplicates were detected only one of them is downloaded. If download
      # fails another duplicate is tried. If download succeeds all remaining
      # duplicates are deleted from queue.
      #
      # NOTE: For automatic duplicate handling option <HealthCheck> must be
      # set to "Delete", "Park" or "None". If it is set to "Pause" you will need to
      # manually unpause another duplicate (if any exists in queue).
      #
      # NOTE: For more info on duplicates see http://nzbget.net/rss.
      DupeCheck=yes


      ##############################################################################
      ### DOWNLOAD QUEUE                                                         ###

      # Flush download queue to disk (yes, no).
      #
      # Immediately flush file buffers for queue state file. This improves
      # safety for the queue file but may decrease disk performance due to
      # disabling of disk caching for queue state file.
      #
      # You can disable this option if it negatively affects disk performance on your
      # system. You should create backups of queue-directory (option <QueueDir>)
      # in that case. Keep the option enabled if your system often crashes.
      FlushQueue=yes

      # Continue download of partially downloaded files (yes, no).
      #
      # If active the current state (the info about what articles were already
      # downloaded) is saved every second and is reloaded after restart. This is
      # about files included in download jobs (usually rar-files), not about
      # download-jobs (nzb-files) itself. Download-jobs are always
      # continued regardless of that option.
      #
      # Disabling this option may slightly reduce disk access and is
      # therefore recommended on fast connections.
      ContinuePartial=yes

      # Propagation delay to your news servers (minutes).
      #
      # The option sets minimum post age for nzb-files. Very recent files
      # are not downloaded to avoid download failures. The files remain
      # on hold in the download queue until the propagation delay expires,
      # after that they are downloaded.
      PropagationDelay=0

      # Memory limit for article cache (megabytes).
      #
      # Article cache helps to improve performance. First the amount of disk
      # operations can be significantly reduced. Second the created files are
      # less fragmented, which again speeds up the post-processing (unpacking).
      #
      # The article cache works best with option <DirectWrite> which can
      # effectively use even small cache (like 50 MB).
      #
      # If option <DirectWrite> is disabled the cache should be big enough to
      # hold all articles of one file (typically up to 200 MB, sometimes even
      # 500 MB). Otherwise the articles are written into temporary directory
      # when the cache is full, which degrades performance.
      #
      # Value "0" disables article cache.
      #
      # In 32 bit mode the maximum allowed value is 1900.
      #
      # NOTE: Also see option <WriteBuffer>.
      ArticleCache=0

      # Write decoded articles directly into destination output file (yes, no).
      #
      # Files are posted to Usenet in multiple pieces (articles). Each file
      # typically consists of hundreds of articles.
      #
      # When option <DirectWrite> is disabled and the article cache (option
      # <ArticleCache>) is not active or is full the program saves downloaded
      # articles into temporary directory and later reads them all to write
      # again into the destination file.
      #
      # When option <DirectWrite> is enabled the program at first creates the
      # output destination file with required size (total size of all articles),
      # then writes the articles directly to this file without creating of any
      # temporary files. If article cache (option <ArticleCache>) is active
      # the downloaded articles are saved into cache first and are written
      # into the destination file when the cache flushes. This happen when
      # all articles of the file are downloaded or when the cache becomes
      # full to 90%.
      #
      # The direct write relies on the ability of file system to create
      # empty files without allocating the space on the drive (sparse files),
      # which most modern file systems support including EXT3, EXT4
      # and NTFS. The notable exception is HFS+ (default file system on OSX).
      #
      # The direct write usually improves performance by reducing the amount
      # of disk operations but may produce more fragmented files when used
      # without article cache.
      DirectWrite=yes

      # Memory limit for per connection write buffer (kilobytes).
      #
      # When downloaded articles are written into disk the OS collects
      # data in the internal buffer before flushing it into disk. This option
      # controls the size of this buffer per connection/download thread.
      #
      # Larger buffers decrease the amount of disk operations and help
      # producing less fragmented files speeding up the post-processing
      # (unpack).
      #
      # To calculate the maximum memory required for all download threads multiply
      # WriteBuffer by number of connections configured in section
      # "NEWS-SERVERS". The option sets the limit, the actual buffer can be
      # smaller if the article size (typically about 500 KB) is below the limit.
      #
      # Write-buffer is managed by OS (system libraries) and therefore
      # the effect of the option is highly OS-dependent.
      #
      # Recommended value for computers with enough memory: 1024.
      #
      # Value "0" disables the setting of buffer size. In this case a buffer
      # of default size (OS and compiler specific) is used, which is usually
      # too small (1-4 KB) and therefore not optimal.
      #
      # NOTE: Also see option <ArticleCache>.
      WriteBuffer=0

      # How to name downloaded files (auto, article, nzb).
      #
      #  Article - use file names stored in article metadata;
      #  Nzb     - use file names as defined in nzb-file;
      #  Auto    - prefer names from article metadata; for obfuscated files use
      #            names from nzb-file.
      #
      # NOTE: This option sets the naming convention for files listed in nzb. It has no
      # effect on files extracted from archives.
      FileNaming=auto

      # Reorder files within nzbs for optimal download order (yes, no).
      #
      # When nzb-file is added to queue the files listed within nzb can be in a random
      # order. When "ReorderFiles" is active the files are automatically sorted
      # alphabetically to ensure download of archive parts in correct order. The
      # par2-files are moved to the end and then sorted by size.
      #
      # NOTE: When option <DirectRename> is active the files are sorted again after the file
      # names become known.
      ReorderFiles=yes

      # Post-processing strategy (sequential, balanced, aggressive, rocket).
      #
      #  Sequential - downloaded items are post processed from a queue, one item at a
      #               time, to dedicate the most computer resources to each
      #               item. Therefore, a post process par repair will prevent another
      #               task from running even if the item does not require a par repair;
      #  Balanced   - items that do not need par repair are post processed one at a
      #               time while par repair tasks may also run simultaneously one after
      #               another at the same time. This means that a post process par
      #               repair will not prevent another task from running, but at a cost
      #               of using more computer resource;
      #  Aggressive - will simultaneously post process up to three items including
      #               one par repair task;
      #  Rocket     - will simultaneously post process up to six items including one
      #               or two par repair tasks.
      #
      # NOTE: Computer resources are in heavy demand when post-processing with
      # simultaneous tasks - make sure the hardware is capable.
      PostStrategy=balanced

      # Pause if disk space gets below this value (megabytes).
      #
      # Disk space is checked for directories pointed by option <DestDir> and
      # option <InterDir>.
      #
      # Value "0" disables the check.
      DiskSpace=250

      # Delete source nzb-file when it is not needed anymore (yes, no).
      #
      # Enable this option for automatic deletion of source nzb-file from
      # incoming directory when the program doesn't require it anymore (the
      # nzb-file has been deleted from queue and history).
      NzbCleanupDisk=yes

      # Keep the history of downloaded nzb-files (days).
      #
      # After download and post-processing the items are added to history where
      # their status can be checked and they can be post-processed again if
      # necessary.
      #
      # After expiring of defined period:
      #
      # If option <DupeCheck> is active the items become hidden and the amount
      # of data kept is significantly reduced (for better performance), only
      # fields necessary for duplicate check are kept. The item remains in the
      # hidden history (forever);
      #
      # If option <DupeCheck> is NOT active the items are removed from history.
      #
      # When a failed item is removed from history or become hidden all downloaded
      # files of that item are deleted from disk.
      #
      # Value "0" disables history. Duplicate check will not work.
      KeepHistory=30

      # Keep the history of outdated feed items (days).
      #
      # After fetching of an RSS feed the information about included items (nzb-files)
      # is saved to disk. This allows to detect new items on next fetch. Feed
      # providers update RSS feeds constantly. Since the feed length is limited
      # (usually 100 items or less) the old items get pushed away by new
      # ones. When an item is not present in the feed anymore it's not necessary
      # to keep the information about this item on the disk.
      #
      # If option is set to "0", the outdated items are deleted from history
      # immediately.
      #
      # Otherwise the items are held in the history for defined number of
      # days. Keeping of items for few days helps in situations when feed provider
      # has technical issues and may response with empty feeds (or with missing
      # items). When the technical issue is fixed the items may reappear in the
      # feed causing the program to re-download items if they were not found in
      # the feed history.
      FeedHistory=7

      # Discard downloaded data (do not write into disk) (yes, no).
      #
      # This option is for speed test purposes (benchmarking). When enabled the
      # downloaded data is not written into disk. The destination files are still
      # created but are either empty or contain zeros (depending on other
      # options). The post-processing (unpack, repair, etc.) is also completely
      # disabled.
      #
      # NOTE: This option is meant for development purposes. You should not
      # activate it except maybe for speed tests.
      SkipWrite=no

      # Write article raw data (yes, no).
      #
      # When enabled the article content is written into disk in raw form without
      # processing.
      #
      # NOTE: This option is meant for development purposes. You should not
      # activate it.
      RawArticle=no

      ##############################################################################
      ### CONNECTION                                                             ###

      # How many retries should be attempted if a download error occurs (0-99).
      #
      # If download fails because of incomplete or damaged article or due to
      # CRC-error the program tries to re-download the article from the same
      # news server as many times as defined in this option. If all attempts fail
      # the program tries another news server.
      #
      # If download fails because of "article or group not found error" the
      # program tries another news server without retrying on the failed server.
      ArticleRetries=3

      # Article retry interval (seconds).
      #
      # If download of article fails because of interrupted connection
      # the server is temporary blocked until the retry interval expires.
      ArticleInterval=10

      # Connection timeout for article downloading (seconds).
      ArticleTimeout=60

      # Number of download attempts for URL fetching (0-99).
      #
      # If fetching of nzb-file via URL or fetching of RSS feed fails another
      # attempt is made after the retry interval (option <UrlInterval>).
      UrlRetries=3

      # URL fetching retry interval (seconds).
      #
      # If fetching of nzb-file via URL or fetching of RSS feed fails another
      # attempt is made after the retry interval.
      UrlInterval=10

      # Connection timeout for URL fetching (seconds).
      #
      # Connection timeout when fetching nzb-files via URLs and fetching RSS feeds.
      UrlTimeout=60

      # Timeout for incoming connections (seconds).
      #
      # Set timeout for connections from clients (web-browsers and API clients).
      RemoteTimeout=90

      # Set the maximum download rate on program start (kilobytes/sec).
      #
      # The download rate can be changed later in web-interface or via remote calls.
      #
      # Value "0" means no speed control.
      DownloadRate=0

      # Maximum number of simultaneous connections for nzb URL downloads (0-999).
      #
      # When NZB-files are added to queue via URL, the program downloads them
      # from the specified URL. The option limits the maximal number of connections
      # used for this purpose, when multiple URLs were added at the same time.
      UrlConnections=4

      # Force URL-downloads even if download queue is paused (yes, no).
      #
      # If option is active the URL-downloads (such as appending of nzb-files
      # via URL or fetching of RSS feeds and nzb-files from feeds) are performed
      # even if download is in paused state.
      UrlForce=yes

      # Monthly download volume quota (megabytes).
      #
      # During download the quota is constantly monitored and the downloading
      # is automatically stopped if the limit is reached. Once the next billing month
      # starts the "quota reached"-status is automatically lifted and the downloading
      # continues.
      #
      # Downloads with force-priority are processed regardless of quota status.
      #
      # Value "0" disables monthly quota check.
      MonthlyQuota=0

      # Day of month when the monthly quota starts (1-31).
      QuotaStartDay=1

      # Daily download volume quota (megabytes).
      #
      # See option <MonthlyQuota> for details.
      #
      # Value "0" disables daily quota check.
      DailyQuota=0


      ##############################################################################
      ### LOGGING                                                                ###

      # How to use log file (none, append, reset, rotate).
      #
      #  none   - do not write into log file;
      #  append - append to the existing log file or create it;
      #  reset  - delete existing log file on program start and create a new one;
      #  rotate - create new log file for each day, delete old files,
      #           see option <RotateLog>.
      WriteLog=append

      # Log file rotation period (days).
      #
      # Defines how long to keep old log-files, when log rotation is active
      # (option <WriteLog> is set to "rotate").
      RotateLog=3

      # How error messages must be printed (screen, log, both, none).
      ErrorTarget=both

      # How warning messages must be printed (screen, log, both, none).
      WarningTarget=both

      # How info messages must be printed (screen, log, both, none).
      InfoTarget=both

      # How detail messages must be printed (screen, log, both, none).
      DetailTarget=log

      # How debug messages must be printed (screen, log, both, none).
      #
      # Debug-messages can be printed only if the program was compiled in
      # debug-mode: "./configure --enable-debug".
      DebugTarget=log

      # Number of messages stored in screen buffer (messages).
      LogBuffer=1000

      # Create log for each downloaded nzb-file (yes, no).
      #
      # The messages are saved for each download separately and can be viewed
      # at any time in download details dialog or history details dialog.
      NzbLog=yes

      # Print call stack trace into log on program crash (Linux and Windows) (yes, no).
      #
      # Call stack traces are very helpful for debugging. Call stack traces can be
      # printed only when the program was compiled in debug mode.
      CrashTrace=yes

      # Save memory dump into disk on program crash (Linux only) (yes, no).
      #
      # Memory dumps (core-files) are very helpful for debugging, especially if
      # they were produced by the program compiled in debug mode.
      #
      # NOTE: Memory dumps may contain sensitive data, like your login/password
      # to news-server etc.
      CrashDump=no

      # Local time correction (hours or minutes).
      #
      # The option allows to adjust timestamps when converting system time to
      # local time and vice versa. The conversion is used when printing messages
      # to the log-file and by option "TaskX.Time" in the scheduler settings.
      #
      # The option is usually not needed if the time zone is set up correctly.
      # However, sometimes, especially when using a binary compiled on another
      # platform (cross-compiling) the conversion between system and local time
      # may not work properly and requires adjustment.
      #
      # Values in the range -24..+24 are interpreted as hours, other values as minutes.
      #  Example 1: set time correction to one hour: TimeCorrection=1;
      #  Example 2: set time correction to one hour and a half: TimeCorrection=90.
      TimeCorrection=0


      ##############################################################################
      ### DISPLAY (TERMINAL)                                                     ###

      # Set screen-outputmode (loggable, colored, curses).
      #
      # loggable - only messages will be printed to standard output;
      # colored  - prints messages (with simple coloring for messages categories)
      #            and download progress info; uses escape-sequences to move cursor;
      # curses   - advanced interactive interface with the ability to edit
      #            download queue and various output option.
      OutputMode=curses

      # Shows NZB-Filename in file list in curses-outputmode (yes, no).
      #
      # This option controls the initial state of curses-frontend,
      # it can be switched on/off in run-time with Z-key.
      CursesNzbName=yes

      # Show files in groups (NZB-files) in queue list in curses-outputmode (yes, no).
      #
      # This option controls the initial state of curses-frontend,
      # it can be switched on/off in run-time with G-key.
      CursesGroup=no

      # Show timestamps in message list in curses-outputmode (yes, no).
      #
      # This option controls the initial state of curses-frontend,
      # it can be switched on/off in run-time with T-key.
      CursesTime=no

      # Update interval for Frontend-output in console mode or remote client
      # mode (milliseconds).
      #
      # Min value 25. Bigger values reduce CPU usage (especially in curses-outputmode)
      # and network traffic in remote-client mode.
      UpdateInterval=200


      ##############################################################################
      ### SCHEDULER                                                              ###

      # Time to execute the command (HH:MM).
      #
      # Multiple comma-separated values are accepted.
      # An asterisk placed in the hours location will run task every hour (e. g. "*:00").
      # An asterisk without minutes will run task at program startup (e. g. "*").
      #
      # Examples: "08:00", "00:00,06:00,12:00,18:00", "*:00", "*,*:00,*:30".
      #
      # NOTE: Also see option <TimeCorrection>.
      #Task1.Time=08:00

      # Week days to execute the command (1-7).
      #
      # Comma separated list of week days numbers.
      # 1 is Monday.
      # Character '-' may be used to define ranges.
      #
      # Examples: "1-7", "1-5", "5,6", "1-5, 7".
      #Task1.WeekDays=1-7

      # Command to be executed (PauseDownload, UnpauseDownload, PausePostProcess,
      # UnpausePostProcess, PauseScan, UnpauseScan, DownloadRate, Script, Process,
      # ActivateServer, DeactivateServer, FetchFeed).
      #
      # Possible commands:
      #   PauseDownload      - pause download;
      #   UnpauseDownload    - resume download;
      #   PausePostProcess   - pause post-processing;
      #   UnpausePostProcess - resume post-processing;
      #   PauseScan          - pause scan of incoming nzb-directory;
      #   UnpauseScan        - resume scan of incoming nzb-directory;
      #   DownloadRate       - set download rate limit;
      #   Script             - execute one or multiple scheduler scripts. The scripts
      #                        must be written specially for NZBGet;
      #   Process            - execute an external (any) program;
      #   ActivateServer     - activate news-server;
      #   DeactivateServer   - deactivate news-server;
      #   FetchFeed          - fetch RSS feed.
      #
      # On start the program checks all tasks and determines current state
      # for download-pause, scan-pause, download-rate and active servers.
      #Task1.Command=PauseDownload

      # Parameters for the command if needed.
      #
      # Some scheduler commands require additional parameters:
      #  DownloadRate     - download rate limit to be set (kilobytes/sec).
      #                     Example: 1000.
      #                     NOTE: use value "0" to disable download limit (unlimited speed).
      #  Script           - list of scheduler scripts to execute. The scripts in the
      #                     list must be separated with commas or semicolons. All
      #                     scripts must be stored in directory set by option
      #                     <ScriptDir> and paths relative to <ScriptDir> must be
      #                     entered here. For developer documentation visit
      #                     http://nzbget.net/extension-scripts;
      #  Process          - path to the program to execute and its parameters.
      #                     Example: /home/user/fetch.sh.
      #                     If filename or any parameter contains spaces it
      #                     must be surrounded with single quotation
      #                     marks. If filename/parameter contains single quotation marks,
      #                     each of them must be replaced (escaped) with two single quotation
      #                     marks and the resulting filename/parameter must be
      #                     surrounded with single quotation marks.
      #                     Example: '/home/user/download/my scripts/task process.sh' 'world's fun'.
      #                     In this example one parameter (world's fun) is passed
      #                     to the script (task process.sh).
      #  ActivateServer   - comma separated list of news server ids or server names.
      #                     Example: 1,3.
      #                     Example: my news server 1, my news server 2.
      #                     NOTE: server names should not have commas.
      #  DeactivateServer - see ActivateServer.
      #  FetchFeed        - comma separated list of RSS feed ids or feed names.
      #                     Example: 1,3.
      #                     Example: bookmarks feed, another feed.
      #                     NOTE: feed names should not have commas.
      #                     NOTE: use feed id "0" to fetch all feeds.
      #Task1.Param=

      #Task2.Time=20:00
      #Task2.WeekDays=1-7
      #Task2.Command=UnpauseDownload
      #Task2.Param=


      ##############################################################################
      ### CHECK AND REPAIR                                                       ###

      # Check CRC of downloaded and decoded articles (yes, no).
      #
      # Normally this option should be enabled for better detecting of download
      # errors and for quick par-verification (option <ParQuick>).
      CrcCheck=yes

      # Whether and how par-verification must be performed (auto, always, force, manual).
      #
      #  Auto   - par-check is performed when needed. One par2-file is always
      #           downloaded. Additional par2-files are downloaded if needed
      #           for repair. Repair is performed if the option <ParRepair>
      #           is enabled;
      #  Always - check every download (even undamaged). One par2-file is
      #           always downloaded. Additional par2-files are downloaded
      #           if needed for repair.  Repair is performed if the option
      #           <ParRepair> is enabled;
      #  Force  - force par-check for every download (even undamaged). All
      #           par2-files are always downloaded. Repair is performed if
      #           the option <ParRepair> is enabled;
      #  Manual - par-check is skipped. One par2-file is always
      #           downloaded. If a damaged download is detected, all
      #           par2-files are downloaded but neither par-check nor par-repair
      #           take place. The download can be then repaired manually,
      #           eventually on another faster computer.
      ParCheck=auto

      # Automatic par-repair after par-verification (yes, no).
      #
      # If option <ParCheck> is set to "Auto" or "Force" this option defines
      # if the download must be repaired when needed. The option can be
      # disabled if a computer does not have enough CPU power, since repairing
      # may consume too many resources and time on a slow computer.
      ParRepair=yes

      # What files should be scanned during par-verification (limited, extended,
      # full, dupe).
      #
      #  Limited  - scan only files belonging to par-set;
      #  Extended - scan files belonging to par-set first, scan other files until
      #             all missing files are found;
      #  Full     - scan all files in destination directory. Can be very time
      #             consuming but may sometimes repair where Limited and Extended fail;
      #  Dupe     - scan files belonging to par-set first, scan other files until
      #             repair is possible. Even files from other duplicate-downloads
      #             are scanned. Can be very time consuming but brings best results.
      ParScan=extended

      # Quick file verification during par-check (yes, no).
      #
      # If the option is active the files are quickly verified using
      # checksums calculated during download; quick verification is very fast
      # because it doesn't require the reading of files from disk, NZBGet
      # knows checksums of downloaded files and quickly compares them with
      # checksums stored in the par-file.
      #
      # If the option is disabled the files are verified as usual. That's
      # slow. Use this if the quick verification doesn't work properly.
      ParQuick=yes

      # Memory limit for par-repair buffer (megabytes).
      #
      # Set the amount of RAM that the par-checker may use during repair. Having
      # the buffer as big as the total size of all damaged blocks allows for
      # the optimal repair speed. The option sets the maximum buffer size, the
      # allocated buffer can be smaller.
      #
      # If you have a lot of RAM set the option to few hundreds (MB) for the
      # best repair performance.
      ParBuffer=16

      # Number of threads to use during par-repair (0-99).
      #
      # On multi-core CPUs for the best speed set the option to the number of
      # logical cores (physical cores + hyper-threading units). If you want
      # to utilize the CPU to 100% you may need to add one or two additional threads
      # to compensate for wait intervals used for thread synchronization.
      #
      # On single-core CPUs use only one thread.
      #
      # Set to '0' to automatically use all available CPU cores (may not
      # work on old or exotic platforms).
      ParThreads=0

      # Files to ignore during par-check.
      #
      # List of file extensions, file names or file masks to ignore by
      # par-rename and par-check. The entries must be separated with
      # commas.
      #
      # The entries must be separated with commas. The entries can be file
      # extensions, file names or file masks containing wildcard
      # characters * and ?.
      #
      # If par-rename or par-check detect missing or damaged files they
      # will ignore files matching this option and will not initiate
      # repair. This avoids time costing repair for unimportant files.
      #
      # Example: .sfv, .nzb, .nfo
      ParIgnoreExt=.sfv, .nzb, .nfo

      # Check for renamed and missing files using par-files (yes, no).
      #
      # Par-rename restores original file names using information stored
      # in par2-files. It also detects missing files (files listed in
      # par2-files but not present on disk). When enabled the par-rename is
      # performed as the first step of post-processing for every nzb-file.
      #
      # Par-rename is very fast and is highly recommended, especially if
      # unpack is disabled.
      ParRename=yes

      # Check for renamed rar-files (yes, no).
      #
      # Rar-rename restores original file names using information stored
      # in rar-files. When enabled the rar-rename is performed as one of the
      # first steps of post-processing for every nzb-file.
      #
      # Rar-rename is useful for downloads not having par2-files or for
      # downloads those files were renamed before creating par2-files. In
      # both cases par-rename (option <ParRename>) can't rename files
      # and the rar-rename makes it possible to unpack downloads which
      # would fail otherwise.
      RarRename=yes

      # Directly rename files during downloading (yes, no).
      #
      # This is similar to par-renaming (option <ParRename>) but the files
      # are renamed during downloading instead of post-processing stage. This
      # requires some tricky handling of files and works only for healthy
      # downloads.
      DirectRename=no

      # What to do if download health drops below critical health (delete, park,
      # pause, none).
      #
      #  Delete - delete nzb-file from queue, also delete already downloaded files;
      #  Park   - move nzb-file to history, keep already downloaded files. Commands
      #           "Download remaining files" and "Retry failed articles" are available
      #           for this nzb;
      #  Pause  - pause nzb-file;
      #  None   - do nothing (continue download).
      #
      # NOTE: For automatic duplicate handling option must be set to "Delete", "Park"
      # or "None". If it is set to "Pause" you will need to manually move another
      # duplicate from history to queue. See also option <DupeCheck>.
      #
      # NOTE: When option <ParScan> is set to "Dupe" the park-action is performed
      # only if article completion is below 10% (empirical threshold). This is to
      # improve efficiency of dupe par scan mode.
      HealthCheck=park

      # Maximum allowed time for par-repair (minutes).
      #
      # If you use NZBGet on a very slow computer like NAS-device, it may be good to
      # limit the time allowed for par-repair. NZBGet calculates the estimated time
      # required for par-repair. If the estimated value exceeds the limit defined
      # here, NZBGet cancels the repair.
      #
      # To avoid a false cancellation NZBGet compares the estimated time with
      # <ParTimeLimit> after the first 5 minutes of repairing, when the calculated
      # estimated time is more or less accurate. But in a case if <ParTimeLimit> is
      # set to a value smaller than 5 minutes, the comparison is made after the first
      # whole minute.
      #
      # Value "0" means unlimited.
      #
      # NOTE: The option limits only the time required for repairing. It doesn't
      # affect the first stage of parcheck - verification of files. However, the
      # verification speed is constant, it doesn't depend on files integrity and
      # therefore it is not necessary to limit the time needed for the first stage.
      ParTimeLimit=0

      # Pause download queue during check/repair (yes, no).
      #
      # Enable the option to give CPU more time for par-check/repair. That helps
      # to speed up check/repair on slow CPUs with fast connection (e.g. NAS-devices).
      #
      # NOTE: If parchecker needs additional par-files it temporarily unpauses
      # the queue.
      #
      # NOTE: See also options <ScriptPauseQueue> and <UnpackPauseQueue>.
      ParPauseQueue=no


      ##############################################################################
      ### UNPACK                                                                 ###

      # Unpack downloaded nzb-files (yes, no).
      #
      # Each download (nzb-file) has a post-processing parameter "Unpack". The option
      # <Unpack> is the default value assigned to this pp-parameter of the download
      # when it is added to queue.
      #
      # When nzb-file is added to queue it can have a category assigned to it. In this
      # case the option <CategoryX.Unpack> overrides the global option <Unpack>.
      #
      # If the download is damaged and could not be repaired using par-files
      # the unpacking is not performed.
      #
      # If the option <ParCheck> is set to "Auto" the program tries to unpack
      # downloaded files first. If the unpacking fails the par-check/repair
      # is performed and the unpack is executed again.
      Unpack=yes

      # Directly unpack files during downloading (yes, no).
      #
      # When active the files are unpacked during downloading instead of post-processing
      # stage. This works only for healthy downloads. Damaged downloads are unpacked
      # as usual during post-processing stage after par-repair.
      #
      # NOTE: This option requires unpack to be enabled in general via option <Unpack>.
      # NOTE: For best results also activate option <DirectRename> and option <ReorderFiles>.
      DirectUnpack=no

      # Pause download queue during unpack (yes, no).
      #
      # Enable the option to give CPU more time for unpacking. That helps
      # to speed up unpacking on slow CPUs.
      #
      # NOTE: See also options <ParPauseQueue> and <ScriptPauseQueue>.
      UnpackPauseQueue=no

      # Delete archive files after successful unpacking (yes, no).
      UnpackCleanupDisk=yes

      # Full path to unrar executable.
      #
      # Example: /usr/bin/unrar.
      #
      # The option can also contain extra switches to pass to unrar. To the
      # here defined command line NZBGet adds the following switches:
      #    x -y -p- -o+ *.rar ./_unpack/
      #
      # Switch "x" is added only if neither "x" nor "e" were defined in
      # the option (this allows you to use switch "e" instead of "x"). switch
      # "-o+" is added only if neither "-o+" nor "-o-" were defined
      # in the command line. All other parameters are always added. Parameter
      # "-p-" is replaced with "-ppassword" if a password is set for nzb-file.
      #
      # Examples:
      # 1) ignore file attributes (permissions):
      # /usr/bin/unrar x -ai;
      # 2) decrease priority of unrar-process:
      # nice -n 19 unrar.
      #
      # For other useful switches refer to unrar documentation.
      #
      # If unrar is in your PATH you may leave the path part and set only
      # the executable name ("unrar" on POSIX or "unrar.exe" on Windows).
      UnrarCmd=unrar

      # Full path to 7-Zip executable.
      #
      # Example: /usr/bin/7z.
      #
      # Similar to option <UnrarCmd> this option can also include extra switches.
      #
      # If 7-Zip binary is in your PATH you may leave the path part and set only
      # the executable name ("7z" or "7za" on POSIX or "7z.exe" on Windows).
      SevenZipCmd=7z

      # Files to delete after successful download.
      #
      # List of file extensions, file names or file masks to delete after
      # successful download. If either unpack or par-check fail the cleanup is
      # not performed. If download doesn't contain archives nor par-files
      # the cleanup is performed if the health is 100%. If parameter "unpack"
      # is disabled for that nzb-file the cleanup isn't performed.
      #
      # The entries must be separated with commas. The entries can be file
      # extensions, file names or file masks containing wildcard
      # characters * and ?.
      #
      # Example: .par2, .sfv
      ExtCleanupDisk=.par2, .sfv

      # Files to ignore during unpack.
      #
      # List of file extensions to ignore when unpacking archives or renaming
      # obfuscated archive files. The entries must be separated with commas.
      #
      # Archive files with non standard extensions belong to one of two categories: they
      # are either obfuscated files or files with special purposes which should not be
      # unpacked. List the files of second type here to avoid attempts to unpack them.
      #
      # This option has effect on two post-processing stages.
      #
      # First, during rar-rename (option <RarRename>) rar-files with non-standard
      # extensions are renamed back to rar-extension, which is required for successful
      # unpacking. Files with extensions listed here will not be renamed.
      #
      # Second, if during unpack no rar-files are found but instead rar-archives
      # with non-rar extensions are found the unpack fails. For files listed here
      # no unpack failure occurs and download is considered not having archive
      # files and be successful.
      #
      # Example: .cbr
      UnpackIgnoreExt=.cbr

      # Path to file containing unpack passwords.
      #
      # If the option is set the program will try all passwords from the file
      # when unpacking the archives. The file must be a text file containing
      # one password per line.
      #
      # If an nzb-file has a defined password (in the post-processing settings)
      # then the password-file is not used for that nzb-file.
      #
      # NOTE: Trying multiple passwords is a time consuming task. Whenever possible
      # passwords should be set per nzb-file in their post-processing settings.
      UnpackPassFile=


      ##############################################################################
      ### EXTENSION SCRIPTS                                                      ###

      # List of active extension scripts for new downloads.
      #
      # Extension scripts associated with nzb-files are executed before, during
      # or after download as defined by script developer.
      #
      # Each download (nzb-file) has its own list of extension scripts; the list
      # can be viewed and changed in web-interface in download details dialog or
      # via API. Option <Extensions> sets defaults for new downloads; changes
      # to option <Extensions> do not affect downloads which are already in queue.
      #
      # When nzb-file is added to queue it can have a category assigned to it. In this
      # case option <CategoryX.Extensions> (if not empty) have precedence and
      # defines the scripts for that nzb-file; consequently global option <Extensions>
      # has no effect for that nzb-file.
      #
      # Certain extensions work globally for the whole program instead of
      # per-nzb basis. Such extensions are activated once and cannot be overriden
      # per category or per nzb.
      #
      # The scripts in the list must be separated with commas or semicolons. All
      # scripts must be stored in directory set by option <ScriptDir> and
      # paths relative to <ScriptDir> must be entered here.
      #
      # Example: Cleanup.sh, Move.sh, EMail.py.
      #
      # NOTE: The script execution order is controlled by option <ScriptOrder>, not
      # by their order in option <Extensions>.
      #
      # NOTE: For the list of interesting extension scripts see
      # http://nzbget.net/catalog-of-extension-scripts.
      #
      # NOTE: For developer documentation visit http://nzbget.net/extension-scripts.
      Extensions=

      # Execution order for extension scripts.
      #
      # If you assign multiple scripts to one nzb-file, they are executed in the
      # order defined by this option.
      #
      # The scripts in the list must be separated with commas or semicolons. All
      # scripts must be stored in directory set by option <ScriptDir> and
      # paths relative to <ScriptDir> must be entered here.
      #
      # Example: Cleanup.sh, Move.sh.
      ScriptOrder=

      # Pause download queue during executing of postprocess-script (yes, no).
      #
      # Enable the option to give CPU more time for postprocess-script. That helps
      # to speed up postprocess on slow CPUs with fast connection (e.g. NAS-devices).
      #
      # NOTE: See also options <ParPauseQueue> and <UnpackPauseQueue>.
      ScriptPauseQueue=no

      # Shell overrides for script interpreters.
      #
      # By default extension scripts are executed as normal programs. The system finds
      # an associated interpreter automatically. If for some reason that doesn't work
      # properly you can provide shell overrides here.
      #
      # This option contains a comma separated list of shell overrides per
      # file extension. A shell override consists of file extension (starting with
      # dot) followed by equal sign and the full path to script interpreter.
      #
      # Example: .py=/usr/bin/python2;.py3=/usr/bin/python3;.sh=/usr/bin/bash.
      ShellOverride=

      # Minimum interval between queue events (seconds).
      #
      # Extension scripts can opt-in for progress notifcations during
      # download. For downloads containing many small files the events can
      # be fired way too often increasing load on the system due to script
      # execution.
      #
      # This option allows to reduce the number of calls of scripts by
      # skipping "file-downloaded"-events if the previous call for the same
      # download (nzb-file) were performed a short time ago (as defined by
      # the option).
      #
      # Value "-1" disables "file-downloaded"-events. Scripts are still
      # notified on other events (such as "nzb-added" or "nzb-downloaded").
      EventInterval=0

      Category2.DestDir=
      Category2.Unpack=yes
      Category2.Extensions=
      Category2.Aliases=
      Category3.DestDir=
      Category3.Unpack=yes
      Category3.Extensions=
      Category3.Aliases=
      Category4.DestDir=
      Category4.Unpack=yes
      Category4.Extensions=
      Category4.Aliases=
    '';
  };
}