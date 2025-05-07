from kfp import compiler, dsl

common_base_image = (
    "registry.redhat.io/ubi8/python-39@sha256:3523b184212e1f2243e76d8094ab52b01ea3015471471290d011625e1763af61"
)

@dsl.component(base_image=common_base_image)
def test_non_optional(non_optional_input: str):
    print(non_optional_input)


@dsl.component(base_image=common_base_image)
def test_implicit_optional(optional_input: str = None):  # noqa:  RUF013
    print(optional_input)

@dsl.pipeline(display_name="Nested pipelines param check")
def test_parameters_nested_pipeline(non_optional_input: str,
                                    optional_input: str = None):  # noqa:  RUF013

    test_non_optional(non_optional_input=non_optional_input).set_caching_options(False)
    test_implicit_optional(optional_input=optional_input).set_caching_options(False)

@dsl.pipeline(name="test-optional-parameters-with-nested-pipelines", description="A pipeline testing optional parameters")
def pipeline(
    non_optional_input: str,
    implicit_optional_input: str = None,  # noqa:  RUF013
):
    """
    A pipeline testing the behaviour of optional input parameters when using nested pipelines
    More info at https://docs.astral.sh/ruff/rules/implicit-optional/
    :param non_optional_input:
    :param implicit_optional_input:
    :return:
    """
    test_parameters_nested_pipeline(non_optional_input=non_optional_input,
                                    optional_input=implicit_optional_input).set_caching_options(False)


if __name__ == "__main__":
    compiler.Compiler().compile(pipeline_func=pipeline, package_path=__file__.replace(".py", "_compiled.yaml"))
