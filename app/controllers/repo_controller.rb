# Copyright 2015 Texas A & M University
#
# This is a port to Rails of the PHP Example Repository for use with the AWL
# Editor
#
# Original License and PHP comments follow:
#
#
# * Copyright 2014 PRImA Research Lab, University of Salford, United Kingdom
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# *  http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# *
# * This file is a sample index page, for the EMOP project.
# * The purpose of this mock website is to provide access to the WebLayoutEditor.
# *
# * Important information
# * - Each document has an ID. This is referred to as Did.
# * - For each document, there can be any number of PAGE files. Each PAGE file
# *   has it's own ID, referred to as Aid.
# * - This index page, for every document contains links to specific attachments
# *   (different versions of PAGE files perhaps).
# * - This is implemented in such a way, so that it is possible to keep track of
# *   changes/updates to the PAGE file, by storing each different version as a
# *   new attachment (that has a different Aid, but is linked to the same Did.
# * - The link to the gateway web page, includes the Aid, so that it can display
# *   the correct version of the PAGE file. If the Did for the particular
# *   document is required, you should ensure that your supporting database can
# *   provide that.
# *
# * Under production circumstances, a lot of the data required for this page
# * would be retrieved from a database. In order to simplify this example, all
# * required data is stored in config.inc.php in various arrays.

require 'openssl'
require 'base64'

class RepoController < ApplicationController
  def index
    repo_files = "#{Rails.root.to_s}/repository"
    @documents = {}
    @attachments = {};
    files = Dir.glob("#{repo_files}/fullview/*")
    files.each do |file|
      id = File.basename(file, File.extname(file))
      @documents[id] = file
    end
    files = Dir.glob("#{repo_files}/attachments/*")
    files.each do |file|
      id = File.basename(file, File.extname(file))
      @attachments[id] = file
    end
  end

  # This method takes as parameter the Aid and generates the access URL for the
  # WebLayoutEditor, which is being displayed inline.
  def gateway
    aid = CGI::unescape(params[:id])
    did = get_document_id_for_attachment(aid)
    # save our client ip
    ip_addr = request.remote_ip
    if ip_addr == '::1' || ip_addr == '0:0:0:0:0:0:0:1' || ip_addr == '0.0.0.0' || ip_addr == '127.0.0.1'
        ip_addr = 'localhost'
    end
    @ip = ip_addr

    # create the authentication token
    secret_key = SECRETS['awl_shared_secret']
    user_name = "user1"  # hardcoded, change to use actual username
    auth_token = create_auth_token(ip_addr, user_name, secret_key)

    # figure out the target url
    url_base = CONFIG['external_links_base_url']
    use_local = params[:uselocal].to_i
    url_base = CONFIG['local_links_base_url'] if use_local == 1
    use_debug  = params['usedebug'].to_i
    url_base = CONFIG['debug_links_base_url'] if use_debug == 1
    @use_debug = use_debug
    @target_url = "#{url_base}Did=#{did}&Aid=#{aid}&Appid=#{CONFIG['app_id']}&a=#{auth_token}"
  end

  def get_document_id_for_attachment(aid)
    return aid.split('.', 2).first
  end

  def create_auth_token(ip, user_name, secret_key)
    time_now = Time.now.to_i

    @token = "{\"ip\":\"#{ip}\",\"ts\":\"#{time_now}\",\"uid\":\"#{user_name}\"}"

    # now encrypt the token in a way the WebLayoutEditor servlet can read
    # Encrypt with 256 bit AES with CBC
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cfb8')
    cipher.encrypt # We are encypting
    # The OpenSSL library will generate random keys and IVs
    real_key = Digest::MD5.hexdigest(secret_key)
    cipher.padding = 0
    cipher.key = real_key
    iv = cipher.iv = cipher.random_iv

    encrypted_data = cipher.update(@token) # Encrypt the data.
    encrypted_data << cipher.final
    encrypted_data = "#{iv}#{encrypted_data}"

    @iv = iv
    @sk = real_key.unpack('H*').join
    @step1 = encrypted_data.unpack('H*').join

    encrypted_data = Base64.encode64(encrypted_data)

    @step2 = encrypted_data

    encrypted_data = CGI::escape(encrypted_data)
    return encrypted_data
  end
end
