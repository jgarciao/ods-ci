*** Settings ***
Documentation  Main RHODS resource file (includes ODHDashboard, ODHJupyterhub, Prometheus ... resources)
...            with some useful keywords to control the operator and main deployments
Resource  ./Page/LoginPage.robot
Resource  ./Page/ODH/ODHDashboard/ODHDashboard.resource
Resource  ./Page/ODH/JupyterHub/ODHJupyterhub.resource
Resource  ./Page/ODH/Prometheus/Prometheus.resource
