package com.migrator.status;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Properties;

import org.apache.log4j.Logger;

public class MigrationStatusService {
	
	public static final String FILENAME = System.getProperty("user.dir")+"\\src\\main\\resources\\migrationStatus.properties";
	
	final static Logger logger = Logger.getLogger(MigrationStatusService.class);


	public static void updatePropertiesStatus(String orgId, int currentPage, int cantDocs){
		Properties prop = new Properties();
		OutputStream output = null;
		try {
			output = new FileOutputStream(FILENAME);
			prop.setProperty("orgId", orgId);
			prop.setProperty("currentPage", String.valueOf(currentPage));
			prop.setProperty("cantDocs", String.valueOf(cantDocs));
			prop.setProperty("lastDocumentId", "");
			prop.store(output, null);
		} catch (IOException io) {
			logger.error("Error at updateStatusProperties: "+io);
		} finally {
			if (output != null) {
				try {
					output.close();
				} catch (IOException e) {
					logger.error("Error at updateStatusProperties: "+e);
				}
			}
		}
	}
	
	public static void updateCurrentPage(int currentPage){
		Properties prop = new Properties();
		OutputStream output = null;
		try {
			InputStream in = new FileInputStream(FILENAME);
			prop.load(in);
			in.close();
		} catch (IOException e1) {
			logger.error("Error loading migrationStatus.properties");
		}
		
		try {
			output = new FileOutputStream(FILENAME);
			String orgId = (prop.getProperty("orgId") != null && !prop.getProperty("orgId").equals(""))?prop.getProperty("orgId"):"";
			String cantDocs = (prop.getProperty("cantDocs") != null && !prop.getProperty("cantDocs").equals(""))?prop.getProperty("cantDocs"):"";
			String lastDocumentId = (prop.getProperty("lastDocumentId") != null && !prop.getProperty("lastDocumentId").equals(""))?prop.getProperty("lastDocumentId"):"";
			prop.setProperty("orgId",orgId);
			prop.setProperty("currentPage",String.valueOf(currentPage));
			prop.setProperty("cantDocs",cantDocs);
			prop.setProperty("lastDocumentId", lastDocumentId);
			prop.store(output, null);
		} catch (IOException io) {
			logger.error("Error at updateCurrentPage: "+io);
		} finally {
			if (output != null) {
				try {
					output.close();
				} catch (IOException e) {
					logger.error("Error at updateCurrentPage: "+e);
				}
			}
		}
	}
	
	public static void updateDocumentLastId(String lastDocumentId){
		Properties prop = new Properties();
		OutputStream output = null;
		try {
			InputStream in = new FileInputStream(FILENAME);
			prop.load(in);
			in.close();
		} catch (IOException e1) {
			logger.error("Error loading migrationStatus.properties");
		}
		
		try {
			output = new FileOutputStream(FILENAME);
			String orgId = (prop.getProperty("orgId") != null && !prop.getProperty("orgId").equals(""))?prop.getProperty("orgId"):"";
			String cantDocs = (prop.getProperty("cantDocs") != null && !prop.getProperty("cantDocs").equals(""))?prop.getProperty("cantDocs"):"";
			String currentPage = (prop.getProperty("currentPage") != null && !prop.getProperty("currentPage").equals(""))?prop.getProperty("currentPage"):"";
			prop.setProperty("orgId",orgId);
			prop.setProperty("currentPage",String.valueOf(currentPage));
			prop.setProperty("cantDocs",cantDocs);
			prop.setProperty("lastDocumentId", lastDocumentId);
			prop.store(output, null);
		} catch (IOException io) {
			logger.error("Error at updateDocumentLastId: "+io);
		} finally {
			if (output != null) {
				try {
					output.close();
				} catch (IOException e) {
					logger.error("Error at updateDocumentLastId: "+e);
				}
			}
		}
	}
	
	public static void cleanProperties(){
		Properties prop = new Properties();
		OutputStream output = null;
		try {
			output = new FileOutputStream(FILENAME);
			prop.setProperty("orgId", "");
			prop.setProperty("currentPage", "");
			prop.setProperty("cantDocs", "");
			prop.setProperty("lastDocumentId", "");
			prop.store(output, null);
		} catch (IOException io) {
			logger.error("Error at cleanProperties: "+io);
		} finally {
			if (output != null) {
				try {
					output.close();
				} catch (IOException e) {
					logger.error("Error at cleanProperties: "+e);
				}
			}
		}
	}
}
