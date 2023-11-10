# set up file

# In[ ]:
import os


# DOWNLOAD THE GLOVE EMBEDDINGS, IN THE DATA FOLDER:


# ENGLISH:
#!wget https://nlp.stanford.edu/data/glove.6B.zip
#!unzip glove.6B.zip


# Command to download the file using wget
download_command_en = "wget https://nlp.stanford.edu/data/glove.6B.zip"
# Command to unzip the downloaded file using gunzip
unzip_command_en = "unzip glove.6B.zip"


# SPANISH:
#!wget http://dcc.uchile.cl/~jperez/word-embeddings/glove-sbwc.i25.vec.gz
#!gunzip glove-sbwc*.gz

# Command to download the file using wget
download_command_es = "wget http://dcc.uchile.cl/~jperez/word-embeddings/glove-sbwc.i25.vec.gz"
# Command to unzip the downloaded file using gunzip
unzip_command_es = "gunzip glove-sbwc*.gz"


download_command = download_command_en
#download_command = download_command_es
unzip_command = unzip_command_en
#unzip_command = unzip_command_es

# In[ ]:

if os.environ.get("CONSUL_TENANT"):
    data_path = '../../tenants/' + os.environ["CONSUL_TENANT"] + '/machine_learning/data'
else:
    data_path = '../data'

def download_and_setup_glove():


    # ENGLISH:
    #!wget https://nlp.stanford.edu/data/glove.6B.zip
    #!unzip glove.6B.zip


    # Command to download the file using wget
    download_command_en = "wget https://nlp.stanford.edu/data/glove.6B.zip"
    # Command to unzip the downloaded file using gunzip
    unzip_command_en = "unzip glove.6B.zip"


    # SPANISH:
    #!wget http://dcc.uchile.cl/~jperez/word-embeddings/glove-sbwc.i25.vec.gz
    #!gunzip glove-sbwc*.gz

    # Command to download the file using wget
    download_command_es = "wget http://dcc.uchile.cl/~jperez/word-embeddings/glove-sbwc.i25.vec.gz"
    # Command to unzip the downloaded file using gunzip
    unzip_command_es = "gunzip glove-sbwc*.gz"


    download_command = download_command_en
    #download_command = download_command_es
    unzip_command = unzip_command_en
    #unzip_command = unzip_command_es

    # In[ ]:

    if os.environ.get("CONSUL_TENANT"):
        data_path = '../../tenants/' + os.environ["CONSUL_TENANT"] + '/machine_learning/data'
    else:
        data_path = '../data'

def download_and_setup_glove(download_command, unzip_command):

    #download Glove files
    from urllib.parse import urlparse

    import subprocess
    parsed_url = urlparse(download_command)
    filename = os.path.basename(parsed_url.path)
    glove_files = os.listdir(data_path)
    glove_files_exist = any(file.startswith("glove.6B.") and file.endswith(".txt") for file in glove_files)

    if not glove_files_exist:
        download_command = f"{download_command_en} -O {os.path.join(data_path, filename)}"
        unzip_command = f"unzip {os.path.join(data_path, filename)} -d {data_path}"
        # Execute the download command
        subprocess.run(download_command, shell=True)

        # Execute the unzip command
        subprocess.run(unzip_command, shell=True)
    else:
        print("Glove files already exist in the data folder.")
        
        
        