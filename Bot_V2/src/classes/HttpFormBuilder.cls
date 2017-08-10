public class HttpFormBuilder {
    //  The boundary is alligned so it doesn't produce padding characters when base64 encoded.
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

    /**
     *  Returns the request's content type for multipart/form-data requests.
     */
    public static string GetContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }

    /**
     *  Pad the value with spaces until the base64 encoding is no longer padded.
     */
    private static string SafelyPad(
        string value,
        string valueCrLf64,
        string lineBreaks) {
        string valueCrLf = '';
        blob valueCrLfBlob = null;

        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }

        return valueCrLf64;
    }

    /**
     *  Write a boundary between parameters to the form's body.
     */
    public static string WriteBoundary() {
        string value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     *  Write a boundary at the end of the form's body.
     */
    public static string WriteBoundary(
        EndingType ending) {
        string value = '';

        if (ending == EndingType.Cr) {
            //  The file's base64 was padded with a single '=',
            //  so it was replaced with '\r'. Now we have to
            //  prepend the boundary with '\n' to complete
            //  the line break.
            value += '\n';
        } else if (ending == EndingType.None) {
            //  The file's base64 was not padded at all,
            //  so we have to prepend the boundary with
            //  '\r\n' to create the line break.
            value += '\r\n';
        }
        //  Else:
        //  The file's base64 was padded with a double '=',
        //  so they were replaced with '\r\n'. We don't have to
        //  do anything to the boundary because there's a complete
        //  line break before it.

        value += '--' + Boundary + '--';

        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     *  Write a key-value pair to the form's body.
     */
    public static string WriteBodyParameter(
        string key,
        string value) {
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        string contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        string valueCrLf = value + '\r\n';
        blob valueCrLfBlob = blob.valueOf(valueCrLf);
        string valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);

        content += SafelyPad(value, valueCrLf64, '\r\n');

        return content;
    }
    public static string WriteBlobBodyParameter(string key, string file64, string filename, string mimeType) {
            string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"; filename="'+filename+'"';
            string contentDispositionCrLf = contentDisposition + '\r\n';
            blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
            string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
            string content = HttpFormBuilder.SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');
            
            string contentTypeHeader = 'Content-Type: ' + mimeType;
            string contentTypeCrLf = contentTypeHeader + '\r\n\r\n';
            blob contentTypeCrLfBlob = blob.valueOf(contentTypeCrLf);
            string contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);
            content += HttpFormBuilder.SafelyPad(contentTypeHeader, contentTypeCrLf64, '\r\n\r\n');
            
            integer file64Length = file64.length();
            String last4Bytes = file64.substring(file64.length()-4,file64.length());
            
            // Avoid padding the file data with spaces, which HttpFormBuilder.SafelyPad does
            // http://salesforce.stackexchange.com/a/33326/102
            EndingType ending = EndingType.None;
            if (last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                file64 = file64.substring(0,file64.length()-4) + last4Bytes;
                ending = EndingType.CrLf;
            } else if (last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                file64 = file64.substring(0,file64.length()-4) + last4Bytes;
                ending = EndingType.Cr;
            }
            
            content += file64;
            content += HttpFormBuilder.WriteBoundary(ending);
            return content;
        }
    

    /**
     *  Helper enum indicating how a file's base64 padding was replaced.
     */
    public enum EndingType {
        Cr,
        CrLf,
        None
    }
}