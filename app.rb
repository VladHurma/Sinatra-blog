#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
	@db = SQLite3::Database.new 'db/blog_content.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'create table if not exists Posts
	(
		id integer primary key autoincrement,
		created_date date,
		content text
	)'
	@db.execute 'create table if not exists Comments
	(
		id integer primary key autoincrement,
		created_date date,
		content text,
		post_id integer
	)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
end

get '/new' do
 erb :new
end

post '/new' do
	content = params[:content]
	if content.length <= 0
		@error = 'Empty field'
		return erb :new
	end
	@db.execute 'insert into Posts (created_date, content) values (datetime(),?)', [content]
	redirect to '/'
end

get '/post/:id' do
	post_id = params[:id]
	results = @db.execute "select * from Posts where id = ?", [post_id]
	@row = results[0]
	@comments = @db.execute "select * from Comments where post_id = ?", [post_id]
	erb :details
end

post '/post/:id' do
	post_id = params[:id]
	content = params[:content]
	if content.length <= 0
		@error = 'Empty field'
		return erb :new
	end
	@db.execute 'insert into Comments
	(created_date, post_id, content)
	values (datetime(), ?, ?)', [post_id, content]
	redirect to "/post/#{post_id}"
end