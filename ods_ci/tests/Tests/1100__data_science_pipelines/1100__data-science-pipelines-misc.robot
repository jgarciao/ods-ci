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
${PIPELINE_EXIT_HANDLER_FILEPATH}=   tests/Resources/Files/pipeline-samples/v2/cache-disabled/exit_handler_compiled.yaml


*** Test Cases ***
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
