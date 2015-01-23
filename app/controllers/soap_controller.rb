require 'repo_utils'

class SoapController < ApplicationController

  include RepoUtils

  ##################################################################################################
  # SOAP interface
  ##################################################################################################

  soap_service namespace: "TypeWright" #, wsse_auth_callback: ->(username, password) {
        # implement user check here for per-user auth
#        return true
#     }

  # Returns XML with source URIs for WebLayoutEditor
  #
  # This function is available via SOAP.
  #
  # @copyright PRImA June 2013
  # @param  string Uid Username
  # @param  string Aid Attachment ID
  # @return string     XML stream
  soap_action "getDocumentAttachmentSources",
              :args   =>  { :Uid => :string, :Aid => :string },
              :return => :string,
              to: :get_document_attachment_sources
  def get_document_attachment_sources


    # $Did = $DATA['Attachments'][$Aid]['Did'];
    # $ATid = "PAGE";
    # $urlFullViewJpeg = getFileURI($Uid, $Did, 'fullViewJPEG');
    # $urlAttachment = getFileURI($Uid, $Aid, 'attachment');

    aid = params[:Aid]
    did = get_document_id_for_attachment(aid)
    attach_type = "PAGE"
    attach_url = url_for :controller => :repo, :action => :attachment, :id => aid
    doc_type = "fullview"
    doc_url = url_for :controller => :repo, :action => :fullview, :id => did

    result =
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <DocumentRepository>
    <DocumentAttachmentSources>
      <ImageSource documentId=\"#{did}\" type=\"#{doc_type}\">#{doc_url}</ImageSource>
      <AttachmentSource attachmentId=\"#{aid}\" type=\"#{attach_type}\">#{attach_url}</ImageSource>
    </DocumentAttachmentSources>
  </DocumentRepository>
"

    render :soap => result
  end


  # Returns XML permissions for a specific document
  #
  # This function is available via SOAP.
  #                                    *
  # @copyright PRImA June 2013
  # @param  string Uid Username
  # @param  string Aid Attachment ID
  # @return string     XML stream
  soap_action "getDocumentAttachmentPermissions",
              :args   =>  { :Uid => :string, :Aid => :string },
              :return => :string,
              to: :get_document_attachment_permissions
  def get_document_attachment_permissions
    aid = params[:Aid]
    result = "
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<DocumentRepository>
	<DocumentAttachmentPermissions attachmentId=\"#{aid}\">
		<Permission name=\"a\"/>
	</DocumentAttachmentPermissions>
</DocumentRepository>
    "
    render :soap => result
  end

  # Returns XML with source URIs for WebLayoutEditor
  #
  # This function is available via SOAP.
  #
  # If mode=new, return a DocumentAttachmentSources - AttachmentSource with the
  # location for the new attachment.
  #
  # @copyright PRImA June 2013
  # @param  string     Uid  Username
  # @param  string     Aid  Attachment ID
  # @param  string     mode enum(new, overwrite)
  # @param  attachment base64 encoded content of new attachment
  # @return string     XML stream
  soap_action "saveDocumentAttachment",
              :args   =>  { :Uid => :string, :Aid => :string, :mode => :string, :attachment => :base64Binary },
              :return => :string,
              :to => :save_document_attachment
  def save_document_attachment
    raise SOAPError, "not implemented"
  end
end
