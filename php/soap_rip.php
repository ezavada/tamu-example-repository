<?php
/*
 * Copyright 2014 PRImA Research Lab, University of Salford, United Kingdom
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/*
 * The followig parameters are for the configuration of this converter script.
 */
 
$RAILS_BASE_URL = "http://localhost:3000/repo";

/*
 * Makes a document or attachment id safe for sending to rails by urlencoding it then 
 * also converting dots to %2E
 */
function urlSafeId($id)
{
	$result = urlencode($id);
	$result = str_replace($result, '.', '%2E');
	return $result;
}

/*
 * Returns XML with source URIs for WebLayoutEditor
 *
 * This function is available via SOAP.
 *
 * @copyright PRImA June 2013
 * @param  string Uid Username
 * @param  string Aid Attachment ID
 * @return string     XML stream
 */
function getDocumentAttachmentSources($Uid, $Aid) {
    global $RAILS_BASE_URL;
    
    $service_url = $RAILS_BASE_URL.'/attachment/'.urlSafeId($Uid).'/'.urlSafeId($Aid);
    $curl = curl_init($service_url);

    error_log ( 'getDocumentAttachmentSources for '.$Uid.' :: '.$Aid );

    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    $curl_response = curl_exec($curl);
    curl_close($curl);
 
    error_log ( 'getDocumentAttachmentSources response '.$curl_response );

    $result = json_decode($curl_response);
    
    error_log ( 'getDocumentAttachmentSources JSON: '. print_r($result, TRUE) );

    
    $Did = $result['did'];
    $Aid = $result['aid'];
    $ATid = $result['attype'];
    $urlFullViewJpeg = $result['viewurl'];
    $urlAttachment = $result['aturl'];
       
       
    error_log ( 'getDocumentAttachmentSources urlAttachment: '. print_r($urlAttachment, TRUE) );

	$xml = new XMLWriter();
	$xml->openMemory();
	$xml->setIndent(true);
	$xml->setIndentString("\t");
	$xml->startDocument('1.0', 'utf-8');
	$xml->startElement("DocumentRepository");
	$xml->startElement("DocumentAttachmentSources");
	$xml->startElement("ImageSource");
	$xml->writeAttribute("documentId", $Did);
	$xml->writeAttribute("type", "fullview");
	$xml->text("$urlFullViewJpeg");
	$xml->endElement();
	$xml->startElement("AttachmentSource");
	$xml->writeAttribute("attachmentId", $Aid);
	$xml->writeAttribute("attachmentTypeId", $ATid);
	$xml->text("$urlAttachment");
	$xml->endElement();
	$xml->endElement();
	$xml->endElement();
	$xml->endDocument();

    $xmlOut = $xml->outputMemory(TRUE);
    error_log ( 'getDocumentAttachmentSources XML response: '. print_r($xmlOut, TRUE) );
    
	return $xmlOut;
}

/*
 * Returns XML perimissions for a specific document
 *
 * This function is available via SOAP.
 *
 * @copyright PRImA June 2013
 * @param  string Uid Username
 * @param  string Aid Attachment ID
 * @return string     XML stream
 */
function getDocumentAttachmentPermissions($Uid, $Aid) {
    global $RAILS_BASE_URL;

    $service_url = $RAILS_BASE_URL.'/attachment/'.urlSafeId($Uid).'/'.urlSafeId($Aid);
    $curl = curl_init($service_url);
    
    error_log ( 'getDocumentAttachmentPermissions for '.$Uid.' :: '.$Aid );

    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    $curl_response = curl_exec($curl);
    curl_close($curl);
 
    error_log ( 'getDocumentAttachmentPermissions response '.$curl_response );

    $result = json_decode($curl_response);

    error_log ( 'getDocumentAttachmentPermissions JSON: '. print_r($result, TRUE) );

    $Did = $result['did'];
    $Aid = $result['aid'];
    $permission = $result['permissions'];

	$xml = new XMLWriter();
	$xml->openMemory();
	$xml->setIndent(true);
	$xml->setIndentString("\t");
	$xml->startDocument('1.0', 'utf-8');
	$xml->startElement("DocumentRepository");
	$xml->startElement("DocumentAttachmentPermissions");
	$xml->writeAttribute("attachmentId", $Aid);
	$xml->startElement("Permission");
	$xml->writeAttribute("name", $permission);
	$xml->endElement();
	$xml->endElement();
	$xml->endElement();
	$xml->endDocument();

	return $xml->outputMemory(TRUE);
}

