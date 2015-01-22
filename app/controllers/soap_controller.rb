require 'repo_utils'

class SoapController < ApplicationController

  include RepoUtils

  ##################################################################################################
  # SOAP interface
  ##################################################################################################

  soap_service namespace: "TypeWright", wsse_auth_callback: ->(username, password) {
        # implement user check here for per-user auth
        return true
     }

  # Returns XML with source URIs for WebLayoutEditor
  #
  # This function is available via SOAP.
  #
  # @copyright PRImA June 2013
  # @param  string Uid Username
  # @param  string Aid Attachment ID
  # @return string     XML stream
  soap_action "getDocumentAttachmentSources",
              :args   =>  { :uid => :string, :aid => :string },
              :return => :string,
              to: :get_document_attachment_sources
  def get_document_attachment_sources


    # $Did = $DATA['Attachments'][$Aid]['Did'];
    # $ATid = "PAGE";
    # $urlFullViewJpeg = getFileURI($Uid, $Did, 'fullViewJPEG');
    # $urlAttachment = getFileURI($Uid, $Aid, 'attachment');
    #
    # $xml = new XMLWriter();
    # $xml->openMemory();
    # $xml->setIndent(true);
    # $xml->setIndentString("\t");
    # $xml->startDocument('1.0', 'utf-8');
    # $xml->startElement("DocumentRepository");
    # $xml->startElement("DocumentAttachmentSources");
    # $xml->startElement("ImageSource");
    # $xml->writeAttribute("documentId", $Did);
    # $xml->writeAttribute("type", "fullview");
    # $xml->text("$urlFullViewJpeg");
    # $xml->endElement();
    # $xml->startElement("AttachmentSource");
    # $xml->writeAttribute("attachmentId", $Aid);
    # $xml->writeAttribute("attachmentTypeId", $ATid);
    # $xml->text("$urlAttachment");
    # $xml->endElement();
    # $xml->endElement();
    # $xml->endElement();
    # $xml->endDocument();

    Rails.application..get_document

    render :soap => params[:uid].to_s
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
              :args   =>  { :uid => :string, :aid => :string },
              :return => :string,
              to: :get_document_attachment_permissions
  def get_document_attachment_permissions
    raise SOAPError, "not implemented"
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
              :args   =>  { :uid => :string, :aid => :string, :mode => :string, :attachment => :base64Binary },
              :return => :string,
              :to => :save_document_attachment
  def save_document_attachment
    raise SOAPError, "not implemented"
  end
end
