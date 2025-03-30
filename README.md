# Big Installer

O **Big Installer** (ou apenas `big`) é um gerenciador de pacotes simples e eficiente para o **Big Linux**, inspirado no `yay`. Ele oferece uma maneira fácil de instalar pacotes do **AUR** e gerenciar o sistema.

## Características

- Instala pacotes do **AUR** usando `yay` ou `paru`.
- Instala ambientes de desktop completos (KDE, GNOME, XFCE, MATE, Cinnamon).
- Permite a configuração de downloads paralelos no **Pacman**.
- Possui funcionalidades para atualizar o sistema e limpar o cache.
- Oferece um menu de ajuda fácil de usar.

## Instalação

Para usar o **Big Installer**, siga os passos abaixo:

### 1. Clone o repositório

```bash
git clone https://github.com/JoaoGaValentim/big-installer.git
cd big-installer
```

### 2. Dê permissão de execução para o script

```bash
chmod +x big
```

Agora vamos gerar seu alias

```bash
chmod +x big && cd ~ && echo "alias big=$HOME/big-installer/big.sh" >> .bashrc # ou .zshrc
```


### 3. (Opcional) Instalar dependências adicionais

Se você ainda não possui um **AUR Helper** como `yay` ou `paru`, o **Big Installer** irá perguntar se deseja instalá-los automaticamente. Caso deseje instalar manualmente, execute:

```bash
sudo pacman -S yay  # ou paru
```

## Uso

Aqui estão os principais comandos do **Big Installer**:

### `big --help`

Mostra o menu de ajuda com todas as opções disponíveis.

### `big --version`

Mostra a versão do **Big Installer**.

### `big install [pkg1, pkg2, ...]`

Instala pacotes usando o AUR helper selecionado (`yay` ou `paru`).

Exemplo:
```bash
big install firefox vlc
```

### `big clean`

Limpa o cache do Pacman, yay e paru.

### `big parallels [number]`

Altera a quantidade de downloads paralelos no **Pacman**. Substitua `[number]` pelo número de downloads paralelos desejado.

Exemplo:
```bash
big parallels 10
```

### `big build-core [num_cores]`

Configura a quantidade de núcleos para a compilação no **makepkg**.

Exemplo:
```bash
big build-core 4
```

### `big update`

Atualiza todos os pacotes do sistema.

### `big search [termo]`

Busca pacotes no Pacman, yay e paru.

Exemplo:
```bash
big search firefox
```

### `big desktop [kde|gnome|xfce|mate|cinnamon]`

Instala um ambiente desktop completo.

Exemplo:
```bash
big desktop kde
```

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Big Installer v0.1.0-rio** - Desenvolvido para facilitar a instalação e manutenção do seu sistema Linux.
