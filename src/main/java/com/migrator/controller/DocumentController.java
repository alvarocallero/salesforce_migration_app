package com.migrator.controller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.migrator.log.LogHelper;
import com.migrator.model.Document;
import com.migrator.service.DocumentService;
import com.migrator.uploader.DocumentUploader;



@Controller
public class DocumentController {
	
	private static final String ACCESS_TOKEN = "ACCESS_TOKEN";

	// clientId is 'Consumer Key' in the Remote Access UI
	private static String clientId = "";
	// This must be identical to 'Callback URL' in the Remote Access UI
	private static String redirectUri = "https://localhost:8443/auth/salesforce/callback";
	private static String environment = "https://login.salesforce.com";
	private String authUrl = null;
	
	final static Logger logger = Logger.getLogger(DocumentController.class);

    @Autowired
    private DocumentService documentService;
    
    @Autowired
    private LogHelper logHelper;

    @RequestMapping("/")
    public String listDocuments(Map<String, Object> map) {

        map.put("documents", new Document());
        return "Document";
    }
    
    @RequestMapping(value = "/transformDocuments", method = RequestMethod.POST)
    public String transformDocuments(HttpServletRequest request) {
    	logger.info("----------  Starting the migration of documents -------------------------");
    	
//    	Create documents un bulk mode of 200
//    	DocumentUploader.bulkDocumentUploading();
    	
    	documentService.transformDocuments(request.getParameter("orgUserName"),request.getParameter("orgPassword"),request.getParameter("orgSecurityToken"));
    	logger.info("----------  Documents Migration ended -----------------------------------");
        return "redirect:/documents/";
    }
    
    @RequestMapping(value = "/auth/salesforce")
	public String authenticate(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		String accessToken = (String) request.getSession().getAttribute(
				ACCESS_TOKEN);
		
		logger.info("accessToken: "+accessToken);
		if(accessToken == null) {
		
			try {
				authUrl = environment
						+ "/services/oauth2/authorize?response_type=code&client_id="
						+ clientId + "&redirect_uri="
						+ URLEncoder.encode(redirectUri, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new ServletException(e);
			}
	
			return "redirect:" + authUrl;
		} else {
			return "redirect:/auth/salesforce/callback";
		}
	}
    
    @RequestMapping(value = "/showLogs", method = RequestMethod.POST)
    public String showLogs(ModelMap model) {
    	logger.info("----------  Starting Show logs ---------------------------------");
    	model.addAttribute("logLst", logHelper.showLogs());
    	logger.info("----------  Ending Show logs -----------------------------------");
        return "Logs";
    }
}
