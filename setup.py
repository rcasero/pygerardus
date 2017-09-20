from setuptools import setup, find_packages

setup(
    name='pysto',
    version='1.0.0',
    packages=find_packages(),

    python_requires='>=3.6',
    install_requires=['matplotlib>=2.0','numpy>=1.13','opencv-python>=3.3.0'],
    
    description='Miscellanea image processing functions',
    url='https://github.com/rcasero/pysto',
    author='Ramón Casero',
    author_email='rcasero@gmail.com',
    license='GPL v3',
)
