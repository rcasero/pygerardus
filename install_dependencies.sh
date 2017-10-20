# install_dependencies.sh
#
#    Summary:
#    ====================================================================
#
#    Project pysto's script to create local environments for python
#    2.7 ("pysto_2.7") and 3.6 ("pysto_3.6"), and install Ubuntu and
#    python dependencies.
#
#    An important dependency is SimpleElastix. As SimpleElastix is not
#    required for all modules, and it has no pip/conda package,
#    instead we build and install it with this script.
#
#    SimpleElastix/SimpleITK:
#    ====================================================================
#
#    Some parts of pysto require SimpleITK. This can be installed
#    either with
#
#         conda install -c simpleitk simpleitk
#
#    or
#
#         pip install simpleitk
#
#    However, we are working in another project were we use image
#    registration with SimpleElastix. SimpleElastix is an externsion
#    of SimpleITK that has no pip/conda package, and needs to be built
#    by hand.
#
#    Thus, in this script we download, build and install
#    SimpleElastix.
#
#    We do it in separate local environments, so that other projects
#    external to pysto can install SimpleElastix without having to
#    rebuild it, just by running
#
#        source activate my_other_project
#        cd ~/Downloads/SimpleElastix/build_2.7/SimpleITK-build/Wrapping/Python/Packaging
#        python setup.py install
#
#    or
#
#        source activate my_other_project
#        cd ~/Downloads/SimpleElastix/build_3.6/SimpleITK-build/Wrapping/Python/Packaging
#        python setup.py install
#
#    Some design decisions:
#
#        1) We create and build conda environments SimpleElastix_2.7
#           and SimpleElastix_3.6 to build the project for python 2.7
#           and 3.6, respectively.
#
#           This way, we only need to build once and then can install
#           in any other local environment, whether pysto or an
#           external project.
#
#           TODO: Currently we build separatedly for 2.7 and 3.6, as
#           we haven't figured out how to reused the part of the build
#           that is independent from python.
#
#        2) We disable shared libraries in the SimpleITK build. This
#           way, _SimpleITK.cpython-*-x86_64-linux-gnu.so is not
#           linked to anything in the SimpleElastix_2.7 or
#           SimpleElastix_3.6 directories, and is more portable for
#           other local environments.
#
#        3) For the SimpleElastix build, we use the python binary,
#           include and library from the corresponding conda
#           SimpleElastix_* environments. This way, we know that they
#           will be the same that other conda local environments use.

#    Copyright © 2017  Ramón Casero <rcasero@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash

#################################################################################################
# auxiliary functions

# # creates conda local environment foo_2.7 with python 2.7 if it doesn't exist
# create_conda_local_environment foo 2.7 
# # creates conda local environment foo_3.6 with python 3.6 if it doesn't exist
# create_conda_local_environment foo 3.6 
create_conda_local_environment() {
    NAME=$1
    PYTHON_VERSION=$2

    if [ -z "$(conda info --envs | sed '/^#/ d' | cut -f1 -d ' ' | grep -w ${NAME}_${PYTHON_VERSION})" ]; then
	tput setaf 1; echo "** Create conda local environment: ${NAME}_${PYTHON_VERSION}"; tput sgr0
	conda create -y --name ${NAME}_${PYTHON_VERSION} python=${PYTHON_VERSION}
    else
	tput setaf 1; echo "** Conda local environment already exists (...skipping): ${NAME}_${PYTHON_VERSION}"; tput sgr0
    fi
}

#################################################################################################
# basic packages

# ubuntu packages
sudo apt-get install -y jq curl automake

#################################################################################################
# build conda and SimpleElastix

# TODO: we build SimpleElastix in separate 2.7 and 3.6 environments,
# as currently we are not sure how to make the produced SimpleITK
# shared object link to the local libraries in each separate local
# environment

./build_SimpleElastix.sh 2.7 || exit 1
./build_SimpleElastix.sh 3.6 || exit 1

#################################################################################################
# pysto local environment: for python 2.7
create_conda_local_environment pysto 2.7

# switch to pysto local environment
tput setaf 1; echo "** Switching to local environment: pysto_2.7"; tput sgr0
source activate pysto_2.7

# install pysto code and dependencies
tput setaf 1; echo "** Install pysto code and dependencies in local environment"; tput sgr0
pip install --upgrade .

# install development tools
tput setaf 1; echo "** Install development tools in local environment"; tput sgr0
conda install -y spyder pytest
pip install --upgrade twine wheel setuptools

#################################################################################################
# pysto local environment: for python 2.7

create_conda_local_environment pysto 2.7 || exit 1

# switch to pysto local environment
tput setaf 1; echo "** Switching to local environment: pysto_2.7"; tput sgr0
source activate pysto_2.7 || exit 1

# install pysto code and dependencies
tput setaf 1; echo "** Install pysto code and dependencies in local environment"; tput sgr0
pip install --upgrade . || exit 1

# install development tools
tput setaf 1; echo "** Install development tools in local environment"; tput sgr0
conda install -y spyder pytest
pip install --upgrade twine wheel setuptools

# install SimpleElastix python wrappers
cd ~/Downloads/SimpleElastix/build_2.7/SimpleITK-build/Wrapping/Python/Packaging || exit 1
python setup.py install || exit 1

#################################################################################################
# pysto local environment: for python 3.6

create_conda_local_environment pysto 3.6 || exit 1

# switch to pysto local environment
tput setaf 1; echo "** Switching to local environment: pysto_3.6"; tput sgr0
source activate pysto_3.6 || exit 1

# install pysto code and dependencies
tput setaf 1; echo "** Install pysto code and dependencies in local environment"; tput sgr0
pip install --upgrade . || exit 1

# install development tools
tput setaf 1; echo "** Install development tools in local environment"; tput sgr0
conda install -y spyder pytest
pip install --upgrade twine wheel setuptools

# install SimpleElastix python wrappers
cd ~/Downloads/SimpleElastix/build_3.6/SimpleITK-build/Wrapping/Python/Packaging || exit 1
python setup.py install || exit 1
