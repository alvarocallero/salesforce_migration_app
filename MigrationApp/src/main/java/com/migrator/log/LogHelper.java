package com.migrator.log;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class LogHelper {
	
	public List<String> showLogs(){
		System.out.println("Hello logs");
		List<String> logLst = new ArrayList<String>();
		logLst.add("Hola");
		logLst.add("loco");
		logLst.add("bye");
		
		return logLst;
		 
	}

}
