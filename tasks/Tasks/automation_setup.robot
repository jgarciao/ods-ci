*** Settings ***
Documentation    Prepares the testing environment for RHODS, using the
...    parameters provided at automation-config.yaml


*** Tasks ***
Automation Setup
    [Documentation]    Prepares the testing environment for RHODS (cluster provisioning,
    ...    gpu support, idp configuration, ...) using the parameters provided at
    ...    automation-config.yaml
    [Tags]    AutomationSetup
    Provision Cluster If Required
    Add GPU Support If Required
    Generate TestVariables File
    Add Htpasswd Identity Provider    add_default_users=True
    Add Ldap Identity Provider    add_default_users=True
    Install RHODS If Required


*** Keywords ***
Provision Cluster If Required
    [Documentation]    Using the parameters at automation-config.yaml, creates a new cluster if needed
    IF    "${AUTOMATION_SETUP.CLUSTER.CREATE}" == "False"
         Log    Cluster creation disabled    console=True
    ELSE
         Log    Creating cluster...    console=True
         # TODO: depending $AUTOMATION_SETUP.CLUSTER.TYPE and .PROVIDER,
         # call different tasks to do the provisioning
    END

Add GPU Support If Required
    [Documentation]    Using the parameters at automation-config.yaml, configures GPU support if needed
    IF    "${AUTOMATION_SETUP.CLUSTER.CREATE}" == "False"
         Log    Cluster creation disabled    console=True
    ELSE
         Log    Creating cluster...    console=True
         # TODO: depending $AUTOMATION_SETUP.CLUSTER.TYPE and .PROVIDER,
         # call different tasks to do the provisioning
    END

Generate TestVariables File
    [Documentation]    Clones the repo containing the test-variables.yml base file
    ...    and adds the cluster variables if required based on
    ...    automation-config.yaml
    Log    Generating test-variables.yml...    console=True

Add Htpasswd Identity Provider
    [Documentation]    Adds htpasswd identity provider if it's
    ...    not already present
    [Arguments]    ${add_default_users}=True
    Log    message=Adding Htpasswd Identity Provider...    console=True

Add Ldap Identity Provider
    [Documentation]    Adds LDAP identity provider if it's
    ...    not already present
    [Arguments]    ${add_default_users}=True
    Log    message=Adding LDAP Identity Provider...    console=True

Install RHODS If Required
    [Documentation]    Istalls RHODS in the cluster, depending on the configuration
    ...    on automation-config.yaml
    IF    "${AUTOMATION_SETUP.RHODS.FLAVOUR}" == "CloudService"
        Log    Installing RHODS Cloud Service
    ELSE
        IF    "${AUTOMATION_SETUP.RHODS.FLAVOUR}" == "SelfManaged"
            Log    Installing RHODS Cloud Service
        ELSE
               Fail    unsuported product ${AUTOMATION_SETUP.RHODS.FLAVOUR}
        END
    END
