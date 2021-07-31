# docker-anaconda
FROM continuumio/anaconda3

# sh -> bash
SHELL ["/bin/bash", "-c"]
# コンテナ側の jupyter ポート開放
EXPOSE 8888

# .env 変数定義
ARG jupyter_pass="none"
ARG jupyter_dir="/home/Jupyter-Home"
ARG add_ch="conda-forge"
ARG jupyter_theme="none"
ARG venv_list="sample/Sample:latest"
ARG nbextensions="toc2/main"
ARG venv_module="numpy pandas matplotlib"

# jupyter の作業ディレクトリ作成
RUN mkdir ${jupyter_dir}

# base-os のアップデート
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev

# conda-forge を追加
RUN for ch in ${add_ch[@]} ; \
    do \
      if [ "${ch}" = "none" ] ; then \
        echo "skip adding channels" ; \
      else \
        conda config --add channels "${ch}" ; \
      fi \
    done \
  && conda config --show-sources

# Anaconda のアップデート & パッケージのアップデート
RUN conda update -y -c defaults --all \ 
  && conda update -n base -c defaults conda

# bash に conda を追加 & bash に適用
RUN conda init \
  && conda init bash \
  && exec bash \
  && exec bash -l \
  && source /root/.bashrc \
  && source /opt/conda/etc/profile.d/conda.sh

# jupyterthemes インストール & アップデート
RUN conda install -c conda-forge jupyterthemes \
  && conda update jupyterthemes

# jupyterthemes の変更
RUN if [ ${jupytertheme} = "none" ]; then \
      echo "skip jupyterthemes" ; \
    else \
      echo "changing jupyterthemes" ; \
      jt ${jupytertheme} ; \
    fi

# jupyter notebook の設定ファイルの作成
RUN jupyter-notebook --generate-config

# jupyter lab の設定ファイルの作成
RUN jupyter lab --generate-config

# https://stackoverflow.com/questions/39759623/jupyter-notebook-server-password-invalid
# jupyter notebook の設定ファイルに設定追記
RUN path="/root/.jupyter/jupyter_notebook_config.py" \
  && echo "# my notebooks settings" >> $path \
  && echo "c = get_config()" >> $path \
  && echo "c.IPKernelApp.pylab = 'inline'" >> $path \
  && echo "c.NotebookApp.ip = '0.0.0.0'" >> $path \
  && echo "c.NotebookApp.port = 8888" >> $path \
  && echo "c.NotebookApp.allow_root = True" >> $path \
  && echo "c.NotebookApp.open_browser = False" >> $path \
  && echo "c.NotebookApp.notebook_dir = '${jupyter_dir}'" >> $path \
  && echo " " >> $path \
  && echo "# setting up the password" >> $path \
  && if [ "${jupyter_pass}" = "none" ] ; then \
      echo "c.NotebookApp.token = ''" >> $path ; \
    else \
      echo "from IPython.lib import passwd" >> $path ; \
      echo 'password = passwd("${jupyter_pass}")' >> $path ; \
      echo "c.NotebookApp.password = password" >> $path ; \
    fi

# https://stackoverflow.com/questions/39759623/jupyter-notebook-server-password-invalid
# jupyter lab の設定ファイルに設定追記
RUN path="/root/.jupyter/jupyter_lab_config.py" \
  && echo "# my notebooks settings" >> $path \
  && echo "c = get_config()" >> $path \
  && echo "c.IPKernelApp.pylab = 'inline'" >> $path \
  && echo "c.ServerApp.ip = '0.0.0.0'" >> $path \
  && echo "c.ServerApp.port = 8888" >> $path \
  && echo "c.ServerApp.allow_root = True" >> $path \
  && echo "c.ServerApp.open_browser = False" >> $path \
  && echo "c.ServerApp.notebook_dir = '${jupyter_dir}'" >> $path \
  && echo " " >> $path \
  && echo "# setting up the password" >> $path \
  && if [ "${jupyter_pass}" = "none" ] ; then \
      echo "c.ServerApp.token = ''" >> $path ; \
    else \
      echo "from IPython.lib import passwd" >> $path ; \
      echo 'password = passwd("${jupyter_pass}")' >> $path ; \
      echo "c.ServerApp.password = password" >> $path ; \
    fi

    # https://ricrowl.hatenablog.com/entry/2020/05/21/222821
    # https://qiita.com/SaitoTsutomu/items/aee41edf1a990cad5be6
    # https://qiita.com/tdrk/items/e6c293021cbcb0e96cd2
    # matplotlib の図を notebook 上で表示許可 ：c.IPKernelApp.pylab = 'inline'
    # 外部の接続の許可アドレス                 ：c.NotebookApp.ip = '0.0.0.0'
    # コンテナ側の接続ポート                   ：c.NotebookApp.port = [コンテナ側の接続ポート]
    # root から jupyter を起動許可            ：c.NotebookApp.allow_root = True
    # jupyter 起動時にブラウザを開くのを禁止　 ：c.NotebookApp.open_browser = False
    # 初期の作業ディレクトリ変更              ：c.NotebookApp.notebook_dir = 'C:\Users'
    # jupyter ログイン時のパスワード          ：c.NotebookApp.token = ''
    # jupyter ログイン時のパスワードハッシュ   ：c.NotebookApp.password = u'sha1:<ハッシュ化されたパスワード>''

