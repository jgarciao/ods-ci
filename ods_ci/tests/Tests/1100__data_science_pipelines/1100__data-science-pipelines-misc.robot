*** Settings ***
Documentation       Miscelaneous tests checking data science pipelines
Resource            ../../Resources/RHOSi.resource
Resource            ../../Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/Projects.resource
Resource            ../../Resources/CLI/DataSciencePipelines/DataSciencePipelinesBackend.resource
Test Tags           DataSciencePipelines-Backend
Suite Setup         Dsp Misc Suite Setup
Suite Teardown      Dsp Misc Suite Teardown


*** Variables ***
${PROJECT}=    dsp-misc
${PIPELINE_OPTIONAL_PARAMETERS_FILEPATH}=    tests/Resources/Files/pipeline-samples/v2/cache-disabled/optional_parameters_compiled.yaml  # robocop: disable:line-too-long
${PIPELINE_EXIT_HANDLER_FILEPATH}=           tests/Resources/Files/pipeline-samples/v2/cache-disabled/exit_handler_compiled.yaml         # robocop: disable:line-too-long


*** Test Cases ***
# robocop: off=line-too-long,too-long-test-case,unused-variable
Verify Pipeline Run Cannot Be Created When Value For Non Optional Parameter Is Not Provided
    [Documentation]    Verifies that a pipeline run cannot be created if value for a mandatory parameter
    ...    is not provided
    [Tags]    Tier1

    Skip If Test Enviroment Is ROSA-HCP    msg=Skipped due to automation bug on ROSA-HCP (tracked at RHOAIENG-16414)
    ${pipeline_run_params}=    Create Dictionary

    Run Keyword And Expect Error    STARTS: ApiException
    ...    DataSciencePipelinesBackend.Import Pipeline And Create Run
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_name=non-optional-parameters
    ...    pipeline_description=Testing creating a pipeline run without providing values for non-optional params
    ...    pipeline_package_path=${PIPELINE_OPTIONAL_PARAMETERS_FILEPATH}
    ...    pipeline_run_name=non-optional-parameters-run
    ...    pipeline_run_params=${pipeline_run_params}

Verify Pipeline Runs Successfully When Not Providing Values For Optional Parameters
    [Documentation]    Creates a pipeline run not providing values for optional parameters and verifies that
    ...    the run finishes successfully
    [Tags]    Tier1

    Skip If Test Enviroment Is ROSA-HCP    msg=Skipped due to automation bug on ROSA-HCP (tracked at RHOAIENG-16414)
    ${pipeline_run_params}=    Create Dictionary    non_optional_input="Non Optional Input Value"

    ${pipeline_id}    ${pipeline_version_id}    ${pipeline_run_id}    ${experiment_id}=
    ...    DataSciencePipelinesBackend.Import Pipeline And Create Run
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_name=optional-parameters-without-values
    ...    pipeline_description=A pipeline testing optional parameters, where optional parameters don't have value
    ...    pipeline_package_path=${PIPELINE_OPTIONAL_PARAMETERS_FILEPATH}
    ...    pipeline_run_name=optional-parameters-without-values-run
    ...    pipeline_run_params=${pipeline_run_params}

    DataSciencePipelinesBackend.Wait For Run Completion And Verify Status
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_run_id=${pipeline_run_id}    pipeline_run_timeout=180
    ...    pipeline_run_expected_status=SUCCEEDED

    [Teardown]       DataSciencePipelinesBackend.Delete Pipeline And Related Resources
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_id=${pipeline_id}

Verify Pipeline Runs Successfully When Providing Values For All Optional Parameters
    [Documentation]    Creates a pipeline run providing values for all optional parameters and verifies that
    ...    the run finishes successfully
    [Tags]    Tier1

    Skip If Test Enviroment Is ROSA-HCP    msg=Skipped due to automation bug on ROSA-HCP (tracked at RHOAIENG-16414)
    ${pipeline_run_params}=    Create Dictionary
    ...    explicit_optional_input="Explicit optional input value"
    ...    implicit_optional_input="Implicit optional input value"
    ...    non_optional_input="Non Optional Input Value"

    ${pipeline_id}    ${pipeline_version_id}    ${pipeline_run_id}    ${experiment_id}=
    ...    DataSciencePipelinesBackend.Import Pipeline And Create Run
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_name=optional-parameters-providing-values
    ...    pipeline_description=A pipeline testing optional parameters, where all optional parameters have values
    ...    pipeline_package_path=${PIPELINE_OPTIONAL_PARAMETERS_FILEPATH}
    ...    pipeline_run_name=optional-parameters-providing-values-run
    ...    pipeline_run_params=${pipeline_run_params}

    DataSciencePipelinesBackend.Wait For Run Completion And Verify Status
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_run_id=${pipeline_run_id}    pipeline_run_timeout=180
    ...    pipeline_run_expected_status=SUCCEEDED

    [Teardown]       DataSciencePipelinesBackend.Delete Pipeline And Related Resources
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_id=${pipeline_id}

Verify Pipeline Run Status When Using Exit Handlers
    [Documentation]  Verifies that, when using using pipeline exit handlers (dsl.ExitHandler), if a task inside the
    ...    handle fails but the exit handler task succeeds, the overall pipeline run status is Failed.
    [Tags]    Tier1

    Skip If Test Enviroment Is ROSA-HCP    msg=Skipped due to automation bug on ROSA-HCP (tracked at RHOAIENG-16414)
    ${pipeline_run_params}=    Create Dictionary

    ${pipeline_id}    ${pipeline_version_id}    ${pipeline_run_id}    ${experiment_id}=
    ...    DataSciencePipelinesBackend.Import Pipeline And Create Run
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_name=exit-handler
    ...    pipeline_description=Verifies pipeline run status when using exit handlers
    ...    pipeline_package_path=${PIPELINE_EXIT_HANDLER_FILEPATH}
    ...    pipeline_run_name=exit-handler-run
    ...    pipeline_run_params=${pipeline_run_params}

    DataSciencePipelinesBackend.Wait For Run Completion And Verify Status
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_run_id=${pipeline_run_id}    pipeline_run_timeout=180
    ...    pipeline_run_expected_status=FAILED

    [Teardown]       DataSciencePipelinesBackend.Delete Pipeline And Related Resources
    ...    namespace=${PROJECT}    username=${TEST_USER.USERNAME}    password=${TEST_USER.PASSWORD}
    ...    pipeline_id=${pipeline_id}


*** Keywords ***
Dsp Misc Suite Setup
    [Documentation]    Dsp Misc Suite Setup
    RHOSi Setup
    Projects.Create Data Science Project From CLI    ${PROJECT}    as_user=${TEST_USER.USERNAME}
    DataSciencePipelinesBackend.Create Pipeline Server    namespace=${PROJECT}
    ...    object_storage_access_key=${S3.AWS_ACCESS_KEY_ID}
    ...    object_storage_secret_key=${S3.AWS_SECRET_ACCESS_KEY}
    ...    object_storage_endpoint=${S3.BUCKET_2.ENDPOINT}
    ...    object_storage_region=${S3.BUCKET_2.REGION}
    ...    object_storage_bucket_name=${S3.BUCKET_2.NAME}
    ...    dsp_version=v2
    DataSciencePipelinesBackend.Wait Until Pipeline Server Is Deployed    namespace=${PROJECT}

Dsp Misc Suite Teardown
    [Documentation]    Dsp Misc Suite Teardown
    Projects.Delete Project Via CLI By Display Name    ${PROJECT}
    RHOSi Teardown
