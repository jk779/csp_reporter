require 'sinatra'
require 'json'
require 'sqlite3'
require 'erb'

DB_NAME = 'db/csp_reports.db'
DB = SQLite3::Database.new(DB_NAME)

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS CSP_Reports (
    id INTEGER PRIMARY KEY,
    report_json TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
SQL

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    username = ENV['REPORTS_USERNAME'] || 'admin'
    password = ENV['REPORTS_PASSWORD'] || halt(500, "REPORTS_PASSWORD not set")
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end
end

post '/report' do
  begin
    report = JSON.parse(request.body.read)
    DB.execute("INSERT INTO CSP_Reports (report_json) VALUES (?)", [report.to_json])
    status 200
    { status: 'ok' }.to_json
  rescue => e
    status 500
    "An error occurred: #{e.message}"
  end
end

get '/reports' do
  protected!

  @reports = DB.execute("SELECT * FROM CSP_Reports ORDER BY created_at DESC LIMIT 1000")
  erb :reports
end
