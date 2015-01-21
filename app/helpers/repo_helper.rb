module RepoHelper

  def make_id(filename)
    escaped = CGI::escape(filename)
    escaped.gsub!('.', '%2E')
    return escaped
  end

end
