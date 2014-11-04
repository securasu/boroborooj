require 'sinatra/base'
require 'rdiscount'

class BoroBoroOJ < Sinatra::Base
  set :root, File.expand_path('.')
  set :ques_dir, "#{root}/question"
  set :questions, []
  enable :sessions

  Dir.open ques_dir do |dir|
    dir.each do |f|
      sub_path = "#{ques_dir}/#{f}"
      if !(File.file? sub_path) && !(sub_path.include? '.')
        str = File.open "#{sub_path}/ques_info.md", "r" do |fff|
          str = fff.readline.chomp
        end
        questions << [f, (str.split "#")[1]]

        get "/#{f}" do
          session[:page] = request.path_info
          md = markdown File.read "#{settings.ques_dir}/#{f}/ques_info.md"
          erb :ques_info, :locals => {:md => md}
        end

        get "/#{f}/submit" do
          redirect '/' unless session[:page]
          erb :submit
        end

        post "/#{f}/result" do
          redirect '/' unless session[:page]
          user = request.ip
          begin
            Dir.mkdir "#{settings.root}/tmp/#{user}"
          rescue
          end
          File.open "#{settings.root}/tmp/#{user}/tmp.c", "w" do |f|
            f.write params[:source]
          end
          rs = ''
          IO.popen "sh #{settings.root}/bin/prochecker.sh #{user} #{session[:page]} 1" do |pp|
            rs << pp.read
          end
          erb :result, :locals => {:rs => rs}
        end
      end
    end
  end

  get '/' do
    erb :index
  end
end
