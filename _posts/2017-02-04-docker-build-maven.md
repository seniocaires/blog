---
layout: post
section-type: post
title: Usando o Docker para fazer build com Maven
category: docker
tags: [ 'docker', 'java', 'maven' ]
---

![Docker e Maven](/img/2017/docker-maven-logo.png)

O objetivo deste post é realizarmos o processo de build de uma aplicação que utiliza Maven sem precisar instalá-lo em nossas máquinas.

Ainda não tem o Docker? [Clique aqui](https://docs.docker.com/engine/installation/){:target="_blank"}.

Realizar o processo de build desta forma é interessante porque sempre que build ocorrer será em um container limpo, construído do zero, sem nenhuma dependência no repositório local, garantindo que o build funciona mesmo fora da IDE.

Então vamos à aplicação de exemplo: Notícias Recentes  
Esta é uma aplicação simples escrita em Java que possui um rest que retorna um Json de notícias, e claro, utiliza Maven.

Você precisará baixá-la para o seu computador clonando o repositório do projeto.

1. Acesse o link do projeto em [https://git.seniocaires.com.br/publico/noticias-recentes](https://git.seniocaires.com.br/publico/noticias-recentes){:target="_blank"}
2. Clone o projeto para seu computador usando o link disponível na página inicial do projeto.

```shell
git clone https://git.seniocaires.com.br/publico/noticias-recentes.git
```

![Docker e Maven](/img/2017/docker-maven-repositorio.png)

Vamos direto ao comando que irá realizar a tarefa e em seguida explicaremos cada parte deste comando.

```shell
docker run -it --rm -v [path_projeto]:/tmp/app -w /tmp/app maven:3 mvn clean install
```

O comando Docker acima é divido em quatro partes:

![Docker e Maven](/img/2017/docker-maven-run.png)

A primeira parte (docker run) corresponde ao comando do Docker para criar e iniciar um novo container. Outros exemplos de comandos Docker são: docker build, docker create, docker start, docker stop, etc)

A segunda parte é onde definimos os parâmetros da criação do container. Neste exemplo, são eles:

**-i -t ou -it** : São usados para que o processo seja interativo (como em um terminal), use -i -t juntos para alocar um tty para o processo do container.  
**–rm** : Ao adicionar este parâmetros dizemos que o container deve ser destruído ao terminar o processo, neste caso, o build do maven. Este parâmetro é útil quando não precisaremos reutilizar o container.  
**-v** : Este parâmetro cria um volume. Um volume, para simplificar, pode ser considerado como uma pasta compartilhada entre o host (sua máquina) e o container. Deste modo, as alterações feitas nesta pasta irão refletir tanto no container quanto no host.  
Ele está divido em duas partes, antes e depois dos dois pontos. **[path_projeto] : /tmp/app** .  
Isso significa que o conteúdo da pasta do projeto noticias-recentes será mapeado na pasta /tmp/app do container. Exemplo: /opt/noticias-recentes:/tmp/app  
**– w** : O diretório padrão de acesso ao container é a raiz (/). Com este parâmetro podemos modificar o workdir, facilitando assim o comando de build do Maven, pois por padrão já estaremos no diretório /tmp/app que contém a nossa aplicação.

A terceira parte do comando indica o nome da imagem e sua respectiva versão. Usaremos a imagem maven, versão 3. Se omitíssemos a versão após os dois pontos o docker entenderia que estamos optando pela versão mais recente (latest), ou seja, maven = maven:latest.

> Quais versões do Maven posso usar? Você poderá encontrar as versões disponíveis no repositório oficial da imagem maven no Docker Hub. [Clique aqui](https://hub.docker.com/_/maven/){:target="_blank"} acessá-lo.

E por fim, a quarta e última parte diz qual é o processo (comando) que será executado dentro do container. No exemplo: mvn clean install

**Resumindo**, criaremos um container que irá executar o mvn clean install dentro da pasta /tmp/app que é um volume (mapeamento) da pasta onde se encontra o projeto na sua máquina. Após concluir o processo o container será destruído, restando somente as alterações que o Maven fez na pasta do projeto.

### Executando o comando

O Docker irá verificar se na sua máquina já existe a imagem maven:3.
Caso não exista, o Docker irá fazer o download da imagem no [Docker Hub](https://hub.docker.com/_/maven/){:target="_blank"}.

```shell
docker run -it --rm -v /tmp/noticias-recentes:/tmp/app -w /tmp/app maven:3 mvn clean install
Unable to find image 'maven:3' locally
3: Pulling from library/maven
5040bd298390: Already exists
fce5728aad85: Already exists
76610ec20bf5: Pull complete
60170fec2151: Pull complete
e98f73de8f0d: Pull complete
11f7af24ed9c: Pull complete
49e2d6393f32: Extracting [=============================================>     ] 118.1 MB/130.1 MB
bb9cdec9c7f3: Download complete
e710119c3eab: Download complete
879aca435fbc: Download complete
b5c82f96d94f: Download complete
```

Após fazer o download da imagem, o Docker irá criar e iniciar o container executando o processo *mvn clean install* dentro da pasta */tmp/app*

```shell
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building noticias-recentes 1.0.0
[INFO] ------------------------------------------------------------------------
Downloading: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom
Downloaded: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom (4 KB at 5.2 KB/sec)
Downloading: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/22/maven-plugins-22.pom
```

O Maven irá concluir o processo de build e em seguida o container será destruído (ver parâmetro –rm).

```shell
Downloaded: https://repo.maven.apache.org/maven2/org/codehaus/plexus/plexus-digest/1.0/plexus-digest-1.0.jar (12 KB at 203.2 KB/sec)
Downloaded: https://repo.maven.apache.org/maven2/org/codehaus/plexus/plexus-utils/3.0.5/plexus-utils-3.0.5.jar (226 KB at 3814.3 KB/sec)
[INFO] Installing /tmp/app/target/noticias.war to /root/.m2/repository/br/com/seniocaires/noticias/noticias-recentes/1.0.0/noticias-recentes-1.0.0.war
[INFO] Installing /tmp/app/pom.xml to /root/.m2/repository/br/com/seniocaires/noticias/noticias-recentes/1.0.0/noticias-recentes-1.0.0.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 10.467 s
[INFO] Finished at: 2017-02-04T12:19:27+00:00
[INFO] Final Memory: 18M/185M
[INFO] ------------------------------------------------------------------------
```

Você poderá notar que foi criada uma pasta target que contém o arquivo **noticias.war** e todos os outros arquivos e pastas resultantes do processo de build do Maven.

Pronto, Já temos o nosso aquivo noticias.war criado em uma “máquina” limpa (dentro de um container).
Podemos fazer o build de diversos projetos com diversas versões do Maven sem precisar instalá-lo no host.

Ficou com alguma dúvida? Entre em contato comigo.