/*
 * Returns XML with source URIs for WebLayoutEditor
 *
 * This function is available via SOAP.
 *
 * If mode=new, return a DocumentAttachmentSources - AttachmentSource with the
 * location for the new attachment.
 *
 * @copyright PRImA June 2013
 * @param  string     Uid  Username
 * @param  string     Aid  Attachment ID
 * @param  string     mode enum(new, overwrite)
 * @param  attachment base64 encoded content of new attachment
 * @return string     XML stream
 */
function saveDocumentAttachment($Uid, $Aid, $mode, $attachment) {
    global $RAILS_BASE_URL;

    $service_url = $RAILS_BASE_URL.'/attachment/'.urlSafeId($Uid).'/'.urlSafeId($Aid);
    $curl = curl_init($service_url);
       $curl_post_data = array(
            "user_id" => 42,
            "emailaddress" => 'lorna@example.com',
            );
       curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
       curl_setopt($curl, CURLOPT_POST, true);
       curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
       $curl_response = curl_exec($curl);
       curl_close($curl);
 
       $xml = new SimpleXMLElement($curl_response);	


	$Did = $DATA['Attachments'][$Aid]['Did'];
	$ATid = "PAGE";
	$returnCode = 0;
	$returnMessage = "";

	switch ($mode) {
		case "new":
			$AidNEW = $Aid . "." . date("Y-m-d-H-i-s", time());
			$urlAttachmentNEW = "repository/attachments/" . $AidNEW . ".xml";
			$pathNEW = __DIR__ . "/../" . $urlAttachmentNEW;
			$content = $attachment;

			break;
		case "overwrite":
			$pathNEW = __DIR__ . "/../" . $DATA['Attachments'][$Aid]['path'];
			break;
	}
	$file_put_contents_Result = file_put_contents($pathNEW, $content);
	if ($file_put_contents_Result === FALSE) {
		//failed
		$returnCode = "1";
		$returnMessage = "Error when creating file (Got back error from file_put_contents: $file_put_contents_Result)";
	}

	$xml = new XMLWriter();
	$xml->openMemory();
	$xml->setIndent(true);
	$xml->setIndentString("\t");
	$xml->startDocument('1.0', 'utf-8');
	$xml->startElement("DocumentRepository");
	$xml->startElement("SaveDocumentAttachmentResult");
	$xml->writeAttribute("attachmentId", $Aid);
	if ($mode == "new")
		$xml->writeAttribute("newAttachmentId", $AidNEW);
	$xml->writeAttribute("returnCode", $returnCode);
	$xml->startElement("ReturnMessage");
	$xml->text("$returnMessage");
	$xml->endElement();
	$xml->endElement();
	if ($mode == "new") {
		$xml->startElement("DocumentAttachmentSources");
		$xml->startElement("AttachmentSource");
		$xml->writeAttribute("attachmentId", $AidNEW);
		$xml->writeAttribute("attachmentTypeId", $ATid);
		$xml->text("$urlAttachmentNEW");
		$xml->endElement();
		$xml->endElement();
	}
	$xml->endElement();
	$xml->endDocument();

	return $xml->outputMemory(TRUE);
}

$server = new SoapServer(null, array('soap_version' => SOAP_1_2, 'uri' => "www.primaresearch.org", 'actor' => "www.primaresearch.org"));
$server->addFunction('getDocumentAttachmentSources');
$server->addFunction('getDocumentAttachmentPermissions');
$server->addFunction('saveDocumentAttachment');
$server->handle();
?>