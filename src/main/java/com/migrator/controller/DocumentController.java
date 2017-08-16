package com.migrator.controller;

import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.migrator.log.LogHelper;
import com.migrator.model.Document;
import com.migrator.service.DocumentService;
import com.migrator.uploader.DocumentUploader;

@Controller
public class DocumentController {
	
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
    public String transformDocuments() {
    	logger.info("----------  Starting the migration of documents ---------------------------------");
//    	DocumentUploader.bulkDocumentUploading();
    	documentService.transformDocuments();
    	logger.info("----------  Ending the migration of documents -----------------------------------");
        return "redirect:/documents/";
    }
    
    @RequestMapping(value = "/showLogs", method = RequestMethod.POST)
    public String showLogs( Model model) {
    	logger.info("----------  Starting Show logs ---------------------------------");
    	model.addAttribute("logLst", logHelper.showLogs());
    	logger.info("----------  Ending Show logs -----------------------------------");
        return "Logs";
    }
}
