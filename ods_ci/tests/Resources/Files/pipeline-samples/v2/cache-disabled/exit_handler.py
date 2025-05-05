from kfp import compiler, dsl

common_base_image = (
    "registry.redhat.io/ubi8/python-39@sha256:3523b184212e1f2243e76d8094ab52b01ea3015471471290d011625e1763af61"
)


@dsl.component(base_image=common_base_image)
def print_op(message: str):
    """Prints a message."""
    print(message)


@dsl.component(base_image=common_base_image)
def fail_op(message: str):
    """Fails."""
    import sys  # noqa: PLC0415

    print(message)
    sys.exit(1)  # comment and successful


@dsl.component(base_image=common_base_image)
def exit_op(
    message: str,
):
    """Prints a message."""
    print(message)


@dsl.pipeline(name="pipeline-with-exit-handler", description="Pipeline using dsl.ExitHandler to catch errors in tasks")
def pipeline_exit_handler():
    """Pipeline with ExitHandler: exit_task should be called if print_op fails"""
    exit_task = exit_op(message="ExitHandler worked as expected").set_caching_options(False)

    with dsl.ExitHandler(exit_task):
        print_op(message="This task should succeed").set_caching_options(False)
        fail_op(message="This task should fail").set_caching_options(False)


if __name__ == "__main__":
    compiler.Compiler().compile(pipeline_exit_handler, package_path=__file__.replace(".py", "_compiled.yaml"))
