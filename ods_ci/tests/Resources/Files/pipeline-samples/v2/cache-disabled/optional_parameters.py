from typing import Optional

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


@dsl.component(base_image=common_base_image)
def test_explicit_optional(optional_input: Optional[str] = None):  # noqa:  UP007
    """
    Test explicit optional using typing.Optional
    More info at https://docs.astral.sh/ruff/rules/implicit-optional/
    :param optional_input:
    :return:
    """
    print(optional_input)


# Note: this is not yet supported by kfp 2.12.1
# @dsl.component(base_image=common_base_image)
# def test_explicit_optional_py210(optional_input: str | None = None):
#     """
#     Test explicit optional using new syntax available at Python 2.10 and newer
#     More info at https://docs.astral.sh/ruff/rules/implicit-optional/
#     :param optional_input:
#     :return:
#     """
#     print(optional_input)


@dsl.pipeline(name="test-optional-parameters", description="A pipeline testing optional parameters")
def pipeline(
    non_optional_input: str,
    implicit_optional_input: str = None,  # noqa:  RUF013
    explicit_optional_input: Optional[str] = None,  # noqa:  UP007
):
    """
    A pipeline testing the behaviour of optional input parameters
    More info at https://docs.astral.sh/ruff/rules/implicit-optional/
    :param non_optional_input:
    :param implicit_optional_input:
    :param explicit_optional_input:
    :return:
    """
    test_non_optional(non_optional_input=non_optional_input).set_caching_options(False)
    test_implicit_optional(optional_input=implicit_optional_input).set_caching_options(False)
    test_explicit_optional(optional_input=explicit_optional_input).set_caching_options(False)
    # test_explicit_optional_py210(optional_input=explicit_optional_input).set_caching_options(False)


if __name__ == "__main__":
    compiler.Compiler().compile(pipeline_func=pipeline, package_path=__file__.replace(".py", "_compiled.yaml"))
