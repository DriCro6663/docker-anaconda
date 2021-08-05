# docker-anaconda

Docker 上に Anaconda 環境を構築できる Dockerfile 群です。

# DEMO

[continuumio/anaconda3][con/ana3] をもとに Anaconda 環境を構築します。

[con/ana3]: https://hub.docker.com/r/continuumio/anaconda3/

![doc-ana-01-min.png](https://user-images.githubusercontent.com/87227607/128315758-a99f1798-81a1-4313-b9b1-1ca4ec21501d.png)

# Features

jupyter_lab_config.py と jupyter_notebook_config.py を作成し、下図のような設定を追加します。

![doc-ana-02-min.png](https://user-images.githubusercontent.com/87227607/128315762-70dc183d-eb70-410a-bbf9-d0b7891277f5.png)

./venv.yml にある virtual-environment.yml をもとに仮想環境を再構築いたします。ローカルにある Anaconda の仮想環境を yaml ファイルにまとめる際は、Usage を確認してください。

![doc-ana-03-min.png](https://user-images.githubusercontent.com/87227607/128315764-13141905-f639-48f7-9236-5d5be46486d1.png)

./.env ファイルの venv_list を参照して、複数の仮想環境を作成可能です。また、作成した仮想環境に venv_module にあるライブラリをインストールします。

![doc-ana-04-min.png](https://user-images.githubusercontent.com/87227607/128315766-f2f68c2e-785e-4ef5-969b-5abc0fe4dffd.png)

# Preparation

以下のプログラムを事前にインストールしておいてください。

* [Docker](https://www.docker.com/products/docker-desktop)
* [git](https://git-scm.com/)

# Usage

Docker に dricro/anaconda3 を作成する場合、以下の操作で作成してください。

1. dricro/anaconda3 を git clone してください。

```bash
# クローン先のディレクトリに移動
cd [clone_dir]

# クローン
git clone https://github.com/DriCro6663/docker-anaconda.git
```

2. ローカルにある Anaconda の仮想環境を再構築する際は、以下のコマンドで仮想環境をファイルにまとめてください。

```bash
# ファイルを出力するディレクトリに移動
cd [clone_dir/venv.yml]

# 仮想環境を出力
conda env export --name [Environment_name] --from-history > [Jupyter_name@Environment_name].yaml

or

conda activate [Environment_name]
conda env export --from-history > [Jupyter_name@Environment_name].yaml
conda deactivate
```

3. docker-compose up 時に作成する仮想環境名とインストールするライブラリを確認してください。


```bash
# .env

# 作成する仮想環境のリスト: "venv_name/display_name:python_version" or "none"
venv_list="twitter/Twitter-Bot:latest sample/Sample:3.7"

# 仮想環境にインストールするモジュール: 必要 おススメ -> "numpy pandas scipy xlrd matplotlib"
venv_module="jupyter notebook ipykernel numpy pandas scipy tqdm xlrd scikit-learn matplotlib opencv"
```

4. dockerfile があるディレクトリに移動して、docker-compose up してください。

```bash
# dockerfile があるディレクトリに移動
cd [dockerfile_dir]

# docker-compose up
docker-compose up --build
```

5. docker exec で bash を起動して、Anaconda を操作してください。

```bash
# dockerfile があるディレクトリに移動
cd [dockerfile_dir]

# コンテナ名の表示
docker ps -all

# コンテナの起動
docker start Anaconda

# Anaconda コンテナの bash 起動
docker exec -it Anaconda bash

# コンテナの停止
docker stop Anaconda
```

# Note

* venv.yml ファルダに yml ファイルが無くても、問題が無いように作っていますが、エラーが出た際は、連絡してください。エラーを修正します。
* [Visual Studio Code][vs_code] と連携して使用すると楽です。おすすめです。

[vs_code]: https://code.visualstudio.com/download

# Author

* [Github: DriCro6663](https://github.com/DriCro6663)
* [Twitter: Dri_Cro_6663](https://twitter.com/Dri_Cro_6663)
* [PieceX: DriCro6663](https://www.piecex.com/users/profile/DriCro6663)
* [ドリクロの備忘録](https://dri-cro-6663.jp/)
* dri.cro.6663@gmail.com

# License

ライセンスは [LICENSE](./LICENSE) ファイルをご確認ください。