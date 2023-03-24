package com.migrator.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown=true)
public class Document {

    @JsonProperty(value="Id")
    private String id;
    
    @JsonProperty(value="AuthorId")
    private String authorId;
    
    @JsonProperty(value="FolderId")
    private String folderId;
    
    @JsonProperty(value="Name")
    private String name;
    
    @JsonProperty(value="Type")
    private String type;
    
    @JsonProperty(value="BodyLength")
    private String bodyLength;
    
    @JsonProperty(value="IsDeleted")
    private String isDeleted;
    
    public String getBody() {
		return body;
	}

	public void setBody(String body) {
		this.body = body;
	}

	@JsonProperty(value="Body")
    private String body;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getAuthorId() {
		return authorId;
	}

	public void setAuthorId(String authorId) {
		this.authorId = authorId;
	}

	public String getFolderId() {
		return folderId;
	}

	public void setFolderId(String folderId) {
		this.folderId = folderId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getBodyLength() {
		return bodyLength;
	}

	public void setBodyLength(String bodyLength) {
		this.bodyLength = bodyLength;
	}

	public String getIsDeleted() {
		return isDeleted;
	}

	public void setIsDeleted(String isDeleted) {
		this.isDeleted = isDeleted;
	}


}
