FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# ---- LaTeX (toolchain d'origine du CV) + Python (scripts des skills) ----
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		latexmk \
		texlive-latex-base \
		texlive-latex-recommended \
		texlive-latex-extra \
		texlive-fonts-recommended \
		texlive-fonts-extra \
		texlive-lang-english \
		python3 \
		python3-pip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /usr/share/locale/*

# ---- Node.js LTS 22 (build du site, Phase 1) ----
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
	&& apt-get install -y --no-install-recommends nodejs jq \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# ---- Playwright (audits web, skill webapp-testing / Phase 5) ----
# Browsers partagés dans /opt (généré au build, utilisable par vscode)
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright
RUN python3 -m pip install --no-cache-dir --break-system-packages playwright \
	&& playwright install --with-deps chromium

# ---- Neovim (dernière release stable, binaire natif selon l'arche cible) ----
ARG TARGETARCH   # amd64 | arm64 — fourni automatiquement par BuildKit
RUN case "$TARGETARCH" in \
		arm64) NV=linux-arm64 ;; \
		*)     NV=linux-x86_64 ;; \
	esac \
	&& curl -fsSL -o /tmp/nvim.tar.gz \
		"https://github.com/neovim/neovim/releases/download/stable/nvim-${NV}.tar.gz" \
	&& mkdir -p /opt \
	&& tar -C /opt -xzf /tmp/nvim.tar.gz \
	&& ln -s "/opt/nvim-${NV}/bin/nvim" /usr/local/bin/nvim \
	&& rm /tmp/nvim.tar.gz

# ---- lazygit (latest au build, binaire natif selon l'arche cible) ----
RUN TAG=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
		| grep -m1 '"tag_name"' | sed -E 's/.*"v([^"]*)".*/\1/') \
	&& case "$TARGETARCH" in \
		arm64) LGARCH=arm64 ;; \
		*)     LGARCH=x86_64 ;; \
	esac \
	&& curl -fsSL -o /tmp/lazygit.tgz \
		"https://github.com/jesseduffield/lazygit/releases/download/v${TAG}/lazygit_${TAG}_Linux_${LGARCH}.tar.gz" \
	&& tar -C /usr/local/bin -xzf /tmp/lazygit.tgz lazygit \
	&& rm /tmp/lazygit.tgz

# ---- gh (GitHub CLI) + client Docker — via dépôts apt officiels ----
RUN install -d -m 0755 /etc/apt/keyrings \
	&& curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
		-o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
		> /etc/apt/sources.list.d/github-cli.list \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" \
		> /etc/apt/sources.list.d/docker.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends gh docker-ce-cli \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# ---- Répertoires HOME pré-créés et possédés par vscode ----
# (sinon les mounts compose/devcontainer créent leurs ancêtres en root
#  et des outils comme opencode échouent avec EACCES en mkdir ~/.local/state)
RUN mkdir -p /home/vscode/.config /home/vscode/.local/share /home/vscode/.local/state /home/vscode/.cache \
	&& chown -R vscode:vscode /home/vscode \
	&& usermod -aG 0 vscode

# ---- OpenCode (via npm officielle, même canal que l'hôte) ----
RUN npm install -g opencode-ai@latest

WORKDIR /work
