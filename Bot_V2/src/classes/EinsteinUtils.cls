
1

public class EinsteinUtils {

2



3

  public static final String KEYWORD_UNDEFINED = 'UNDEFINED';

4

  private static Id KEYWORD_ID_UNDEFINED;

5

  // UPLOAD STATUS

6

  public static final String UPLOAD_STATUS_NOT_UPLOADED = 'Not Uploaded';

7

  public static final String UPLOAD_STATUS_UPLOADED = 'Uploaded';

8

  public static final String UPLOAD_STATUS_IN_PROCESS = 'In Process';

9

  public static final String UPLOAD_STATUS_ERROR = 'Error';

10



11

  //KNOWN ISSUES STATUS

12

  public static final String KNOWN_ISSUE_PENDING_APPROVAL = 'Pending Approval';

13

  public static final String KNOWN_ISSUE_NEW = 'New';

14

  public static final String KNOWN_ISSUE_FIXED = 'Fixed';

15

  public static final String KNOWN_ISSUE_DUPLICATED = 'Duplicated';

16

  public static final String KNOWN_ISSUE_INVALID = 'Invalid';

17



18

  // EINSTEIN TRAIN STATUS

19

  public static final String EINSTEIN_TRAIN_STATUS_SUCCEEDED = 'SUCCEEDED';

20

  public static final String EINSTEIN_TRAIN_STATUS_QUEUED = 'QUEUED';

21

  public static final String EINSTEIN_TRAIN_STATUS_RUNNING = 'RUNNING';

22

  public static final String EINSTEIN_TRAIN_STATUS_FAILED = 'FAILED';

23



24

  // EINSTEIN DATASET STATUS

25

  public static final String EINSTEIN_DS_STATUS_SUCCEEDED = 'SUCCEEDED';

26

  // This status begins with FAILURE and is composed with its reason like this: 'FAILURE: <failure_reason>—Data upload has failed.'

27

  public static final String EINSTEIN_DS_STATUS_FAILURE = 'FAILED';

28

  public static final String EINSTEIN_DS_STATUS_UPLOADING = 'UPLOADING';

29



30

  // EINSTEIN ENDPOINTS

31

  // EINSTEIN ENDPOINTS - API TOKEN - URL

32

  public static final String EINSTEIN_ENDPOINT_APITOKEN_URL = 'https://api.metamind.io/v1/oauth2/token';

33

  // EINSTEIN ENDPOINTS - API TOKEN - KEYNAME

34

  public static final String EINSTEIN_ENDPOINT_APITOKEN_KEYNAME = 'einstein_platform';

35

  // EINSTEIN ENDPOINTS - API TOKEN - KEYNAME_OLD

36

  public static final String EINSTEIN_ENDPOINT_APITOKEN_KEYNAME_OLD = 'predictive_services';

37

  // EINSTEIN ENDPOINTS - API TOKEN - JWTISS

38

  public static final String EINSTEIN_ENDPOINT_APITOKEN_JWTISS = 'developer.force.com';

39

  // EINSTEIN ENDPOINTS - API TOKEN - JWTSUB

40

  public static final String EINSTEIN_ENDPOINT_APITOKEN_JWTSUB = 'etorrano@altimetrik.com';

41



42

  // EINSTEIN ENDPOINTS - LANGUAGE_API

43

  public static final String EINSTEIN_ENDPOINT_LANGUAGE_API = 'https://api.einstein.ai/v2/language';

44



45

  // EINSTEIN ENDPOINTS - DATASETS

46

  public static final String EINSTEIN_ENDPOINT_DATASETS = '/datasets/';

47



48

  // EINSTEIN ENDPOINTS - CREATE DATASET

49

  public static final String EINSTEIN_ENDPOINT_CREATEDS = EINSTEIN_ENDPOINT_DATASETS + 'upload';

50



51

  // EINSTEIN ENDPOINTS - CREATE EXAMPLE


Filter
