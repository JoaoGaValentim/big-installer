#!/bin/bash

# Caminho do arquivo de configuração do big
BIG_CONFIG="$HOME/.config/big.conf"
BIG_VERSION="big installer v0.1.0-rio"

# Verifica se yay ou paru estão instalados
check_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        echo -e "\e[31m❌ Nenhum AUR helper encontrado.\e[0m"
        echo -e "\e[33m⚙️ Deseja instalar yay ou paru? (yay/paru)\e[0m"
        read -r CHOICE
        if [[ "$CHOICE" == "yay" ]]; then
            git clone https://aur.archlinux.org/yay.git && cd yay || exit
            makepkg -si 
            AUR_HELPER="yay"
        elif [[ "$CHOICE" == "paru" ]]; then
            git clone https://aur.archlinux.org/paru.git && cd paru || exit
            makepkg -si 
            AUR_HELPER="paru"
        else
            echo -e "\e[31m⚠️ Escolha inválida. Abortando.\e[0m"
            exit 1
        fi
    fi
    echo "AUR_HELPER=$AUR_HELPER" > "$BIG_CONFIG"
}

# Carrega o helper do AUR salvo
load_aur_helper() {
    if [[ -f "$BIG_CONFIG" ]]; then
        source "$BIG_CONFIG"
    else
        check_aur_helper
    fi
}

# Mostra o menu de ajuda
show_help() {
    echo -e "\e[32m📖 big --help\e[0m - \e[33mMostra este menu\e[0m"
    echo -e "\e[32m🛠️ big --version\e[0m - \e[33mMostra a versão do big installer\e[0m"
    echo -e "\e[32m📦 big install [pkg1, pkg2]\e[0m - \e[33mInstala pacotes usando o AUR helper selecionado\e[0m"
    echo -e "\e[32m🧹 big clean\e[0m - \e[33mLimpa o cache do Pacman, yay e paru\e[0m"
    echo -e "\e[32m⚡ big parallels [number]\e[0m - \e[33mAltera a quantidade de downloads paralelos no Pacman\e[0m"
    echo -e "\e[32m🔧 big build-core [num_cores]\e[0m - \e[33mConfigura a quantidade de núcleos para compilação\e[0m"
    echo -e "\e[32m🔄 big update\e[0m - \e[33mAtualiza todos os pacotes do sistema\e[0m"
    echo -e "\e[32m🔍 big search [termo]\e[0m - \e[33mBusca por um pacote no Pacman, yay e paru\e[0m"
    echo -e "\e[32m🖥️ big desktop [kde, gnome, xfce, mate, cinnamon]\e[0m - \e[33mInstala um ambiente desktop completo\e[0m"
}

# Instala ambiente desktop completo
install_desktop() {
    case "$1" in
        kde)
            echo -e "\e[34m🖥️ Instalando KDE Plasma completo...\e[0m"
            sudo pacman -S plasma kde-applications kde-office-meta kde-system-meta kde-graphics-meta sddm
            sudo systemctl enable sddm
            ;;
        gnome)
            echo -e "\e[34m🖥️ Instalando GNOME completo...\e[0m"
            sudo pacman -S  gnome gnome-extra gdm
            sudo systemctl enable gdm
            ;;
        xfce)
            echo -e "\e[34m🖥️ Instalando XFCE completo...\e[0m"
            sudo pacman -S  xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        mate)
            echo -e "\e[34m🖥️ Instalando MATE completo...\e[0m"
            sudo pacman -S  mate mate-extra lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        cinnamon)
            echo -e "\e[34m🖥️ Instalando Cinnamon completo...\e[0m"
            sudo pacman -S  cinnamon lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        *)
            echo -e "\e[31m❌ Ambiente não reconhecido. Escolha entre: kde, gnome, xfce, mate, cinnamon.\e[0m"
            exit 0
            ;;
    esac
    echo -e "\e[34m🔤 Instalando fontes e utilitários essenciais...\e[0m"
    sudo pacman -S ttf-dejavu ttf-liberation ttf-font-awesome noto-fonts noto-fonts-cjk noto-fonts-emoji \
        bash-completion git firefox vlc
    echo -e "\e[32m✅ Ambiente desktop $1 instalado com sucesso! Reinicie para aplicar as mudanças.\e[0m"
}

# Instala pacotes
install_packages() {
    load_aur_helper
    echo -e "\e[34m📦 Instalando pacotes: $@...\e[0m"
    $AUR_HELPER -S "$@"
}

# Limpa cache
clean_cache() {
    echo -e "\e[35m🧹 Limpando cache...\e[0m"
    sudo pacman -Scc --noconfirm
    if command -v yay &>/dev/null; then yay -Scc --noconfirm; fi
    if command -v paru &>/dev/null; then paru -Scc --noconfirm; fi
}

# Atualiza pacotes
update_system() {
    load_aur_helper
    echo -e "\e[32m🔄 Atualizando sistema...\e[0m"
    sudo pacman -Syu --noconfirm
    $AUR_HELPER -Syu --noconfirm
}

# Mostra a versão
show_version() {
     echo -e "\e[32m🛠️ $BIG_VERSION\e[0m"
}

# Altera downloads paralelos no Pacman
set_parallel_downloads() {
    echo -e "\e[36m⚡ Ajustando downloads paralelos para $1...\e[0m"
    sudo sed -i "s/^#\\?ParallelDownloads.*/ParallelDownloads = $1/" /etc/pacman.conf
}

# Altera núcleos de compilação
set_build_cores() {
    echo -e "\e[33m🔧 Configurando compilação para $1 núcleos...\e[0m"
    if grep -q "^#\\?MAKEFLAGS=" /etc/makepkg.conf; then
        sudo sed -i "s/^#\\?MAKEFLAGS=.*/MAKEFLAGS=\"-j$1\"/" /etc/makepkg.conf
    else
        echo "MAKEFLAGS=\"-j$1\"" | sudo tee -a /etc/makepkg.conf
    fi
}

# Busca pacotes
search_packages() {
    echo -e "\e[36m🔍 Buscando pacotes para: $1...\e[0m"
    pacman -Ss "$1"
    if command -v yay &>/dev/null; then yay -Ss "$1"; fi
    if command -v paru &>/dev/null; then paru -Ss "$1"; fi
}

# Processa argumentos
case "$1" in
    --help)
        show_help
        ;;
    --version)
        show_version
        ;;
    install)
        shift
        install_packages "$@"
        ;;
    clean)
        clean_cache
        ;;
    parallels)
        set_parallel_downloads "$2"
        ;;
    build-core)
        set_build_cores "$2"
        ;;
    search)
        search_packages "$2"
        ;;
    update)
        update_system
        ;;
    desktop)
        install_desktop "$2"
        ;; 
    *)
        show_help
        ;;
esac