# https://www.soudegesu.com/post/python/jupyter-autocomplete/
# jupyter の拡張機能のインストール＆有効化
RUN conda install -y -c conda-forge jupyter_contrib_nbextensions \
  && conda install -y -c conda-forge jupyter_nbextensions_configurator \
  && jupyter contrib nbextension install \
  && jupyter nbextensions_configurator enable

# https://qiita.com/simonritchie/items/88161c806197a0b84174
# jupyter の拡張機能の有効化
RUN for path in ${nbextensions[@]}; \
    do \
      # jupyter の拡張機能の有効化しない場合
      if [ "${path}" = "none" ] ; then \
        echo "running default jupyter_contrib_nbextensions" ; exit 0 ; \
      else \
        echo "jupyter nbextension enable ${path}"; \
        jupyter nbextension enable "${path}" | grep '- Validating: problems found:  - require?' | exit $(wc -l) ; \
      fi \
    done

# 仮想環境.yml をコピー
COPY ./venv.yml /home/venv.yml
RUN ls /home/venv.yml

# 仮想環境の再構築
RUN for file in /home/venv.yml/*; \
    do \
      # /home/venv.yml 内に yml ファイルがない場合
      if [ "${file}" = "/home/venv.yml/*" ] ; then \
        echo "the file is missing in venv.yml." ; \
        echo "skip rebuilding the virtual environment."; exit 0 ; \
      # /home/venv.yml 内の .yml 読み込み
      else \
        f_name=${file##*/} ; f_name=${f_name%.*} ; \
        d_name=${f_name%@*} ; e_name=${f_name##*@} ; \
        echo "conda env create -f $file" ; \
        conda env create -n "${e_name}" -f "$file" ; \
        source /opt/conda/etc/profile.d/conda.sh ; \
        conda activate "${e_name}" ; \
        conda install jupyter notebook ipykernel ; \
        echo "make jupyter aware of '${e_name}' - '${d_name}'" ; \
        ipython kernel install --user --name "${e_name}" --display-name "${d_name}" ; \
        conda deactivate ; \
      fi \
    done

# 仮想環境の構築
RUN for venv in ${venv_list[@]}; \
    do \
      # 仮想環境を作らない場合
      if [ "${venv}" = "none" ]; then \
        echo "don't build a virtual environment" ; exit 0 ; \
      else \
        venv_name=${venv%/*} ; venv_ver=${venv##*:} ; \
        venv_2=${venv##*/} ; venv_disp=${venv_2%:*} ; \
        \
        # 仮想環境を作成するオプションの確認
        if [ ${#venv_name} = 0 ]; then \
          echo '"venv_name" is not set.' ; \
          echo "please confirm." ; exit $(wc -l) ; \
        elif [ ${#venv_disp} = 0 ]; then \
          echo '"venv_display_name" is not set.' ; \
          echo "please confirm." ; exit $(wc -l) ; \
        elif [ ${#venv_ver} = 0 ]; then \
          echo '"venv_python_version" is not set.' ; \
          echo "please confirm." ; exit $(wc -l) ; \
          \
        else \
          echo "conda create -n ${venv_name} python=${venv_ver}" ; \
          # python_version: "latest"
          if [ "${venv_ver}" = "latest" ]; then \
            conda create -n "${venv_name}" ; \
            source /opt/conda/etc/profile.d/conda.sh ; \
            conda activate "${venv_name}" ; \
            conda install -y ${venv_module} ; \
            conda install -y jupyter notebook ipykernel ; \
            echo "make jupyter aware of '${venv_name}' - '${venv_disp}'" ; \
            ipython kernel install --user --name "${venv_name}" --display-name "${venv_disp}" ; \
            conda deactivate ; \
          # python_version: number
          else \
            conda create -n "${venv_name}" python="${venv_ver}" ; \
            source /opt/conda/etc/profile.d/conda.sh ; \
            conda activate "${venv_name}" ; \
            conda install -y ${venv_module} ; \
            conda install -y jupyter notebook ipykernel ; \
            echo "make jupyter aware of '${venv_name}' - '${venv_disp}'" ; \
            ipython kernel install --user --name "${venv_name}" --display-name "${venv_disp}" ; \
            conda deactivate ; \
          fi \
        fi \
      fi \
    done

# bash の起動
CMD ["/bin/bash"]