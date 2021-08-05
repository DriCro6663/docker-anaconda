# docker-anaconda

A set of Dockerfiles to build Anaconda environment on Docker.

# DEMO

Build the Anaconda environment based on [continuumio/anaconda3][con/ana3].

[con/ana3]: https://hub.docker.com/r/continuumio/anaconda3/

![doc-ana-01-min.png](https://user-images.githubusercontent.com/87227607/128315758-a99f1798-81a1-4313-b9b1-1ca4ec21501d.png)

# Features

It create jupyter_lab_config.py and jupyter_notebook_config.py, and add the configuration shown below.

![doc-ana-02-min.png](https://user-images.githubusercontent.com/87227607/128315762-70dc183d-eb70-410a-bbf9-d0b7891277f5.png)

It can rebuild the virtual environment based on the virtual-environment.yml file from "./venv.yml". When you put the local Anaconda virtual environment into a yaml file, please check the [Usage](#Usage).

![doc-ana-03-min.png](https://user-images.githubusercontent.com/87227607/128315764-13141905-f639-48f7-9236-5d5be46486d1.png)

./.env ファイルの venv_list を参照して、複数の仮想環境を作成可能です。また、作成した仮想環境に venv_module にあるライブラリをインストールします。

It can create multiple virtual environments by referring to the venv_list in the ".env" file. You can also install the libraries in venv_module in the created virtual environments.

![doc-ana-04-min.png](https://user-images.githubusercontent.com/87227607/128315766-f2f68c2e-785e-4ef5-969b-5abc0fe4dffd.png)

# Preparation

Please install the following programs in advance.

* [Docker](https://www.docker.com/products/docker-desktop)
* [git](https://git-scm.com/)

# Usage

If you want to create dricro/anaconda3 in Docker, please do the following.

1. Do a git clone of dricro/anaconda3.

```bash
# Go to the clone destination directory
cd [clone_dir]

# Clone
git clone https://github.com/DriCro6663/docker-anaconda.git
```

2. When rebuilding the local Anaconda virtual environment, please use the following command to put the virtual environment into a file.

```bash
# Go to the directory where you want to output the file
cd [clone_dir/venv.yml]

# Output virtual environment file
conda env export --name [Environment_name] --from-history > [Jupyter_name@Environment_name].yaml

or

conda activate [Environment_name]
conda env export --from-history > [Jupyter_name@Environment_name].yaml
conda deactivate
```

3. Please check the name of the virtual environment to be created and the libraries to be installed when docker-compose up.

```bash
# .env

# List of virtual environments to create: "venv_name/display_name:python_version" or "none"
venv_list="twitter/Twitter-Bot:latest sample/Sample:3.7"

# Modules to be installed in virtual environment: Required / Recommended -> "numpy pandas scipy xlrd matplotlib"
venv_module="jupyter notebook ipykernel numpy pandas scipy tqdm xlrd scikit-learn matplotlib opencv"
```

4. Please go to the directory containing the dockerfile and docker-compose up.

```bash
# Go to the directory containing the dockerfile
cd [dockerfile_dir]

# docker-compose up
docker-compose up --build
```

5. Start bash with docker exec and manipulate Anaconda.

```bash
# Go to the directory containing the dockerfile
cd [dockerfile_dir]

# Display container name
docker ps -all

# Start the container
docker start Anaconda

# Start bash of Anaconda container
docker exec -it Anaconda bash

# Stop the container
docker stop Anaconda
```

# Note

* I have made it so that there will be no problem even if there is no yml file in the venv.yml folder. However, if you encounter any errors, please contact me. I will fix them.
* It is easy to use in conjunction with [Visual Studio Code][vs_code]. Recommended.

[vs_code]: https://code.visualstudio.com/download

# Author

* [Github: DriCro6663](https://github.com/DriCro6663)
* [Twitter: Dri_Cro_6663](https://twitter.com/Dri_Cro_6663)
* [PieceX: DriCro6663](https://www.piecex.com/users/profile/DriCro6663)
* [Dri-Cro's Memorandum](https://dri-cro-6663.jp/)
* dri.cro.6663@gmail.com

# License

Please check the [LICENSE](./LICENSE) file.