---
layout: post
section-type: post
title: Docker no Windows
category: docker
tags: [ 'docker' ]
---

Atualmente existem três formas de utilizar o Docker no Windows:

1. Docker Toolbox
2. Docker for Windows
3. Máquina virtual Linux

A instalação vai depender da sua preferência e das configurações do seu computador.

### Docker for Windows
É um aplicativo nativo para Windows, integrado com o Hyper-V (o virtualizador nativo do Windows), com interface de usuário para configurar rede, proxy, memória, etc.  
É o modo mais fácil e rápido de instalar o Docker no Windows.  
Entretanto, além do fato de que você só poderá utilizar o Docker for Windows se o seu sistema operacional for o Windows 10 Pro ou Enterprise 64-bit, com o tempo você poderá encontrar algumas coisas que irão incomodar e talvez limitar a sua utilização, por exemplo: alguns bugs; criar scripts para Windows e Linux, não conseguir conectar em um registry privado que utiliza certificado auto-assinado, dentre outros.  
Para baixar o Docker for Windows, [clique aqui](https://www.docker.com/products/docker#/windows).

### Docker Toolbox
O Docker Toolbox foi a primeira alternativa do Docker para Windows.  
É um instalador que rapidamente irá instalar e configurar um ambiente Docker no seu computador. Ele utiliza o VirtualBox para criar uma máquina virtual com Docker usando a distribuição Linux boot2docker baseada no Tiny Core Linux. Por ser uma distribuição bastante enxuta, muitas vezes preferimos instalar o Docker na nossa distribuição preferida do Linux ou à qual temos mais contato.  
Para baixar o Docker Toolbox, [clique aqui](https://www.docker.com/products/docker-toolbox). E para conhecer mais sobre o boot2docker, [clique aqui](http://boot2docker.io/).

### Máquina virtual Linux
Com as limitações do Docker for Windows, atualmente esta opção só perde para a utilização do Docker diretamente no Linux (sem Windows).  
Neste post vamos orientá-lo em como utilizar o Vagrant para criar uma máquina virtual Linux com o Docker, acesso SSH e com pastas compartilhadas com o Windows.

### Para continuar, você precisará instalar:

- Vagrant – [link](https://www.vagrantup.com/downloads.html)
- VirtualBox – [link](https://www.virtualbox.org/wiki/Downloads)
- PuTTY e PuTTYgen – [link](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

Para criarmos a máquina virtual utilizaremos um arquivo Vagrantfile que descreve como a máquina será criada pelo Vagrant no VirtualBox.

Você precisará baixar o arquivo completo para o seu computador clonando o repositório do projeto.

1. Acesse o link do projeto em [https://git.seniocaires.com.br/publico/docker-windows](https://git.seniocaires.com.br/publico/docker-windows)
2. Clone o projeto para seu computador usando o link disponível na página inicial do projeto.

```shell
git clone https://git.seniocaires.com.br/publico/docker-windows.git
```

![Repositório Docker no Windows](/img/2017/docker-windows-repositorio.png)

Pelo terminal (PowerShell), acesse a pasta do projeto. Nesta pasta estará o arquivo Vagrantfile que descreve como o Vagrant irá criar a máquina virtual.

### Explicando o arquivo:

Na primeira linha temos uma variável que declara o diretório onde o VirtualBox está configurado para criar as máquinas virtuais.

```ruby
PATH_VM_VIRTUAL_BOX = "F:/VM/"
```

Mude o valor desta variável para o local que está configurado no VirtualBox. Você poderá encontrá-lo abrindo o VirtualBox, acessando o menu “Arquivo” > “Preferências”, na aba “Geral”, no campo “Pasta Padrão para Máquinas:”.  
Não se esqueça de alterar as barras invertidas “\” para barras normais “/”

```ruby
PATH_VM_VIRTUAL_BOX = "C:/Users/SenioCaires/Documents/maquinas_virtuais"
```

![Repositório Docker no Windows](/img/2017/docker-windows-repositorio.png)

Na terceira linha começa o bloco de configuração do Vagrant. Nesta linha é informado que utilizaremos a versão mais recente do padrão de configuração, a versão 2.

```ruby
Vagrant.configure("2") do |config|
  # ...
end
```

Como podem ver na quinta linha, nossa máquina virtual será um Debian Jessie 64-bit. Você poderá encontrar outras distribuições (Boxes) no Atlas do Vagrant. Clique aqui para acessá-lo.

```ruby
config.vm.box = "debian/jessie64"
```

As linhas 9 e 10 é onde faremos as configurações de redirecionamento de porta entre o nosso computador e a máquina virtual. De acordo com esta configuração, ao acessarmos as portas 80 ou 443 do nosso computador a requisição será encaminhada para as respectivas portas (de mesmo número) da máquina virtual.

```ruby
config.vm.network "forwarded_port", guest: 80, host: 80
config.vm.network "forwarded_port", guest: 443, host: 443
```

Adicione mais configurações de porta de acordo com a sua necessidade.

Na linha 12 informamos que a pasta *F:\workspaces\docker* será compartilhada e mapeada dentro da máquina virtual no diretório */shared*. Deste modo, o que alterarmos dentro desta pasta, seja dentro do nosso computador ou da máquina virtual, irá refletir em ambos. Definimos também quem será o usuário e grupo proprietário desta pasta (*root:root*). Podemos dizer o mesmo para a linha 13, diferindo apenas que este mapeamento padrão estará desabilitado (*disabled: true*)

```ruby
config.vm.synced_folder "F:\\workspaces\\docker", "/shared", type: "virtualbox", owner: "root", group: "root"
config.vm.synced_folder ".", "/vagrant", type: "virtualbox", owner: "root", group: "root", disabled: true
```

Entre a linha 15 e 19 é onde utilizamos comandos customizados do VirtualBox para informar a quantidade de memória RAM e o nome da máquina virtual.  
A quantidade de memória deve ser preenchida em MB.

```rubby
  config.vm.provider "virtualbox" do |virtualbox|
    virtualbox.gui = true
    virtualbox.memory = "3584"
    virtualbox.name = "Docker_#{Time.now.getutc.to_i}"
  end
```

Entre as linhas 23 e 29 definimos os comandos para instalação do curl, docker e docker-compose.

```ruby
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt install -y curl
    curl -sSL "https://get.docker.com" | sh
    curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  SHELL
```

Por fim, para criar a máquina virtual, execute o comando *vagrant up* dentro da pasta em que se encontra o Vagrantfile. O vagrant irá baixar a Box *debian/jessie64* e em seguida continuará a criação e configuração da máquina virtual.

```shell
vagrant up
```

![PowerShell](/img/2017/docker-windows-powershell.png)

Para destruir a máquina virtual, execute o comando *vagrant destroy*.

```shell
vagrant destroy
```

Se tudo der certo, o VirtualBox irá abrir uma tela com um terminal aguardando login.  
O usuário padrão é *“vagrant”* e a senha é *“vagrant“*.

![VM](/img/2017/docker-windows-vm.png)

### Fazendo uma conexão SSH com a máquina virtual

Dentro do diretório do projeto o Vagrant criou uma pasta chamada *“.vagrant“*. Nesta pasta você irá encontrar a chave privada para acessar a máquina virtual.  
Private Key: *.vagrant\machines\default\virtualbox\private_key*

Primeiramente precisaremos converter esta chave para um formato que o PuTTY reconhece.

1. Abra o PuTTYgen;
2. Clique em *“File”* , *“Load private key“*;
3. Acesse a pasta *.vagrant\machines\default\virtualbox\*;
4. Como os arquivos desta pasta não possuem extensão, você terá que selecionar a opção de visualizar todos os arquivos;
5. Selecione o arquivo private_key e importe-o.
6. Clique em *“File“*, *“Save private key”* e salve o arquivo com qualquer nome e com a extensão *.ppk* (PuTTY Private Key).

![VM](/img/2017/docker-windows-tipo-key.png)

Vamos ao PuTTY.

Preencha o campo *Host Name (or IP adress)* com *localhost* e o campo *Port* com *2222*.  
O Vagrant, por padrão, configurou o redirecionamento da porta 2222 do seu computador para a porta 22 da máquina virtual.

![VM](/img/2017/docker-windows-putty.png)

No item *Data*, preencha o campo *Auto-login username* com o nome de usuário *(vagrant)*.

![VM](/img/2017/docker-windows-putty-data.png)

No item *SSH, Auth*, no campo *Private key file for authentication*, selecione a chave privada que importamos anteriormente.

![VM](/img/2017/docker-windows-putty-private-key.png)

Clique em Open para conectar à máquina virtual.

![VM](/img/2017/docker-windows-putty-vagrant-docker.png)

Está pronta a nossa máquina virtual com Docker.

Ficou com alguma dúvida? Entre em contato comigo.



