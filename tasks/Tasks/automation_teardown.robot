*** Settings ***
Documentation    Tears down the testing environment for RHODS, using the
...    parameters provided at automation-config.yaml


*** Tasks ***
Automation Teardown
    [Documentation]    Tears down the testing environment for RHODS (cluster hibernation or deletion, ...)
    ...    using the parameters provided at automation-config.yaml
    [Tags]    AutomationTeardown
    HibernateCluster If Required
    DeleteCluster If Required


*** Keywords ***
HibernateCluster If Required
    [Documentation]    Hibernates the cluster if required based on
    ...    the configuration at automation-config.yaml
    IF    "${AUTOMATION_TEARDOWN.CLUSTER.HIBERNATE}" == "True"
        Log    Hibernating cluster...    console=True
    END

DeleteCluster If Required
    [Documentation]    UninstallDeletes the cluster if required based on
    ...    the configuration at automation-config.yaml
    IF    "${AUTOMATION_TEARDOWN.CLUSTER.DELETE}" == "True"
        Log    Uninstalling RHODS and deleting the cluster...    console=True
    END
