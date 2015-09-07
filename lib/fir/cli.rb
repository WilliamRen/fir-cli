# encoding: utf-8

module FIR
  class CLI < Thor
    class_option :token,   type: :string,  aliases: "-T", desc: "User's API Token at fir.im"
    class_option :logfile, type: :string,  aliases: "-L", desc: "Path to writable logfile"
    class_option :verbose, type: :boolean, aliases: "-V", desc: "Show verbose", default: true
    class_option :quiet,   type: :boolean, aliases: "-q", desc: "Silence commands"
    class_option :help,    type: :boolean, aliases: "-h", desc: "Show this help message and quit"

    desc "build_ipa BUILD_DIR [options] [settings]", "Build iOS app (alias: 'bi')."
    long_desc <<-LONGDESC
      `build_ipa` command will auto build your project/workspace to an ipa package
      and it also can auto publish your built ipa to fir.im if use `-p` option.
      Internally, it use `xcodebuild` to accomplish these things, use `man xcodebuild` to get more information.

      Example:

      $ fir bi <project dir> [-C <configuration>] [-t <target name>] [-o <ipa output dir>] [settings] [-c <changelog>] [-p -T <your api token>]

      $ fir bi <project dir> [-c <changelog> -P <bughd project id> -M -p -T <your api token>]

      $ fir bi <workspace dir> -w -S <scheme name> [-C <configuration>] [-t <target name>] [-o <ipa output dir>] [settings] [-c <changelog>] [-p -T <your api token>]
    LONGDESC
    map ["b", "bi"] => :build_ipa
    method_option :workspace,     type: :boolean, aliases: "-w", desc: "true/false if build workspace"
    method_option :scheme,        type: :string,  aliases: "-S", desc: "Set the scheme NAME if build workspace"
    method_option :configuration, type: :string,  aliases: "-C", desc: "Use the build configuration NAME for building each target"
    method_option :target,        type: :string,  aliases: "-t", desc: "Build the target specified by targetname"
    method_option :output,        type: :string,  aliases: "-o", desc: "IPA output path, the default is: BUILD_DIR/fir_build_ipa"
    method_option :name,          type: :string,  aliases: "-n", desc: "IPA name, the default is: YOUR PROJECT NAME"
    method_option :publish,       type: :boolean, aliases: "-p", desc: "true/false if publish to fir.im"
    method_option :short,         type: :string,  aliases: "-s", desc: "Set custom short link if publish to fir.im"
    method_option :changelog,     type: :string,  aliases: "-c", desc: "Set changelog if publish to fir.im"
    method_option :mapping,       type: :boolean, aliases: "-M", desc: "true/false if upload app's mapping file to BugHD.com"
    method_option :proj,          type: :string,  aliases: "-P", desc: "Project id in BugHD.com if upload app's mapping file"
    def build_ipa(*args)
      prepare :build_ipa

      FIR.build_ipa(*args, options)
    end

    desc "build_apk BUILD_DIR", "Build Android app (alias: 'ba')."
    long_desc <<-LONGDESC
      `build_apk` command will auto build your project to an apk package
      and it also can auto publish your built apk to fir.im if use `-p` option.
      Internally, it use `gradle` to accomplish these things, use `gradle --help` to get more information.

      Example:

      $ fir ba <project dir> [-o <apk output dir> -c <changelog> -p -T <your api token>]
    LONGDESC
    map ["ba"] => :build_apk
    method_option :output,    type: :string,  aliases: "-o", desc: "APK output path, the default is: BUILD_DIR/build/outputs/apk"
    method_option :publish,   type: :boolean, aliases: "-p", desc: "true/false if publish to fir.im"
    method_option :short,     type: :string,  aliases: "-s", desc: "Set custom short link if publish to fir.im"
    method_option :changelog, type: :string,  aliases: "-c", desc: "Set changelog if publish to fir.im"
    def build_apk(*args)
      prepare :build_apk

      FIR.build_apk(*args, options)
    end

    desc "info APP_FILE_PATH", "Show iOS/Android app's info, support ipa/apk file (aliases: 'i')."
    map "i" => :info
    method_option :all, type: :boolean, aliases: "-a", desc: "Show all information in application"
    def info(*args)
      prepare :info

      FIR.info(*args, options)
    end

    desc "publish APP_FILE_PATH", "Publish iOS/Android app to fir.im, support ipa/apk file (aliases: 'p')."
    long_desc <<-LONGDESC
      `publish` command will publish your app file to fir.im, also the command support to publish app's short & changelog.

      Example:

      $ fir p <app file path> [-c <changelog> -s <custom short link> -T <your api token>]

      $ fir p <app file path> [-c <changelog> -s <custom short link> -m <mapping file path> -P <bughd project id> -T <your api token>]
    LONGDESC
    map "p" => :publish
    method_option :short,       type: :string, aliases: "-s", desc: "Set custom short link"
    method_option :changelog,   type: :string, aliases: "-c", desc: "Set changelog"
    method_option :mappingfile, type: :string, aliases: "-m", desc: "App's mapping file"
    method_option :proj,        type: :string, aliases: "-P", desc: "Project id in BugHD.com if upload app's mapping file"
    def publish(*args)
      prepare :publish

      FIR.publish(*args, options)
    end

    desc "login", "Login fir.im (aliases: 'l')."
    map "l" => :login
    def login(*args)
      prepare :login

      token = options[:token] || args.first || ask("Please enter your fir.im API Token:", :white, echo: true)
      FIR.login(token)
    end

    desc "me", "Show current user info if user is logined."
    def me(*args)
      prepare :me

      FIR.me
    end

    desc "mapping MAPPING_FILE_PATH", "Upload app's mapping file to BugHD.com (aliases: 'm')."
    long_desc <<-LONGDESC
      `mapping` command will upload your app's mapping file to BugHD.com if you have the same app/project in BugHD.com.

      Example:

      $ fir m <mapping file path> -P <bughd project id> -v <app version> -b <app build> -T <your fir api token>
    LONGDESC
    map "m" => :mapping
    method_option :proj,    type: :string, aliases: "-P", desc: "Project id in BugHD.com"
    method_option :version, type: :string, aliases: "-v", desc: "App version"
    method_option :build,   type: :string, aliases: "-b", desc: "App build"
    def mapping(*args)
      prepare :mapping

      FIR.mapping(*args, options)
    end

    desc "upgrade", "Upgrade fir-cli and quit (aliases: u)."
    map "u" => :upgrade
    def upgrade
      prepare :upgrade

      say "✈ Upgrade fir-cli (use `gem install fir-cli --no-ri --no-rdoc`)"
      say `gem install fir-cli --no-ri --no-rdoc`
    end

    desc "version", "Show fir-cli version number and quit (aliases: v)"
    map ["v", "-v", "--version"] => :version
    def version
      say "✈ fir-cli #{FIR::VERSION}"
    end

    desc "help", "Describe available commands or one specific command."
    map Thor::HELP_MAPPINGS => :help
    def help(command = nil, subcommand = false)
      super
    end

    no_commands do
      def invoke_command(command, *args)
        logfile = options[:logfile].blank? ? STDOUT : options[:logfile]
        logfile = '/dev/null' if options[:quiet]

        FIR.logger       = Logger.new(logfile)
        FIR.logger.level = options[:verbose] ? Logger::INFO : Logger::ERROR
        super
      end
    end

    private

      def prepare(task)
        if options.help?
          help(task.to_s)
          raise SystemExit
        end
        $DEBUG = true if ENV["DEBUG"]
      end

  end
end
