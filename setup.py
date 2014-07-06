from setuptools import setup

from setuptools.command.test import test as TestCommand
from setuptools import setup

from hbite import VERSION as version


class Tox(TestCommand):
    def finalize_options(self):
        TestCommand.finalize_options(self)
        self.test_args = []
        self.test_suite = True

    def run_tests(self):
        #import here, cause outside the eggs aren't loaded
        import tox
        errno = tox.cmdline(self.test_args)
        sys.exit(errno)

install_requires = [
    'protobuf==2.5.0',
    'protobuf-socket-rpc==1.3'
    ]

test_requires = [
    'tox'
    ]

setup(
    name='hbite',
    version=version,
    url='https://github.com/ravwojdyla/hbite',
    author='Rafal Wojdyla',
    author_email='ravwojdyla@gmail.com',
    description='A high-level Python library for Hadoop RPCs',
    packages=['hbite'],
    install_requires=install_requires,
    tests_require=test_requires,
    cmdclass={'test': Tox}
)
