require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'octokit'

get '/' do
  @repositories = []
  page = 1
  loop do
    more_repos = Octokit.repositories("heroku", :per_page => 100, :page => page)
    @repositories.concat more_repos
    # In case we receive less than a 100 repos, this means we are on the last page
    page += 1
    break if more_repos.size < 100
  end
  
  @buildpacks = @repositories.select { |r| r.name.include?("heroku-buildpack-")}  
  @popularity_ranking = @buildpacks.each_with_object({}) { |repository, ranking| ranking[popularity_score(repository)] = repository }
  
  haml :index, :format => :html5
end

def popularity_score(repo)
  (repo.watchers_count + repo.forks) / 2
end