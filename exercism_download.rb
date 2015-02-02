#!/path/to/ruby

require 'rubygems'
require 'mechanize'
require 'fileutils'

def base_path
  base_path = "/Users/justin.leveck/code/exercism/solutions"
  track_id  =  @submission['track_id']
  username  =  @submission['username']
  slug      =  @submission['slug']
  id        =  ARGV[0]
  file_path = "#{base_path}/#{username}/#{track_id}/#{slug}/#{id}"
end

def create_problem_files
  @submission['problem_files'].each do |problem_file|
    file_name     = problem_file[0]
    @test_file = file_name if file_name.match /_test.rb/
    file_contents = problem_file[1]
    file_contents = file_contents.gsub(/\s{4}skip\n/,'') if @test_file
    file_path     = "#{base_path}/#{file_name}"
    create_path(base_path)
    create_file(file_path, file_contents)
  end
end

def create_solution_files
  @submission['solution_files'].each do |solution_file|
    file_name     = File.basename(solution_file[0])
    file_contents = solution_file[1]
    file_path     = "#{base_path}/#{file_name}"
    create_path(base_path)
    create_file(file_path, file_contents)
  end
end

def create_path(path)
  unless File.directory?(path)
    FileUtils.mkdir_p(path)
  end
end

def create_file(file_path, contents)
  File.open(file_path, 'w') do |f|
    f.write(contents)
  end
end

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

a.get("http://exercism.io/api/v1/submissions/#{ARGV[0]}") do |page|
  @submission = JSON.parse(page.body)
  create_problem_files
  create_solution_files
  `tmux new-window -c #{base_path}`
end
