# lib/repo_utils.rb

# functions shared between repo controller and soap controller

module RepoUtils

  def get_document_id_for_attachment(aid)
    return aid.split('.', 2).first
  end

  def find_document(id)
    path = nil
    files = Dir.glob("#{Rails.root.to_s}/repository/fullview/*")
    files.each do |file|
      temp_id = File.basename(file, File.extname(file))
      if temp_id == id
        path = file
        break
      end
    end
    return path
  end

end
