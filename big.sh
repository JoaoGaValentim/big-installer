#!/bin/bash

# Caminho do arquivo de configuração do big
BIG_CONFIG="$HOME/.config/big.conf"
BIG_VERSION="big installer v0.1.2-sao-paulo"

# Mostra o menu de ajuda
show_help() {
    echo -e "\e[32mComandos do big"
    echo -e "\e[32m\t📖 big --help\e[0m - \e[33mMostra este menu\e[0m"
    echo -e "\e[32m\t🛠️ big --version\e[0m - \e[33mMostra a versão do big installer\e[0m"
    echo -e "\e[32m\t📦 big install [pkg1, pkg2]\e[0m - \e[33mInstala pacotes usando o AUR helper selecionado\e[0m"
    echo -e "\e[32m\t🗑️ big remove [pkg1, pkg2]\e[0m - \e[33mRemove pacotes usando o AUR helper selecionado\e[0m"
    echo -e "\e[32m\t🔧 big enable [chaotic]\e[0m - \e[33mAtiva o chaotic-aur\e[0m"
    echo -e "\e[32m\t🔧 big disable [chaotic]\e[0m - \e[33mDesativa o chaotic-aur\e[0m"
    echo -e "\e[32m\t🧹 big clean\e[0m - \e[33mLimpa o cache do Pacman, yay e paru\e[0m"
    echo -e "\e[32m\t⚡ big parallels [number]\e[0m - \e[33mAltera a quantidade de downloads paralelos no Pacman\e[0m"
    echo -e "\e[32m\t🔧 big build-core [num_cores]\e[0m - \e[33mConfigura a quantidade de núcleos para compilação\e[0m"
    echo -e "\e[32m\t🔄 big update\e[0m - \e[33mAtualiza todos os pacotes do sistema\e[0m"
    echo -e "\e[32m\t🔍 big search [termo]\e[0m - \e[33mBusca por um pacote no Pacman, yay e paru\e[0m"
    echo -e "\e[32m\t🖥️ big desktop [kde, gnome, xfce, mate, cinnamon]\e[0m - \e[33mInstala um ambiente desktop completo\e[0m"
    echo -e "\e[32m\t🌎 big mirrors [restore]\e[0m - \e[33mAtualiza os espelhos ou restaura o backup\e[0m"
}

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

# Habilita o repositório Chaotic-AUR
enable_chaotic_aur() {
    echo -e "\e[36m⚙️ Habilitando Chaotic-AUR...\e[0m"

    # Verifica se já está habilitado
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        echo -e "\e[32m✅ Chaotic-AUR já está habilitado.\e[0m"
        return
    fi

    # Adiciona a chave e o repositório
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

    echo -e "\e[34m🔄 Atualizando banco de dados do Pacman...\e[0m"
    sudo pacman -Sy

    echo -e "\e[32m✅ Chaotic-AUR habilitado com sucesso!\e[0m"
}

# Desabilita o repositório Chaotic-AUR
disable_chaotic_aur() {
    echo -e "\e[31m⚠️ Desabilitando Chaotic-AUR...\e[0m"

    # Verifica se o repositório existe antes de remover
    if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        echo -e "\e[33m❌ Chaotic-AUR já está desabilitado.\e[0m"
        return
    fi

    # Remove o repositório do pacman.conf
    sudo sed -i '/\[chaotic-aur\]/,/Include = \/etc\/pacman.d\/chaotic-mirrorlist/d' /etc/pacman.conf

    echo -e "\e[34m🔄 Atualizando banco de dados do Pacman...\e[0m"
    sudo pacman -Sy

    echo -e "\e[32m✅ Chaotic-AUR desabilitado com sucesso!\e[0m"
}

