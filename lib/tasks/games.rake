# games/TestGame.pitpex/install_games.rake
require 'fileutils'
require 'active_support/core_ext/string/inflections'
desc 'Install all Pitpex games in the games folder'

namespace :games do

  task :install do
    Dir.chdir "games"
    games = Dir["*.pitpex"]
    games.each do |g|
      next if File.exists? "#{g}/installed"
      puts "Installing #{g}"
      name = g.chomp(".pitpex")
      gamedata = "../../public/gamedata/#{name.underscore}"
      viewpath = "../../app/views/games/#{name.underscore}"
      indexpath = "/gamedata/#{name.underscore}"
      controllerpath = "../../app/controllers/games/#{name.underscore}_controller.rb"
      Dir.chdir g
      if Dir.exists? gamedata
        FileUtils.rm_rf(gamedata)
        puts "  removing old gamedata"
      end
      if Dir.exists? viewpath
        FileUtils.rm_rf(viewpath)
        puts "  removing old views"
      end
      Dir.mkdir gamedata
      Dir.mkdir viewpath
      FileUtils.cp_r("Release/.", gamedata)
      FileUtils.cp_r("TemplateData/.", gamedata)
      puts "  installing gamedata"
      if File.exists? controllerpath
        FileUtils.rm(controllerpath)
        puts "  removing old controller"
      end
      puts "  generating controller"
      File.open(controllerpath, "w") do |f|
        f.write("class Games::#{name.camelize}Controller < Games::GamesController")
        f.write("\nend")
      end
      puts "  populating template"
      File.open("index.template", "r") do |template|
        File.open("index.html.erb", "w") do |f|
          while (!(line = template.gets).nil?)
            line.gsub!("##PP##", indexpath)
            line.gsub!("##PN##", name.underscore.titleize)
            f.puts(line)
          end
        end
      end

      FileUtils.cp("index.html.erb", viewpath)
      routespath = "../../config/routes.rb"
      FileUtils.cp(routespath, "#{routespath}.old")
      File.open(routespath + ".old", "r") do |routes|
        File.open(routespath, "w") do |f|
          while(!(line = routes.gets).nil?)
            if line.include? "    get \"/#{name.underscore}\" => \"#{name.underscore}#index\""
              puts "  removing old route"
            else
              f.puts line
            end
            if line.include? "namespace :games do"
              f.puts "    get \"/#{name.underscore}\" => \"#{name.underscore}#index\""
              puts "  adding new route"
            end
          end
        end
      end
      puts "  installation complete!"
      FileUtils.touch("installed")
      Dir.chdir("..")
    end
  end
end

=begin
def camelize(term, uppercase_first_letter = true)
  string = term.to_s
  if uppercase_first_letter
    string = string.sub(/^[a-z\d]*/) { inflections.acronyms[$&] || $&.capitalize }
  else
    string = string.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
  end
  string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{inflections.acronyms[$2] || $2.capitalize}" }.gsub('/', '::')
end

def underscore(camel_cased_word)
  word = camel_cased_word.to_s.dup
  word.gsub!('::', '/')
  word.gsub!(/(?:([A-Za-z\d])|^)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
  word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
  word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
  word.tr!("-", "_")
  word.downcase!
  word
end

def humanize(lower_case_and_underscored_word)
  result = lower_case_and_underscored_word.to_s.dup
  inflections.humans.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
  result.gsub!(/_id$/, "")
  result.tr!('_', ' ')
  result.gsub(/([a-z\d]*)/i) { |match|
    "#{inflections.acronyms[match] || match.downcase}"
  }.gsub(/^\w/) { $&.upcase }
end
=end
