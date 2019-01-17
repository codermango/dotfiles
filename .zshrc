# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/ke.ma/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git, zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH=$ANDROID_HOME/platform-tools:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ke.ma/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/ke.ma/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ke.ma/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/ke.ma/google-cloud-sdk/completion.zsh.inc'; fi


export JAVA_HOME=$(/usr/libexec/java_home)
export MAVEN_OPTS="-Xms512m -Xmx1024m"



gcpenv () { gcloud config set project $1; gcloud container clusters get-credentials leo-frontend --zone europe-west1-c; kubectl config use-context gke_$1_europe-west1-c_leo-frontend  }
#there is also kubectx and kubens that are installable with homebrew: https://github.com/ahmetb/kubectx
gcpproxy () { local a=$1; local b=$2; local c=$3; eval $(kubectl -n $a get pods | grep $b | awk 'NR==1{printf "kubectl -n $a port-forward %s %s\n", $1, "$c:$c" }') }
gcplags () { gcpproxy $1 leo-api-gateway-service- 5011 }
gcpcouch () { gcpproxy $1 couchbase 8091 }
gcplogs () { local a=$1; local b=$2; local c=${3:=200}; eval $(kubectl -n $a get pods | grep $b | awk 'NR==1{printf "kubectl -n $a logs %s -c $b --tail=$c\n", $1 }') }



gcplffs () {
  COUCHBASE=127.0.0.1:8091 \
  LBCS_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-blocked-countries-service/proxy \
  LLCS_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-language-config-service/proxy \
  LSEOS_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-seo-service/proxy \
  LI18NS_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-i18n-service/proxy \
  LPRES_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-payment-result-service/proxy \
  GQL_URL=http://localhost:8001/api/v1/namespaces/$1/services/leo-graphql/proxy \
  LSC_URL=http://portal-frontend-sport.lb.test01.portal.rslon.int.leovegas.net/static/sports-client \
  LAGS_URL=http://localhost:5011 npm run $2
}
 
gcpfbuild () { gcplffs $1 dev-build }
gcpfssr () { gcplffs $1 dev-ssr }
 
gcplagsdev () {
  contains () {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0
    else
        return 1
    fi
  }
 
  # rhinoUrl="https://10.90.4.211/frontend/api"
  rhinoUrl="https://10.90.26.59/frontend/api"
  rabbitUrl="amqp://frontend_service:rabbitFrontendPsw@10.90.4.20:5672/platform"
 
  if contains $1 "payment"
  then
    rhinoUrl="https://10.90.22.11/frontend/api"
    rabbitUrl="amqp://leo-service:eeHo6Tiushohraefeib2@127.0.0.1:5672/platform"
 
  elif contains $1 "mr"
  then
    rhinoUrl="https://10.90.18.9/frontend/api"
    rabbitUrl="amqp://leo-service:6f1eda7d92d5b61b31af5aa20a1088d9@127.0.0.1:5672/platform"
  fi
 
  NODE_TLS_REJECT_UNAUTHORIZED=0 COUCHBASE=127.0.0.1 \
  RABBITMQ_URL=$rabbitUrl \
  RHINO_URL=$rhinoUrl \
  LALS_URL=${LALS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-address-lookup-service/proxy"} \
  LAVS_URL=${LAVS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-account-verification-service/proxy"} \
  LMS_URL=${LMS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-metrics-service/proxy"} \
  LGS_URL=${LGS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-game-service/proxy"} \
  LJS_URL=${LJS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-jackpot-service/proxy"} \
  LLS_URL=${LLS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-livecasino-service/proxy"} \
  LSS_URL=${LSS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-settings-service/proxy"} \
  LCS_URL=${LCS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-content-service/proxy"} \
  LSUS_URL=${LSUS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-signup-service/proxy"} \
  LPMS_URL=${LPMS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-promotions-service/proxy"} \
  LLCS_URL=${LLCS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-language-config-service/proxy"} \
  LI18NS_URL=${LI18NS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-i18n-service/proxy"} \
  LAHS_URL=${LAHS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-account-history-service/proxy"} \
  LGHS_URL=${LGHS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-game-history-service/proxy"} \
  LSDS_URL=${LSDS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-sports-discovery-service/proxy"} \
  LFAQS_URL=${LFAQS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-faq-service/proxy"} \
  LPAS_URL=${LPAS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-payment-applepay-service/proxy"} \
  LPRS_URL=${LPRS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-password-reset-service/proxy"} \
  LTS_URL=${LTS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-tracking-service/proxy"} \
  LUSS_URL=${LUSS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-user-settings-service/proxy"} \
  LSHS_URL=${LSHS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-sports-history-service/proxy"} \
  LPS_URL=${LPS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-payment-service/proxy"} \
  LUMS_URL=${LUMS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-user-metrics-service/proxy"} \
  LASS_URL=${LASS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-aams-settings-service/proxy"} \
  LSOS_URL=${LSOS_URL:="http://localhost:8001/api/v1/namespaces/$1/services/leo-sports-oddsboost-service/proxy"} \
  npm run dev
}
 
gcpproxyall () {
  cleanup () {
    echo "Cleaning up processes"
 
    killall kubectl > /dev/null 2>&1
    killall gcpproxy > /dev/null 2>&1
  }
  close () {
    cleanup
 
    trap '' SIGINT SIGTERM EXIT
    kill -SIGTERM $$
  }
 
  local ARGUMENT_DEV_SERVER=$1
  if [ -z "$ARGUMENT_DEV_SERVER" ]; then
    echo "ERROR: You need to specify dev server as first argument, example: 'gcpproxyall portal-devXX'"
    return 1
  fi
  if [ "$ARGUMENT_DEV_SERVER" = '--help' ]; then
    echo "Proxies everything in a GCP dev env!\n\nUse like:\ngcpproxyall portal-devXX\n\nIf you want to run LAGS or LEPS locally you can do\nLOCAL_LAGS=true LOCAL_LEPS=true gcpproxyall portal-devXX\n"
    return 1
  fi
 
  cleanup
 
  kubectl proxy &
  gcpcouch "${ARGUMENT_DEV_SERVER}" &
 
  if [ "${LOCAL_LAGS}" = 'true' ] || [ "${LOCAL_LAGS}" = '1' ]; then
    gcpproxy "${ARGUMENT_DEV_SERVER}" couchbase 11210 &
    gcpproxy "${ARGUMENT_DEV_SERVER}" rabbitmq 5672 &
  else
    gcplags "${ARGUMENT_DEV_SERVER}" &
  fi
 
  if [ "${LOCAL_LEPS}" = 'true' ] || [ "${LOCAL_LEPS}" = '1' ]; then
    gcpproxy "${ARGUMENT_DEV_SERVER}" couchbase 8092 &
  fi
 
  trap 'close' SIGINT SIGTERM EXIT
  wait
}