# Instala ambiente desktop completo
install_desktop() {
    # Pergunta ao usuário qual driver gráfico deseja instalar
    echo -e "\e[34m🔧 Qual driver gráfico você gostaria de instalar?\e[0m"
    echo -e "1) NVIDIA"
    echo -e "2) AMD"
    echo -e "3) Intel"
    echo -e "4) Driver genérico (VESA)"
    echo -e "5) Deixar o sistema detectar automaticamente"
    read -p "Escolha uma opção (1-5): " driver_choice

    case "$driver_choice" in
        1)
            echo -e "\e[32m🎮 Instalando drivers NVIDIA...\e[0m"
            sudo pacman -S nvidia nvidia-utils
            ;;
        2)
            echo -e "\e[32m🎮 Instalando drivers AMD...\e[0m"
            sudo pacman -S xf86-video-amdgpu
            ;;
        3)
            echo -e "\e[32m🎮 Instalando drivers Intel...\e[0m"
            sudo pacman -S xf86-video-intel
            ;;
        4)
            echo -e "\e[32m🎮 Instalando driver genérico VESA...\e[0m"
            sudo pacman -S xf86-video-vesa
            ;;
        5)
            # Detecção automática de placa gráfica
            echo -e "\e[34m🔧 Detectando automaticamente a placa gráfica...\e[0m"
            if lspci | grep -i nvidia; then
                echo -e "\e[32m🎮 Placa gráfica NVIDIA detectada. Instalando drivers NVIDIA...\e[0m"
                sudo pacman -S nvidia nvidia-utils
            elif lspci | grep -i amd; then
                echo -e "\e[32m🎮 Placa gráfica AMD detectada. Instalando drivers AMD...\e[0m"
                sudo pacman -S xf86-video-amdgpu
            elif lspci | grep -i vga | grep -i intel; then
                echo -e "\e[32m🎮 Placa gráfica Intel detectada. Instalando drivers Intel...\e[0m"
                sudo pacman -S xf86-video-intel
            else
                echo -e "\e[31m❌ Placa gráfica não identificada. Instalando drivers genéricos...\e[0m"
                sudo pacman -S xf86-video-vesa
            fi
            ;;
        *)
            echo -e "\e[31m❌ Opção inválida. Instalando driver genérico VESA...\e[0m"
            sudo pacman -S xf86-video-vesa
            ;;
    esac

    # Instalando fontes e utilitários essenciais
    echo -e "\e[34m🔤 Instalando fontes e utilitários essenciais...\e[0m"
    sudo pacman -S ttf-dejavu ttf-liberation ttf-font-awesome noto-fonts noto-fonts-cjk noto-fonts-emoji \
        bash-completion git firefox vlc

    # Verificando se o argumento do desktop foi passado corretamente
    case "$1" in
        kde)
            echo -e "\e[34m🖥️ Instalando KDE Plasma completo...\e[0m"
            sudo pacman -S plasma kde-applications kde-office-meta kde-system-meta kde-graphics-meta sddm
            sudo systemctl enable sddm
            ;;
        gnome)
            echo -e "\e[34m🖥️ Instalando GNOME completo...\e[0m"
            sudo pacman -S gnome gnome-extra gdm
            sudo systemctl enable gdm
            ;;
        xfce)
            echo -e "\e[34m🖥️ Instalando XFCE completo...\e[0m"
            sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        mate)
            echo -e "\e[34m🖥️ Instalando MATE completo...\e[0m"
            sudo pacman -S mate mate-extra lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        cinnamon)
            echo -e "\e[34m🖥️ Instalando Cinnamon completo...\e[0m"
            sudo pacman -S cinnamon lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            ;;
        *)
            echo -e "\e[31m❌ Ambiente não reconhecido. Escolha entre: kde, gnome, xfce, mate, cinnamon.\e[0m"
            exit 1
            ;;
    esac

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

# Configura os espelhos rápidos com backup e restauração
update_mirrors() {
    # Detectar a distribuição com base no conteúdo de /etc/os-release
    DISTRO=$(cat /etc/os-release | grep '^ID=' | cut -d= -f2 | tr -d '"')

    # Para Arch Linux puro, usa o reflector
    if [[ "$DISTRO" == "arch" ]]; then
        echo -e "\e[36m🌎 Atualizando espelhos para Arch Linux...\e[0m"
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
        if ! command -v reflector &>/dev/null; then
            echo -e "\e[33m⚠️ Reflector não encontrado. Instalando...\e[0m"
            sudo pacman -Syu --noconfirm reflector
        fi
        sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    # Para Manjaro, BigLinux e outras distros baseadas no Manjaro
    elif [[ "$DISTRO" == "manjaro" || "$DISTRO" == "biglinux" ]]; then
        echo -e "\e[36m🌎 Atualizando espelhos para Manjaro/BigLinux...\e[0m"
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
        sudo pacman-mirrors --fasttrack 10
        sudo pacman -Syy
    else
        echo -e "\e[31m❌ Sistema não reconhecido como uma distribuição baseada em Arch. Não é possível atualizar espelhos.\e[0m"
        exit 1
    fi
    echo -e "\e[32m✅ Espelhos atualizados com sucesso! Backup salvo em /etc/pacman.d/mirrorlist.bak\e[0m"
}

# Busca pacotes
search_packages() {
    echo -e "\e[36m🔍 Buscando pacotes para: $1...\e[0m"
    pacman -Ss "$1"
    if command -v yay &>/dev/null; then yay -Ss "$1"; fi
    if command -v paru &>/dev/null; then paru -Ss "$1"; fi
}

# Remove pacotes
remove_package() {
    load_aur_helper
    if command -v "$AUR_HELPER" &>/dev/null; then
        echo -e "\e[34m🗑️ Removendo pacote: $1...\e[0m"
        $AUR_HELPER -Rns "$1" --noconfirm
    else
        echo -e "\e[31m❌ AUR helper não encontrado. Tentando com pacman...\e[0m"
        sudo pacman -Rns "$1" --noconfirm
    fi
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
    remove)
        shift
        remove_package "$@"
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
    mirrors)
        update_mirrors "$2"
        ;;
    enable)
        case "$2" in
            chaotic)
                enable_chaotic_aur
                ;;
            *)
                echo -e "\e[31m❌ Opção inválida. Use: big enable chaotic\e[0m"
                ;;
        esac
        ;;
    disable)
        case "$2" in
            chaotic)
                disable_chaotic_aur
                ;;
            *)
                echo -e "\e[31m❌ Opção inválida. Use: big disable chaotic\e[0m"
                ;;
        esac
        ;;
    *)
        show_help
        ;;
esac
